#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

WRITER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/write-terminal-closeout-local-evidence.sh"
STATE_MACHINE_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh"
HOSTED_LANDING_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
LIFECYCLE_ALIGNMENT_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/branch-no-pr-delivery-receipt-builder.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

SHA="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
PRE_SHA="9999999999999999999999999999999999999999"
SOURCE_BRANCH="chore/fixture-no-pr"
LANDING_AUTH="$TMP_ROOT/landing-authorization.json"
CLEANUP_AUTH="$TMP_ROOT/branch-cleanup-authorization.json"
RECEIPT="$TMP_ROOT/change-receipt.json"
INVALID_RECEIPT="$TMP_ROOT/invalid-missing-hosted-landing.json"
INVALID_MISSING_PUBLISHABLE_RECEIPT="$TMP_ROOT/invalid-missing-publishable-evidence.json"
TERMINAL_PROOF="$TMP_ROOT/terminal-current-state-proof.yml"

require_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  grep -Fq -- "$needle" "$file" || {
    echo "[ERROR] missing $label in ${file#$ROOT_DIR/}" >&2
    exit 1
  }
  echo "[OK] $label"
}

cat >"$LANDING_AUTH" <<JSON
{
  "schema_version": "branch-landing-authorization-v1",
  "authorization_id": "fixture-hosted-no-pr-authorization",
  "authorization_result": "approved",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "cleaned",
  "remote": "origin",
  "target_branch": "main",
  "source_branch": "$SOURCE_BRANCH",
  "source_ref": "$SHA",
  "remote_source_ref": "$SHA",
  "target_pre_ref": "$PRE_SHA",
  "provider_ruleset_ref": "github-ruleset:fixture-no-pr",
  "no_pr_required": true,
  "preflight_status": "passed",
  "required_check_refs": [
    "route_neutral_closeout_validation@$SHA",
    "branch_naming_validation@$SHA",
    "route_aware_autonomy_validation@$SHA",
    "exact_source_sha_validation@$SHA"
  ],
  "allow_empty_check_set": false,
  "rollback_handle": "$SHA",
  "host_controls_not_bypassed": true,
  "runtime_safety_boundary": "Fixture authorization does not bypass platform, sandbox, provider, or host controls.",
  "created_at": "2026-06-24T00:00:00Z"
}
JSON

cat >"$CLEANUP_AUTH" <<JSON
{
  "schema_version": "branch-cleanup-authorization-v1",
  "authorization_id": "fixture-branch-cleanup-authorization",
  "authorization_result": "approved",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "cleaned",
  "remote": "origin",
  "base_branch": "main",
  "source_branch": "$SOURCE_BRANCH",
  "landed_ref": "$SHA",
  "origin_main_ref": "$SHA",
  "local_main_ref": "$SHA",
  "local_main_synced_to_origin_main": true,
  "origin_main_contains_landed_ref": true,
  "local_main_contains_landed_ref": true,
  "source_branch_contained_in_origin_main": true,
  "source_branch_protected": false,
  "open_pr_count": 0,
  "rollback_handle": "$SHA",
  "cleanup_policy_allowed": true,
  "delete_remote_requested": true,
  "remove_worktrees_requested": true,
  "sync_main_requested": true,
  "host_controls_not_bypassed": true,
  "runtime_safety_boundary": "Fixture cleanup authorization does not bypass platform, sandbox, provider, or host controls.",
  "created_at": "2026-06-24T00:00:00Z"
}
JSON

cat >"$RECEIPT" <<JSON
{
  "schema_version": "change-receipt-v1",
  "change_id": "fixture-branch-no-pr-cleaned",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "cleaned",
  "lifecycle_outcome": "cleaned",
  "outcome_intent": "attempt-cleaned-closeout",
  "intent": "Fixture cleaned branch-no-PR receipt for receipt builder regression coverage.",
  "scope": {
    "summary": "Fixture branch-no-PR hosted landing, sync, cleanup, and cleaned proof.",
    "diff_refs": [
      "origin/$SOURCE_BRANCH@$SHA"
    ]
  },
  "source_branch_ref": "$SOURCE_BRANCH",
  "target_branch_ref": "origin/main@$SHA",
  "remote_branch_ref": "origin/$SOURCE_BRANCH@$SHA",
  "landing_authorization_ref": "$LANDING_AUTH",
  "cleanup_authorization_ref": "$CLEANUP_AUTH",
  "hosted_landing": {
    "remote": "origin",
    "target_branch": "main",
    "source_branch": "$SOURCE_BRANCH",
    "source_ref": "$SHA",
    "target_pre_ref": "$PRE_SHA",
    "target_post_ref": "$SHA",
    "validated_ref": "$SHA",
    "required_check_refs": [
      "route_neutral_closeout_validation@$SHA",
      "branch_naming_validation@$SHA",
      "route_aware_autonomy_validation@$SHA",
      "exact_source_sha_validation@$SHA"
    ],
    "provider_ruleset_ref": "github-ruleset:fixture-no-pr",
    "push_refspec": "$SHA:refs/heads/main",
    "fast_forward_only": true
  },
  "landing_evaluation": {
    "status": "succeeded",
    "provider_ruleset_ref": "github-ruleset:fixture-no-pr",
    "source_ref": "$SHA",
    "target_ref": "origin/main@$SHA",
    "evidence_refs": [
      "$LANDING_AUTH",
      "hosted-no-pr-preflight@$SHA"
    ]
  },
  "source_branch_integration": {
    "source_branch_ref": "$SOURCE_BRANCH",
    "source_ref": "$SHA",
    "landed_ref": "$SHA",
    "origin_main_ref": "$SHA",
    "integrated": true,
    "method": "fast-forward",
    "evidence_refs": [
      "$LANDING_AUTH",
      "$CLEANUP_AUTH",
      "origin-main-contains-source@$SHA"
    ]
  },
  "landed_ref": "$SHA",
  "main_alignment": {
    "local_main_ref": "$SHA",
    "origin_main_ref": "$SHA",
    "landed_ref": "$SHA",
    "aligned": true,
    "origin_fetch_evidence_ref": "git-fetch-origin-main@$SHA",
    "local_main_sync_evidence_ref": "git-fast-forward-local-main@$SHA",
    "origin_main_contains_landed_ref": true,
    "local_main_contains_landed_ref": true,
    "verification_ref": "final-main-sync@$SHA"
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "completed",
  "cleanup_evidence_refs": [
    "$CLEANUP_AUTH",
    "branch-cleanup@$SHA"
  ],
  "publishable_evidence_receipt_refs": [
    {
      "receipt_ref": ".octon/state/evidence/validation/fixture/publishable-receipt.json",
      "schema_ref": ".octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json",
      "disclosure_tier": "repo-publishable",
      "claim_scope_ref": "fixture-branch-no-pr-cleaned",
      "receipt_digest": "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      "raw_evidence_not_published": true
    }
  ],
  "source_branch_cleanup": {
    "status": "completed",
    "local_branch": "$SOURCE_BRANCH",
    "remote_branch": "origin/$SOURCE_BRANCH",
    "evidence_refs": [
      "$CLEANUP_AUTH",
      "branch-cleanup@$SHA"
    ]
  },
  "validation_evidence_refs": [
    "test-branch-no-pr-delivery-receipt-builder.sh"
  ],
  "durable_history": {
    "kind": "commit",
    "ref": "$SHA",
    "branch": "$SOURCE_BRANCH"
  },
  "rollback_handle": {
    "kind": "revert-commit",
    "ref": "$SHA",
    "instructions": "Revert fixture landed commit $SHA if post-landing verification fails."
  },
  "stateful_closeout": {
    "state_machine_version": "change-closeout-state-machine-v1",
    "initial_inventory_ref": "fixture-inventory@$SHA",
    "residue_classification_ref": "fixture-residue-classification@$SHA",
    "phase_exit_refs": [
      "fixture-phase-exit@$SHA"
    ],
    "cleanup_decision_refs": [
      "$CLEANUP_AUTH"
    ],
    "safe_cleanup_evidence_class": "origin-main-containment",
    "hosted_landing_refs": [
      "$LANDING_AUTH"
    ],
    "branch_cleanup_refs": [
      "$CLEANUP_AUTH"
    ],
    "final_verification_ref": "fixture-final-main-sync@$SHA"
  },
  "closeout_outcome": "completed",
  "created_at": "2026-06-24T00:00:00Z"
}
JSON

cat >"$TERMINAL_PROOF" <<YAML
schema_version: lifecycle-terminal-current-state-proof-v1
proof_id: terminal-proof-fixture-branch-no-pr-cleaned
observed_at: "2026-06-24T00:00:00Z"
change_id: fixture-branch-no-pr-cleaned
lifecycle_outcome: cleaned
non_authority_classification: retained-evidence-only
final_refs:
  head_ref: $SHA
  main_ref: $SHA
  origin_main_ref: $SHA
  landed_ref: $SHA
alignment:
  head_equals_local_main: true
  local_main_equals_origin_main: true
  origin_main_contains_landed_ref: true
  local_main_contains_landed_ref: true
worktree:
  status: clean
  status_ref: evidence://validation/git-status.log
  residue_counts:
    staged: 0
    unstaged: 0
    untracked: 0
cleanup_classifier_ref: evidence://validation/residue-classifier.log
validator_refs:
  - validator: test-branch-no-pr-delivery-receipt-builder
    command: bash .octon/framework/assurance/runtime/_ops/tests/test-branch-no-pr-delivery-receipt-builder.sh
    cwd: $ROOT_DIR
    runtime: bash
    exit_code: 0
    evidence_ref: evidence://validation/terminal-proof-fixture.log
evidence_refs:
  - evidence://validation/terminal-proof-fixture.log
YAML

require_text "hosted_landing" "$WRITER" "writer emits hosted_landing"
require_text "source_branch_integration" "$WRITER" "writer emits source_branch_integration"
require_text "validate-hosted-no-pr-landing.sh" "$WRITER" "writer invokes hosted no-PR validator"
require_text "validate-change-closeout-lifecycle-alignment.sh" "$WRITER" "writer invokes lifecycle alignment validator"
require_text "validate-evidence-disclosure-tiers.sh" "$WRITER" "writer invokes disclosure-tier validator"

"$STATE_MACHINE_VALIDATOR" --receipt "$RECEIPT"
"$HOSTED_LANDING_VALIDATOR" --receipt "$RECEIPT" --skip-live-remote
"$LIFECYCLE_ALIGNMENT_VALIDATOR" --receipt "$RECEIPT"

jq 'del(.hosted_landing)' "$RECEIPT" >"$INVALID_RECEIPT"
if "$HOSTED_LANDING_VALIDATOR" --receipt "$INVALID_RECEIPT" --skip-live-remote >/dev/null 2>&1; then
  echo "[ERROR] hosted no-PR validator accepted a landed/cleaned branch-no-PR receipt without hosted_landing" >&2
  exit 1
fi
echo "[OK] hosted no-PR validator rejects missing hosted_landing"

jq 'del(.publishable_evidence_receipt_refs)' "$RECEIPT" >"$INVALID_MISSING_PUBLISHABLE_RECEIPT"
if "$WRITER" \
  --change-id fixture-branch-no-pr-cleaned \
  --proof "$TERMINAL_PROOF" \
  --receipt "$INVALID_MISSING_PUBLISHABLE_RECEIPT" \
  --landed-ref "$SHA" >/tmp/octon-writer-snapshot-negative.log 2>&1; then
  echo "[ERROR] writer snapshot mode accepted hosted/shared cleaned receipt without publishable evidence" >&2
  cat /tmp/octon-writer-snapshot-negative.log >&2
  exit 1
fi
grep -Fq "missing publishable authorization evidence" /tmp/octon-writer-snapshot-negative.log
rm -f /tmp/octon-writer-snapshot-negative.log
echo "[OK] writer snapshot mode refuses missing publishable hosted/shared evidence"

echo "Validation summary: errors=0"
