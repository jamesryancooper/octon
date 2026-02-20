#!/usr/bin/env bash
# replan.sh - Deterministic plan pruning and resequencing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Enforce deny-by-default policy at runtime for this shell service.
source "$SCRIPT_DIR/../../../_ops/scripts/enforce-deny-by-default.sh"
harmony_enforce_service_policy "replan" "$0" "$@"


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
if [[ "$command" != "replan" ]]; then
  fail_input "${command:-unknown}" "Unsupported command: ${command:-unknown}"
fi

plan_path="$(printf '%s' "$payload" | jq -r '.planPath // empty')"
plan_payload="$(printf '%s' "$payload" | jq -c '.plan // empty')"
blocked_steps="$(printf '%s' "$payload" | jq -c '.blockedSteps // []')"
allow_missing="$(printf '%s' "$payload" | jq -r '.allowMissingDependencies // false')"

if ! jq -e 'type == "array"' <<<"$blocked_steps" >/dev/null 2>&1; then
  fail_input "$command" "blockedSteps must be an array"
fi
if [[ "$allow_missing" != "true" && "$allow_missing" != "false" ]]; then
  fail_input "$command" "allowMissingDependencies must be boolean"
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

goal="$(jq -r '.goal // ""' <<<"$plan_json")"
steps_json="$(jq -c '.steps' <<<"$plan_json")"

step_ids=()
declare -A seen
declare -A step_by_id
declare -A deps_by_id

while IFS= read -r step; do
  id="$(jq -r '.id // empty' <<<"$step")"
  if [[ -z "$id" ]]; then
    fail_input "$command" "Every step requires a non-empty id"
  fi
  if [[ -n "${seen[$id]+x}" ]]; then
    fail_input "$command" "Duplicate step id: $id"
  fi

  seen["$id"]=1
  step_ids+=("$id")

  deps="$(jq -c '(.depends_on // []) | map(select(type=="string" and length > 0)) | unique' <<<"$step")"
  if ! jq -e 'type == "array"' <<<"$deps" >/dev/null 2>&1; then
    fail_input "$command" "Step '$id' has invalid depends_on"
  fi

  step_by_id["$id"]="$step"
  deps_by_id["$id"]="$deps"
done < <(jq -c '.[]' <<<"$steps_json")

for id in "${step_ids[@]}"; do
  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    if [[ -z "${seen[$dep]+x}" ]]; then
      if [[ "$allow_missing" == "true" ]]; then
        continue
      fi
      fail_runtime "$command" "Step '$id' depends on missing dependency '$dep'" '{"issues":[{"code":"MISSING_DEPENDENCY","severity":"critical","message":"Missing dependency in replanning input"}]}'
    fi
  done < <(jq -r '.[]' <<<"${deps_by_id[$id]}")
done

declare -A blocked_lookup
for id in $(jq -r '.[]' <<<"$blocked_steps"); do
  [[ -z "$id" ]] && continue
  if [[ -n "${seen[$id]+x}" ]]; then
    blocked_lookup["$id"]=1
  fi
done

# Start with all non-blocked steps and remove transitive dependents.
declare -A kept_lookup
for id in "${step_ids[@]}"; do
  if [[ -z "${blocked_lookup[$id]+x}" ]]; then
    kept_lookup["$id"]=1
  fi
done

changed=true
while [[ "$changed" == true ]]; do
  changed=false
  for id in "${step_ids[@]}"; do
    if [[ -z "${kept_lookup[$id]+x}" ]]; then
      continue
    fi

    while IFS= read -r dep; do
      [[ -z "$dep" ]] && continue
      if [[ -z "${kept_lookup[$dep]+x}" ]]; then
        unset "kept_lookup[$id]"
        changed=true
        break
      fi
    done < <(jq -r '.[]' <<<"${deps_by_id[$id]}")
  done
done

kept_steps='[]'
removed_steps=()
for id in "${step_ids[@]}"; do
  if [[ -z "${kept_lookup[$id]+x}" ]]; then
    removed_steps+=("$id")
    continue
  fi

  retained_deps='[]'
  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    if [[ -n "${kept_lookup[$dep]+x}" ]]; then
      retained_deps="$(jq -cn --argjson list "$retained_deps" --arg value "$dep" '$list + [$value]')"
      continue
    fi

    if [[ "$allow_missing" != "true" ]]; then
      fail_runtime "$command" "Kept step '$id' depends on removed dependency '$dep'" '{"issues":[{"code":"MISSING_DEPENDENCY","severity":"critical","message":"Removed dependency in replan"}]}'
    fi
  done < <(jq -r '.[]' <<<"${deps_by_id[$id]}")

  step_with_deps="$(jq -cn --argjson step "${step_by_id[$id]}" --argjson deps "$retained_deps" '$step | .depends_on = $deps')"
  kept_steps="$(jq -cn --argjson list "$kept_steps" --argjson step "$step_with_deps" '$list + [$step]')"
done

kept_count="${#kept_lookup[@]}"

declare -A indegree
for id in "${step_ids[@]}"; do
  if [[ -z "${kept_lookup[$id]+x}" ]]; then
    continue
  fi

  indegree["$id"]=0
  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    if [[ -n "${kept_lookup[$dep]+x}" ]]; then
      indegree["$id"]=$((indegree["$id"] + 1))
    fi
  done < <(jq -r '.[]' <<<"${deps_by_id[$id]}")
done

ready_ids=()
for id in "${step_ids[@]}"; do
  if [[ -z "${kept_lookup[$id]+x}" ]]; then
    continue
  fi
  if [[ "${indegree[$id]}" == "0" ]]; then
    ready_ids+=("$id")
  fi
done

ordered='[]'
declare -A ordered_lookup
visited_count=0

while (( ${#ready_ids[@]} > 0 )); do
  mapfile -t ready_ids < <(printf '%s\n' "${ready_ids[@]}" | sort)

  node="${ready_ids[0]}"
  ready_ids=("${ready_ids[@]:1}")

  if [[ -n "${ordered_lookup[$node]+x}" ]]; then
    continue
  fi

  ordered_lookup["$node"]=1
  ordered="$(jq -cn --argjson list "$ordered" --arg value "$node" '$list + [$value]')"
  visited_count=$((visited_count + 1))

  for candidate in "${step_ids[@]}"; do
    if [[ -z "${kept_lookup[$candidate]+x}" ]]; then
      continue
    fi
    if [[ -n "${ordered_lookup[$candidate]+x}" ]]; then
      continue
    fi

    while IFS= read -r dep; do
      [[ -z "$dep" ]] && continue
      if [[ "$dep" == "$node" ]]; then
        indegree["$candidate"]=$((indegree["$candidate"] - 1))
        break
      fi
    done < <(jq -r '.[]' <<<"${deps_by_id[$candidate]}")

    if (( indegree["$candidate"] == 0 )); then
      ready_ids+=("$candidate")
    fi
  done

done

if [[ "$visited_count" -ne "$kept_count" ]]; then
  fail_runtime "$command" "Dependency cycle prevents replan ordering" '{"issues":[{"code":"CYCLE_DETECTED","severity":"critical","message":"Cycle detected while replanning"}]}'
fi

removed_steps_json='[]'
for id in "${removed_steps[@]}"; do
  removed_steps_json="$(jq -cn --argjson list "$removed_steps_json" --arg value "$id" '$list + [$value]')"
done

removed_count="${#removed_steps[@]}"
result_json="$(jq -cn \
  --arg command "$command" \
  --arg source "$plan_source" \
  --arg goal "$goal" \
  --argjson replannedSteps "$kept_steps" \
  --argjson replannedOrder "$ordered" \
  --argjson removedSteps "$removed_steps_json" \
  --argjson removedCount "$removed_count" \
  '{
    command:$command,
    source:$source,
    goal:($goal | tostring),
    replannedPlan:{goal:($goal | tostring),steps:$replannedSteps,order:$replannedOrder},
    delta:{removedCount:$removedCount,removedSteps:$removedSteps},
    blockedCount:($removedCount)
  }')"

if (( removed_count > 0 )); then
  if (( removed_count == kept_count + removed_count )); then
    emit_output "partial" "$command" "$result_json" '[]' '["all steps were removed"]'
  else
    emit_output "partial" "$command" "$result_json" '[]' '["replan removed one or more steps"]'
  fi
  exit 0
fi

emit_output "success" "$command" "$result_json"
