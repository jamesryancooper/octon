#!/usr/bin/env bash
set -euo pipefail

WORKFLOW_ID="${OCTON_CI_WORKFLOW_ID:-unknown-workflow}"
RUN_ROOT=".octon/state/evidence/runs/ci/${WORKFLOW_ID}-$(date -u +%Y%m%dT%H%M%SZ)"
RECEIPT_PATH="$RUN_ROOT/execution-receipt.json"
OUTCOME_PATH="$RUN_ROOT/outcome.json"

mkdir -p "$RUN_ROOT"

requested_mode="${OCTON_REQUESTED_POLICY_MODE:-${OCTON_EFFECTIVE_POLICY_MODE:-hard-enforce}}"
protected="${OCTON_PROTECTED_EXECUTION:-true}"
expect_ai="${EXPECT_AI_GATE_ENFORCE:-false}"
expect_autonomy="${EXPECT_AUTONOMY_POLICY_ENFORCE:-false}"
ai_gate="${AI_GATE_ENFORCE:-false}"
autonomy="${AUTONOMY_POLICY_ENFORCE:-false}"
effective_mode="${OCTON_EFFECTIVE_POLICY_MODE:-}"

errors=()

if [[ -z "$effective_mode" ]]; then
  errors+=("OCTON_EFFECTIVE_POLICY_MODE must be exported from a live control-plane signal")
fi

if [[ "$protected" == "true" && "$effective_mode" != "hard-enforce" ]]; then
  errors+=("protected execution requires hard-enforce")
fi

if [[ "$expect_ai" == "true" && "${ai_gate,,}" != "true" ]]; then
  errors+=("AI_GATE_ENFORCE must be true for protected workflow")
fi

if [[ "$expect_autonomy" == "true" && "${autonomy,,}" != "true" ]]; then
  errors+=("AUTONOMY_POLICY_ENFORCE must be true for protected workflow")
fi

status="succeeded"
error_text=""
if [[ ${#errors[@]} -gt 0 ]]; then
  status="failed"
  error_text="$(printf '%s; ' "${errors[@]}")"
fi

jq -n \
  --arg workflow_id "$WORKFLOW_ID" \
  --arg requested_mode "$requested_mode" \
  --arg effective_mode "$effective_mode" \
  --arg protected "$protected" \
  --arg ai_gate "$ai_gate" \
  --arg autonomy "$autonomy" \
  --arg status "$status" \
  --arg error_text "$error_text" \
  '{
    schema_version: "execution-receipt-v1",
    request_id: ("ci-" + $workflow_id),
    grant_id: ("ci-grant-" + $workflow_id),
    target_id: $workflow_id,
    action_type: "protected_ci_guard",
    path_type: "ci",
    environment_class: (if $protected == "true" then "protected" else "development" end),
    requested_capabilities: ["ci.protected.guard"],
    granted_capabilities: ["ci.protected.guard"],
    policy_mode_requested: $requested_mode,
    policy_mode_effective: $effective_mode,
    decision: (if $status == "failed" then "DENY" else "ALLOW" end),
    reason_codes: (if $status == "failed" then ["PROTECTED_EXECUTION_REQUIRES_HARD_ENFORCE"] else ["EXECUTION_AUTHORIZED"] end),
    side_effects: {
      touched_scope: [],
      shell_commands: [],
      network_targets: [],
      publications: [],
      branch_mutations: [],
      dangerous_flags_blocked: []
    },
    timestamps: {
      started_at: (now | todateiso8601),
      completed_at: (now | todateiso8601)
    },
    evidence_links: {
      outcome: "outcome.json"
    },
    ai_review_enforced: ($ai_gate == "true"),
    autonomy_policy_enforced: ($autonomy == "true")
  }' > "$RECEIPT_PATH"

jq -n \
  --arg status "$status" \
  --arg error_text "$error_text" \
  '{
    status: $status,
    error: (if $error_text == "" then null else $error_text end)
  }' > "$OUTCOME_PATH"

if [[ "$status" == "failed" ]]; then
  echo "$error_text" >&2
  exit 1
fi
