#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
PROFILE_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh"
RECEIPT_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh"
WORKFLOW_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

pass_count=0
fail_count=0

pass() {
  echo "[OK] $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "[ERROR] $1"
  fail_count=$((fail_count + 1))
}

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] $1 is required" >&2
    exit 1
  fi
}

expect_pass() {
  local description="$1"
  shift
  if "$@" >"$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.log" 2>&1; then
    pass "$description"
  else
    cat "$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.log"
    fail "$description"
  fi
}

expect_fail() {
  local description="$1"
  shift
  if "$@" >"$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.log" 2>&1; then
    cat "$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.log"
    fail "$description unexpectedly passed"
  else
    pass "$description rejected"
  fi
}

mutate_profile_expect_fail() {
  local description="$1" expression="$2" target
  target="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.yml"
  cp "$TMP_DIR/valid-profile.yml" "$target"
  yq -i "$expression" "$target"
  expect_fail "$description" "$PROFILE_VALIDATOR" --profile "$target"
}

mutate_receipt_expect_fail() {
  local description="$1" expression="$2" target
  target="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.yml"
  cp "$TMP_DIR/valid-receipt.yml" "$target"
  yq -i "$expression" "$target"
  expect_fail "$description" "$RECEIPT_VALIDATOR" --receipt "$target"
}

require_tool yq

cat >"$TMP_DIR/valid-profile.yml" <<'YAML'
schema_version: proposal-program-delivery-profile-v1
profile_id: test-proposal-program-delivery-profile
created_at: "2026-06-14T00:00:00Z"
target_program_path: .octon/inputs/exploratory/proposals/architecture/example-proposal-program-delivery
target_outcome: cleaned
route_preference:
  work_unit_route: branch-no-pr
  landing_route: branch-no-pr
  pr_creation_allowed: false
pr_policy:
  mode: forbid-pr
  allow_pr_creation: false
  fallback_to_pr: false
stash_policy:
  mode: forbidden
  preserve_unrelated_work: true
child_execution:
  replan_after_material_changes: true
  target_owned_receipts_required: true
  parent_summary_satisfies_child_receipts: false
required_proposal_validators:
  - validate-proposal-review-gate.sh
  - validate-proposal-implementation-readiness.sh
  - validate-architecture-proposal.sh
required_implementation_validators:
  - validate-proposal-implementation-conformance.sh
  - validate-proposal-post-implementation-drift.sh
  - validate-proposal-lifecycle-terminal-freshness.sh
publication_checks:
  owning_publishers_only: true
  generated_outputs_are_non_authority: true
  freshness_validator: validate-capability-publication-state.sh
  direct_generated_output_edits_allowed: false
mechanism_integration_checks:
  required_when_applicable: true
  receipt_required_when_required: true
closeout_requirements:
  packet_closeout_required: true
  archive_lifecycle_required: true
  change_closeout_required: true
  delegate_git_mutation_to_change_closeout: true
hygiene_requirements:
  cleanup_authorization_required: true
  classification_alone_authorizes_deletion: false
terminal_proof_requirements:
  terminal_current_state_proof_required: true
  worktree_hygiene_required: true
final_sync_requirements:
  main_origin_landed_ref_equality_required: true
non_authority_boundaries:
  proposal_local_files: non-authority
  generated_prompts: non-authority
  generated_outputs: derived-only-non-authority
  dashboards: non-authority
  chat_or_model_memory: non-authority
YAML

cat >"$TMP_DIR/valid-receipt.yml" <<'YAML'
schema_version: proposal-program-delivery-receipt-v1
receipt_id: test-proposal-program-delivery-receipt
emitted_at: "2026-06-14T00:00:00Z"
profile:
  profile_id: test-proposal-program-delivery-profile
  profile_ref: .octon/state/evidence/validation/proposals/proposal-program-delivery/20260614T000000Z/delivery-profile.yml
  validated_at: "2026-06-14T00:00:00Z"
  verdict: pass
target_program:
  path: .octon/inputs/exploratory/proposals/architecture/example-proposal-program-delivery
  status: accepted
  accepted_review_digest: sha256:0000000000000000000000000000000000000000000000000000000000000000
target_outcome: cleaned
actual_outcome: cleaned
parent_program_lifecycle:
  workflow_ref: .octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml
  receipt_ref: .octon/state/evidence/runs/workflows/test/proposal-program-delivery-receipt.yml
  verdict: pass
  replanned_after_material_changes: true
child_packet_coverage:
  parent_summary_satisfies_child_receipts: false
  children:
    - path: .octon/inputs/exploratory/proposals/architecture/example-child
      status: implemented
      required_receipts:
        - support/implementation-run.md
        - support/implementation-conformance-review.md
        - support/post-implementation-drift-churn-review.md
      fresh: true
child_receipts:
  implementation_run:
    - .octon/inputs/exploratory/proposals/architecture/example-child/support/implementation-run.md
  implementation_conformance:
    - .octon/inputs/exploratory/proposals/architecture/example-child/support/implementation-conformance-review.md
  post_implementation_drift_churn:
    - .octon/inputs/exploratory/proposals/architecture/example-child/support/post-implementation-drift-churn-review.md
  packet_closeout:
    - .octon/inputs/exploratory/proposals/architecture/example-child/support/proposal-closeout.md
  archive:
    - .octon/state/evidence/runs/workflows/test/archive-receipt.yml
  change_closeout:
    - .octon/state/evidence/runs/skills/closeout-change/test/change-closeout-receipt.yml
implementation_conformance:
  receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-proposal-program-delivery/support/implementation-conformance-review.md
  fresh: true
  verdict: pass
post_implementation_drift_churn:
  receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-proposal-program-delivery/support/post-implementation-drift-churn-review.md
  fresh: true
  verdict: pass
generated_publication:
  validator: validate-capability-publication-state.sh
  publisher_refs:
    - .octon/framework/capabilities/_ops/scripts/publish-capabilities.sh
  fresh: true
  direct_generated_output_edit_used: false
governed_mechanism_integration:
  required: true
  verdict: pass
  receipt_refs:
    - .octon/state/evidence/validation/proposals/proposal-program-delivery/20260614T000000Z/governed-mechanism-integration.log
  not_applicable_rationale: ""
lifecycle_residue_cleanup:
  cleanup_performed: true
  cleanup_authorization_refs:
    - .octon/state/evidence/runs/skills/repo-hygiene-cleanup/test/cleanup-authorization.json
  unauthorized_deletion_performed: false
change_closeout:
  route: branch-no-pr
  receipt_ref: .octon/state/evidence/runs/skills/closeout-change/test/change-closeout-receipt.yml
  verdict: pass
branch_authorization:
  landing_performed: true
  landing_authorization_ref: .octon/state/evidence/runs/skills/closeout-change/test/landing-authorization.json
  branch_cleanup_performed: true
  cleanup_authorization_ref: .octon/state/evidence/runs/skills/closeout-change/test/branch-cleanup-authorization.json
  branch_deleted: true
final_sync:
  landed_ref: 0000000000000000000000000000000000000000
  local_main_ref: 0000000000000000000000000000000000000000
  origin_main_ref: 0000000000000000000000000000000000000000
  main_origin_landed_ref_equal: true
terminal_current_state_proof:
  evidence_ref: .octon/state/evidence/validation/proposals/proposal-program-delivery/20260614T000000Z/terminal-current-state-proof.log
  fresh_after_last_mutation: true
  verdict: pass
worktree_hygiene:
  evidence_ref: .octon/state/evidence/validation/proposals/proposal-program-delivery/20260614T000000Z/worktree-hygiene.log
  dirty_worktree: false
  verdict: pass
blockers: []
non_authority_classification:
  proposal_local_files: non-authority
  generated_prompts: non-authority
  generated_outputs: derived-only-non-authority
  dashboards: non-authority
  chat_or_model_memory: non-authority
target_owned_evidence_policy:
  target_owned_receipts_required: true
  aggregate_receipt_replaces_target_owned_receipts: false
YAML

expect_pass "schema-only profile validator" "$PROFILE_VALIDATOR"
expect_pass "valid profile" "$PROFILE_VALIDATOR" --profile "$TMP_DIR/valid-profile.yml"
expect_pass "schema-only receipt validator" "$RECEIPT_VALIDATOR"
expect_pass "valid receipt" "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/valid-receipt.yml"
expect_pass "workflow validator" "$WORKFLOW_VALIDATOR"

mutate_profile_expect_fail "missing profile gate declarations" 'del(.publication_checks)'
mutate_profile_expect_fail "branch-no-pr PR fallback forbidden" '.pr_policy.fallback_to_pr = true'
mutate_profile_expect_fail "stash policy cannot widen" '.stash_policy.mode = "allowed"'
mutate_profile_expect_fail "stash policy required" 'del(.stash_policy)'

mutate_receipt_expect_fail "parent summary substituted for child receipts" '.child_packet_coverage.parent_summary_satisfies_child_receipts = true'
mutate_receipt_expect_fail "stale child receipts" '.child_packet_coverage.children[0].fresh = false'
mutate_receipt_expect_fail "missing implementation conformance" 'del(.implementation_conformance.receipt_ref)'
mutate_receipt_expect_fail "missing drift churn receipt" 'del(.post_implementation_drift_churn.receipt_ref)'
mutate_receipt_expect_fail "stale generated publication evidence" '.generated_publication.fresh = false'
mutate_receipt_expect_fail "missing governed mechanism integration receipt" '.governed_mechanism_integration.required = true | .governed_mechanism_integration.receipt_refs = []'
mutate_receipt_expect_fail "branch-no-pr landing without authorization" '.branch_authorization.landing_performed = true | .branch_authorization.landing_authorization_ref = "not-applicable"'
mutate_receipt_expect_fail "branch cleanup without authorization" '.branch_authorization.branch_cleanup_performed = true | .branch_authorization.cleanup_authorization_ref = "not-applicable"'
mutate_receipt_expect_fail "repo hygiene deletion without cleanup authorization" '.lifecycle_residue_cleanup.cleanup_performed = true | .lifecycle_residue_cleanup.cleanup_authorization_refs = []'
mutate_receipt_expect_fail "missing terminal current-state proof" 'del(.terminal_current_state_proof.evidence_ref)'
mutate_receipt_expect_fail "dirty worktree cleaned overclaim" '.worktree_hygiene.dirty_worktree = true'
mutate_receipt_expect_fail "main origin landed ref mismatch" '.final_sync.main_origin_landed_ref_equal = false'
mutate_receipt_expect_fail "generated prompt used as authority" '.non_authority_classification.generated_prompts = "authority"'
mutate_receipt_expect_fail "proposal-local file used as authority" '.non_authority_classification.proposal_local_files = "authority"'
mutate_receipt_expect_fail "aggregate receipt replacing target-owned receipts" '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts = true'

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
