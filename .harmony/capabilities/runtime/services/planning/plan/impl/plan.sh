#!/usr/bin/env bash
# plan.sh - Native planning synthesis with DAG validation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Enforce deny-by-default policy at runtime for this shell service.
source "$SCRIPT_DIR/../../../_ops/scripts/enforce-deny-by-default.sh"
harmony_enforce_service_policy "plan" "$0" "$@"


emit_output() {
  local status="$1"
  local plan_json="$2"
  local warnings_json="${3:-[]}"
  jq -n --arg status "$status" --argjson plan "$plan_json" --argjson warnings "$warnings_json" \
    '{status:$status,plan:$plan,warnings:$warnings}'
}

fail_input() {
  local message="$1"
  emit_output "error" "{}" "$(jq -cn --arg m "$message" '[ $m ]')"
  exit 5
}

fail_runtime() {
  local goal="$1"
  local steps_json="$2"
  local message="$3"
  local plan_json
  plan_json="$(jq -cn --arg goal "$goal" --argjson steps "$steps_json" '{goal:$goal,steps:$steps}')"
  emit_output "error" "$plan_json" "$(jq -cn --arg m "$message" '[ $m ]')"
  exit 4
}

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' '{"status":"error","plan":{},"warnings":["jq is required"]}'
  exit 6
fi

payload="$(cat)"
if [[ -z "$(printf '%s' "$payload" | tr -d '[:space:]')" ]]; then
  fail_input "Expected JSON payload"
fi

if ! printf '%s' "$payload" | jq -e . >/dev/null 2>&1; then
  fail_input "Payload is not valid JSON"
fi

goal="$(printf '%s' "$payload" | jq -r '.goal // empty')"
constraints_json="$(printf '%s' "$payload" | jq -c '.constraints // {}')"
steps_input_json="$(printf '%s' "$payload" | jq -c '.steps // []')"

if [[ -z "$goal" ]]; then
  fail_input "Missing goal"
fi

if ! jq -e 'type == "array"' <<<"$steps_input_json" >/dev/null 2>&1; then
  fail_input "steps must be an array"
fi

if ! jq -e 'type == "object"' <<<"$constraints_json" >/dev/null 2>&1; then
  fail_input "constraints must be an object"
fi

steps_json="$steps_input_json"
if [[ "$(jq 'length' <<<"$steps_json")" -eq 0 ]]; then
  steps_json='[{"id":"execute-goal","depends_on":[]}]'
fi

declare -A step_by_id
declare -A deps_by_id
declare -A seen
ids=()

while IFS= read -r step; do
  id="$(jq -r '.id // empty' <<<"$step")"
  if [[ -z "$id" ]]; then
    fail_runtime "$goal" "$steps_json" "Every plan step requires a non-empty id"
  fi

  if [[ -n "${seen[$id]:-}" ]]; then
    fail_runtime "$goal" "$steps_json" "Duplicate plan step id: $id"
  fi
  seen[$id]=1
  ids+=("$id")

  canonical_step="$(jq -c '
    {
      id,
      depends_on: ((.depends_on // []) | map(select(type=="string" and length>0)) | unique | sort)
    }
    + (if has("tool") then {tool:.tool} else {} end)
    + (if has("inputs") then {inputs:.inputs} else {} end)
  ' <<<"$step")"

  deps_line="$(jq -r '.depends_on | join(" ")' <<<"$canonical_step")"
  deps_by_id["$id"]="$deps_line"
  step_by_id["$id"]="$canonical_step"
done < <(jq -c '.[]' <<<"$steps_json")

for id in "${ids[@]}"; do
  for dep in ${deps_by_id[$id]}; do
    if [[ -z "${seen[$dep]:-}" ]]; then
      fail_runtime "$goal" "$steps_json" "Step '$id' depends on unknown step '$dep'"
    fi
  done
done

# DFS topological sort with cycle detection.
declare -A visiting
declare -A visited
order=()

visit_step() {
  local node="$1"

  if [[ "${visiting[$node]:-0}" -eq 1 ]]; then
    return 2
  fi
  if [[ "${visited[$node]:-0}" -eq 1 ]]; then
    return 0
  fi

  visiting[$node]=1
  for dep in ${deps_by_id[$node]}; do
    if ! visit_step "$dep"; then
      return $?
    fi
  done

  visiting[$node]=0
  visited[$node]=1
  order+=("$node")
  return 0
}

for id in "${ids[@]}"; do
  if visit_step "$id"; then
    :
  else
    status="$?"
    if [[ "$status" -eq 2 ]]; then
      fail_runtime "$goal" "$steps_json" "Cyclic dependency detected in plan steps"
    fi
    fail_runtime "$goal" "$steps_json" "Failed to resolve plan dependency graph"
  fi
done

ordered_steps='[]'
for id in "${order[@]}"; do
  ordered_steps="$(jq -cn --argjson arr "$ordered_steps" --argjson step "${step_by_id[$id]}" '$arr + [$step]')"
done

order_json="$(printf '%s\n' "${order[@]}" | jq -R . | jq -s .)"
plan_json="$(jq -cn \
  --arg goal "$goal" \
  --argjson constraints "$constraints_json" \
  --argjson steps "$ordered_steps" \
  --argjson order "$order_json" \
  '{goal:$goal,constraints:$constraints,steps:$steps,order:$order}')"

emit_output "success" "$plan_json" "[]"
