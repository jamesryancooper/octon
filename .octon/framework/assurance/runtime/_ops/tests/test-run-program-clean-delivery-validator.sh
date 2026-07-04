#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh"
GENERATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-program-delivery-evidence-index.sh"
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
  local description="$1" expression="$2" target_root receipt
  target_root="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}-root"
  cp -R "$VALID_ROOT" "$target_root"
  receipt="$(receipt_path "$target_root")"
  yq -i "$expression" "$receipt"
  expect_fail "$description" "$VALIDATOR" --receipt "$receipt"
}

mutate_index_expect_fail() {
  local description="$1" expression="$2" target_root index
  target_root="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}-root"
  cp -R "$VALID_ROOT" "$target_root"
  index="$target_root/$INDEX_REL"
  yq -i "$expression" "$index"
  expect_fail "$description" "$VALIDATOR" --receipt "$(receipt_path "$target_root")"
}

mutate_compact_expect_fail() {
  local description="$1" expression="$2" target
  target="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}-compact.yml"
  cp "$COMPACT_RECEIPT" "$target"
  yq -i "$expression" "$target"
  expect_fail "$description" "$VALIDATOR" --compact-receipt "$target"
}

mutate_no_dispatch_expect_fail() {
  local description="$1" expression="$2" target
  target="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}-no-dispatch-ledger.yml"
  cp "$NO_DISPATCH_LEDGER" "$target"
  yq -i "$expression" "$target"
  expect_fail "$description" "$VALIDATOR" --no-dispatch-ledger "$target"
}

mutate_stale_retirement_expect_fail() {
  local description="$1" expression="$2" target_root receipt
  target_root="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}-root"
  cp -R "$VALID_ROOT" "$target_root"
  receipt="$(receipt_path "$target_root")"
  yq -i "$expression" "$receipt"
  expect_fail "$description" "$VALIDATOR" --receipt "$receipt"
}

write_file() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$@" >"$path"
}

receipt_path() {
  printf '%s/%s\n' "$1" "$RECEIPT_REL"
}

make_fixture_files() {
  local root="$1"

  mkdir -p "$root/.octon/framework/constitution/contracts/retention"
  cp "$ROOT_DIR/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml" \
    "$root/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml"
  cp "$ROOT_DIR/.octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json" \
    "$root/.octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json"

  write_file "$root/.octon/state/evidence/validation/proposals/program-clean/profile.yml" "profile: pass"
  write_file "$root/.octon/state/evidence/local/README.md" "local evidence marker"
  write_file "$root/.octon/state/evidence/runs/workflows/program-clean/parent-lifecycle.yml" "parent_lifecycle: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-child/support/implementation-run.md" "verdict: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-child/support/implementation-conformance-review.md" "verdict: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-child/support/post-implementation-drift-churn-review.md" "verdict: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-child/support/proposal-closeout.md" "verdict: pass"
  write_file "$root/.octon/state/evidence/runs/workflows/program-clean/archive-receipt.yml" "archive: pass"
  write_file "$root/.octon/state/evidence/runs/skills/closeout-change/program-clean/change-closeout-receipt.yml" "change_closeout: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-program/support/implementation-conformance-review.md" "verdict: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-program/support/post-implementation-drift-churn-review.md" "verdict: pass"
  write_file "$root/.octon/framework/capabilities/_ops/scripts/publish-capabilities.sh" "#!/usr/bin/env bash" "exit 0"
  write_file "$root/.octon/state/evidence/validation/proposals/program-clean/governed-mechanism-integration.log" "governed mechanism integration pass"
  write_file "$root/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/program-clean/cleanup-authorization.json" '{"authorized":true}'
  write_file "$root/.octon/state/evidence/runs/skills/closeout-change/program-clean/landing-authorization.json" '{"authorized":true}'
  write_file "$root/.octon/state/evidence/runs/skills/closeout-change/program-clean/branch-cleanup-authorization.json" '{"authorized":true}'
  write_file "$root/.octon/state/evidence/runs/skills/closeout-change/program-clean/stale-branch-retirement-authorization.json" '{"authorized":true}'
  write_file "$root/.octon/state/evidence/runs/skills/closeout-change/program-clean/dirty-stale-worktree-retirement.yml" "verdict: pass"
  write_file "$root/.octon/state/evidence/runs/skills/closeout-change/program-clean/stale-branch-post-delete-verification.yml" "verdict: pass"
  write_file "$root/.octon/state/evidence/runs/skills/closeout-change/program-clean/dirty-stale-branch-post-delete-verification.yml" "verdict: pass"
  write_file "$root/.octon/state/evidence/local/terminal-proof/program-clean/terminal-current-state-proof.yml" "terminal: pass"
  write_file "$root/.octon/state/evidence/local/terminal-proof/program-clean/worktree-hygiene.yml" "worktree: clean"
}

write_receipt() {
  local root="$1"
  mkdir -p "$(dirname "$(receipt_path "$root")")"
  cat >"$(receipt_path "$root")" <<'YAML'
schema_version: proposal-program-delivery-receipt-v1
receipt_id: test-run-program-clean-delivery-receipt
emitted_at: "2026-06-29T00:00:00Z"
profile:
  profile_id: test-proposal-program-delivery-profile
  profile_ref: .octon/state/evidence/validation/proposals/program-clean/profile.yml
  validated_at: "2026-06-29T00:00:00Z"
  verdict: pass
target_program:
  path: .octon/inputs/exploratory/proposals/architecture/example-program
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
  receipt_ref: .octon/state/evidence/runs/workflows/program-clean/delivery-readiness-preflight.yml
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
  receipt_ref: .octon/state/evidence/runs/workflows/program-clean/parent-lifecycle.yml
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
    - .octon/state/evidence/runs/workflows/program-clean/archive-receipt.yml
  change_closeout:
    - .octon/state/evidence/runs/skills/closeout-change/program-clean/change-closeout-receipt.yml
implementation_conformance:
  receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-program/support/implementation-conformance-review.md
  fresh: true
  verdict: pass
post_implementation_drift_churn:
  receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-program/support/post-implementation-drift-churn-review.md
  fresh: true
  verdict: pass
feature_catalog_drift:
  receipt_ref: .octon/state/evidence/runs/workflows/program-clean/feature-catalog-drift-receipt.yml
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
    - .octon/state/evidence/validation/proposals/program-clean/governed-mechanism-integration.log
  not_applicable_rationale: ""
lifecycle_residue_cleanup:
  cleanup_performed: true
  cleanup_authorization_refs:
    - .octon/state/evidence/runs/skills/repo-hygiene-cleanup/program-clean/cleanup-authorization.json
  unauthorized_deletion_performed: false
change_closeout:
  route: branch-no-pr
  receipt_ref: .octon/state/evidence/runs/skills/closeout-change/program-clean/change-closeout-receipt.yml
  verdict: pass
branch_authorization:
  landing_performed: true
  landing_authorization_ref: .octon/state/evidence/runs/skills/closeout-change/program-clean/landing-authorization.json
  branch_cleanup_performed: true
  cleanup_authorization_ref: .octon/state/evidence/runs/skills/closeout-change/program-clean/branch-cleanup-authorization.json
  branch_deleted: true
stale_branch_retirement:
  required: true
  evidence_only: true
  detection_is_deletion_authority: false
  remote_mutation_authorized_by_delivery: false
  cleanup_reports:
    branches:
      - branch: chore/dirty-anchor
        role_label: source-dirty-anchor
        ref: "1111111111111111111111111111111111111111"
        upstream_state: none
        pr_state: none
        protected_status: false
        worktree_attachment: current-dirty-source
        unique_commit_status: no-unique-commits
        disposition: retained
        reason: dirty anchor preserved until local-worktree retirement evidence exists
      - branch: chore/program-delivery
        role_label: route-owned-delivery-branch
        ref: "2222222222222222222222222222222222222222"
        upstream_state: none
        pr_state: none
        protected_status: false
        worktree_attachment: route-owned
        unique_commit_status: delivery-branch
        disposition: retained
        reason: route-owned delivery branch remains the surviving branch
      - branch: chore/stale-no-unique
        role_label: retired-stale
        ref: "3333333333333333333333333333333333333333"
        upstream_state: none
        pr_state: none
        protected_status: false
        worktree_attachment: none
        unique_commit_status: no-unique-commits
        disposition: retired
        reason: no unique commits and no ownership blockers
      - branch: release/protected
        role_label: retained-protected
        ref: "4444444444444444444444444444444444444444"
        upstream_state: none
        pr_state: none
        protected_status: true
        worktree_attachment: none
        unique_commit_status: not-evaluated
        disposition: retained
        reason: protected branch names are never stale-retired
      - branch: chore/dirty-stale
        role_label: retired-stale
        ref: "5555555555555555555555555555555555555555"
        upstream_state: none
        pr_state: none
        protected_status: false
        worktree_attachment: switched-from-dirty-source
        unique_commit_status: no-unique-commits
        disposition: retired
        reason: dirty checked-out branch retired after local-worktree disposition
  retirement_receipts:
    - candidate_branch: chore/stale-no-unique
      role_label: retired-stale
      stale_ref: "3333333333333333333333333333333333333333"
      surviving_branch: chore/program-delivery
      surviving_ref: "2222222222222222222222222222222222222222"
      merge_base: "2222222222222222222222222222222222222222"
      unique_commit_count: 0
      no_unique_commits: true
      upstream_state: none
      remote_ref_state: absent
      pr_state: none
      protected_status: false
      active_worktree_dependency: false
      dirty_residue:
        checked_out: false
        disposition: not-applicable
        authorization_ref: not-required
        safe_switch_completed: false
      authorization:
        receipt_ref: .octon/state/evidence/runs/skills/closeout-change/program-clean/stale-branch-retirement-authorization.json
        switch_authorized: false
        local_delete_authorized: true
        remote_mutation_status: not-authorized
        remote_mutation_receipt_ref: not-required
        remote_mutation_current: false
      post_delete_verification:
        verification_ref: .octon/state/evidence/runs/skills/closeout-change/program-clean/stale-branch-post-delete-verification.yml
        local_branch_absent: true
        surviving_ref_aligned: true
      rollback:
        stale_ref_retained: true
        recreate_command: git branch chore/stale-no-unique 3333333333333333333333333333333333333333
      blockers: []
    - candidate_branch: chore/dirty-stale
      role_label: retired-stale
      stale_ref: "5555555555555555555555555555555555555555"
      surviving_branch: chore/program-delivery
      surviving_ref: "2222222222222222222222222222222222222222"
      merge_base: "2222222222222222222222222222222222222222"
      unique_commit_count: 0
      no_unique_commits: true
      upstream_state: none
      remote_ref_state: absent
      pr_state: none
      protected_status: false
      active_worktree_dependency: false
      dirty_residue:
        checked_out: true
        disposition: local-worktree-retired
        authorization_ref: .octon/state/evidence/runs/skills/closeout-change/program-clean/dirty-stale-worktree-retirement.yml
        safe_switch_completed: true
      authorization:
        receipt_ref: .octon/state/evidence/runs/skills/closeout-change/program-clean/stale-branch-retirement-authorization.json
        switch_authorized: true
        local_delete_authorized: true
        remote_mutation_status: not-authorized
        remote_mutation_receipt_ref: not-required
        remote_mutation_current: false
      post_delete_verification:
        verification_ref: .octon/state/evidence/runs/skills/closeout-change/program-clean/dirty-stale-branch-post-delete-verification.yml
        local_branch_absent: true
        surviving_ref_aligned: true
      rollback:
        stale_ref_retained: true
        recreate_command: git branch chore/dirty-stale 5555555555555555555555555555555555555555
      blockers: []
final_sync:
  landed_ref: 0000000000000000000000000000000000000000
  local_main_ref: 0000000000000000000000000000000000000000
  origin_main_ref: 0000000000000000000000000000000000000000
  main_origin_landed_ref_equal: true
terminal_current_state_proof:
  evidence_ref: .octon/state/evidence/local/terminal-proof/program-clean/terminal-current-state-proof.yml
  fresh_after_last_mutation: true
  verdict: pass
worktree_hygiene:
  evidence_ref: .octon/state/evidence/local/terminal-proof/program-clean/worktree-hygiene.yml
  dirty_worktree: false
  verdict: pass
retained_state_report:
  delivered_branch:
    row_kind: delivered_branch
    subjects:
      - origin/main@0000000000000000000000000000000000000000
    disposition: delivered
    evidence_refs:
      - .octon/state/evidence/local/terminal-proof/program-clean/terminal-current-state-proof.yml
    retention_or_blocker_reason: landed ref is contained in origin/main and local main
  route_owned_delivery_branch:
    row_kind: route_owned_delivery_branch
    subjects:
      - chore/program-delivery
    disposition: deleted
    evidence_refs:
      - .octon/state/evidence/runs/skills/closeout-change/program-clean/branch-cleanup-authorization.json
    retention_or_blocker_reason: route-owned delivery branch was deleted after landing
  source_dirty_anchor_branches:
    row_kind: source_dirty_anchor_branches
    subjects:
      - none
    disposition: not-applicable
    evidence_refs:
      - none
    retention_or_blocker_reason: fixture has no retained dirty anchor branches
  retained_local_branches:
    row_kind: retained_local_branches
    subjects:
      - none
    disposition: not-applicable
    evidence_refs:
      - none
    retention_or_blocker_reason: fixture has no retained local branches
  retained_worktrees:
    row_kind: retained_worktrees
    subjects:
      - none
    disposition: not-applicable
    evidence_refs:
      - none
    retention_or_blocker_reason: fixture has no retained worktrees
  retained_required_evidence:
    row_kind: retained_required_evidence
    subjects:
      - .octon/state/evidence/local/terminal-proof/program-clean/terminal-current-state-proof.yml
    disposition: retained
    evidence_refs:
      - .octon/state/evidence/local/terminal-proof/program-clean/terminal-current-state-proof.yml
    retention_or_blocker_reason: terminal proof remains required closeout evidence
  local_private_evidence:
    row_kind: local_private_evidence
    subjects:
      - none
    disposition: not-applicable
    evidence_refs:
      - none
    retention_or_blocker_reason: fixture has no retained local-private evidence
  generated_diagnostics:
    row_kind: generated_diagnostics
    subjects:
      - none
    disposition: not-applicable
    evidence_refs:
      - none
    retention_or_blocker_reason: fixture has no generated diagnostics
  deleted_residue:
    row_kind: deleted_residue
    subjects:
      - chore/program-delivery
    disposition: deleted
    evidence_refs:
      - .octon/state/evidence/runs/skills/closeout-change/program-clean/branch-cleanup-authorization.json
    retention_or_blocker_reason: branch cleanup deleted the route-owned delivery branch
  excluded_residue:
    row_kind: excluded_residue
    subjects:
      - none
    disposition: not-applicable
    evidence_refs:
      - none
    retention_or_blocker_reason: fixture excludes no residue
  manual_review_residue:
    row_kind: manual_review_residue
    subjects:
      - none
    disposition: not-applicable
    evidence_refs:
      - none
    retention_or_blocker_reason: fixture leaves no manual-review residue
  remote_mutation_status:
    row_kind: remote_mutation_status
    subjects:
      - origin/main@0000000000000000000000000000000000000000
    disposition: authorized
    evidence_refs:
      - .octon/state/evidence/runs/skills/closeout-change/program-clean/landing-authorization.json
    retention_or_blocker_reason: origin/main mutation was authorized for the fixture
  archive_authorization:
    row_kind: archive_authorization
    subjects:
      - none
    disposition: not-authorized
    evidence_refs:
      - none
    retention_or_blocker_reason: Change closeout does not authorize archive movement
  final_current_state_proof:
    row_kind: final_current_state_proof
    subjects:
      - .octon/state/evidence/local/terminal-proof/program-clean/terminal-current-state-proof.yml
    disposition: verified
    evidence_refs:
      - .octon/state/evidence/local/terminal-proof/program-clean/terminal-current-state-proof.yml
    retention_or_blocker_reason: terminal proof verifies the cleaned fixture state
delivery_evidence_index:
  ref: .octon/state/evidence/runs/workflows/program-clean/proposal-program-delivery-evidence-index.yml
  schema_version: proposal-program-delivery-evidence-index-v1
  validator_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh
  validator_verdict: pass
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
}

make_valid_root() {
  local root="$1"
  make_fixture_files "$root"
  write_receipt "$root"
  if ! bash "$GENERATOR" \
    --root "$root" \
    --receipt "$RECEIPT_REL" \
    --run-id "program-clean" \
    --generated-at "2026-06-29T00:00:00Z" \
    --write >"$TMP_DIR/generator.log" 2>&1; then
    cat "$TMP_DIR/generator.log"
    return 1
  fi
}

mutate_index_source_to_other_expect_fail() {
  local target_root other_receipt index
  target_root="$TMP_DIR/index-points-at-different-source-root"
  cp -R "$VALID_ROOT" "$target_root"
  other_receipt="$target_root/.octon/state/evidence/runs/workflows/program-clean/other-receipt.yml"
  cp "$(receipt_path "$target_root")" "$other_receipt"
  index="$target_root/$INDEX_REL"
  python3 - "$target_root" "$index" <<'PY'
import hashlib
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
index = pathlib.Path(sys.argv[2])
other_ref = ".octon/state/evidence/runs/workflows/program-clean/other-receipt.yml"
other_path = root / other_ref
other_sha = "sha256:" + hashlib.sha256(other_path.read_bytes()).hexdigest()
data = json.loads(index.read_text())
data["source_receipt"]["ref"] = other_ref
data["source_receipt"]["sha256"] = other_sha
for item in data["indexed_evidence_refs"]:
    if item.get("source_field") == ".source_receipt":
        item["ref"] = other_ref
        item["sha256"] = other_sha
        break
index.write_text(json.dumps(data, indent=2) + "\n")
PY
  expect_fail "index pointing at different source receipt" "$VALIDATOR" --receipt "$(receipt_path "$target_root")"
}

command -v yq >/dev/null 2>&1 || {
  echo "[ERROR] yq is required" >&2
  exit 1
}

RECEIPT_REL=".octon/state/evidence/runs/workflows/program-clean/proposal-program-delivery-receipt.yml"
INDEX_REL=".octon/state/evidence/runs/workflows/program-clean/proposal-program-delivery-evidence-index.yml"
VALID_ROOT="$TMP_DIR/valid-root"
make_valid_root "$VALID_ROOT"
COMPACT_RECEIPT="$TMP_DIR/compact-blocker-remediation-receipt.yml"
cat >"$COMPACT_RECEIPT" <<'YAML'
schema_version: octon-program-compact-blocker-remediation-receipt-v1
schema_ref: .octon/framework/engine/runtime/spec/program-compact-blocker-remediation-receipt-v1.schema.json
run_id: program-clean
lifecycle_id: proposal-program
target: .octon/inputs/exploratory/proposals/architecture/example-program
producer: lifecycle-program-controller
generated_at: "2026-06-29T00:00:00Z"
authority_boundary:
  replaces_source_evidence: false
  authorizes_execution: false
  proposal_input_authority: non-authoritative
  generated_output_authority: derived-only
  raw_evidence_retained: true
mode: compact-blocker-remediation
trigger_count: 1
budget_policy:
  repeated_blocker_fingerprint_threshold: 1
  repeated_full_workflow_directory_threshold: 1
  file_count_limit: 64
  total_byte_limit: 8388608
  compact_continuation_requires_retained_evidence_preservation: true
  compact_continuation_denied_when_required_receipts_missing: true
  compact_continuation_denied_when_full_evidence_missing: true
  compact_summaries_are_authority: false
retained_evidence_refs:
  - artifact_ref: .octon/state/evidence/runs/workflows/program-clean/raw-log-summary.yml
    sha256: sha256:0000000000000000000000000000000000000000000000000000000000000000
bounded_log_summary_ref:
  artifact_ref: .octon/state/evidence/runs/workflows/program-clean/raw-log-summary.yml
  sha256: sha256:0000000000000000000000000000000000000000000000000000000000000000
compact_continuation:
  continuation_allowed: true
  requires_retained_evidence_preservation: true
  denies_when_required_receipts_missing: true
  denies_when_full_evidence_missing: true
  evidence_loss_risk: false
  summary_outputs_are_authority: false
  route_owned_recovery_required: true
entries:
  - scope: child
    child_id: example-child
    route_id: run-packet-implementation
    blocker_class: validation-failed
    trigger_kind: combined-budget
    trigger_signals:
      - repeated-fingerprint
      - repeated-full-workflow-directory
      - file-count
      - byte-count
    current_fingerprint: sha256:1111111111111111111111111111111111111111111111111111111111111111
    prior_matching_fingerprint: sha256:1111111111111111111111111111111111111111111111111111111111111111
    budget_snapshot:
      limits:
        repeated_blocker_fingerprint_threshold: 1
        repeated_full_workflow_directory_threshold: 1
        file_count_limit: 64
        total_byte_limit: 8388608
      observed_file_count: 65
      observed_total_bytes: 8388609
      attempts_used: 1
      remaining_attempts: 1
      exhausted: true
      retained_evidence_preserved: true
    retained_evidence_refs:
      - artifact_ref: .octon/state/evidence/runs/workflows/program-clean/raw-log-summary.yml
        sha256: sha256:0000000000000000000000000000000000000000000000000000000000000000
    bounded_log_summary_ref:
      artifact_ref: .octon/state/evidence/runs/workflows/program-clean/raw-log-summary.yml
      sha256: sha256:0000000000000000000000000000000000000000000000000000000000000000
    next_route: run-packet-implementation
    human_review_required: false
    full_output_path_status: fail-closed-after-threshold
    compact_continuation:
      continuation_allowed: true
      requires_retained_evidence_preservation: true
      denies_when_required_receipts_missing: true
      denies_when_full_evidence_missing: true
      evidence_loss_risk: false
      summary_outputs_are_authority: false
      route_owned_recovery_required: true
    authority_boundary_notice: compact blocker-remediation evidence is evidence-only and does not replace child packet, parent delivery, archive, cleanup, Change, generated-publication, branch cleanup, terminal proof, or proposal status receipts
source_refs: []
validation_binding:
  status: digest-bound
  source_event_index: 1
  child_registry_digest: sha256:2222222222222222222222222222222222222222222222222222222222222222
  failure_behavior:
    - fail-closed-on-source-missing
failure_behavior:
  - fail-closed-on-required-receipt-loss
  - fail-closed-on-full-evidence-ref-loss
  - fail-closed-on-compact-summary-authority-substitution
YAML
NO_DISPATCH_LEDGER="$TMP_DIR/no-dispatch-attempt-ledger.yml"
cat >"$NO_DISPATCH_LEDGER" <<'YAML'
schema_version: octon-program-no-dispatch-attempt-ledger-v1
schema_ref: .octon/framework/engine/runtime/spec/program-no-dispatch-attempt-ledger-v1.schema.json
run_id: program-clean
lifecycle_id: proposal-program
target: .octon/inputs/exploratory/proposals/architecture/example-program
producer: lifecycle-program-controller
generated_at: "2026-06-29T00:00:00Z"
authority_boundary:
  replaces_source_evidence: false
  authorizes_execution: false
  proposal_input_authority: non-authoritative
  generated_output_authority: derived-only
  raw_evidence_retained: true
evidence_only: true
max_recent_attempts: 5
entry_count: 1
source_evidence_refs:
  - artifact_ref: .octon/state/evidence/runs/workflows/program-clean/program-plan.yml
    sha256: sha256:0000000000000000000000000000000000000000000000000000000000000000
entries:
  - key_digest: sha256:1111111111111111111111111111111111111111111111111111111111111111
    target: .octon/inputs/exploratory/proposals/architecture/example-program
    route: none
    route_owner: none
    input_digest: sha256:2222222222222222222222222222222222222222222222222222222222222222
    blocker_class: none
    blocker_fingerprint: sha256:3333333333333333333333333333333333333333333333333333333333333333
    attempt_count: 2
    first_seen_at: "2026-06-29T00:00:00Z"
    latest_seen_at: "2026-06-29T00:05:00Z"
    latest_event_index: 12
    latest_event_sha256: sha256:4444444444444444444444444444444444444444444444444444444444444444
    source_evidence_refs:
      - artifact_ref: .octon/state/evidence/runs/workflows/program-clean/program-plan.yml
        sha256: sha256:0000000000000000000000000000000000000000000000000000000000000000
    recent_attempts:
      - attempt_number: 1
        recorded_at: "2026-06-29T00:00:00Z"
        event_index: 6
        event_sha256: sha256:5555555555555555555555555555555555555555555555555555555555555555
        source_evidence_refs:
          - artifact_ref: .octon/state/evidence/runs/workflows/program-clean/program-plan.yml
            sha256: sha256:0000000000000000000000000000000000000000000000000000000000000000
      - attempt_number: 2
        recorded_at: "2026-06-29T00:05:00Z"
        event_index: 12
        event_sha256: sha256:4444444444444444444444444444444444444444444444444444444444444444
        source_evidence_refs:
          - artifact_ref: .octon/state/evidence/runs/workflows/program-clean/program-plan.yml
            sha256: sha256:0000000000000000000000000000000000000000000000000000000000000000
    authority_boundary_notice: no-dispatch attempt ledger evidence is evidence-only and does not authorize execution or replace route-owned receipts
failure_behavior:
  - fail-closed-on-key-digest-missing
  - fail-closed-on-input-digest-missing
  - fail-closed-on-blocker-fingerprint-missing
  - fail-closed-on-unbounded-recent-attempts
  - fail-closed-on-authority-substitution
YAML

expect_pass "static clean delivery validator chain" "$VALIDATOR"
expect_pass "valid cleaned delivery receipt plus evidence index" "$VALIDATOR" --receipt "$(receipt_path "$VALID_ROOT")"
expect_pass "valid compact blocker-remediation receipt" "$VALIDATOR" --compact-receipt "$COMPACT_RECEIPT"
expect_pass "valid no-dispatch attempt ledger" "$VALIDATOR" --no-dispatch-ledger "$NO_DISPATCH_LEDGER"

expect_fail "missing delivery receipt" "$VALIDATOR" --receipt "$TMP_DIR/missing-receipt.yml"
mutate_receipt_expect_fail "non-cleaned delivery outcome" '.actual_outcome = "landed"'
mutate_receipt_expect_fail "stale source receipt digest" '.receipt_id = "tampered-clean-delivery-receipt"'
target_root="$TMP_DIR/missing-index-root"
cp -R "$VALID_ROOT" "$target_root"
rm "$target_root/$INDEX_REL"
expect_fail "missing evidence index" "$VALIDATOR" --receipt "$(receipt_path "$target_root")"
mutate_index_expect_fail "incomplete evidence index" 'del(.indexed_evidence_refs[] | select(.source_field == ".child_receipts.archive"))'
mutate_index_source_to_other_expect_fail
mutate_receipt_expect_fail "open blockers" '.blockers += [{"class": "terminal-blocker", "status": "open", "evidence_ref": ".octon/state/evidence/runs/workflows/program-clean/open-blocker.yml"}]'
mutate_receipt_expect_fail "remote local mismatch" '.final_sync.main_origin_landed_ref_equal = false'
mutate_receipt_expect_fail "dirty worktree proof" '.worktree_hygiene.dirty_worktree = true'
mutate_receipt_expect_fail "stale terminal proof" '.terminal_current_state_proof.fresh_after_last_mutation = false'
mutate_receipt_expect_fail "parent summary substitution" '.child_packet_coverage.parent_summary_satisfies_child_receipts = true'
mutate_receipt_expect_fail "aggregate evidence substitution" '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts = true'
mutate_index_expect_fail "generated-output substitution" '.evidence_policy.generated_outputs_are_authority = true'
mutate_index_expect_fail "child-authority replacement attempt" '.evidence_policy.satisfies_child_receipts = true'
mutate_receipt_expect_fail "unpromoted generated run-health projection claim" '.terminal_current_state_proof.generated_run_health_ref = ".octon/generated/cognition/projections/materialized/runs/program-clean/health.yml"'
mutate_compact_expect_fail "compact evidence-loss continuation" '.entries[0].compact_continuation.evidence_loss_risk = true | .entries[0].compact_continuation.continuation_allowed = true'
mutate_compact_expect_fail "compact missing retained evidence digest" 'del(.entries[0].retained_evidence_refs[0].sha256)'
mutate_compact_expect_fail "compact unclassified blocker continuation" '.entries[0].blocker_class = "unclassified" | .entries[0].compact_continuation.continuation_allowed = true'
mutate_compact_expect_fail "compact summary authority substitution" '.entries[0].compact_continuation.summary_outputs_are_authority = true'
mutate_compact_expect_fail "compact repeated full output must fail closed" '.entries[0].full_output_path_status = "duplicate-full-output-written"'
mutate_no_dispatch_expect_fail "no-dispatch ledger authority substitution" '.authority_boundary.authorizes_execution = true'
mutate_no_dispatch_expect_fail "no-dispatch ledger missing input digest" 'del(.entries[0].input_digest)'
mutate_no_dispatch_expect_fail "no-dispatch ledger unbounded recent attempts" '.max_recent_attempts = 1'
mutate_no_dispatch_expect_fail "no-dispatch ledger missing source digest" 'del(.entries[0].source_evidence_refs[0].sha256)'
mutate_stale_retirement_expect_fail "stale branch unique commits block retirement" '.stale_branch_retirement.retirement_receipts[0].unique_commit_count = 1 | .stale_branch_retirement.retirement_receipts[0].no_unique_commits = false'
mutate_stale_retirement_expect_fail "stale branch protected status blocks retirement" '.stale_branch_retirement.retirement_receipts[0].protected_status = true'
mutate_stale_retirement_expect_fail "stale branch unresolved upstream blocks retirement" '.stale_branch_retirement.retirement_receipts[0].upstream_state = "unresolved"'
mutate_stale_retirement_expect_fail "stale branch open PR blocks retirement" '.stale_branch_retirement.retirement_receipts[0].pr_state = "open"'
mutate_stale_retirement_expect_fail "stale branch active worktree blocks retirement" '.stale_branch_retirement.retirement_receipts[0].active_worktree_dependency = true'
mutate_stale_retirement_expect_fail "dirty stale branch unpreservable residue blocks retirement" '.stale_branch_retirement.retirement_receipts[1].dirty_residue.disposition = "unpreservable"'
mutate_stale_retirement_expect_fail "stale branch missing retirement authorization blocks retirement" 'del(.stale_branch_retirement.retirement_receipts[0].authorization.receipt_ref)'
mutate_stale_retirement_expect_fail "stale branch missing post-delete verification blocks retirement" '.stale_branch_retirement.retirement_receipts[0].post_delete_verification.local_branch_absent = false'
mutate_stale_retirement_expect_fail "stale branch report label alone cannot retire branch" 'del(.stale_branch_retirement.retirement_receipts)'
mutate_stale_retirement_expect_fail "stale branch remote deletion needs separate current receipt" '.stale_branch_retirement.retirement_receipts[0].authorization.remote_mutation_status = "deleted" | .stale_branch_retirement.retirement_receipts[0].authorization.remote_mutation_receipt_ref = "not-required" | .stale_branch_retirement.retirement_receipts[0].authorization.remote_mutation_current = false'
target_root="$TMP_DIR/stale-disclosure-validation-root"
cp -R "$VALID_ROOT" "$target_root"
yq -i '.schema_version = "stale-evidence-disclosure-tiers-v1"' "$target_root/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml"
expect_fail "stale disclosure validation" "$VALIDATOR" --receipt "$(receipt_path "$target_root")"

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
