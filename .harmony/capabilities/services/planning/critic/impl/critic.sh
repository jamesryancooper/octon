#!/usr/bin/env bash
# critic.sh - Deterministic plan structure validation and risk scoring.

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
if [[ "$command" != "validate" && "$command" != "score" ]]; then
  fail_input "${command:-unknown}" "Unsupported command: ${command:-unknown}"
fi

risk_tolerance="$(printf '%s' "$payload" | jq -r '.riskTolerance // "medium"')"
if [[ "$risk_tolerance" != "low" && "$risk_tolerance" != "medium" && "$risk_tolerance" != "high" ]]; then
  fail_input "$command" "riskTolerance must be low, medium, or high"
fi

strict_input="$(printf '%s' "$payload" | jq -r '.strict // empty')"
strict=false
if [[ "$command" == "validate" && -z "$strict_input" ]]; then
  strict=true
elif [[ "$strict_input" == "true" ]]; then
  strict=true
fi

plan_path="$(printf '%s' "$payload" | jq -r '.planPath // empty')"
plan_json="$(printf '%s' "$payload" | jq -c '.plan // empty')"

if [[ -n "$plan_json" && "$plan_json" != "null" && "$plan_json" != "{}" ]]; then
  if ! jq -e 'type == "object"' <<<"$plan_json" >/dev/null 2>&1; then
    fail_input "$command" "plan must be an object"
  fi
elif [[ -n "$plan_path" && "$plan_path" != "null" ]]; then
  if [[ ! -f "$plan_path" ]]; then
    fail_input "$command" "Plan file does not exist: $plan_path"
  fi
  if ! jq -e . "$plan_path" >/dev/null 2>&1; then
    fail_input "$command" "Plan file is not valid JSON: $plan_path"
  fi
  plan_json="$(cat "$plan_path")"
else
  fail_input "$command" "Missing plan source; provide planPath or inline plan"
fi

if ! jq -e '.steps | type == "array"' <<<"$plan_json" >/dev/null 2>&1; then
  fail_input "$command" "Plan must contain a steps array"
fi

goal="$(jq -r '.goal // ""' <<<"$plan_json")"
steps_json="$(jq -c '.steps' <<<"$plan_json")"

issues='[]'
step_ids=()
declare -A seen

declare -A deps_by_id

append_issue() {
  local code="$1"
  local severity="$2"
  local message="$3"
  local step_id="$4"
  issues="$(jq -cn --argjson list "$issues" \
    --arg code "$code" \
    --arg severity "$severity" \
    --arg message "$message" \
    --arg stepId "$step_id" \
    '$list + [{code:$code,severity:$severity,message:$message,stepId:$stepId}]')"
}

while IFS= read -r step; do
  id="$(jq -r '.id // empty' <<<"$step")"

  if [[ -z "$id" ]]; then
    append_issue "MISSING_STEP_ID" "critical" "A step is missing a non-empty id" ""
    continue
  fi

  if [[ -n "${seen[$id]+x}" ]]; then
    append_issue "DUPLICATE_STEP_ID" "critical" "Duplicate step id: $id" "$id"
    continue
  fi

  seen["$id"]=1
  step_ids+=("$id")

  deps_raw="$(jq -c '(.depends_on // [])' <<<"$step")"
  if ! jq -e 'type == "array"' <<<"$deps_raw" >/dev/null 2>&1; then
    append_issue "BAD_DEPENDS_ON" "warning" "depends_on must be an array" "$id"
    deps='[]'
  else
    deps="$(jq -c 'map(select(type=="string" and length > 0)) | unique' <<<"$deps_raw")"
  fi

  deps_by_id["$id"]="$deps"

done < <(jq -c '.[]' <<<"$steps_json")

for id in "${step_ids[@]}"; do
  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    if [[ "$dep" == "$id" ]]; then
      append_issue "SELF_DEPENDENCY" "critical" "Step '$id' depends on itself" "$id"
      continue
    fi
    if [[ -z "${seen[$dep]+x}" ]]; then
      append_issue "MISSING_DEPENDENCY" "critical" "Step '$id' depends on missing step '$dep'" "$id"
    fi
  done < <(jq -r '.[]' <<<"${deps_by_id[$id]}")
done

ordered='[]'
declare -A visit_state
cycle=false

visit_step() {
  local node="$1"
  local state="${visit_state[$node]:-0}"

  if [[ "$state" -eq 1 ]]; then
    cycle=true
    return
  fi
  if [[ "$state" -eq 2 ]]; then
    return
  fi

  visit_state[$node]=1
  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    visit_step "$dep"
  done < <(jq -r '.[]' <<<"${deps_by_id[$node]}")
  visit_state[$node]=2
  ordered="$(jq -cn --argjson list "$ordered" --arg value "$node" '$list + [$value]')"
}

for id in "${step_ids[@]}"; do
  visit_step "$id"
done

if [[ "$cycle" == true ]]; then
  append_issue "CYCLE_DETECTED" "critical" "Dependency graph contains a cycle" ""
fi

step_count="${#step_ids[@]}"
issue_count="$(jq 'length' <<<"$issues")"
critical_count="$(jq '[.[] | select(.severity == "critical")] | length' <<<"$issues")"
warning_count="$(jq '[.[] | select(.severity == "warning")] | length' <<<"$issues")"

risk_score=$((step_count * 3 + critical_count * 22 + warning_count * 4))
if [[ "$risk_tolerance" == "low" ]]; then
  risk_score=$((risk_score + 10))
elif [[ "$risk_tolerance" == "high" ]]; then
  risk_score=$((risk_score - 10))
fi
[[ "$risk_score" -lt 0 ]] && risk_score=0
[[ "$risk_score" -gt 100 ]] && risk_score=100

if (( risk_score >= 80 )); then
  risk_level="critical"
elif (( risk_score >= 60 )); then
  risk_level="high"
elif (( risk_score >= 40 )); then
  risk_level="medium"
else
  risk_level="low"
fi

if (( critical_count > 0 )); then
  recommendations='["Fix structural graph defects before execution"]'
elif (( warning_count > 0 )); then
  recommendations='["Review warning-level quality issues"]'
else
  recommendations='["Plan graph is structurally sound"]'
fi

source="inline"
if [[ "$plan_json" != "$(printf '%s' "$payload" | jq -c '.plan // empty')" && -n "$plan_path" && "$plan_path" != "null" ]]; then
  source="$plan_path"
fi

result_json="$(jq -cn \
  --arg command "$command" \
  --arg goal "$goal" \
  --arg source "$source" \
  --arg riskTolerance "$risk_tolerance" \
  --arg riskLevel "$risk_level" \
  --argjson stepCount "$step_count" \
  --argjson issueCount "$issue_count" \
  --argjson criticalCount "$critical_count" \
  --argjson warningCount "$warning_count" \
  --argjson riskScore "$risk_score" \
  --argjson issues "$issues" \
  --argjson recommendations "$recommendations" \
  --argjson topologicalOrder "$ordered" \
  '{
    command:$command,
    goal:($goal|tostring),
    planSource:$source,
    stepCount:$stepCount,
    issueCount:$issueCount,
    criticalIssueCount:$criticalCount,
    warningIssueCount:$warningCount,
    riskTolerance:$riskTolerance,
    riskScore:$riskScore,
    riskLevel:$riskLevel,
    topologicalOrder:$topologicalOrder,
    recommendations:$recommendations,
    issues:$issues
  }')"

if (( critical_count > 0 )); then
  if [[ "$command" == "validate" ]] || [[ "$strict" == true ]]; then
    fail_runtime "$command" "Critical planning defects detected" "$result_json"
  fi
  emit_output "partial" "$command" "$result_json" '[]' '["non-blocking critical defects remain"]'
  exit 0
fi

if (( issue_count > 0 )); then
  emit_output "partial" "$command" "$result_json" '[]' '["non-blocking warnings remain"]'
  exit 0
fi

emit_output "success" "$command" "$result_json"
