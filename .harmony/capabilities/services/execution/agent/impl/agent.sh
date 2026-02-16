#!/usr/bin/env bash
# agent.sh - Native plan-driven agent execution MVP with checkpoint/resume/HITL.

set -euo pipefail

STATE_ROOT=".harmony/runtime/_ops/state/agent"
CHECKPOINT_DIR="$STATE_ROOT/checkpoints"
RUNS_DIR="$STATE_ROOT/runs"

emit_output() {
  local status="$1"
  local run_id="$2"
  local result_json="$3"
  local artifacts_json="${4:-}"
  local checkpoint_json="${5:-}"

  if [[ -z "$artifacts_json" ]]; then
    artifacts_json='[]'
  fi
  if [[ -z "$checkpoint_json" ]]; then
    checkpoint_json='{}'
  fi

  jq -n \
    --arg status "$status" \
    --arg runId "$run_id" \
    --argjson result "$result_json" \
    --argjson artifacts "$artifacts_json" \
    --argjson checkpoint "$checkpoint_json" \
    '{status:$status,runId:$runId,result:$result,artifacts:$artifacts,checkpoint:$checkpoint}'
}

fail_input() {
  local run_id="$1"
  local message="$2"
  emit_output "error" "$run_id" "{}" "[]" "$(jq -cn --arg m "$message" '{state:"invalid-input",message:$m}')"
  exit 5
}

fail_runtime() {
  local run_id="$1"
  local message="$2"
  emit_output "error" "$run_id" "{}" "[]" "$(jq -cn --arg m "$message" '{state:"runtime-error",message:$m}')"
  exit 4
}

stable_run_id() {
  local seed="$1"
  local hash
  hash="$(printf '%s' "$seed" | cksum | awk '{print $1}')"
  printf 'run-%s' "$hash"
}

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' '{"status":"error","runId":"run-missing-jq","result":{},"artifacts":[],"checkpoint":{"state":"invalid-runtime","message":"jq is required"}}'
  exit 6
fi

payload="$(cat)"
if [[ -z "$(printf '%s' "$payload" | tr -d '[:space:]')" ]]; then
  fail_input "run-invalid" "Expected JSON payload"
fi

if ! printf '%s' "$payload" | jq -e . >/dev/null 2>&1; then
  fail_input "run-invalid" "Payload is not valid JSON"
fi

plan_path="$(printf '%s' "$payload" | jq -r '.planPath // empty')"
run_id="$(printf '%s' "$payload" | jq -r '.runId // empty')"
resume="$(printf '%s' "$payload" | jq -r '.resume // false')"
memoize="$(printf '%s' "$payload" | jq -r '.memoize // false')"
dry_run="$(printf '%s' "$payload" | jq -r '.dryRun // false')"
hitl_json="$(printf '%s' "$payload" | jq -c '.hitl // {}')"
hitl_required="$(jq -r '.required // false' <<<"$hitl_json")"
hitl_approved="$(jq -r '.approved // false' <<<"$hitl_json")"
hitl_reason="$(jq -r '.reason // empty' <<<"$hitl_json")"

if [[ -z "$plan_path" ]]; then
  fail_input "run-invalid" "Missing planPath"
fi

if [[ "$resume" == "true" && -z "$run_id" ]]; then
  fail_input "run-invalid" "resume=true requires runId"
fi

if [[ -z "$run_id" ]]; then
  run_id="$(stable_run_id "$plan_path|$memoize|$dry_run|$hitl_required|$hitl_reason")"
fi

mkdir -p "$CHECKPOINT_DIR" "$RUNS_DIR"

checkpoint_path="$CHECKPOINT_DIR/$run_id.json"
run_record_path="$RUNS_DIR/$run_id.json"

if [[ "$resume" == "true" ]]; then
  if [[ ! -f "$checkpoint_path" ]]; then
    fail_runtime "$run_id" "Checkpoint not found for runId: $run_id"
  fi

  checkpoint_before="$(cat "$checkpoint_path")"
  previous_state="$(jq -r '.state // "unknown"' <<<"$checkpoint_before")"
  resume_count="$(jq -r '.resumeCount // 0' <<<"$checkpoint_before")"
  resume_count="$((resume_count + 1))"

  if [[ "$previous_state" == "awaiting_human" && "$hitl_approved" != "true" ]]; then
    state="awaiting_human"
    status="partial"
    summary="Awaiting human approval before resume"
  else
    state="resumed"
    status="success"
    summary="Run resumed from checkpoint"
  fi

  checkpoint_json="$(jq -cn \
    --arg runId "$run_id" \
    --arg planPath "$plan_path" \
    --arg state "$state" \
    --arg previousState "$previous_state" \
    --argjson resumeCount "$resume_count" \
    --argjson hitlRequired "$hitl_required" \
    --argjson hitlApproved "$hitl_approved" \
    --arg hitlReason "$hitl_reason" \
    '{runId:$runId,planPath:$planPath,state:$state,previousState:$previousState,resumeCount:$resumeCount,hitlRequired:$hitlRequired,hitlApproved:$hitlApproved,hitlReason:$hitlReason}')"

  printf '%s\n' "$checkpoint_json" | jq -S . > "$checkpoint_path"

  result_json="$(jq -cn \
    --arg mode "resume" \
    --arg summary "$summary" \
    --arg planPath "$plan_path" \
    --argjson memoize "$memoize" \
    --argjson dryRun "$dry_run" \
    --argjson hitl "$hitl_json" \
    --arg checkpointPath "$checkpoint_path" \
    '{mode:$mode,summary:$summary,planPath:$planPath,memoize:$memoize,dryRun:$dryRun,hitl:$hitl,checkpointPath:$checkpointPath}')"

  run_record_json="$(jq -cn \
    --arg runId "$run_id" \
    --arg mode "resume" \
    --arg status "$status" \
    --arg planPath "$plan_path" \
    --argjson checkpoint "$checkpoint_json" \
    --argjson result "$result_json" \
    '{runId:$runId,mode:$mode,status:$status,planPath:$planPath,checkpoint:$checkpoint,result:$result}')"
  printf '%s\n' "$run_record_json" | jq -S . > "$run_record_path"

  artifacts_json="$(jq -cn --arg p "$run_record_path" '[ $p ]')"
  emit_output "$status" "$run_id" "$result_json" "$artifacts_json" "$checkpoint_json"
  exit 0
fi

if [[ ! -f "$plan_path" ]]; then
  warnings='["planPath does not exist on disk; executing in logical mode only"]'
else
  warnings='[]'
fi

if [[ "$hitl_required" == "true" && "$hitl_approved" != "true" ]]; then
  state="awaiting_human"
  status="partial"
  summary="Checkpoint created and waiting for human approval"
elif [[ "$dry_run" == "true" ]]; then
  state="checkpointed"
  status="partial"
  summary="Dry-run checkpoint created"
else
  state="running"
  status="success"
  summary="Execution accepted"
fi

checkpoint_json="$(jq -cn \
  --arg runId "$run_id" \
  --arg planPath "$plan_path" \
  --arg state "$state" \
  --argjson resumeCount 0 \
  --argjson memoize "$memoize" \
  --argjson dryRun "$dry_run" \
  --argjson hitlRequired "$hitl_required" \
  --argjson hitlApproved "$hitl_approved" \
  --arg hitlReason "$hitl_reason" \
  '{runId:$runId,planPath:$planPath,state:$state,resumeCount:$resumeCount,memoize:$memoize,dryRun:$dryRun,hitlRequired:$hitlRequired,hitlApproved:$hitlApproved,hitlReason:$hitlReason}')"
printf '%s\n' "$checkpoint_json" | jq -S . > "$checkpoint_path"

result_json="$(jq -cn \
  --arg mode "execute" \
  --arg summary "$summary" \
  --arg planPath "$plan_path" \
  --argjson resume false \
  --argjson memoize "$memoize" \
  --argjson dryRun "$dry_run" \
  --argjson hitl "$hitl_json" \
  --argjson warnings "$warnings" \
  --arg checkpointPath "$checkpoint_path" \
  '{mode:$mode,summary:$summary,planPath:$planPath,resume:$resume,memoize:$memoize,dryRun:$dryRun,hitl:$hitl,warnings:$warnings,checkpointPath:$checkpointPath}')"

run_record_json="$(jq -cn \
  --arg runId "$run_id" \
  --arg mode "execute" \
  --arg status "$status" \
  --arg planPath "$plan_path" \
  --argjson checkpoint "$checkpoint_json" \
  --argjson result "$result_json" \
  '{runId:$runId,mode:$mode,status:$status,planPath:$planPath,checkpoint:$checkpoint,result:$result}')"
printf '%s\n' "$run_record_json" | jq -S . > "$run_record_path"

artifacts_json="$(jq -cn --arg p "$run_record_path" '[ $p ]')"
emit_output "$status" "$run_id" "$result_json" "$artifacts_json" "$checkpoint_json"
