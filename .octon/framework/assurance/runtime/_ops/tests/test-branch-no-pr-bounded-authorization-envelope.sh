#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-branch-no-pr-delivery-authorization-envelope.sh"
PREFLIGHT="$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/git/git-branch-mutation-preflight.sh"
DELIVERY_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/branch-no-pr-envelope.XXXXXX")"
trap 'chmod -R u+w "$TMP_ROOT" >/dev/null 2>&1 || true; rm -rf "$TMP_ROOT"' EXIT

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1" >&2
  exit 1
}

require_text() {
  local needle="$1" file="$2" label="$3"
  grep -Fq -- "$needle" "$file" || fail "missing $label in $file"
  pass "$label"
}

ENVELOPE="$TMP_ROOT/envelope.yml"
cat >"$ENVELOPE" <<'YAML'
schema_version: branch-no-pr-delivery-authorization-envelope-v1
envelope_id: fixture-branch-no-pr-envelope
selected_route: branch-no-pr
target_lifecycle_outcome: cleaned
source_branch: chore/fixture-branch-no-pr
target_branch: main
remote: origin
allowed_effects:
  branch_commit: true
  branch_push: true
  hosted_no_pr_landing: true
  sync: true
  branch_cleanup: true
forbidden_effects:
  pr_creation: true
  pr_update: true
  pr_merge: true
  force_push: true
  unapproved_cleanup: true
rollback_handle: fixture-rollback-handle
required_validators:
  - validate-proposal-program-delivery-receipt.sh
  - validate-hosted-no-pr-landing.sh
staged_proof_locks:
  commit_before_push:
    required: true
    evidence_ref_field: branch_local_commit_ref
  push_before_landing:
    required: true
    evidence_ref_field: remote_branch_ref
  landing_before_sync:
    required: true
    evidence_ref_field: landing_authorization_ref
  sync_before_cleanup:
    required: true
    evidence_ref_field: final_sync.local_main_ref
  cleanup_before_cleaned:
    required: true
    evidence_ref_field: branch_authorization.cleanup_authorization_ref
git_mutation_preflight:
  required: true
  script_ref: .octon/framework/execution-roles/_ops/scripts/git/git-branch-mutation-preflight.sh
  blocked_classes:
    - git-index-write-denied
    - git-ref-write-denied
    - git-index-lock-present
    - git-ref-rollback-failed
  non_authorizing: true
authority_boundaries:
  parent_summary_replaces_child_evidence: false
  archive_authorizes_delivery: false
  preflight_authorizes_side_effects: false
  generated_outputs_authority: derived-only
YAML

"$VALIDATOR" --envelope "$ENVELOPE"

REPO="$TMP_ROOT/repo"
mkdir -p "$REPO"
git -C "$REPO" init -q
git -C "$REPO" config user.email "octon@example.invalid"
git -C "$REPO" config user.name "Octon Test"
printf 'initial\n' >"$REPO/file.txt"
git -C "$REPO" add file.txt
git -C "$REPO" commit -q -m "test: initial"

PASS_EVIDENCE="$TMP_ROOT/git-preflight-pass.json"
"$PREFLIGHT" --repo "$REPO" --check-index --check-ref --evidence "$PASS_EVIDENCE"
jq -e '.status == "passed" and .authority_effects.delivery == false and .authority_effects.branch_deletion == false' "$PASS_EVIDENCE" >/dev/null ||
  fail "writable git preflight must pass without authorizing side effects"
pass "writable git preflight passes and remains non-authorizing"

chmod u-w "$REPO/.git"
INDEX_EVIDENCE="$TMP_ROOT/git-preflight-index-blocked.json"
if "$PREFLIGHT" --repo "$REPO" --check-index --evidence "$INDEX_EVIDENCE" >"$TMP_ROOT/index.out" 2>"$TMP_ROOT/index.err"; then
  fail "read-only .git index preflight unexpectedly passed"
fi
chmod u+w "$REPO/.git"
jq -e '.status == "blocked" and .blocker_class == "git-index-write-denied" and .authority_effects.delivery == false' "$INDEX_EVIDENCE" >/dev/null ||
  fail "read-only index blocker evidence must be typed and non-authorizing"
require_text "git-index-write-denied" "$TMP_ROOT/index.err" "typed index blocker stderr"

chmod -R u-w "$REPO/.git/refs"
REF_EVIDENCE="$TMP_ROOT/git-preflight-ref-blocked.json"
if "$PREFLIGHT" --repo "$REPO" --check-ref --evidence "$REF_EVIDENCE" >"$TMP_ROOT/ref.out" 2>"$TMP_ROOT/ref.err"; then
  fail "read-only .git refs preflight unexpectedly passed"
fi
chmod -R u+w "$REPO/.git/refs"
jq -e '.status == "blocked" and .blocker_class == "git-ref-write-denied" and .authority_effects.cleanup == false' "$REF_EVIDENCE" >/dev/null ||
  fail "read-only ref blocker evidence must be typed and non-authorizing"
require_text "git-ref-write-denied" "$TMP_ROOT/ref.err" "typed ref blocker stderr"

printf 'unclassified dirty source\n' >"$REPO/untracked.txt"
CLEAN_ROUTE_EVIDENCE="$TMP_ROOT/git-preflight-clean-route-blocked.json"
if "$PREFLIGHT" --repo "$REPO" --require-clean-route-classification --check-index --evidence "$CLEAN_ROUTE_EVIDENCE" >"$TMP_ROOT/clean-route.out" 2>"$TMP_ROOT/clean-route.err"; then
  fail "dirty source clean-route preflight unexpectedly passed without include-path classification"
fi
jq -e '.status == "blocked" and .blocker_class == "worktree-dirty-unclassified" and .clean_worktree_route.selected_route == "blocked" and .authority_effects.delivery == false' "$CLEAN_ROUTE_EVIDENCE" >/dev/null ||
  fail "dirty source clean-route blocker evidence must be typed and non-authorizing"
require_text "worktree-dirty-unclassified" "$TMP_ROOT/clean-route.err" "typed clean-route blocker stderr"

CLASSIFICATION="$TMP_ROOT/include-path-classification.yml"
cat >"$CLASSIFICATION" <<'YAML'
schema_version: include-path-classification-v1
selected_route: route-owned-clean-worktree
included_paths:
  - untracked.txt
YAML
CLASSIFIED_EVIDENCE="$TMP_ROOT/git-preflight-clean-route-classified.json"
"$PREFLIGHT" --repo "$REPO" --require-clean-route-classification --include-path-classification "$CLASSIFICATION" --check-index --evidence "$CLASSIFIED_EVIDENCE"
jq -e '.status == "passed" and .source_posture.dirty == true and .clean_worktree_route.selected_route == "route-owned-clean-worktree" and .clean_worktree_route.include_path_classification_present == true' "$CLASSIFIED_EVIDENCE" >/dev/null ||
  fail "dirty source with include-path classification must select route-owned clean worktree"
pass "dirty source with include-path classification selects route-owned clean worktree"
rm "$REPO/untracked.txt"

BLOCKED_RECEIPT="$TMP_ROOT/blocked-delivery-receipt.yml"
cat >"$BLOCKED_RECEIPT" <<YAML
schema_version: proposal-program-delivery-receipt-v1
receipt_id: fixture-blocked-git-index-write-denied
emitted_at: "2026-06-24T00:00:00Z"
profile:
  profile_id: fixture
  profile_ref: fixture-profile.yml
  validated_at: "2026-06-24T00:00:00Z"
  verdict: pass
target_program:
  path: fixture/programs/operator-free-lifecycle-delivery-autonomy-hardening
  status: archived
  accepted_review_digest: sha256:fixture
target_outcome: cleaned
actual_outcome: blocked
order_policy:
  canonical_order_ref: child-before-parent-delivery
  requested_order_ref: child-before-parent-delivery
  operator_requested_alternative_order: false
  override_receipt_required: false
  override_receipt_ref: not-applicable
  override_receipt_status: not-required
delivery_readiness_preflight:
  receipt_ref: $INDEX_EVIDENCE
  fresh: true
  verdict: blocked
  checked_git_write: true
  checked_worktree_cleanliness: true
  checked_review_freshness: true
  checked_child_receipt_compatibility: true
  checked_tooling: true
  checked_route_legality: true
  checked_generated_freshness: true
  blockers:
    - git-index-write-denied
parent_program_lifecycle:
  workflow_ref: .octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml
  receipt_ref: fixture-parent-terminal.yml
  verdict: pass
  replanned_after_material_changes: true
child_packet_coverage:
  parent_summary_satisfies_child_receipts: false
  children:
    - path: fixture/children/branch-no-pr-bounded-authorization-envelope
      status: archived
      required_receipts:
        - support/implementation-run.md
      fresh: true
child_receipts:
  implementation_run:
    - fixture-implementation-run.md
  implementation_conformance:
    - fixture-implementation-conformance.md
  post_implementation_drift_churn:
    - fixture-drift.md
  packet_closeout:
    - fixture-closeout.md
  archive:
    - fixture-archive.yml
  change_closeout:
    - fixture-change-closeout.json
implementation_conformance:
  receipt_ref: fixture-implementation-conformance.md
  verdict: pass
  fresh: true
post_implementation_drift_churn:
  receipt_ref: fixture-drift.md
  verdict: pass
  fresh: true
feature_catalog_drift:
  receipt_ref: fixture-feature-catalog-drift.yml
  validator_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh
  fresh: true
  verdict: pass
  outcome: documented-change
  unresolved_count: 0
  affected_feature_ids:
    - run-first-runtime-lifecycle
  required_documentation_actions: []
  child_receipt_refs:
    - fixture-child-feature-catalog-drift.yml
  authority_notes:
    - parent drift summary is evidence-only and does not replace child receipts
generated_publication:
  validator: validate-publication-freshness-gates.sh
  publisher_refs:
    - fixture-publication
  fresh: true
  direct_generated_output_edit_used: false
governed_mechanism_integration:
  required: true
  verdict: pass
  receipt_refs:
    - fixture-envelope.yml
  not_applicable_rationale: ""
lifecycle_residue_cleanup:
  cleanup_performed: false
  cleanup_authorization_refs: []
  unauthorized_deletion_performed: false
change_closeout:
  route: branch-no-pr
  receipt_ref: fixture-change-closeout-blocked.json
  verdict: blocked
branch_authorization:
  landing_performed: false
  landing_authorization_ref: not-applicable
  branch_cleanup_performed: false
  cleanup_authorization_ref: not-applicable
  branch_deleted: false
final_sync:
  landed_ref: not-run
  local_main_ref: not-run
  origin_main_ref: not-run
  main_origin_landed_ref_equal: false
terminal_current_state_proof:
  evidence_ref: not-run
  fresh_after_last_mutation: false
  verdict: not-run
worktree_hygiene:
  evidence_ref: not-run
  dirty_worktree: true
  verdict: not-run
delivery_evidence_index:
  ref: not-run
  schema_version: proposal-program-delivery-evidence-index-v1
  validator_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh
  validator_verdict: not-run
  evidence_only: true
  source_receipt_digest_bound: true
  circular_digest_required: false
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
blockers:
  - class: git-index-write-denied
    evidence_ref: $INDEX_EVIDENCE
    status: open
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

"$DELIVERY_VALIDATOR" --receipt "$BLOCKED_RECEIPT"
pass "blocked delivery receipt validates with typed git blocker and no side effects"

INVALID_RECEIPT="$TMP_ROOT/invalid-blocked-delivery-receipt.yml"
cp "$BLOCKED_RECEIPT" "$INVALID_RECEIPT"
yq -i '.branch_authorization.landing_performed = true' "$INVALID_RECEIPT"
if "$DELIVERY_VALIDATOR" --receipt "$INVALID_RECEIPT" >/dev/null 2>&1; then
  fail "blocked delivery receipt with claimed landing side effect unexpectedly validated"
fi
pass "blocked delivery receipt cannot claim landing side effects"

echo "Validation summary: errors=0"
