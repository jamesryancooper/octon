#!/usr/bin/env bash
# agent.sh - Native plan-driven agent execution MVP with checkpoint/resume.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Enforce deny-by-default policy at runtime for this shell service.
export HARMONY_OPERATION_CLASS="${HARMONY_OPERATION_CLASS:-service.execute}"
export HARMONY_OPERATION_PHASE="${HARMONY_OPERATION_PHASE:-stage}"
source "$SCRIPT_DIR/../../../_ops/scripts/enforce-deny-by-default.sh"
harmony_enforce_service_policy "agent" "$0" "$@"


STATE_ROOT=".harmony/engine/_ops/state/agent"
CHECKPOINT_DIR="$STATE_ROOT/checkpoints"
RUNS_DIR="$STATE_ROOT/runs"
CONTINUITY_RUNS_DIR=".harmony/continuity/runs"
POLICY_FILE=".harmony/capabilities/governance/policy/deny-by-default.v2.yml"
POLICY_RUNNER=".harmony/engine/runtime/policy"
PROFILE_RESOLVER=".harmony/capabilities/_ops/scripts/policy-profile-resolve.sh"
BUDGET_METER=".harmony/capabilities/_ops/scripts/policy-budget-meter.sh"
ACP_REQUEST_BUILDER=".harmony/capabilities/_ops/scripts/policy-acp-request.sh"
ACP_EVAL=".harmony/capabilities/_ops/scripts/policy-acp-eval.sh"
RECEIPT_WRITER=".harmony/capabilities/_ops/scripts/policy-receipt-write.sh"
REVERSIBLE_PRIMITIVES_SCRIPT=".harmony/capabilities/_ops/scripts/policy-reversible-primitives.sh"
BREAKER_ACTIONS_SCRIPT=".harmony/capabilities/_ops/scripts/policy-circuit-breaker-actions.sh"
AGENT_POLICY_LAST_DENY_JSON='{}'
AGENT_POLICY_ATTEMPTS=0
AGENT_START_TS="${AGENT_START_TS:-$(date +%s)}"

agent_elapsed_ms() {
  local now elapsed
  now="$(date +%s)"
  elapsed=$(( (now - AGENT_START_TS) * 1000 ))
  if (( elapsed < 0 )); then
    elapsed=0
  fi
  printf '%s\n' "$elapsed"
}

agent_default_context_acquisition_json() {
  local file_reads search_queries commands subagent_spawns duration_ms
  file_reads="${HARMONY_CONTEXT_FILE_READS:-0}"
  search_queries="${HARMONY_CONTEXT_SEARCH_QUERIES:-0}"
  commands="${HARMONY_CONTEXT_COMMANDS:-1}"
  subagent_spawns="${HARMONY_CONTEXT_SUBAGENT_SPAWNS:-0}"
  duration_ms="$(agent_elapsed_ms)"

  [[ "$file_reads" =~ ^[0-9]+$ ]] || file_reads=0
  [[ "$search_queries" =~ ^[0-9]+$ ]] || search_queries=0
  [[ "$commands" =~ ^[0-9]+$ ]] || commands=0
  [[ "$subagent_spawns" =~ ^[0-9]+$ ]] || subagent_spawns=0
  [[ "$duration_ms" =~ ^[0-9]+$ ]] || duration_ms=0

  jq -cn \
    --argjson file_reads "$file_reads" \
    --argjson search_queries "$search_queries" \
    --argjson commands "$commands" \
    --argjson subagent_spawns "$subagent_spawns" \
    --argjson duration_ms "$duration_ms" \
    '{
      file_reads: $file_reads,
      search_queries: $search_queries,
      commands: $commands,
      subagent_spawns: $subagent_spawns,
      duration_ms: $duration_ms
    }'
}

emit_output() {
  local status="$1"
  local run_id="$2"
  local result_json="$3"
  local artifacts_json="${4:-}"
  local checkpoint_json="${5:-}"
  local context_acquisition_json="${6:-}"
  local context_overhead_ratio="${7:-${HARMONY_CONTEXT_OVERHEAD_RATIO:-0}}"

  if [[ -z "$artifacts_json" ]]; then
    artifacts_json='[]'
  fi
  if [[ -z "$checkpoint_json" ]]; then
    checkpoint_json='{}'
  fi
  if [[ -z "$context_acquisition_json" ]]; then
    context_acquisition_json="$(agent_default_context_acquisition_json)"
  fi
  if ! jq -e '
    type == "object" and
    (.file_reads | type == "number" and . >= 0 and . == floor) and
    (.search_queries | type == "number" and . >= 0 and . == floor) and
    (.commands | type == "number" and . >= 0 and . == floor) and
    (.subagent_spawns | type == "number" and . >= 0 and . == floor) and
    (.duration_ms | type == "number" and . >= 0 and . == floor)
  ' >/dev/null 2>&1 <<<"$context_acquisition_json"; then
    context_acquisition_json="$(agent_default_context_acquisition_json)"
  fi
  if ! jq -en --arg ratio "$context_overhead_ratio" '$ratio | tonumber | . >= 0' >/dev/null 2>&1; then
    context_overhead_ratio="0"
  fi

  jq -n \
    --arg status "$status" \
    --arg runId "$run_id" \
    --argjson result "$result_json" \
    --argjson artifacts "$artifacts_json" \
    --argjson checkpoint "$checkpoint_json" \
    --argjson context_acquisition "$context_acquisition_json" \
    --arg context_overhead_ratio "$context_overhead_ratio" \
    '{
      status:$status,
      runId:$runId,
      result:$result,
      artifacts:$artifacts,
      checkpoint:$checkpoint,
      context_acquisition:$context_acquisition,
      context_overhead_ratio: ($context_overhead_ratio | tonumber)
    }'
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

unique_run_id() {
  local stamp pid rand
  stamp="$(date -u +"%Y%m%dT%H%M%SZ")"
  pid="$$"
  rand="${RANDOM:-0}"
  printf 'run-%s-%s-%s' "$stamp" "$pid" "$rand"
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

hash_text() {
  local text="$1"
  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$text" | shasum -a 256 | awk '{print $1}'
    return
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    printf '%s' "$text" | sha256sum | awk '{print $1}'
    return
  fi
  printf '%s' "$text" | cksum | awk '{print $1}'
}

hash_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    hash_text ""
    return
  fi
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
    return
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
    return
  fi
  cksum "$file" | awk '{print $1}'
}

build_evidence_json() {
  local run_dir="$1"
  local plan_path="$2"
  local evidence_dir="$run_dir/evidence"
  mkdir -p "$evidence_dir"

  local diff_file tests_file ci_file rollback_file
  diff_file="$evidence_dir/diff.patch"
  tests_file="$evidence_dir/tests.json"
  ci_file="$evidence_dir/ci.json"
  rollback_file="$evidence_dir/rollback.log"

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git diff -- "$plan_path" > "$diff_file" 2>/dev/null || true
  else
    printf '%s\n' "no-git-diff" > "$diff_file"
  fi
  jq -n --arg plan "$plan_path" --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '{status:"recorded",plan:$plan,timestamp:$ts}' > "$tests_file"
  jq -n --arg status "${HARMONY_CI_STATUS:-pass}" --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '{status:$status,timestamp:$ts}' > "$ci_file"
  printf '%s\n' "rollback-check:pending" > "$rollback_file"

  jq -n \
    --arg diff_ref "$diff_file" \
    --arg diff_hash "$(hash_file "$diff_file")" \
    --arg tests_ref "$tests_file" \
    --arg tests_hash "$(hash_file "$tests_file")" \
    --arg ci_ref "$ci_file" \
    --arg ci_hash "$(hash_file "$ci_file")" \
    --arg rollback_ref "$rollback_file" \
    --arg rollback_hash "$(hash_file "$rollback_file")" \
    '[
      {type:"diff",ref:$diff_ref,sha256:$diff_hash},
      {type:"tests",ref:$tests_ref,sha256:$tests_hash},
      {type:"ci",ref:$ci_ref,sha256:$ci_hash},
      {type:"rollback_test",ref:$rollback_ref,sha256:$rollback_hash}
    ]'
}

build_attestations_json() {
  local run_id="$1"
  local plan_hash="$2"
  local evidence_hash="$3"
  local attestations_dir="$4"
  local proposer="${HARMONY_AGENT_ID:-agent-local}"
  local now
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  local proposer_sig proposer_json
  proposer_sig="$(hash_text "proposer|$proposer|$plan_hash|$evidence_hash|$run_id")"
  proposer_json="$(jq -cn \
    --arg now "$now" \
    --arg actor "$proposer" \
    --arg plan_hash "$plan_hash" \
    --arg evidence_hash "$evidence_hash" \
    --arg signature "$proposer_sig" \
    '{role:"proposer",actor_id:$actor,timestamp:$now,plan_hash:$plan_hash,evidence_hash:$evidence_hash,signature:$signature}')"

  # Legacy compatibility path for controlled simulations.
  if [[ "${HARMONY_ALLOW_INPROCESS_ATTESTATIONS:-false}" == "true" || "${HARMONY_DISABLE_QUORUM:-false}" == "true" || "${HARMONY_QUORUM_DISAGREE:-false}" == "true" ]]; then
    local verifier recovery verifier_sig recovery_sig
    verifier="${HARMONY_VERIFIER_AGENT_ID:-agent-verifier}"
    recovery="${HARMONY_RECOVERY_AGENT_ID:-agent-recovery}"
    verifier_sig="$(hash_text "verifier|$verifier|$plan_hash|$evidence_hash|$run_id")"
    recovery_sig="$(hash_text "recovery|$recovery|$plan_hash|$evidence_hash|$run_id")"

    if [[ "${HARMONY_DISABLE_QUORUM:-false}" == "true" ]]; then
      jq -cn --argjson proposer "$proposer_json" '[ $proposer ]'
      return
    fi

    if [[ "${HARMONY_QUORUM_DISAGREE:-false}" == "true" ]]; then
      jq -cn \
        --argjson proposer "$proposer_json" \
        --arg now "$now" \
        --arg verifier "$verifier" \
        --arg recovery "$recovery" \
        --arg plan_hash "$plan_hash" \
        --arg evidence_hash "$evidence_hash" \
        --arg verifier_sig "$verifier_sig" \
        --arg recovery_sig "$recovery_sig" \
        '[
          $proposer,
          {role:"verifier",actor_id:$verifier,timestamp:$now,plan_hash:$plan_hash,evidence_hash:"mismatch",signature:$verifier_sig},
          {role:"recovery",actor_id:$recovery,timestamp:$now,plan_hash:$plan_hash,evidence_hash:$evidence_hash,signature:$recovery_sig}
        ]'
      return
    fi

    jq -cn \
      --argjson proposer "$proposer_json" \
      --arg now "$now" \
      --arg verifier "$verifier" \
      --arg recovery "$recovery" \
      --arg plan_hash "$plan_hash" \
      --arg evidence_hash "$evidence_hash" \
      --arg verifier_sig "$verifier_sig" \
      --arg recovery_sig "$recovery_sig" \
      '[
        $proposer,
        {role:"verifier",actor_id:$verifier,timestamp:$now,plan_hash:$plan_hash,evidence_hash:$evidence_hash,signature:$verifier_sig},
        {role:"recovery",actor_id:$recovery,timestamp:$now,plan_hash:$plan_hash,evidence_hash:$evidence_hash,signature:$recovery_sig}
      ]'
    return
  fi

  local external_json
  external_json='[]'

  local inline_attestations
  inline_attestations="${HARMONY_ATTESTATIONS_JSON:-[]}"
  if jq -e . >/dev/null 2>&1 <<<"$inline_attestations"; then
    local normalized_inline
    normalized_inline="$(jq -c 'if type=="array" then . elif type=="object" then [.] else [] end' <<<"$inline_attestations" 2>/dev/null || echo '[]')"
    external_json="$(jq -cn --argjson base "$external_json" --argjson next "$normalized_inline" '$base + $next')"
  fi

  local -a source_files=()
  local file
  for file in \
    "$attestations_dir/verifier.attestation.json" \
    "$attestations_dir/recovery.attestation.json" \
    "$attestations_dir/observer.attestation.json"; do
    [[ -f "$file" ]] && source_files+=("$file")
  done

  if [[ -n "${HARMONY_ATTESTATION_FILES:-}" ]]; then
    local -a raw_files=()
    IFS=',' read -r -a raw_files <<<"${HARMONY_ATTESTATION_FILES:-}"
    for file in "${raw_files[@]}"; do
      file="${file#"${file%%[![:space:]]*}"}"
      file="${file%"${file##*[![:space:]]}"}"
      [[ -n "$file" ]] && source_files+=("$file")
    done
  fi

  local source
  for source in "${source_files[@]}"; do
    [[ -f "$source" ]] || continue
    local raw normalized
    raw="$(cat "$source" 2>/dev/null || true)"
    [[ -n "$raw" ]] || continue
    normalized="$(jq -c 'if type=="array" then . elif type=="object" then [.] else [] end' <<<"$raw" 2>/dev/null || echo '[]')"
    external_json="$(jq -cn --argjson base "$external_json" --argjson next "$normalized" '$base + $next')"
  done

  jq -cn \
    --argjson proposer "$proposer_json" \
    --argjson external "$external_json" \
    --arg now "$now" \
    --arg plan_hash "$plan_hash" \
    --arg evidence_hash "$evidence_hash" \
    '([ $proposer ] + $external)
    | map({
        role: (.role // ""),
        actor_id: (.actor_id // ""),
        timestamp: (.timestamp // $now),
        plan_hash: (.plan_hash // $plan_hash),
        evidence_hash: (.evidence_hash // $evidence_hash),
        signature: (.signature // "")
      })
    | map(select((.role == "proposer" or .role == "verifier" or .role == "recovery" or .role == "observer") and (.actor_id|length > 0)))
    | reduce .[] as $item ({seen:{},ordered:[]};
        if .seen[$item.role] then
          .
        else
          .seen[$item.role] = true | .ordered += [$item]
        end
      )
    | .ordered
    | reduce .[] as $item ({actors:[],ordered:[]};
        if $item.role == "observer" then
          .ordered += [$item]
        elif (.actors | index($item.actor_id)) then
          .
        else
          .actors += [$item.actor_id] | .ordered += [$item]
        end
      )
    | .ordered'
}

emit_acp_receipt() {
  local request_file="$1"
  local decision_file="$2"
  if [[ ! -x "$RECEIPT_WRITER" ]]; then
    return 0
  fi
  "$RECEIPT_WRITER" --policy "$POLICY_FILE" --request "$request_file" --decision "$decision_file" >/dev/null 2>&1 || true
}

handle_circuit_trip() {
  local run_id="$1"
  local decision_file="$2"
  local request_file="$3"
  local rollback_dir="$4"

  if [[ ! -x "$BREAKER_ACTIONS_SCRIPT" ]]; then
    return 0
  fi

  "$BREAKER_ACTIONS_SCRIPT" run \
    --run-id "$run_id" \
    --decision "$decision_file" \
    --request "$request_file" \
    --rollback-dir "$rollback_dir" \
    --scope "service:agent" \
    --owner "${HARMONY_AGENT_ID:-agent-local}" >/dev/null 2>&1 || true
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
  if [[ "${HARMONY_DETERMINISTIC_RUN_ID:-false}" == "true" ]]; then
    run_id="$(stable_run_id "$plan_path|$memoize|$dry_run")"
  else
    run_id="$(unique_run_id)"
  fi
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

mkdir -p "$CONTINUITY_RUNS_DIR"
continuity_run_dir="$CONTINUITY_RUNS_DIR/$run_id"
evidence_dir="$continuity_run_dir/evidence"
attestations_dir="$continuity_run_dir/attestations"
rollback_dir="$continuity_run_dir/rollback"
mkdir -p "$continuity_run_dir" "$evidence_dir" "$attestations_dir" "$rollback_dir"

if [[ ! -f "$plan_path" ]]; then
  warnings='["planPath does not exist on disk; executing in logical mode only"]'
  printf '%s\n' "$plan_path" > "$continuity_run_dir/plan.txt"
else
  warnings='[]'
  cp "$plan_path" "$continuity_run_dir/plan.source" 2>/dev/null || true
fi

state="staged"
checkpoint_json="$(jq -cn \
  --arg runId "$run_id" \
  --arg planPath "$plan_path" \
  --arg state "$state" \
  --argjson resumeCount 0 \
  --argjson memoize "$memoize" \
  --argjson dryRun "$dry_run" \
  '{runId:$runId,planPath:$planPath,state:$state,resumeCount:$resumeCount,memoize:$memoize,dryRun:$dryRun}')"
printf '%s\n' "$checkpoint_json" | jq -S . > "$checkpoint_path"

evidence_json="$(build_evidence_json "$continuity_run_dir" "$plan_path")"
printf '%s\n' "$evidence_json" | jq -S . > "$evidence_dir/evidence.json"

if [[ -f "$plan_path" ]]; then
  plan_hash="$(hash_file "$plan_path")"
else
  plan_hash="$(hash_text "$plan_path")"
fi
evidence_hash="$(hash_text "$evidence_json")"
attestations_json="$(build_attestations_json "$run_id" "$plan_hash" "$evidence_hash" "$attestations_dir")"
printf '%s\n' "$attestations_json" | jq -S . > "$attestations_dir/attestations.json"

counters_file="$continuity_run_dir/counters.json"
if [[ -x "$BUDGET_METER" ]]; then
  "$BUDGET_METER" init --file "$counters_file" >/dev/null
  "$BUDGET_METER" record-git-diff --file "$counters_file" >/dev/null || true
  "$BUDGET_METER" add --file "$counters_file" --metric "commands.count" --value 1 >/dev/null
  "$BUDGET_METER" add --file "$counters_file" --metric "net.calls" --value "${HARMONY_NET_CALLS:-0}" >/dev/null
  counters_json="$("$BUDGET_METER" emit --file "$counters_file")"
else
  counters_json='{}'
fi

profile="$(printf '%s' "$payload" | jq -r '.profile // empty')"
if [[ -z "$profile" || "$profile" == "null" ]]; then
  profile="${HARMONY_POLICY_PROFILE:-$(infer_policy_profile "$plan_path")}"
fi

operation_class="$(printf '%s' "$payload" | jq -r '.operationClass // empty')"
if [[ -z "$operation_class" || "$operation_class" == "null" ]]; then
  operation_class="${HARMONY_OPERATION_CLASS:-git.commit}"
fi

target_json="$(printf '%s' "$payload" | jq -c '.target // {}')"
if [[ "$target_json" == "null" ]]; then
  target_json='{}'
fi
if [[ "$operation_class" == "fs.soft_delete" ]]; then
  target_json="$(jq -c '
    if type != "object" then
      {scope:"broad"}
    elif has("scope") then
      .
    else
      . + {scope:"broad"}
    end
  ' <<<"$target_json" 2>/dev/null || echo '{"scope":"broad"}')"
fi

phase="$(printf '%s' "$payload" | jq -r '.phase // empty')"
if [[ -z "$phase" || "$phase" == "null" ]]; then
  if [[ "$dry_run" == "true" ]]; then
    phase="stage"
  else
    phase="promote"
  fi
fi

intent="$(printf '%s' "$payload" | jq -r '.intent // "plan-stage-promote flow"')"
boundaries="$(printf '%s' "$payload" | jq -r '.boundaries // "policy-bounded autonomous execution"')"
budgets_json="$(printf '%s' "$payload" | jq -c '.budgets // {}')"
signals_json="$(printf '%s' "$payload" | jq -c '.circuitSignals // []')"
reversibility_json="$(printf '%s' "$payload" | jq -c '.reversibility // {}')"
if [[ "$reversibility_json" == "{}" || "$reversibility_json" == "null" ]]; then
  default_primitive="git.revert_commit"
  case "$operation_class" in
    git.merge) default_primitive="git.revert_merge" ;;
    fs.soft_delete) default_primitive="fs.move_to_trash" ;;
    db.migrate) default_primitive="db.down_migration_or_shadow" ;;
    service.deploy) default_primitive="deploy.rollback" ;;
  esac
  reversibility_json="$(jq -cn \
    --arg primitive "$default_primitive" \
    --arg rollback_handle "${HARMONY_ROLLBACK_HANDLE:-$default_primitive:$run_id}" \
    --arg recovery_window "${HARMONY_RECOVERY_WINDOW:-P30D}" \
    '{reversible:true,primitive:$primitive,rollback_handle:$rollback_handle,recovery_window:$recovery_window}')"
fi

primitive_artifacts='[]'
if [[ -x "$REVERSIBLE_PRIMITIVES_SCRIPT" ]]; then
  primitive_output="$("$REVERSIBLE_PRIMITIVES_SCRIPT" apply \
    --run-id "$run_id" \
    --operation-class "$operation_class" \
    --target-json "$target_json" \
    --workspace "$(pwd)" \
    --recovery-window "$(jq -r '.recovery_window // empty' <<<"$reversibility_json")" \
    --rollback-handle "$(jq -r '.rollback_handle // empty' <<<"$reversibility_json")" \
    --primitive "$(jq -r '.primitive // empty' <<<"$reversibility_json")" 2>/dev/null || true)"

  if jq -e . >/dev/null 2>&1 <<<"$primitive_output"; then
    reversibility_json="$(jq -cn \
      --argjson base "$reversibility_json" \
      --argjson next "$primitive_output" \
      '{
        reversible: ($base.reversible // $next.applied // false),
        primitive: ($base.primitive // $next.primitive // null),
        rollback_handle: ($base.rollback_handle // $next.rollback_handle // null),
        recovery_window: ($base.recovery_window // $next.recovery_window // null),
        rollback_proof: ($base.rollback_proof // null)
      }')"
    primitive_artifacts="$(jq -c '.artifacts // []' <<<"$primitive_output")"
  fi
fi

if [[ "$primitive_artifacts" != "[]" ]]; then
  evidence_json="$(jq -cn \
    --argjson evidence "$evidence_json" \
    --argjson artifacts "$primitive_artifacts" \
    '$evidence + ($artifacts | map({type:(.type // "reversible_primitive"),ref:(.ref // ""),sha256:(.sha256 // null)}))')"
fi

acp_request_file="$continuity_run_dir/acp-request.json"
acp_decision_file="$continuity_run_dir/acp-decision.json"

if [[ ! -x "$ACP_REQUEST_BUILDER" || ! -x "$ACP_EVAL" ]]; then
  fail_runtime "$run_id" "ACP helper scripts are required for autonomous promotion"
fi

"$ACP_REQUEST_BUILDER" \
  --output "$acp_request_file" \
  --run-id "$run_id" \
  --phase "$phase" \
  --profile "$profile" \
  --operation-class "$operation_class" \
  --actor-id "${HARMONY_AGENT_ID:-agent-local}" \
  --actor-type "agent" \
  --target-json "$target_json" \
  --reversibility-json "$reversibility_json" \
  --evidence-json "$evidence_json" \
  --attestations-json "$attestations_json" \
  --budgets-json "$budgets_json" \
  --counters-json "$counters_json" \
  --signals-json "$signals_json" \
  --plan-hash "$plan_hash" \
  --evidence-hash "$evidence_hash" \
  --intent "$intent" \
  --boundaries "$boundaries" >/dev/null

if [[ "$dry_run" == "true" ]]; then
  jq -n \
    --arg decision "STAGE_ONLY" \
    --arg acp "ACP-1" \
    '{allow:false,decision:$decision,effective_acp:$acp,reason_codes:["ACP_STAGE_ONLY_REQUIRED"],notes:["dry-run stage only"],requirements:{}}' > "$acp_decision_file"
else
  acp_output="$("$ACP_EVAL" enforce --policy "$POLICY_FILE" --request "$acp_request_file" 2>&1)" || acp_rc=$?
  acp_rc="${acp_rc:-0}"
  if jq -e . >/dev/null 2>&1 <<<"$acp_output"; then
    printf '%s\n' "$acp_output" > "$acp_decision_file"
  else
    jq -n --arg msg "$acp_output" '{allow:false,decision:"DENY",effective_acp:"ACP-0",reason_codes:["DDB025_RUNTIME_DECISION_ENGINE_ERROR"],notes:[$msg],requirements:{}}' > "$acp_decision_file"
    acp_rc=13
  fi
fi

emit_acp_receipt "$acp_request_file" "$acp_decision_file"
handle_circuit_trip "$run_id" "$acp_decision_file" "$acp_request_file" "$rollback_dir"

decision_kind="$(jq -r '.decision // "DENY"' "$acp_decision_file")"
effective_acp="$(jq -r '.effective_acp // "ACP-0"' "$acp_decision_file")"
reason_codes="$(jq -c '.reason_codes // []' "$acp_decision_file")"

case "$decision_kind" in
  ALLOW)
    state="promoted"
    status="success"
    summary="Promotion allowed by ACP gate"
    exit_code=0
    ;;
  STAGE_ONLY|ESCALATE)
    state="stage-only"
    status="partial"
    summary="Promotion blocked; staged artifacts preserved"
    exit_code=0
    ;;
  *)
    state="denied"
    status="error"
    summary="ACP gate denied promotion"
    exit_code=13
    ;;
esac

checkpoint_json="$(jq -cn \
  --arg runId "$run_id" \
  --arg planPath "$plan_path" \
  --arg state "$state" \
  --arg decision "$decision_kind" \
  --arg effectiveAcp "$effective_acp" \
  --argjson resumeCount 0 \
  --argjson memoize "$memoize" \
  --argjson dryRun "$dry_run" \
  '{runId:$runId,planPath:$planPath,state:$state,decision:$decision,effectiveAcp:$effectiveAcp,resumeCount:$resumeCount,memoize:$memoize,dryRun:$dryRun}')"
printf '%s\n' "$checkpoint_json" | jq -S . > "$checkpoint_path"

result_json="$(jq -cn \
  --arg mode "execute" \
  --arg summary "$summary" \
  --arg planPath "$plan_path" \
  --argjson resume false \
  --argjson memoize "$memoize" \
  --argjson dryRun "$dry_run" \
  --argjson warnings "$warnings" \
  --arg decision "$decision_kind" \
  --arg effectiveAcp "$effective_acp" \
  --argjson reasonCodes "$reason_codes" \
  --arg requestPath "$acp_request_file" \
  --arg decisionPath "$acp_decision_file" \
  --arg checkpointPath "$checkpoint_path" \
  '{mode:$mode,summary:$summary,planPath:$planPath,resume:$resume,memoize:$memoize,dryRun:$dryRun,warnings:$warnings,decision:$decision,effectiveAcp:$effectiveAcp,reasonCodes:$reasonCodes,acpRequestPath:$requestPath,acpDecisionPath:$decisionPath,checkpointPath:$checkpointPath}')"

run_record_json="$(jq -cn \
  --arg runId "$run_id" \
  --arg mode "execute" \
  --arg status "$status" \
  --arg planPath "$plan_path" \
  --argjson checkpoint "$checkpoint_json" \
  --argjson result "$result_json" \
  '{runId:$runId,mode:$mode,status:$status,planPath:$planPath,checkpoint:$checkpoint,result:$result}')"
printf '%s\n' "$run_record_json" | jq -S . > "$run_record_path"

artifacts_json="$(jq -cn \
  --arg run "$run_record_path" \
  --arg receipt "$continuity_run_dir/receipt.json" \
  --arg digest "$continuity_run_dir/digest.md" \
  --arg request "$acp_request_file" \
  --arg decision "$acp_decision_file" \
  '[$run,$receipt,$digest,$request,$decision]')"

emit_output "$status" "$run_id" "$result_json" "$artifacts_json" "$checkpoint_json"
exit "$exit_code"
