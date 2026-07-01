#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
PROFILE_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh"
RECEIPT_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh"
EVIDENCE_INDEX_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh"
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

mutate_text_fixture_expect_workflow_fail() {
  local description="$1" source_path="$2" env_name="$3" script="$4" target
  target="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.txt"
  cp "$source_path" "$target"
  perl -0pi -e "$script" "$target"
  expect_fail "$description" env "$env_name=$target" "$WORKFLOW_VALIDATOR"
}

mutate_yaml_fixture_expect_workflow_fail() {
  local description="$1" source_path="$2" env_name="$3" expression="$4" target
  target="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.yml"
  cp "$source_path" "$target"
  yq -i "$expression" "$target"
  expect_fail "$description" env "$env_name=$target" "$WORKFLOW_VALIDATOR"
}

require_tool yq

cat >"$TMP_DIR/valid-profile.yml" <<'YAML'
schema_version: proposal-program-delivery-profile-v1
profile_id: test-proposal-program-delivery-profile
created_at: "2026-06-14T00:00:00Z"
target_program_path: .octon/inputs/exploratory/proposals/architecture/example-proposal-program-delivery
target_outcome: cleaned
execution_order_policy:
  canonical_order_required: true
  canonical_order_ref: child-before-parent-delivery
  operator_requested_alternative_order: false
  requested_order_ref: child-before-parent-delivery
  override_required_when_order_differs: true
  override_receipt_ref: not-applicable
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

cat >"$TMP_DIR/valid-order-override.yml" <<'YAML'
schema_version: proposal-program-delivery-order-override-receipt-v1
receipt_id: test-order-override
emitted_at: "2026-06-14T00:00:00Z"
target_program:
  path: .octon/inputs/exploratory/proposals/architecture/example-proposal-program-delivery
  accepted_review_digest: sha256:0000000000000000000000000000000000000000000000000000000000000000
run_binding:
  delivery_run_id: test-run
  profile_id: test-proposal-program-delivery-profile
requested_order:
  canonical_order_ref: child-before-parent-delivery
  requested_order_ref: parent-delivery-before-child-archive
  operator_requested_alternative_order: true
  rationale: "Operator requested a bounded efficiency exception."
operator_authority:
  identity: test-operator
  authority_source: test-fixture
efficiency_risk_acknowledgement:
  acknowledged: true
  acknowledged_by: test-operator
  acknowledged_at: "2026-06-14T00:00:00Z"
  risk_summary: "Non-canonical execution can defer child-owned proof and is accepted only for this test run."
revocation:
  revoked: false
  stale_after: "2026-06-15T00:00:00Z"
  supersedes_receipt_ref: ""
non_authority_classification:
  proposal_local_files: non-authority
  generated_prompts: non-authority
  generated_outputs: derived-only-non-authority
  dashboards: non-authority
  chat_or_model_memory: non-authority
authority_boundary:
  retained_evidence_only: true
  authorizes_delivery: false
  authorizes_child_receipt_replacement: false
  authorizes_archive: false
  authorizes_git_mutation: false
  authorizes_cleanup: false
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

expect_pass "schema-only profile validator" "$PROFILE_VALIDATOR"
expect_pass "valid profile" "$PROFILE_VALIDATOR" --profile "$TMP_DIR/valid-profile.yml"
cp "$TMP_DIR/valid-profile.yml" "$TMP_DIR/valid-profile-with-override.yml"
yq -i '.execution_order_policy.operator_requested_alternative_order = true | .execution_order_policy.requested_order_ref = "parent-delivery-before-child-archive" | .execution_order_policy.override_receipt_ref = "valid-order-override.yml"' "$TMP_DIR/valid-profile-with-override.yml"
expect_pass "valid non-canonical profile with override" "$PROFILE_VALIDATOR" --profile "$TMP_DIR/valid-profile-with-override.yml"
expect_pass "schema-only receipt validator" "$RECEIPT_VALIDATOR"
expect_pass "valid receipt" "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/valid-receipt.yml"
expect_pass "schema-only delivery evidence index validator" "$EVIDENCE_INDEX_VALIDATOR"
expect_pass "workflow validator" "$WORKFLOW_VALIDATOR"

expect_fail \
  "workflow rejects missing additive alias command" \
  env "OCTON_PROPOSAL_PROGRAM_DELIVERY_ALIAS_COMMAND_PATH=$TMP_DIR/missing-additive-alias.md" "$WORKFLOW_VALIDATOR"
cat >"$TMP_DIR/native-alias.md" <<'TXT'
# /octon-proposal-run-program-delivery
TXT
expect_fail \
  "workflow rejects native framework alias command" \
  env "OCTON_PROPOSAL_PROGRAM_DELIVERY_NATIVE_ALIAS_COMMAND_PATH=$TMP_DIR/native-alias.md" "$WORKFLOW_VALIDATOR"
mutate_text_fixture_expect_workflow_fail \
  "workflow rejects optional command admission inputs" \
  "$ROOT_DIR/.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md" \
  "OCTON_PROPOSAL_PROGRAM_DELIVERY_COMMAND_PATH" \
  's|/proposal-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>|/proposal-program-delivery target=<proposal-program-path> [outcome=cleaned] [profile=<profile-path>] [run-id=<id>]|'
mutate_text_fixture_expect_workflow_fail \
  "workflow rejects optional additive alias admission inputs" \
  "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/octon-proposal-run-program-delivery.md" \
  "OCTON_PROPOSAL_PROGRAM_DELIVERY_ALIAS_COMMAND_PATH" \
  's|/octon-proposal-run-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>|/octon-proposal-run-program-delivery target=<proposal-program-path> [outcome=cleaned] [profile=<profile-path>] [run-id=<id>]|'
mutate_text_fixture_expect_workflow_fail \
  "workflow rejects optional skill admission inputs" \
  "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md" \
  "OCTON_PROPOSAL_PROGRAM_DELIVERY_SKILL_PATH" \
  's|/proposal-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>|/proposal-program-delivery target=<proposal-program-path> [outcome=cleaned] [profile=<profile-path>] [run-id=<id>]|'
mutate_text_fixture_expect_workflow_fail \
  "workflow rejects optional command manifest admission inputs" \
  "$ROOT_DIR/.octon/framework/capabilities/runtime/commands/manifest.yml" \
  "OCTON_PROPOSAL_PROGRAM_DELIVERY_COMMAND_MANIFEST_PATH" \
  's|target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>|target=<proposal-program-path> [outcome=cleaned] [profile=<profile-path>] [run-id=<id>]|'
mutate_yaml_fixture_expect_workflow_fail \
  "workflow rejects native command manifest alias registration" \
  "$ROOT_DIR/.octon/framework/capabilities/runtime/commands/manifest.yml" \
  "OCTON_PROPOSAL_PROGRAM_DELIVERY_COMMAND_MANIFEST_PATH" \
  '.commands += [{"id": "octon-proposal-run-program-delivery", "display_name": "Run Program to Clean Delivery", "path": "octon-proposal-run-program-delivery.md", "summary": "Alias for proposal-program-delivery.", "access": "agent", "argument_hint": "target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>"}]'
mutate_yaml_fixture_expect_workflow_fail \
  "workflow rejects optional additive alias manifest admission inputs" \
  "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/manifest.fragment.yml" \
  "OCTON_PROPOSAL_LIFECYCLE_COMMAND_MANIFEST_PATH" \
  '(.commands[] | select(.id == "octon-proposal-run-program-delivery") | .argument_hint) = "target=<proposal-program-path> [outcome=cleaned] [profile=<profile-path>] [run-id=<id>]"'
mutate_text_fixture_expect_workflow_fail \
  "workflow rejects missing bundle matrix alias hook" \
  "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md" \
  "OCTON_PROPOSAL_LIFECYCLE_BUNDLE_MATRIX_PATH" \
  's|; alias `octon-proposal-run-program-delivery`||; s|The optional operator-facing command alias is\n`octon-proposal-run-program-delivery` with display label\n`Run Program to Clean Delivery`. It delegates to `proposal-program-delivery`\nand does not create an independent workflow, lifecycle mode, closeout, archive,\ncleanup, Git mutation, branch cleanup, generated publication, receipt schema,\nprofile schema, or terminal proof rule.\n||'
mutate_text_fixture_expect_workflow_fail \
  "workflow rejects missing lifecycle delivery_run_id input hook" \
  "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml" \
  "OCTON_PROPOSAL_PROGRAM_DELIVERY_LIFECYCLE_CONTRACT_PATH" \
  's|\n        - "delivery_run_id"||'
mutate_text_fixture_expect_workflow_fail \
  "workflow rejects missing lifecycle resume non-authority guard" \
  "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml" \
  "OCTON_PROPOSAL_PROGRAM_DELIVERY_LIFECYCLE_CONTRACT_PATH" \
  's|\n          - "generated outputs"||'
mutate_yaml_fixture_expect_workflow_fail \
  "workflow rejects alias lifecycle delivery mode" \
  "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml" \
  "OCTON_PROPOSAL_PROGRAM_DELIVERY_LIFECYCLE_CONTRACT_PATH" \
  '.delivery_modes += [{"mode_id": "octon-proposal-run-program-delivery"}]'

mutate_profile_expect_fail "missing profile gate declarations" 'del(.publication_checks)'
mutate_profile_expect_fail "branch-no-pr PR fallback forbidden" '.pr_policy.fallback_to_pr = true'
mutate_profile_expect_fail "stash policy cannot widen" '.stash_policy.mode = "allowed"'
mutate_profile_expect_fail "stash policy required" 'del(.stash_policy)'
cp "$TMP_DIR/valid-order-override.yml" "$TMP_DIR/revoked-order-override.yml"
yq -i '.revocation.revoked = true' "$TMP_DIR/revoked-order-override.yml"
cp "$TMP_DIR/valid-order-override.yml" "$TMP_DIR/target-mismatch-order-override.yml"
yq -i '.target_program.path = ".octon/inputs/exploratory/proposals/architecture/other-program"' "$TMP_DIR/target-mismatch-order-override.yml"
cp "$TMP_DIR/valid-order-override.yml" "$TMP_DIR/run-mismatch-order-override.yml"
yq -i '.run_binding.profile_id = "other-profile"' "$TMP_DIR/run-mismatch-order-override.yml"
cp "$TMP_DIR/valid-order-override.yml" "$TMP_DIR/risk-unacknowledged-order-override.yml"
yq -i '.efficiency_risk_acknowledgement.acknowledged = false' "$TMP_DIR/risk-unacknowledged-order-override.yml"
mutate_profile_expect_fail "non-canonical order without override fails" '.execution_order_policy.operator_requested_alternative_order = true | .execution_order_policy.requested_order_ref = "parent-delivery-before-child-archive" | .execution_order_policy.override_receipt_ref = "not-applicable"'
mutate_profile_expect_fail "stale revoked override fails" '.execution_order_policy.operator_requested_alternative_order = true | .execution_order_policy.requested_order_ref = "parent-delivery-before-child-archive" | .execution_order_policy.override_receipt_ref = "revoked-order-override.yml"'
mutate_profile_expect_fail "target-mismatched override fails" '.execution_order_policy.operator_requested_alternative_order = true | .execution_order_policy.requested_order_ref = "parent-delivery-before-child-archive" | .execution_order_policy.override_receipt_ref = "target-mismatch-order-override.yml"'
mutate_profile_expect_fail "run-mismatched override fails" '.execution_order_policy.operator_requested_alternative_order = true | .execution_order_policy.requested_order_ref = "parent-delivery-before-child-archive" | .execution_order_policy.override_receipt_ref = "run-mismatch-order-override.yml"'
mutate_profile_expect_fail "risk-unacknowledged override fails" '.execution_order_policy.operator_requested_alternative_order = true | .execution_order_policy.requested_order_ref = "parent-delivery-before-child-archive" | .execution_order_policy.override_receipt_ref = "risk-unacknowledged-order-override.yml"'

mutate_receipt_expect_fail "parent summary substituted for child receipts" '.child_packet_coverage.parent_summary_satisfies_child_receipts = true'
mutate_receipt_expect_fail "non-canonical order without override receipt fails" '.order_policy.requested_order_ref = "parent-delivery-before-child-archive" | .order_policy.operator_requested_alternative_order = true | .order_policy.override_receipt_required = false | .order_policy.override_receipt_status = "missing"'
cp "$TMP_DIR/valid-receipt.yml" "$TMP_DIR/valid-noncanonical-receipt.yml"
yq -i '.order_policy.requested_order_ref = "parent-delivery-before-child-archive" | .order_policy.operator_requested_alternative_order = true | .order_policy.override_receipt_required = true | .order_policy.override_receipt_ref = ".octon/state/evidence/runs/workflows/test/order-override.yml" | .order_policy.override_receipt_status = "valid"' "$TMP_DIR/valid-noncanonical-receipt.yml"
expect_pass "valid non-canonical receipt with override status" "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/valid-noncanonical-receipt.yml"
mutate_receipt_expect_fail "stale child receipts" '.child_packet_coverage.children[0].fresh = false'
mutate_receipt_expect_fail "missing implementation conformance" 'del(.implementation_conformance.receipt_ref)'
mutate_receipt_expect_fail "missing drift churn receipt" 'del(.post_implementation_drift_churn.receipt_ref)'
mutate_receipt_expect_fail "unresolved feature catalog drift blocks non-blocked receipt" '.feature_catalog_drift.outcome = "blocked-unresolved-drift" | .feature_catalog_drift.unresolved_count = 1'
mutate_receipt_expect_fail "missing feature catalog drift receipt" 'del(.feature_catalog_drift.receipt_ref)'
mutate_receipt_expect_fail "stale generated publication evidence" '.generated_publication.fresh = false'
mutate_receipt_expect_fail "missing governed mechanism integration receipt" '.governed_mechanism_integration.required = true | .governed_mechanism_integration.receipt_refs = []'
mutate_receipt_expect_fail "branch-no-pr landing without authorization" '.branch_authorization.landing_performed = true | .branch_authorization.landing_authorization_ref = "not-applicable"'
mutate_receipt_expect_fail "branch cleanup without authorization" '.branch_authorization.branch_cleanup_performed = true | .branch_authorization.cleanup_authorization_ref = "not-applicable"'
mutate_receipt_expect_fail "repo hygiene deletion without cleanup authorization" '.lifecycle_residue_cleanup.cleanup_performed = true | .lifecycle_residue_cleanup.cleanup_authorization_refs = []'
mutate_receipt_expect_fail "missing terminal current-state proof" 'del(.terminal_current_state_proof.evidence_ref)'
mutate_receipt_expect_fail "dirty worktree cleaned overclaim" '.worktree_hygiene.dirty_worktree = true'
mutate_receipt_expect_fail "main origin landed ref mismatch" '.final_sync.main_origin_landed_ref_equal = false'
mutate_receipt_expect_fail "missing readiness preflight fails" 'del(.delivery_readiness_preflight)'
mutate_receipt_expect_fail "readiness preflight blocker fails non-blocked receipt" '.delivery_readiness_preflight.blockers = ["git-index-write-denied"]'
mutate_receipt_expect_fail "dirty source without include-path classification fails" '.clean_worktree_route.source_dirty = true | .clean_worktree_route.selected_route = "current-clean-worktree" | .clean_worktree_route.include_path_classification_ref = "not-required" | .clean_worktree_route.include_path_classification_valid = false'
mutate_receipt_expect_fail "broad stage-all without include-path classification fails" '.clean_worktree_route.broad_stage_all_requested = true | .clean_worktree_route.include_path_classification_ref = "not-required" | .clean_worktree_route.include_path_classification_valid = false'
mutate_receipt_expect_fail "required postmortem without artifacts fails" '.lifecycle_postmortem.required = true | .lifecycle_postmortem.status = "required-missing" | .lifecycle_postmortem.verdict = "fail"'
mutate_receipt_expect_fail "generated prompt used as authority" '.non_authority_classification.generated_prompts = "authority"'
mutate_receipt_expect_fail "proposal-local file used as authority" '.non_authority_classification.proposal_local_files = "authority"'
mutate_receipt_expect_fail "aggregate receipt replacing target-owned receipts" '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts = true'

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
