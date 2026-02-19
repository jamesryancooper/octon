#!/usr/bin/env bash
# agent.sh - Native plan-driven agent execution MVP with checkpoint/resume.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Enforce deny-by-default policy at runtime for this shell service.
source "$SCRIPT_DIR/../../../_ops/scripts/enforce-deny-by-default.sh"
harmony_enforce_service_policy "agent" "$0" "$@"


STATE_ROOT=".harmony/runtime/_ops/state/agent"
CHECKPOINT_DIR="$STATE_ROOT/checkpoints"
RUNS_DIR="$STATE_ROOT/runs"
POLICY_FILE=".harmony/capabilities/_ops/policy/deny-by-default.v2.yml"
POLICY_RUNNER=".harmony/capabilities/_ops/scripts/run-harmony-policy.sh"
PROFILE_RESOLVER=".harmony/capabilities/_ops/scripts/policy-profile-resolve.sh"
AGENT_POLICY_LAST_DENY_JSON='{}'
AGENT_POLICY_ATTEMPTS=0

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

infer_policy_profile() {
  local plan_path="$1"
  if [[ "$plan_path" == *"test"* || "$plan_path" == *"spec"* ]]; then
    echo "tests"
    return
  fi
  if [[ "$plan_path" == *"README"* || "$plan_path" == *".md" ]]; then
    echo "docs"
    return
  fi
  echo "refactor"
}

run_profile_grant_eval() {
  local profile_json="$1"
  local run_id="$2"
  local attempt="$3"

  local tier
  tier="$(jq -r '.auto_grant_tier // "none"' <<<"$profile_json")"
  if [[ "$tier" == "none" ]]; then
    AGENT_POLICY_LAST_DENY_JSON='{}'
    return 0
  fi

  local -a args
  args=(grant-eval --policy "$POLICY_FILE" --tier "$tier" --request-id "policy-$run_id-$attempt" --agent-id "${HARMONY_AGENT_ID:-agent-unknown}" --plan-step-id "agent-preflight-$attempt")

  local token
  while IFS= read -r token; do
    [[ -n "$token" ]] && args+=(--tool "$token")
  done < <(jq -r '.tool_bundle[]?' <<<"$profile_json")

  while IFS= read -r token; do
    [[ -n "$token" ]] && args+=(--write-scope "$token")
  done < <(jq -r '.write_scope_bundle[]?' <<<"$profile_json")

  if [[ -n "${HARMONY_REVIEW_AGENT_ID:-}" ]]; then
    args+=(--has-review-evidence)
  fi
  if [[ -n "${HARMONY_QUORUM_TOKEN:-}" ]]; then
    args+=(--has-quorum-evidence)
  fi

  local output rc=0
  output="$("$POLICY_RUNNER" "${args[@]}" 2>&1)" || rc=$?
  if [[ $rc -eq 13 ]]; then
    AGENT_POLICY_LAST_DENY_JSON="$(jq -c '.deny // {}' <<<"$output" 2>/dev/null || echo '{}')"
  elif [[ $rc -ne 0 ]]; then
    AGENT_POLICY_LAST_DENY_JSON="$(jq -cn --arg m "$output" '{code:"DDB025_RUNTIME_DECISION_ENGINE_ERROR",message:$m,remediation_hint:"Inspect policy engine diagnostics"}')"
  else
    AGENT_POLICY_LAST_DENY_JSON='{}'
  fi

  return $rc
}

agent_policy_preflight_loop() {
  local run_id="$1"
  local plan_path="$2"

  if [[ ! -x "$POLICY_RUNNER" || ! -x "$PROFILE_RESOLVER" || ! -f "$POLICY_FILE" ]]; then
    return 0
  fi

  local profile max_attempts auto_remediate risk_tier
  profile="${HARMONY_POLICY_PROFILE:-$(infer_policy_profile "$plan_path")}"
  max_attempts="${HARMONY_DDB_REMEDIATE_MAX_ATTEMPTS:-2}"
  auto_remediate="${HARMONY_DDB_AUTO_REMEDIATE:-true}"
  risk_tier="$(echo "${HARMONY_RISK_TIER:-low}" | tr '[:upper:]' '[:lower:]')"

  local attempt=0
  while (( attempt < max_attempts )); do
    attempt=$((attempt + 1))
    AGENT_POLICY_ATTEMPTS="$attempt"

    local profile_json
    if ! profile_json="$("$PROFILE_RESOLVER" "$profile" 2>/dev/null)"; then
      AGENT_POLICY_LAST_DENY_JSON="$(jq -cn --arg p "$profile" '{code:"DDB023_PROFILE_NOT_FOUND",message:("Unknown profile: " + $p),remediation_hint:"Select a valid policy profile"}')"
      return 1
    fi

    if run_profile_grant_eval "$profile_json" "$run_id" "$attempt"; then
      return 0
    fi

    local rc=$?
    if [[ $rc -ne 13 ]]; then
      return 1
    fi

    if [[ "$risk_tier" != "low" || "$auto_remediate" != "true" ]]; then
      return 1
    fi

    local -a grant_args
    grant_args=("$profile" --emit-grant --subject "service:agent:$run_id" --request-id "policy-remediate-$run_id-$attempt" --agent-id "${HARMONY_AGENT_ID:-agent-unknown}" --plan-step-id "agent-remediate-$attempt")
    if [[ -n "${HARMONY_REVIEW_AGENT_ID:-}" ]]; then
      grant_args+=(--review-evidence)
    fi
    if [[ -n "${HARMONY_QUORUM_TOKEN:-}" ]]; then
      grant_args+=(--quorum-evidence)
    fi

    if ! "$PROFILE_RESOLVER" "${grant_args[@]}" >/dev/null 2>&1; then
      return 1
    fi
  done

  AGENT_POLICY_LAST_DENY_JSON="$(jq -cn --argjson attempts "$AGENT_POLICY_ATTEMPTS" '{code:"DDB024_REMEDIATION_ATTEMPTS_EXCEEDED",message:"Auto-remediation attempts exceeded",remediation_hint:"Narrow requested scope or select a more specific profile",attempts:$attempts}')"
  return 1
}

fail_policy_preflight() {
  local run_id="$1"
  local deny_json="$2"
  local safe_deny_json="$deny_json"

  if ! jq -e . >/dev/null 2>&1 <<<"$safe_deny_json"; then
    safe_deny_json='{"code":"DDB025_RUNTIME_DECISION_ENGINE_ERROR","message":"Policy preflight failed","remediation_hint":"Inspect policy diagnostics"}'
  fi

  local result_json checkpoint_json
  result_json="$(jq -cn --argjson deny "$safe_deny_json" --argjson attempts "$AGENT_POLICY_ATTEMPTS" '{summary:"Policy preflight denied",deny:$deny,attempts:$attempts}')"
  checkpoint_json="$(jq -cn --argjson deny "$safe_deny_json" --argjson attempts "$AGENT_POLICY_ATTEMPTS" '{state:"policy-denied",deny:$deny,attempts:$attempts}')"
  emit_output "error" "$run_id" "$result_json" "[]" "$checkpoint_json"
  exit 13
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

if [[ -z "$plan_path" ]]; then
  fail_input "run-invalid" "Missing planPath"
fi

if [[ "$resume" == "true" && -z "$run_id" ]]; then
  fail_input "run-invalid" "resume=true requires runId"
fi

if [[ -z "$run_id" ]]; then
  run_id="$(stable_run_id "$plan_path|$memoize|$dry_run")"
fi

if ! agent_policy_preflight_loop "$run_id" "$plan_path"; then
  fail_policy_preflight "$run_id" "$AGENT_POLICY_LAST_DENY_JSON"
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
  state="resumed"
  status="success"
  summary="Run resumed from checkpoint"

  checkpoint_json="$(jq -cn \
    --arg runId "$run_id" \
    --arg planPath "$plan_path" \
    --arg state "$state" \
    --arg previousState "$previous_state" \
    --argjson resumeCount "$resume_count" \
    '{runId:$runId,planPath:$planPath,state:$state,previousState:$previousState,resumeCount:$resumeCount}')"

  printf '%s\n' "$checkpoint_json" | jq -S . > "$checkpoint_path"

  result_json="$(jq -cn \
    --arg mode "resume" \
    --arg summary "$summary" \
    --arg planPath "$plan_path" \
    --argjson memoize "$memoize" \
    --argjson dryRun "$dry_run" \
    --arg checkpointPath "$checkpoint_path" \
    '{mode:$mode,summary:$summary,planPath:$planPath,memoize:$memoize,dryRun:$dryRun,checkpointPath:$checkpointPath}')"

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

if [[ "$dry_run" == "true" ]]; then
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
  '{runId:$runId,planPath:$planPath,state:$state,resumeCount:$resumeCount,memoize:$memoize,dryRun:$dryRun}')"
printf '%s\n' "$checkpoint_json" | jq -S . > "$checkpoint_path"

result_json="$(jq -cn \
  --arg mode "execute" \
  --arg summary "$summary" \
  --arg planPath "$plan_path" \
  --argjson resume false \
  --argjson memoize "$memoize" \
  --argjson dryRun "$dry_run" \
  --argjson warnings "$warnings" \
  --arg checkpointPath "$checkpoint_path" \
  '{mode:$mode,summary:$summary,planPath:$planPath,resume:$resume,memoize:$memoize,dryRun:$dryRun,warnings:$warnings,checkpointPath:$checkpointPath}')"

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
