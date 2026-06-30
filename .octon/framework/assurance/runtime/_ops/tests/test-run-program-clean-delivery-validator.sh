#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh"
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

mutate_receipt_expect_fail() {
  local description="$1" expression="$2" target
  target="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.yml"
  cp "$TMP_DIR/valid-receipt.yml" "$target"
  yq -i "$expression" "$target"
  expect_fail "$description" "$VALIDATOR" --receipt "$target"
}

command -v yq >/dev/null 2>&1 || {
  echo "[ERROR] yq is required" >&2
  exit 1
}

cat >"$TMP_DIR/valid-receipt.yml" <<'YAML'
schema_version: proposal-program-delivery-receipt-v1
receipt_id: test-run-program-clean-delivery-receipt
emitted_at: "2026-06-29T00:00:00Z"
profile:
  profile_id: test-proposal-program-delivery-profile
  profile_ref: .octon/state/evidence/validation/proposals/proposal-program-delivery/profile.yml
  validated_at: "2026-06-29T00:00:00Z"
  verdict: pass
target_program:
  path: .octon/inputs/exploratory/proposals/architecture/example-proposal-program-delivery
  status: accepted
  accepted_review_digest: sha256:0000000000000000000000000000000000000000000000000000000000000000
target_outcome: cleaned
actual_outcome: cleaned
order_policy:
  canonical_order_ref: child-before-parent-delivery
  requested_order_ref: child-before-parent-delivery
  operator_requested_alternative_order: false
  override_receipt_required: false
  override_receipt_ref: not-applicable
  override_receipt_status: not-required
delivery_readiness_preflight:
  receipt_ref: .octon/state/evidence/runs/workflows/test/delivery-readiness-preflight.yml
  fresh: true
  verdict: pass
  checked_git_write: true
  checked_worktree_cleanliness: true
  checked_review_freshness: true
  checked_child_receipt_compatibility: true
  checked_tooling: true
  checked_route_legality: true
  checked_generated_freshness: true
  blockers: []
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
feature_catalog_drift:
  receipt_ref: .octon/state/evidence/runs/workflows/test/feature-catalog-drift-receipt.yml
  validator_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh
  fresh: true
  verdict: pass
  outcome: documented-change
  unresolved_count: 0
  affected_feature_ids:
    - run-first-runtime-lifecycle
  required_documentation_actions: []
  child_receipt_refs:
    - .octon/inputs/exploratory/proposals/architecture/example-child/support/feature-catalog-drift-receipt.yml
  authority_notes:
    - parent drift summary is evidence-only and does not replace child receipts
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
    - .octon/state/evidence/validation/proposals/proposal-program-delivery/governed-mechanism-integration.log
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
  evidence_ref: .octon/state/evidence/validation/proposals/proposal-program-delivery/terminal-current-state-proof.log
  fresh_after_last_mutation: true
  verdict: pass
worktree_hygiene:
  evidence_ref: .octon/state/evidence/validation/proposals/proposal-program-delivery/worktree-hygiene.log
  dirty_worktree: false
  verdict: pass
clean_worktree_route:
  source_dirty: false
  source_stale: false
  selected_route: current-clean-worktree
  route_owned_worktree_ref: not-required
  include_path_classification_ref: not-required
  include_path_classification_valid: false
  broad_stage_all_requested: false
lifecycle_postmortem:
  required: false
  status: not-required
  evaluation_ref: not-required
  report_ref: not-required
  readiness_summary_ref: not-required
  evidence_map_ref: not-required
  digest_bound_evidence_refs: []
  verdict: not-required
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

expect_pass "static clean delivery validator chain" "$VALIDATOR"
expect_pass "valid cleaned delivery receipt" "$VALIDATOR" --receipt "$TMP_DIR/valid-receipt.yml"

mutate_receipt_expect_fail "non-cleaned delivery outcome" '.actual_outcome = "landed"'
mutate_receipt_expect_fail "stale terminal proof" '.terminal_current_state_proof.fresh_after_last_mutation = false'
mutate_receipt_expect_fail "aggregate evidence substitution" '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts = true'

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
