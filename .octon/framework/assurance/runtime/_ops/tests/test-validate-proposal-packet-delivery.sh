#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
PROFILE_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-profile.sh"
RECEIPT_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh"
WORKFLOW_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh"
TMP_DIR="$(mktemp -d)"
REPO_FIXTURE_ROOT="$ROOT_DIR/.octon/state/evidence/runs/workflows/test-partition-clean-delivery-$$"
trap 'rm -rf "$TMP_DIR" "$REPO_FIXTURE_ROOT"' EXIT

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

digest_file() {
  shasum -a 256 "$1" | awk '{print "sha256:" $1}'
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

write_partition_clean_fixtures() {
  local fixture_ref_base classifier_ref report_ref return_ref override_ref
  local classifier_path report_path return_path override_path
  local fingerprint classifier_digest report_digest return_digest
  fixture_ref_base=".octon/state/evidence/runs/workflows/test-partition-clean-delivery-$$"
  classifier_ref="$fixture_ref_base/worktree-hygiene-classifier.yml"
  report_ref="$fixture_ref_base/closeout-worktree-report.yml"
  return_ref="$fixture_ref_base/lifecycle-interaction-return.json"
  override_ref="$fixture_ref_base/proposal-packet-delivery-order-override-receipt.yml"
  classifier_path="$ROOT_DIR/$classifier_ref"
  report_path="$ROOT_DIR/$report_ref"
  return_path="$ROOT_DIR/$return_ref"
  override_path="$ROOT_DIR/$override_ref"
  fingerprint="sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

  mkdir -p "$REPO_FIXTURE_ROOT"
  cat >"$classifier_path" <<YAML
schema_version: octon-proposal-worktree-hygiene-v1
worktree_hygiene_verdict: blocked
worktree_hygiene_foreign_path_count: 1
worktree_hygiene_foreign_fingerprint: $fingerprint
YAML
  classifier_digest="$(digest_file "$classifier_path")"

  cat >"$report_path" <<YAML
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
default_work_unit: Change
run_id: closeout-worktree-fixture-partition-clean-delivery
observed_change_set_count: 3
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
repo_hygiene_cleanup_actions_performed: false
initial_inventory_ref: $classifier_ref
residue_classification_ref: $classifier_ref
final_inventory_ref: $classifier_ref
selected_candidate_id: delivery-change
candidates:
  - candidate_id: delivery-change
    disposition: deferred
    residue_routing_class: publishable_change
    ownership: coherent delivery change candidate
    route_hint: closeout-change branch-no-pr after archive authorization
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: preserve for later branch-no-pr closeout
    boundaries:
      include_paths:
        - .octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/workflow.yml
      exclude_paths:
        - .git
  - candidate_id: packet-archive
    disposition: foreign
    residue_routing_class: foreign_manual_review
    ownership: packet and protected route evidence preserved
    route_hint: closeout-worktree preserve-and-exclude return
    target_lifecycle_outcome: preserved
    rollback_or_discard_posture: preserve-only; no mutation
    boundaries:
      include_paths:
        - .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery
      exclude_paths:
        - .git
    proposal_program_handoff_authorization:
      authorization_grant: fixture preserve/exclude
      child_id: example-proposal-packet-delivery
      route_id: closeout-worktree
      interaction_request_ref: $fixture_ref_base/lifecycle-interaction-request.json
      classifier_output_ref: $classifier_ref
      classifier_output_digest: $classifier_digest
      authorized_foreign_fingerprint: $fingerprint
      foreign_fingerprint: $fingerprint
      authorized_paths:
        - .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery
      disposition: preserve-and-exclude-from-child-closeout-blocking
      non_mutating: true
      preserve_and_exclude_from_child_closeout_blocking: true
      parent_summary_not_child_closeout_receipt: true
      child_closeout_authority_preserved: true
      forbidden_actions:
        deletion: false
        reset: false
        staging: false
        commit: false
        push: false
        publication: false
        archive: false
        branch_cleanup: false
        git_ref_mutation: false
        worktree_cleanup: false
        repo_hygiene_deletion: false
        promotion: false
        hosted_provider_action: false
        cleaned_claim: false
        child_closeout_receipt_replacement: false
        child_validation_replacement: false
  - candidate_id: retained-local
    disposition: retained
    residue_routing_class: local_private_retained
    ownership: ignored local evidence retained
    route_hint: repo-hygiene-cleanup only with authorization
    target_lifecycle_outcome: retained
    rollback_or_discard_posture: retain; no cleanup
    boundaries:
      include_paths:
        - .octon/state/evidence/local/
      exclude_paths:
        - .git
iterations: []
final_candidate_dispositions:
  delivery-change:
    state: deferred
  packet-archive:
    state: foreign
  retained-local:
    state: retained
retained_residue:
  - candidate_id: packet-archive
    path: .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery
    disposition: foreign/manual lifecycle residue preserved and excluded from child closeout blocking
  - candidate_id: retained-local
    path: .octon/state/evidence/local/
    disposition: ignored/local residue retained as non-authoritative local evidence; no cleanup performed
blockers:
  - candidate_id: delivery-change
    blocker: branch-no-pr Change closeout is ordered after archive
    reason: selected candidate is safely separable but must defer until archive route authorization
    evidence_refs:
      - $classifier_ref
final_residue_classes:
  ignored: 1
worktree_terminal_state: nonterminal
next_route_condition: return to proposal-packet-delivery closeout-packet with lifecycle-interaction-return evidence
YAML
  report_digest="$(digest_file "$report_path")"

  cat >"$return_path" <<JSON
{
  "schema_version": "lifecycle-interaction-return-v1",
  "interaction_id": "partition-clean-delivery-fixture-return",
  "consumer": {
    "lifecycle_id": "closeout-worktree",
    "run_id": "closeout-worktree-fixture-partition-clean-delivery"
  },
  "outcome": {
    "completed": true,
    "lifecycle_outcome": "preserved",
    "non_mutating": true,
    "cleaned_claim": false,
    "blocker": "delivery change candidate remains deferred until archive authorization"
  },
  "return_evidence_refs": [
    {
      "ref": "$report_ref",
      "digest": "$report_digest",
      "schema_version": "closeout-worktree-report-v1"
    }
  ],
  "remaining_residue": [
    ".octon/framework",
    ".octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery",
    ".octon/state/evidence/local"
  ]
}
JSON
  return_digest="$(digest_file "$return_path")"

  cat >"$override_path" <<YAML
schema_version: proposal-packet-delivery-order-override-receipt-v1
receipt_id: partition-clean-delivery-fixture
emitted_at: "2026-06-26T00:00:00Z"
target_packet:
  path: .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery
  accepted_review_digest: sha256:1111111111111111111111111111111111111111111111111111111111111111
run_binding:
  delivery_run_id: partition-clean-delivery-fixture-run
  profile_id: test-proposal-packet-delivery-profile
requested_order:
  canonical_order_ref: archive-before-branch-no-pr-change-closeout
  requested_order_ref: partition-clean-archive-readiness-before-branch-no-pr-change-closeout
  operator_requested_alternative_order: true
  rationale: fixture validates partition-clean archive readiness before branch-no-pr Change closeout
partition_clean_archive_readiness:
  mode: partition-clean-for-archive-readiness
  closeout_worktree_report_ref: $report_ref
  closeout_worktree_report_digest: $report_digest
  lifecycle_interaction_return_ref: $return_ref
  lifecycle_interaction_return_digest: $return_digest
  source_worktree_hygiene_classifier_ref: $classifier_ref
  source_worktree_hygiene_classifier_digest: $classifier_digest
  authorized_foreign_fingerprint: $fingerprint
  delivery_change_candidate_id: delivery-change
  packet_archive_candidate_id: packet-archive
  retained_local_evidence_candidate_id: retained-local
  authorized_candidate_ids:
    - delivery-change
    - packet-archive
    - retained-local
  allowed_residue_routing_classes:
    - publishable_change
    - foreign_manual_review
    - local_private_retained
  allowed_final_states:
    - deferred
    - foreign
    - retained
  remaining_dirty_paths_exactly_partitioned: true
  no_arbitrary_foreign_user_owned_or_unsafe_residue_masked: true
  child_packet_closeout_authority_preserved: true
  closeout_worktree_report_validated: true
  lifecycle_interaction_return_validated: true
  closeout_worktree_non_mutating: true
  closeout_worktree_cleaned_claim: false
  git_clean_claim: false
  archive_authorization_claim: false
  hosted_landing_claim: false
  branch_cleanup_claim: false
  repo_hygiene_cleanup_claim: false
  cleaned_outcome_claim: false
  branch_no_pr_change_closeout_remains_owner: true
operator_authority:
  identity: fixture
  authority_source: validator test
efficiency_risk_acknowledgement:
  acknowledged: true
  acknowledged_by: fixture
  acknowledged_at: "2026-06-26T00:00:00Z"
  risk_summary: fixture acknowledges order override must not authorize downstream mutation
revocation:
  revoked: false
  stale_after: fixture evidence changes
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
  authorizes_hosted_landing: false
  authorizes_branch_cleanup: false
  authorizes_repo_hygiene_cleanup: false
  authorizes_cleaned_claim: false
  authorizes_cleanup: false
YAML

  PARTITION_OVERRIDE_REF="$override_ref"
  PARTITION_OVERRIDE_DIGEST="$(digest_file "$override_path")"
  PARTITION_REPORT_REF="$report_ref"
  PARTITION_RETURN_REF="$return_ref"
}

require_tool yq

cat >"$TMP_DIR/valid-profile.yml" <<'YAML'
schema_version: proposal-packet-delivery-profile-v1
profile_id: test-proposal-packet-delivery-profile
created_at: "2026-06-16T00:00:00Z"
target_packet_path: .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery
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
packet_execution:
  replan_after_material_changes: true
  target_owned_receipts_required: true
  aggregate_receipt_replaces_target_receipts: false
  self_authorization_allowed: false
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
promotion_requirements:
  promote_proposal_required: true
  implemented_status_required: true
  promotion_receipt_required: true
closeout_requirements:
  packet_closeout_required: true
  terminal_closeout_required: true
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
schema_version: proposal-packet-delivery-receipt-v1
receipt_id: test-proposal-packet-delivery-receipt
emitted_at: "2026-06-16T00:00:00Z"
profile:
  profile_id: test-proposal-packet-delivery-profile
  profile_ref: .octon/state/evidence/validation/proposals/proposal-packet-delivery/20260616T000000Z/delivery-profile.yml
  validated_at: "2026-06-16T00:00:00Z"
  verdict: pass
target_packet:
  path: .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery
  status: implemented
  accepted_review_digest: sha256:0000000000000000000000000000000000000000000000000000000000000000
  accepted_review_fresh: true
  implementation_authorized: true
  implementation_authorization_ref: .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/proposal-review.md
target_outcome: cleaned
actual_outcome: cleaned
packet_lifecycle:
  workflow_ref: .octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/workflow.yml
  receipt_ref: .octon/state/evidence/runs/workflows/test/proposal-packet-delivery-receipt.yml
  verdict: pass
  replanned_after_material_changes: true
target_receipts:
  implementation_run:
    - .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/implementation-run.md
  implementation_conformance:
    - .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/implementation-conformance-review.md
  post_implementation_drift_churn:
    - .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/post-implementation-drift-churn-review.md
  promotion:
    - .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/promotion-receipt.yml
  packet_closeout:
    - .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/proposal-closeout.md
  terminal_closeout:
    - .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/proposal-terminal-closeout.yml
  archive:
    - .octon/state/evidence/runs/workflows/test/archive-receipt.yml
  change_closeout:
    - .octon/state/evidence/runs/skills/closeout-change/test/change-closeout-receipt.yml
implementation_conformance:
  receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/implementation-conformance-review.md
  fresh: true
  verdict: pass
post_implementation_drift_churn:
  receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/post-implementation-drift-churn-review.md
  fresh: true
  verdict: pass
generated_publication:
  validator: validate-capability-publication-state.sh
  publisher_refs:
    - .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
  fresh: true
  direct_generated_output_edit_used: false
governed_mechanism_integration:
  required: true
  verdict: pass
  receipt_refs:
    - .octon/state/evidence/validation/proposals/proposal-packet-delivery/20260616T000000Z/governed-mechanism-integration.log
  not_applicable_rationale: ""
promotion:
  receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/promotion-receipt.yml
  fresh: true
  verdict: pass
packet_closeout:
  receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/proposal-closeout.md
  fresh: true
  verdict: pass
terminal_closeout:
  receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-proposal-packet-delivery/support/proposal-terminal-closeout.yml
  fresh: true
  verdict: pass
archive:
  receipt_ref: .octon/state/evidence/runs/workflows/test/archive-receipt.yml
  fresh: true
  verdict: pass
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
  evidence_ref: .octon/state/evidence/validation/proposals/proposal-packet-delivery/20260616T000000Z/terminal-current-state-proof.log
  fresh_after_last_mutation: true
  verdict: pass
worktree_hygiene:
  evidence_ref: .octon/state/evidence/validation/proposals/proposal-packet-delivery/20260616T000000Z/worktree-hygiene.log
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

write_partition_clean_fixtures
cp "$TMP_DIR/valid-receipt.yml" "$TMP_DIR/partition-clean-archive-ready-receipt.yml"
PARTITION_OVERRIDE_REF="$PARTITION_OVERRIDE_REF" \
PARTITION_OVERRIDE_DIGEST="$PARTITION_OVERRIDE_DIGEST" \
PARTITION_REPORT_REF="$PARTITION_REPORT_REF" \
PARTITION_RETURN_REF="$PARTITION_RETURN_REF" \
yq -i '
  .actual_outcome = "archive-ready" |
  .worktree_hygiene.evidence_ref = strenv(PARTITION_REPORT_REF) |
  .worktree_hygiene.dirty_worktree = true |
  .worktree_hygiene.verdict = "partition-clean" |
  .partition_clean_archive_readiness = {
    "enabled": true,
    "mode": "partition-clean-for-archive-readiness",
    "order_override_receipt_ref": strenv(PARTITION_OVERRIDE_REF),
    "order_override_receipt_digest": strenv(PARTITION_OVERRIDE_DIGEST),
    "closeout_worktree_report_ref": strenv(PARTITION_REPORT_REF),
    "lifecycle_interaction_return_ref": strenv(PARTITION_RETURN_REF),
    "does_not_authorize_archive": true,
    "does_not_authorize_git_mutation": true,
    "does_not_authorize_cleaned_claim": true
  }
' "$TMP_DIR/partition-clean-archive-ready-receipt.yml"

cp "$TMP_DIR/partition-clean-archive-ready-receipt.yml" "$TMP_DIR/stale-partition-clean-receipt.yml"
yq -i '.partition_clean_archive_readiness.order_override_receipt_digest = "sha256:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"' "$TMP_DIR/stale-partition-clean-receipt.yml"

expect_pass "schema-only profile validator" "$PROFILE_VALIDATOR"
expect_pass "valid profile" "$PROFILE_VALIDATOR" --profile "$TMP_DIR/valid-profile.yml"
expect_pass "schema-only receipt validator" "$RECEIPT_VALIDATOR"
expect_pass "valid receipt" "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/valid-receipt.yml"
expect_pass "valid partition-clean archive-ready receipt" "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/partition-clean-archive-ready-receipt.yml"
expect_pass "workflow validator" "$WORKFLOW_VALIDATOR"

mutate_profile_expect_fail "missing profile gate declarations" 'del(.publication_checks)'
mutate_profile_expect_fail "branch-no-pr PR fallback forbidden" '.pr_policy.fallback_to_pr = true'
mutate_profile_expect_fail "stash policy cannot widen" '.stash_policy.mode = "allowed"'
mutate_profile_expect_fail "self authorization forbidden" '.packet_execution.self_authorization_allowed = true'
mutate_profile_expect_fail "promotion requirements required" 'del(.promotion_requirements)'

mutate_receipt_expect_fail "missing implementation conformance" 'del(.implementation_conformance.receipt_ref)'
mutate_receipt_expect_fail "stale accepted review authorization" '.target_packet.accepted_review_fresh = false'
mutate_receipt_expect_fail "missing implementation authorization" 'del(.target_packet.implementation_authorization_ref)'
mutate_receipt_expect_fail "missing drift churn receipt" 'del(.post_implementation_drift_churn.receipt_ref)'
mutate_receipt_expect_fail "missing promotion receipt" 'del(.promotion.receipt_ref)'
mutate_receipt_expect_fail "stale promotion receipt" '.promotion.fresh = false'
mutate_receipt_expect_fail "missing packet closeout receipt" 'del(.packet_closeout.receipt_ref)'
mutate_receipt_expect_fail "missing terminal closeout receipt" 'del(.terminal_closeout.receipt_ref)'
mutate_receipt_expect_fail "missing archive receipt" 'del(.archive.receipt_ref)'
mutate_receipt_expect_fail "stale generated publication evidence" '.generated_publication.fresh = false'
mutate_receipt_expect_fail "direct generated output edit" '.generated_publication.direct_generated_output_edit_used = true'
mutate_receipt_expect_fail "missing governed mechanism integration receipt" '.governed_mechanism_integration.required = true | .governed_mechanism_integration.receipt_refs = []'
mutate_receipt_expect_fail "branch-no-pr landing without authorization" '.branch_authorization.landing_performed = true | .branch_authorization.landing_authorization_ref = "not-applicable"'
mutate_receipt_expect_fail "branch cleanup without authorization" '.branch_authorization.branch_cleanup_performed = true | .branch_authorization.cleanup_authorization_ref = "not-applicable"'
mutate_receipt_expect_fail "repo hygiene deletion without cleanup authorization" '.lifecycle_residue_cleanup.cleanup_performed = true | .lifecycle_residue_cleanup.cleanup_authorization_refs = []'
expect_fail "stale partition-clean order override digest" "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/stale-partition-clean-receipt.yml"
mutate_receipt_expect_fail "missing terminal current-state proof" 'del(.terminal_current_state_proof.evidence_ref)'
mutate_receipt_expect_fail "dirty worktree cleaned overclaim" '.worktree_hygiene.dirty_worktree = true'
mutate_receipt_expect_fail "main origin landed ref mismatch" '.final_sync.main_origin_landed_ref_equal = false'
mutate_receipt_expect_fail "generated prompt used as authority" '.non_authority_classification.generated_prompts = "authority"'
mutate_receipt_expect_fail "proposal-local file used as authority" '.non_authority_classification.proposal_local_files = "authority"'
mutate_receipt_expect_fail "aggregate receipt replacing target-owned receipts" '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts = true'

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
