#!/usr/bin/env bash
# scheduler.sh - Deterministic dependency-aware step scheduler.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Enforce deny-by-default policy at runtime for this shell service.
source "$SCRIPT_DIR/../../../_ops/scripts/enforce-deny-by-default.sh"
harmony_enforce_service_policy "scheduler" "$0" "$@"


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
if [[ "$command" != "schedule" ]]; then
  fail_input "${command:-unknown}" "Unsupported command: ${command:-unknown}"
fi

plan_path="$(printf '%s' "$payload" | jq -r '.planPath // empty')"
plan_payload="$(printf '%s' "$payload" | jq -c '.plan // {}')"
max_parallel="$(printf '%s' "$payload" | jq -r '.maxParallel // 0')"
prefer="$(printf '%s' "$payload" | jq -r '.prefer // "compact"')"

if [[ "$max_parallel" == "null" ]]; then
  max_parallel=0
fi
if ! [[ "$max_parallel" =~ ^[0-9]+$ ]]; then
  fail_input "$command" "maxParallel must be a non-negative integer"
fi

if [[ "$prefer" != "compact" && "$prefer" != "throughput" ]]; then
  fail_input "$command" "Unsupported prefer mode: $prefer"
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
declare -A step_lookup
declare -A deps_by_id
declare -A duration_by_id

while IFS= read -r step; do
  id="$(jq -r '.id // empty' <<<"$step")"
  if [[ -z "$id" ]]; then
    fail_input "$command" "Every step requires a non-empty id"
  fi
  if [[ -n "${step_lookup[$id]+x}" ]]; then
    fail_input "$command" "Duplicate step id: $id"
  fi

  step_lookup["$id"]="$step"
  step_ids+=("$id")

  deps="$(jq -c '(.depends_on // []) | map(select(type=="string" and length > 0)) | unique' <<<"$step")"
  if [[ -z "$deps" || "$deps" == "null" ]]; then
    deps='[]'
  fi
  deps_by_id["$id"]="$deps"

  duration="$(jq -r '(.duration // 1) | if (type=="number" and . >= 1) then . else 1 end | floor' <<<"$step")"
  if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
    duration=1
  fi
  if (( duration < 1 )); then
    duration=1
  fi
  duration_by_id["$id"]="$duration"

done < <(jq -c '.[]' <<<"$steps_json")

for id in "${step_ids[@]}"; do
  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    if [[ -z "${step_lookup[$dep]+x}" ]]; then
      fail_runtime "$command" "Step '$id' depends on missing step '$dep'" '{"issues":[{"code":"MISSING_DEPENDENCY","severity":"critical","message":"Missing dependency"}]}'
    fi
  done < <(jq -r '.[]' <<<"${deps_by_id[$id]}")
done

if [[ ${#step_ids[@]} -eq 0 ]]; then
  result_json="$(jq -cn --arg command "$command" --arg source "$plan_source" --arg goal "$goal" '{command:$command,source:$source,goal:($goal|tostring),schedule:{stages:[],order:[],metrics:{totalDuration:0,totalStages:0,totalSteps:0,maxParallel:0,maxStageDuration:0,prefer:"compact"},durationsPerStage:[]}')"
  emit_output "success" "$command" "$result_json" "[]" '["empty plan"]'
  exit 0
fi

declare -A indegree
declare -A scheduled
declare -A queued

enqueue_ready() {
  local node="$1"
  if [[ -z "$node" ]]; then
    return
  fi
  if [[ -n "${queued[$node]+x}" || -n "${scheduled[$node]+x}" ]]; then
    return
  fi
  ready_ids+=("$node")
  queued["$node"]=1
}

for id in "${step_ids[@]}"; do
  indegree["$id"]=0
  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    indegree["$id"]=$((indegree["$id"] + 1))
  done < <(jq -r '.[]' <<<"${deps_by_id[$id]}")
done

ready_ids=()
for id in "${step_ids[@]}"; do
  if [[ "${indegree[$id]}" == "0" ]]; then
    enqueue_ready "$id"
  fi
done

ordered='[]'
stages='[]'
stage_durations='[]'
visited_count=0
total_steps=${#step_ids[@]}

while (( ${#ready_ids[@]} > 0 )); do
  mapfile -t ready_ids < <(printf '%s\n' "${ready_ids[@]}" | sort | uniq)

  batch_size=0
  if [[ "$max_parallel" == "0" || "$max_parallel" -gt ${#ready_ids[@]} ]]; then
    batch_size=${#ready_ids[@]}
  else
    batch_size="$max_parallel"
  fi

  batch=("${ready_ids[@]:0:batch_size}")
  ready_ids=("${ready_ids[@]:batch_size}")

  # Remove consumed nodes from queue index.
  for node in "${batch[@]}"; do
    unset "queued[$node]"
  done

  stage_nodes=()

  stage_duration=0
  for node in "${batch[@]}"; do
    if [[ -n "${scheduled[$node]+x}" ]]; then
      continue
    fi
    stage_nodes+=("$node")

    scheduled["$node"]=1
    visited_count=$((visited_count + 1))

    if [[ "$prefer" == "throughput" ]]; then
      if (( duration_by_id[$node] > stage_duration )); then
        stage_duration=${duration_by_id[$node]}
      fi
    else
      stage_duration=$((stage_duration + duration_by_id[$node]))
    fi

    for dependent in "${step_ids[@]}"; do
      [[ "${indegree[$dependent]+x}" == "" ]] && continue
      for dep in $(jq -r '.[]' <<<"${deps_by_id[$dependent]}"); do
        [[ -z "$dep" ]] && continue
        if [[ "$dep" == "$node" ]]; then
          indegree[$dependent]=$((indegree[$dependent] - 1))
          break
        fi
      done

      if [[ "${indegree[$dependent]}" == "0" ]]; then
        enqueue_ready "$dependent"
      fi
    done
  done
  if [[ ${#stage_nodes[@]} -eq 0 ]]; then
    fail_runtime "$command" "Scheduler produced no schedulable nodes" '{"issues":[{"code":"SCHEDULER_STALE_QUEUE","severity":"critical","message":"Ready queue contains only already scheduled steps"}]}'
  fi

  stage="$(printf '%s\n' "${stage_nodes[@]}" | jq -R . | jq -s .)"
  stages="$(jq -cn --argjson list "$stages" --argjson stage "$stage" '$list + [$stage]')"
  ordered="$(jq -cn --argjson list "$ordered" --argjson batch "$stage" '$list + $batch')"

  stage_durations="$(jq -cn --argjson list "$stage_durations" --argjson value "$stage_duration" '$list + [$value]')"
done

if (( visited_count != total_steps )); then
  fail_runtime "$command" "Cycle detected in dependency graph" '{"issues":[{"code":"CYCLE_DETECTED","severity":"critical","message":"Scheduler requires an acyclic graph"}]}'
fi

total_duration=0
while IFS= read -r val; do
  [[ -z "$val" ]] && continue
  total_duration=$((total_duration + val))
done < <(jq -r '.[]' <<<"$stage_durations")

max_stage=0
while IFS= read -r val; do
  [[ -z "$val" ]] && continue
  if (( val > max_stage )); then
    max_stage="$val"
  fi
done < <(jq -r '.[]' <<<"$stage_durations")

result_json="$(jq -cn \
  --arg command "$command" \
  --arg source "$plan_source" \
  --arg goal "$goal" \
  --argjson stages "$stages" \
  --argjson order "$ordered" \
  --argjson totalDuration "$total_duration" \
  --argjson totalSteps "$total_steps" \
  --argjson stageCount "$(jq 'length' <<<"$stages")" \
  --argjson maxParallel "$max_parallel" \
  --argjson maxStageDuration "$max_stage" \
  --arg prefer "$prefer" \
  --argjson durationsPerStage "$stage_durations" \
  '{
    command:$command,
    source:$source,
    goal:($goal|tostring),
    schedule:{
      stages:$stages,
      order:$order,
      metrics:{
        totalDuration:$totalDuration,
        totalStages:$stageCount,
        totalSteps:$totalSteps,
        maxParallel:$maxParallel,
        maxStageDuration:$maxStageDuration,
        prefer:$prefer
      },
      durationsPerStage:$durationsPerStage
    }
  }')"

emit_output "success" "$command" "$result_json"
