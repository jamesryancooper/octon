#!/usr/bin/env bash
# capability-bind.sh - Deterministic capability capability binding for planning.

set -euo pipefail

emit_output() {
  local status="$1"
  local command="$2"
  local result_json="$3"
  local artifacts_json="${4:-[]}"
  local warnings_json="${5:-[]}"

  jq -n \
    --arg status "$status" \
    --arg command "$command" \
    --argjson result "$result_json" \
    --argjson artifacts "$artifacts_json" \
    --argjson warnings "$warnings_json" \
    '{status:$status,command:$command,result:$result,artifacts:$artifacts,warnings:$warnings}'
}

fail_input() {
  local command="$1"
  local message="$2"
  emit_output "error" "$command" '{}' '[]' "$(jq -cn --arg m "$message" '[ $m ]')"
  exit 5
}

fail_runtime() {
  local command="$1"
  local message="$2"
  local result_json="$3"
  emit_output "error" "$command" "$result_json" '[]' "$(jq -cn --arg m "$message" '[ $m ]')"
  exit 4
}

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' '{"status":"error","command":"unknown","result":{},"artifacts":[],"warnings":["jq is required"]}'
  exit 6
fi

payload="$(cat)"
if [[ -z "$(printf '%s' "$payload" | tr -d '[:space:]')" ]]; then
  fail_input "unknown" "Expected JSON payload"
fi

if ! printf '%s' "$payload" | jq -e . >/dev/null 2>&1; then
  fail_input "unknown" "Payload is not valid JSON"
fi

command="$(printf '%s' "$payload" | jq -r '.command // empty')"
if [[ "$command" != "bind" && "$command" != "validate" ]]; then
  fail_input "${command:-unknown}" "Unsupported command: ${command:-unknown}"
fi

plan_path="$(printf '%s' "$payload" | jq -r '.planPath // empty')"
plan_payload="$(printf '%s' "$payload" | jq -c '.plan // empty')"
required_capabilities_json="$(printf '%s' "$payload" | jq -c '.requiredCapabilities // []')"
available_capabilities_json="$(printf '%s' "$payload" | jq -c '.availableCapabilities // {}')"
strategy="$(printf '%s' "$payload" | jq -r '.strategy // "prefer-native"')"
strict_input="$(printf '%s' "$payload" | jq -r '.strict // false')"

if ! jq -e 'type == "array"' <<<"$required_capabilities_json" >/dev/null 2>&1; then
  fail_input "$command" "requiredCapabilities must be an array"
fi
if ! jq -e 'type == "object"' <<<"$available_capabilities_json" >/dev/null 2>&1; then
  fail_input "$command" "availableCapabilities must be an object"
fi
if [[ "$strategy" != "prefer-native" && "$strategy" != "prefer-adapter" && "$strategy" != "prefer-available" ]]; then
  fail_input "$command" "strategy must be prefer-native, prefer-adapter, or prefer-available"
fi

strict=false
if [[ "$command" == "validate" ]]; then
  strict=true
fi
if [[ "$strict_input" == "true" ]]; then
  strict=true
fi

load_plan() {
  if [[ "$plan_payload" != "{}" && "$plan_payload" != "null" && -n "$plan_payload" ]]; then
    if ! jq -e 'type == "object"' <<<"$plan_payload" >/dev/null 2>&1; then
      fail_input "$command" "plan must be an object"
    fi
    printf '%s' "$plan_payload"
    return
  fi

  if [[ -z "$plan_path" ]]; then
    fail_input "$command" "Missing plan source; provide planPath or inline plan"
  fi
  if [[ ! -f "$plan_path" ]]; then
    fail_input "$command" "Plan file does not exist: $plan_path"
  fi
  if ! jq -e . "$plan_path" >/dev/null 2>&1; then
    fail_input "$command" "Plan file is not valid JSON: $plan_path"
  fi
  cat "$plan_path"
}

plan_json="$(load_plan)"
if ! jq -e '.steps | type == "array"' <<<"$plan_json" >/dev/null 2>&1; then
  fail_input "$command" "Plan must contain a steps array"
fi

plan_source="inline"
if [[ "$plan_payload" == "{}" || "$plan_payload" == "null" || -z "$plan_payload" ]]; then
  plan_source="$plan_path"
fi

goal="$(jq -r '.goal // "unnamed-plan"' <<<"$plan_json")"
steps_json="$(jq -c '.steps' <<<"$plan_json")"

requested_caps='[]'
if [[ "$(jq -c 'length' <<<"$required_capabilities_json")" -gt 0 ]]; then
  requested_caps="$required_capabilities_json"
else
  while IFS= read -r step; do
    step_reqs="$(jq -c '(.requires // .requiredCapabilities // .requires_capabilities // []) | map(select(type=="string" and length>0)) | unique' <<<"$step")"
    requested_caps="$(jq -cn --argjson list "$requested_caps" --argjson add "$step_reqs" '$list + $add | unique')"
  done < <(jq -c '.[]' <<<"$steps_json")
fi

if ! jq -e 'type == "array"' <<<"$requested_caps" >/dev/null 2>&1; then
  fail_input "$command" "required capabilities list invalid"
fi

resolve_capability_state() {
  local capability="$1"
  local raw
  raw="$(jq -r --arg cap "$capability" 'if has($cap) then .[$cap] else "unsupported" end' <<<"$available_capabilities_json")"
  case "$raw" in
    true)
      echo "supported|native|false|native capability available"
      ;;
    false)
      echo "unsupported|manual|true|capability explicitly unavailable"
      ;;
    "native")
      echo "supported|native|false|native capability available"
      ;;
    "adapter")
      echo "degraded|adapter|true|adapter capability available"
      ;;
    "supported")
      echo "supported|native|false|capability supported"
      ;;
    "degraded")
      echo "degraded|adapter|true|capability degraded"
      ;;
    "unsupported"|"")
      echo "unsupported|manual|true|capability unavailable"
      ;;
    *)
      if [[ "$raw" == "null" ]]; then
        echo "unsupported|manual|true|capability unavailable"
      else
        echo "unsupported|manual|true|unknown capability state"
      fi
      ;;
  esac
}

mapfile -t required_capability_ids < <(jq -r '.[]' <<<"$requested_caps" | sort -u)

capability_catalog='[]'
supported_cap_count=0
degraded_cap_count=0
unsupported_cap_count=0
unsupported_caps='[]'
for capability in "${required_capability_ids[@]}"; do
  [[ -z "$capability" ]] && continue
  read -r state via evidence notes <<<"$(resolve_capability_state "$capability" | tr '|' ' ')"
  capabilities_with_state="$(jq -cn --arg capability "$capability" --arg state "$state" --arg via "$via" --argjson evidence "$evidence" --arg notes "$notes" '{capability:$capability,state:$state,via:$via,evidence_required:$evidence,notes:$notes}')"
  capability_catalog="$(jq -cn --argjson list "$capability_catalog" --argjson item "$capabilities_with_state" '$list + [$item]')"

  case "$state" in
    supported) supported_cap_count=$((supported_cap_count + 1)) ;;
    degraded) degraded_cap_count=$((degraded_cap_count + 1)) ;;
    unsupported) unsupported_cap_count=$((unsupported_cap_count + 1)); unsupported_caps="$(jq -cn --argjson list "$unsupported_caps" --arg c "$capability" '$list + [$c]')";;
  esac
done

step_bindings='[]'
unsupported_step_ids='[]'
step_count=0
supported_mode=0
degraded_mode=0
unsupported_mode=0

while IFS= read -r step; do
  step_id="$(jq -r '.id // empty' <<<"$step")"
  if [[ -z "$step_id" ]]; then
    fail_input "$command" "Every step must have a non-empty id"
  fi
  step_count=$((step_count + 1))

  step_required="$(jq -c '(.requires // .requiredCapabilities // .requires_capabilities // []) | map(select(type=="string" and length>0))' <<<"$step")"
  if [[ "$step_required" == "null" || -z "$step_required" ]]; then
    step_required='[]'
  fi

  step_missing='[]'
  missing_mode="bound"
  step_mode="native"
  for cap in $(jq -r '.[]' <<<"$step_required"); do
    [[ -z "$cap" ]] && continue
    read -r cap_state cap_via _ <<<"$(resolve_capability_state "$cap" | tr '|' ' ')"
    if [[ "$cap_state" == "unsupported" ]]; then
      missing_mode="unsupported"
      step_mode="manual"
      step_missing="$(jq -cn --argjson list "$step_missing" --arg c "$cap" '$list + [$c]')"
      unsupported_step_ids="$(jq -cn --argjson list "$unsupported_step_ids" --arg s "$step_id" '$list + [$s]')"
    elif [[ "$cap_state" == "degraded" && "$missing_mode" != "unsupported" ]]; then
      missing_mode="degraded"
      step_mode="adapter"
    fi
  done

  case "$missing_mode" in
    bound) supported_mode=$((supported_mode + 1)) ;;
    degraded) degraded_mode=$((degraded_mode + 1)) ;;
    unsupported) unsupported_mode=$((unsupported_mode + 1)) ;;
  esac

  binding_entry="$(jq -cn \
    --arg stepId "$step_id" \
    --argjson required "$step_required" \
    --argjson missing "$step_missing" \
    --arg status "$missing_mode" \
    --arg mode "$step_mode" \
    '{stepId:$stepId,requiredCapabilities:$required,missingCapabilities:$missing,status:$status,mode:$mode}')"
  step_bindings="$(jq -cn --argjson list "$step_bindings" --argjson item "$binding_entry" '$list + [$item]')"
done < <(jq -c '.[]' <<<"$steps_json")

binding_summary="$(jq -cn \
  --argjson totalSteps "$step_count" \
  --argjson requestedCount "$(jq 'length' <<<"$requested_caps")" \
  --argjson supportedCount "$supported_cap_count" \
  --argjson degradedCount "$degraded_cap_count" \
  --argjson unsupportedCount "$unsupported_cap_count" \
  --argjson unsupportedCapabilities "$unsupported_caps" \
  '{
    totalSteps:$totalSteps,
    requestedCapabilitiesCount:$requestedCount,
    supportedCapabilitiesCount:$supportedCount,
    degradedCapabilitiesCount:$degradedCount,
    unsupportedCapabilitiesCount:$unsupportedCount,
    unsupportedCapabilities:$unsupportedCapabilities
  }')"

result_json="$(jq -cn \
  --arg command "$command" \
  --arg source "$plan_source" \
  --arg strategy "$strategy" \
  --arg goal "$goal" \
  --argjson totalSteps "$step_count" \
  --argjson bindings "$step_bindings" \
  --argjson catalog "$capability_catalog" \
  --argjson summary "$binding_summary" \
  '{command:$command,source:$source,strategy:$strategy,planSummary:{goal:$goal,stepCount:$totalSteps},bindingSummary:$summary,capabilityCatalog:$catalog,stepBindings:$bindings}')"

if (( unsupported_cap_count > 0 )); then
  if [[ "$strict" == true || "$unsupported_cap_count" -gt 0 && "$command" == "validate" ]]; then
    fail_runtime "$command" "Unsupported required capabilities detected" "$result_json"
  fi
  emit_output "partial" "$command" "$result_json" '[]' "$(jq -cn '[ "One or more required capabilities are unsupported in this plan context" ]')"
  exit 0
fi

if (( degraded_cap_count > 0 )); then
  emit_output "partial" "$command" "$result_json" '[]' "$(jq -cn '[ "One or more required capabilities are degraded and will execute via fallback mode" ]')"
  exit 0
fi

emit_output "success" "$command" "$result_json"
