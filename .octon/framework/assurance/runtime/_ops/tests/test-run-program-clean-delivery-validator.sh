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
  bash "$GENERATOR" \
    --root "$root" \
    --receipt "$RECEIPT_REL" \
    --run-id "program-clean" \
    --generated-at "2026-06-29T00:00:00Z" \
    --write >/dev/null
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

expect_pass "static clean delivery validator chain" "$VALIDATOR"
expect_pass "valid cleaned delivery receipt plus evidence index" "$VALIDATOR" --receipt "$(receipt_path "$VALID_ROOT")"

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
target_root="$TMP_DIR/stale-disclosure-validation-root"
cp -R "$VALID_ROOT" "$target_root"
yq -i '.schema_version = "stale-evidence-disclosure-tiers-v1"' "$target_root/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml"
expect_fail "stale disclosure validation" "$VALIDATOR" --receipt "$(receipt_path "$target_root")"

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
