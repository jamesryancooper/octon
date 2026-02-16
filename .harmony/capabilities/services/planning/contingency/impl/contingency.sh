#!/usr/bin/env bash
# contingency.sh - Deterministic alternative-plan generation for failed or degraded steps.

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

id_array_to_json() {
  local -n ids_ref="$1"
  local out='[]'

  if [[ ${#ids_ref[@]} -eq 0 ]]; then
    printf '%s' "$out"
    return
  fi

  local -a unique_ids
  mapfile -t unique_ids < <(printf '%s\n' "${ids_ref[@]}" | sort -u)

  for value in "${unique_ids[@]}"; do
    [[ -z "$value" ]] && continue
    out="$(jq -cn --argjson list "$out" --arg value "$value" '$list + [$value]')"
  done

  printf '%s' "$out"
}

collect_descendants() {
  local -n seeds_ref="$1"

  local -A closed=()
  local -a queue=()
  local -a out_ids=()

  for seed in "${seeds_ref[@]}"; do
    [[ -z "$seed" ]] && continue
    if [[ -n "${seen[$seed]+x}" && -z "${closed[$seed]+x}" ]]; then
      queue+=("$seed")
      closed["$seed"]=1
    fi
  done

  while (( ${#queue[@]} > 0 )); do
    seed="${queue[0]}"
    queue=("${queue[@]:1}")
    out_ids+=("$seed")

    for child in ${dependents_by_id[$seed]:-}; do
      [[ -z "$child" ]] && continue
      if [[ -z "${closed[$child]+x}" ]]; then
        closed["$child"]=1
        queue+=("$child")
      fi
    done
  done

  id_array_to_json out_ids
}

load_plan() {
  if [[ "$plan_payload" != "{}" && "$plan_payload" != "null" && -n "$plan_payload" ]]; then
    if ! jq -e 'type == "object"' <<<"$plan_payload" >/dev/null 2>&1; then
      fail_input "$command" "plan must be an object"
    fi
    printf '%s' "$plan_payload"
    return
  fi

  if [[ -z "$plan_path" || "$plan_path" == "null" ]]; then
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

run_toposort() {
  local -n ids_ref="$1"
  local -n deps_ref="$2"
  local -n kept_set_ref="$3"
  local -n order_ref="$4"

  local -A indegree=()
  local -a queue=()
  local -a sorted_order=()
  local -A queued=()
  local -A visited_map=()
  local visited_count=0
  local node dep candidate

  for node in "${ids_ref[@]}"; do
    indegree["$node"]=0
    while IFS= read -r dep; do
      [[ -z "$dep" ]] && continue
      if [[ -n "${kept_set_ref[$dep]+x}" ]]; then
        indegree["$node"]=$((indegree["$node"] + 1))
      fi
    done < <(jq -r '.[]' <<<"${deps_ref[$node]}")
  done

  for node in "${ids_ref[@]}"; do
    if [[ "${indegree[$node]}" == "0" ]]; then
      queue+=("$node")
      queued["$node"]=1
    fi
  done

  while (( ${#queue[@]} > 0 )); do
    mapfile -t queue < <(printf '%s\n' "${queue[@]}" | sort)
    node="${queue[0]}"
    queue=("${queue[@]:1}")
    if [[ -n "${visited_map[$node]+x}" ]]; then
      unset "queued[$node]"
      continue
    fi

    sorted_order+=("$node")
    visited_count=$((visited_count + 1))
    visited_map["$node"]=1
    unset "queued[$node]"

    for candidate in "${ids_ref[@]}"; do
      [[ -z "${kept_set_ref[$candidate]+x}" ]] && continue
      if [[ -n "${visited_map[$candidate]+x}" ]]; then
        continue
      fi
      for dep in $(jq -r '.[]' <<<"${deps_ref[$candidate]}"); do
        [[ -z "$dep" ]] && continue
        if [[ "$dep" == "$node" ]]; then
          indegree[$candidate]=$((indegree[$candidate] - 1))
          break
        fi
      done
      if [[ "${indegree[$candidate]}" == "0" ]]; then
        if [[ -z "${queued[$candidate]+x}" ]]; then
          queue+=("$candidate")
          queued["$candidate"]=1
        fi
      fi
    done
  done

  order_ref="$(jq -R . <<<"${sorted_order[@]}" | jq -s '.')"
  printf '%d' "$visited_count"
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
if [[ "$command" != "generate" && "$command" != "validate" ]]; then
  fail_input "${command:-unknown}" "Unsupported command: ${command:-unknown}"
fi

plan_path="$(printf '%s' "$payload" | jq -r '.planPath // empty')"
plan_payload="$(printf '%s' "$payload" | jq -c '.plan // empty')"
failed_steps_json="$(printf '%s' "$payload" | jq -c '.failedSteps // []')"
allow_descendants="$(printf '%s' "$payload" | jq -r '.allowDescendants // true')"
max_alternatives="$(printf '%s' "$payload" | jq -r '.maxAlternatives // 3')"
strict_input="$(printf '%s' "$payload" | jq -r '.strict // empty')"

if ! jq -e 'type == "array"' <<<"$failed_steps_json" >/dev/null 2>&1; then
  fail_input "$command" "failedSteps must be an array"
fi

if [[ "$allow_descendants" != "true" && "$allow_descendants" != "false" ]]; then
  fail_input "$command" "allowDescendants must be boolean"
fi

if ! [[ "$max_alternatives" =~ ^[0-9]+$ ]] || [[ "$max_alternatives" -lt 1 ]]; then
  fail_input "$command" "maxAlternatives must be an integer >= 1"
fi
if (( max_alternatives > 9999 )); then
  max_alternatives=9999
fi

strict=false
if [[ "$command" == "validate" || "$strict_input" == "true" ]]; then
  strict=true
fi

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
declare -A seen=()
declare -A step_by_id=()
declare -A deps_by_id=()
declare -A dependents_by_id=()

while IFS= read -r step; do
  step_id="$(jq -r '.id // empty' <<<"$step")"
  if [[ -z "$step_id" ]]; then
    fail_input "$command" "Every step requires a non-empty id"
  fi
  if [[ -n "${seen[$step_id]+x}" ]]; then
    fail_input "$command" "Duplicate step id: $step_id"
  fi

  seen["$step_id"]=1
  step_ids+=("$step_id")
  step_by_id["$step_id"]="$step"

  deps="$(jq -c '(.depends_on // []) | map(select(type=="string" and length > 0)) | unique' <<<"$step")"
  if ! jq -e 'type == "array"' <<<"$deps" >/dev/null 2>&1; then
    fail_input "$command" "Step '$step_id' has invalid depends_on"
  fi
  deps_by_id["$step_id"]="$deps"

  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    if [[ -n "${dependents_by_id[$dep]+x}" ]]; then
      dependents_by_id["$dep"]+=" $step_id"
    else
      dependents_by_id["$dep"]="$step_id"
    fi
  done < <(jq -r '.[]' <<<"$deps")
done < <(jq -c '.[]' <<<"$steps_json")

for step_id in "${step_ids[@]}"; do
  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    if [[ -z "${seen[$dep]+x}" ]]; then
      fail_runtime "$command" "Step '$step_id' depends on missing step '$dep'" '{"issues":[{"code":"MISSING_DEPENDENCY","severity":"critical","message":"Contingency requires complete dependency graph"}]}'
    fi
  done < <(jq -r '.[]' <<<"${deps_by_id[$step_id]}")
done

base_failed=()
while IFS= read -r failed; do
  [[ -z "$failed" ]] && continue
  if [[ -n "${seen[$failed]+x}" ]]; then
    base_failed+=("$failed")
  fi
done < <(jq -r '.[]' <<<"$failed_steps_json")

if (( ${#base_failed[@]} > 0 )); then
  mapfile -t base_failed < <(printf '%s\n' "${base_failed[@]}" | sort -u)
fi
requested_failed_count="${#base_failed[@]}"

base_removed='[]'
if (( requested_failed_count > 0 )); then
  if [[ "$allow_descendants" == "true" ]]; then
    base_removed="$(collect_descendants base_failed)"
  else
    base_removed="$(id_array_to_json base_failed)"
  fi
fi

candidate_payloads=()
append_candidate() {
  local payload="$1"
  if [[ "$payload" == "[]" ]]; then
    return
  fi
  for existing in "${candidate_payloads[@]}"; do
    if [[ "$existing" == "$payload" ]]; then
      return
    fi
  done
  candidate_payloads+=("$payload")
}

if (( requested_failed_count == 0 )); then
  candidate_payloads+=("[]")
else
  append_candidate "$base_removed"
  for failed in "${base_failed[@]}"; do
    single=()
    single+=("$failed")
    if [[ "$allow_descendants" == "true" ]]; then
      append_candidate "$(collect_descendants single)"
    else
      append_candidate "$(id_array_to_json single)"
    fi
  done
fi

alternatives='[]'
feasible_count=0
alternative_count=0

for candidate in "${candidate_payloads[@]}"; do
  alternative_count=$((alternative_count + 1))
  if (( alternative_count > max_alternatives )); then
    break
  fi

  removed_ids=()
  while IFS= read -r removed_id; do
    [[ -z "$removed_id" ]] && continue
    removed_ids+=("$removed_id")
  done < <(jq -r '.[]' <<<"$candidate")

  declare -A removed_set=()
  for removed_id in "${removed_ids[@]}"; do
    removed_set["$removed_id"]=1
  done

  kept_ids=()
  declare -A kept_set=()
  for step_id in "${step_ids[@]}"; do
    if [[ -n "${removed_set[$step_id]+x}" ]]; then
      continue
    fi
    kept_ids+=("$step_id")
    kept_set["$step_id"]=1
  done

  replanned_steps='[]'
  declare -A step_deps_for_ordering=()
  for step_id in "${kept_ids[@]}"; do
    step_ref="${step_by_id[$step_id]}"
    filtered_deps='[]'
    while IFS= read -r dep; do
      [[ -z "$dep" ]] && continue
      if [[ -n "${removed_set[$dep]+x}" ]]; then
        continue
      fi
      filtered_deps="$(jq -cn --argjson list "$filtered_deps" --arg value "$dep" '$list + [$value]')"
    done < <(jq -r '.[]' <<<"${deps_by_id[$step_id]}")

    step_with_deps="$(jq -cn --argjson step "$step_ref" --argjson deps "$filtered_deps" '$step | .depends_on = $deps')"
    replanned_steps="$(jq -cn --argjson list "$replanned_steps" --argjson step "$step_with_deps" '$list + [$step]')"
    step_deps_for_ordering["$step_id"]="$filtered_deps"
  done

  topo_order='[]'
  visited_count="$(run_toposort kept_ids step_deps_for_ordering kept_set topo_order)"
  if (( visited_count != "${#kept_ids[@]}" )); then
    continue
  fi

  feasible_count=$((feasible_count + 1))
  ordered_removed="$(id_array_to_json removed_ids)"
  delta="$(jq -cn --argjson removedCount "${#removed_ids[@]}" --argjson keptCount "${#kept_ids[@]}" '{removedCount:$removedCount, keptCount:$keptCount}')"
  delta_plan="$(jq -cn --arg goal "$goal" --argjson steps "$replanned_steps" --argjson order "$topo_order" '{goal:($goal|tostring),steps:$steps,order:$order}')"
  alt="$(jq -cn --argjson removed "$ordered_removed" --argjson delta "$delta" --argjson plan "$delta_plan" '{removedStepIds:$removed,delta:$delta,plan:$plan}')"

  alternatives="$(jq -cn --argjson list "$alternatives" --argjson alt "$alt" '$list + [$alt]')"

done

summary="$(jq -cn \
  --argjson alternatives "${#candidate_payloads[@]}" \
  --argjson requested "$requested_failed_count" \
  --argjson feasible "$feasible_count" \
  --argjson max "$max_alternatives" \
  '{alternatives:$alternatives,requestedFailedCount:$requested,feasibleAlternatives:$feasible,maxAlternatives:$max}')"
result_json="$(jq -cn --arg command "$command" --arg source "$plan_source" --arg goal "$goal" --argjson alternatives "$alternatives" --argjson summary "$summary" '{command:$command,source:$source,goal:($goal|tostring),alternatives:$alternatives,contingencySummary:$summary}')"

if (( requested_failed_count == 0 )); then
  emit_output "success" "$command" "$result_json" '[]' '["no failed steps provided"]'
  exit 0
fi

if (( feasible_count == 0 )); then
  if [[ "$command" == "validate" || "$strict" == true ]]; then
    fail_runtime "$command" "No feasible contingency alternatives could be generated" '{"issues":[{"code":"NO_CONTINGENCY","severity":"critical","message":"No feasible alternatives found"}]}'
  fi
  emit_output "error" "$command" "$result_json" '[]' '["No feasible contingency alternative was possible"]'
  exit 0
fi

emit_output "partial" "$command" "$result_json" '[]' '[ "contingency alternatives generated" ]'
