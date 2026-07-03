#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
GENERATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-program-delivery-evidence-index.sh"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh"
RECEIPT_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh"

pass_count=0
fail_count=0

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_failure() {
  local label="$1"
  shift
  if "$@"; then
    fail "$label"
  else
    pass "$label"
  fi
}

write_file() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$@" >"$path"
}

make_fixture_files() {
  local root="$1"

  write_file "$root/.octon/state/evidence/validation/proposals/program-delivery/profile.yml" "profile: pass"
  write_file "$root/.octon/state/evidence/runs/workflows/program-delivery/parent-lifecycle.yml" "parent_lifecycle: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-child/support/implementation-run.md" "verdict: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-child/support/implementation-conformance-review.md" "verdict: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-child/support/post-implementation-drift-churn-review.md" "verdict: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-child/support/proposal-closeout.md" "verdict: pass" "archive_authorized: yes"
  write_file "$root/.octon/state/evidence/runs/workflows/program-delivery/archive-receipt.yml" "archive: pass"
  write_file "$root/.octon/state/evidence/runs/skills/closeout-change/program-delivery/change-closeout-receipt.yml" "change_closeout: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-program/support/implementation-conformance-review.md" "verdict: pass"
  write_file "$root/.octon/inputs/exploratory/proposals/architecture/example-program/support/post-implementation-drift-churn-review.md" "verdict: pass"
  write_file "$root/.octon/framework/capabilities/_ops/scripts/publish-capabilities.sh" "#!/usr/bin/env bash" "exit 0"
  write_file "$root/.octon/state/evidence/validation/proposals/program-delivery/governed-mechanism-integration.log" "governed mechanism integration pass"
  write_file "$root/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/program-delivery/cleanup-authorization.json" '{"authorized":true}'
  write_file "$root/.octon/state/evidence/runs/skills/closeout-change/program-delivery/landing-authorization.json" '{"authorized":true}'
  write_file "$root/.octon/state/evidence/runs/skills/closeout-change/program-delivery/branch-cleanup-authorization.json" '{"authorized":true}'
  write_file "$root/.octon/state/evidence/local/terminal-proof/program-delivery/terminal-current-state-proof.yml" "terminal: pass"
  write_file "$root/.octon/state/evidence/local/terminal-proof/program-delivery/worktree-hygiene.yml" "worktree: clean"
  write_file "$root/.octon/state/evidence/runs/workflows/program-delivery/git-index-write-denied.yml" "blocker: git-index-write-denied"
}

write_receipt() {
  local root="$1"
  local receipt="$root/.octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-receipt.yml"
  mkdir -p "$(dirname "$receipt")"
  cat >"$receipt" <<'YAML'
schema_version: proposal-program-delivery-receipt-v1
receipt_id: test-proposal-program-delivery-receipt
emitted_at: "2026-06-24T00:00:00Z"
profile:
  profile_id: test-proposal-program-delivery-profile
  profile_ref: .octon/state/evidence/validation/proposals/program-delivery/profile.yml
  validated_at: "2026-06-24T00:00:00Z"
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
  receipt_ref: .octon/state/evidence/runs/workflows/program-delivery/delivery-readiness-preflight.yml
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
  receipt_ref: .octon/state/evidence/runs/workflows/program-delivery/parent-lifecycle.yml
  verdict: pass
  replanned_after_material_changes: true
child_packet_coverage:
  parent_summary_satisfies_child_receipts: false
  children:
    - path: .octon/inputs/exploratory/proposals/architecture/example-child
      status: archived
      required_receipts:
        - support/implementation-run.md
        - support/implementation-conformance-review.md
        - support/post-implementation-drift-churn-review.md
        - support/proposal-closeout.md
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
    - .octon/state/evidence/runs/workflows/program-delivery/archive-receipt.yml
  change_closeout:
    - .octon/state/evidence/runs/skills/closeout-change/program-delivery/change-closeout-receipt.yml
implementation_conformance:
  receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-program/support/implementation-conformance-review.md
  fresh: true
  verdict: pass
post_implementation_drift_churn:
  receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-program/support/post-implementation-drift-churn-review.md
  fresh: true
  verdict: pass
feature_catalog_drift:
  receipt_ref: .octon/state/evidence/runs/workflows/program-delivery/feature-catalog-drift-receipt.yml
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
    - .octon/state/evidence/validation/proposals/program-delivery/governed-mechanism-integration.log
  not_applicable_rationale: ""
lifecycle_residue_cleanup:
  cleanup_performed: true
  cleanup_authorization_refs:
    - .octon/state/evidence/runs/skills/repo-hygiene-cleanup/program-delivery/cleanup-authorization.json
  unauthorized_deletion_performed: false
change_closeout:
  route: branch-no-pr
  receipt_ref: .octon/state/evidence/runs/skills/closeout-change/program-delivery/change-closeout-receipt.yml
  verdict: pass
branch_authorization:
  landing_performed: true
  landing_authorization_ref: .octon/state/evidence/runs/skills/closeout-change/program-delivery/landing-authorization.json
  branch_cleanup_performed: true
  cleanup_authorization_ref: .octon/state/evidence/runs/skills/closeout-change/program-delivery/branch-cleanup-authorization.json
  branch_deleted: true
final_sync:
  landed_ref: 0000000000000000000000000000000000000000
  local_main_ref: 0000000000000000000000000000000000000000
  origin_main_ref: 0000000000000000000000000000000000000000
  main_origin_landed_ref_equal: true
terminal_current_state_proof:
  evidence_ref: .octon/state/evidence/local/terminal-proof/program-delivery/terminal-current-state-proof.yml
  fresh_after_last_mutation: true
  verdict: pass
worktree_hygiene:
  evidence_ref: .octon/state/evidence/local/terminal-proof/program-delivery/worktree-hygiene.yml
  dirty_worktree: false
  verdict: pass
delivery_evidence_index:
  ref: .octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml
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

make_fixture() {
  local root="$1"
  make_fixture_files "$root"
  write_receipt "$root"
}

make_blocked_receipt() {
  local root="$1"
  make_fixture "$root"
  local receipt="$root/.octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-receipt.yml"
  yq -i '
    .actual_outcome = "blocked" |
    .change_closeout.verdict = "blocked" |
    .branch_authorization.landing_performed = false |
    .branch_authorization.landing_authorization_ref = "not-applicable" |
    .branch_authorization.branch_cleanup_performed = false |
    .branch_authorization.cleanup_authorization_ref = "not-applicable" |
    .branch_authorization.branch_deleted = false |
    .delivery_readiness_preflight.verdict = "blocked" |
    .delivery_readiness_preflight.blockers = ["git-index-write-denied"] |
    .final_sync.landed_ref = "not-run" |
    .final_sync.local_main_ref = "not-run" |
    .final_sync.origin_main_ref = "not-run" |
    .final_sync.main_origin_landed_ref_equal = false |
    .terminal_current_state_proof.evidence_ref = "not-run" |
    .terminal_current_state_proof.fresh_after_last_mutation = false |
    .terminal_current_state_proof.verdict = "not-run" |
    .worktree_hygiene.evidence_ref = "not-run" |
    .worktree_hygiene.dirty_worktree = true |
    .worktree_hygiene.verdict = "not-run" |
    .blockers = [{"class":"git-index-write-denied","evidence_ref":".octon/state/evidence/runs/workflows/program-delivery/git-index-write-denied.yml","status":"open"}]
  ' "$receipt"
}

generate_index() {
  local root="$1" run_id="$2"
  bash "$GENERATOR" \
    --root "$root" \
    --receipt ".octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-receipt.yml" \
    --run-id "$run_id" \
    --generated-at "2026-06-24T00:00:00Z" \
    --write >/dev/null
}

mutate_index() {
  local path="$1"
  local expression="$2"
  python3 - "$path" "$expression" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
expression = sys.argv[2].replace("\\n", "\n")
data = json.loads(path.read_text())
exec(expression, {"data": data})
path.write_text(json.dumps(data, indent=2) + "\n")
PY
}

main() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '$tmp'" EXIT

  assert_success "schema-only validator passes" \
    bash "$VALIDATOR"

  local valid_root="$tmp/valid"
  make_fixture "$valid_root"
  assert_success "source delivery receipt fixture validates" \
    bash "$RECEIPT_VALIDATOR" --receipt "$valid_root/.octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-receipt.yml"
  assert_success "valid delivery evidence index materializes" \
    generate_index "$valid_root" "program-delivery"
  assert_success "valid delivery evidence index validates" \
    bash "$VALIDATOR" --root "$valid_root" --index ".octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml"
  assert_success "index keeps child delivery deferred from sibling progression" \
    yq -e '.outcome_authority.child_delivery_required_for_sibling_progression == false' \
      "$valid_root/.octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml" >/dev/null

  local blocked_root="$tmp/blocked"
  make_blocked_receipt "$blocked_root"
  assert_success "blocked branch-no-pr delivery receipt remains indexable evidence" \
    generate_index "$blocked_root" "program-delivery"
  assert_success "blocked branch-no-pr delivery index validates without granting delivery authority" \
    bash "$VALIDATOR" --root "$blocked_root" --index ".octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml"

  local stale_source_root="$tmp/stale-source"
  make_fixture "$stale_source_root"
  generate_index "$stale_source_root" "program-delivery"
  printf 'tampered: true\n' >>"$stale_source_root/.octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-receipt.yml"
  assert_failure "source receipt digest drift fails closed" \
    bash "$VALIDATOR" --root "$stale_source_root" --index ".octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml"

  local stale_child_root="$tmp/stale-child"
  make_fixture "$stale_child_root"
  generate_index "$stale_child_root" "program-delivery"
  printf 'tampered: true\n' >>"$stale_child_root/.octon/inputs/exploratory/proposals/architecture/example-child/support/implementation-run.md"
  assert_failure "child receipt digest drift fails closed" \
    bash "$VALIDATOR" --root "$stale_child_root" --index ".octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml"

  local aggregate_replacement_root="$tmp/aggregate-replacement"
  make_fixture "$aggregate_replacement_root"
  generate_index "$aggregate_replacement_root" "program-delivery"
  mutate_index "$aggregate_replacement_root/.octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml" \
    "data['target_owned_evidence_policy']['aggregate_receipt_replaces_target_owned_receipts'] = True"
  assert_failure "aggregate receipt replacement claim fails closed" \
    bash "$VALIDATOR" --root "$aggregate_replacement_root" --index ".octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml"

  local archive_delivery_root="$tmp/archive-delivery"
  make_fixture "$archive_delivery_root"
  generate_index "$archive_delivery_root" "program-delivery"
  mutate_index "$archive_delivery_root/.octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml" \
    "data['outcome_authority']['archive_evidence_claims_delivery'] = True"
  assert_failure "archive evidence cannot claim delivery authority" \
    bash "$VALIDATOR" --root "$archive_delivery_root" --index ".octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml"

  local local_private_root="$tmp/local-private"
  make_fixture "$local_private_root"
  generate_index "$local_private_root" "program-delivery"
  mutate_index "$local_private_root/.octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml" \
    "\nfor item in data['indexed_evidence_refs']:\n    if item['ref'].startswith('.octon/state/evidence/local/'):\n        item['authority_use'] = 'retained-evidence-ref'\n        break\n"
  assert_failure "local-private evidence cannot claim retained authority" \
    bash "$VALIDATOR" --root "$local_private_root" --index ".octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml"

  local missing_archive_root="$tmp/missing-archive"
  make_fixture "$missing_archive_root"
  generate_index "$missing_archive_root" "program-delivery"
  mutate_index "$missing_archive_root/.octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml" \
    "data['indexed_evidence_refs'] = [item for item in data['indexed_evidence_refs'] if item['source_field'] != '.child_receipts.archive']"
  assert_failure "missing child archive family fails closed" \
    bash "$VALIDATOR" --root "$missing_archive_root" --index ".octon/state/evidence/runs/workflows/program-delivery/proposal-program-delivery-evidence-index.yml"

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
