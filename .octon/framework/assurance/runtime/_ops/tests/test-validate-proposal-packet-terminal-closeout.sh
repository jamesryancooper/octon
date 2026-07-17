#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
PROFILE_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-profile.sh"
RECEIPT_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-receipt.sh"
WORKFLOW_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh"
TMP_DIR="$(mktemp -d)"
REPO_FIXTURE_ROOT="$ROOT_DIR/.octon/state/evidence/runs/workflows/test-partition-clean-terminal-$$"
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

expect_no_packet_specific_terminal_closeout_logic() {
  local description="$1" matches_file
  matches_file="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.log"
  if grep -nE 'proposal-program-delivery|architecture/proposal-program-delivery|state/evidence/validation/proposals/proposal-program-delivery|generated/proposals/artifacts/architecture/proposal-program-delivery' \
    "$ROOT_DIR/.octon/framework/engine/runtime/crates/kernel/src/workflow.rs" \
    "$ROOT_DIR/.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs" >"$matches_file" 2>&1; then
    cat "$matches_file"
    fail "$description"
  else
    pass "$description"
  fi
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
  fixture_ref_base=".octon/state/evidence/runs/workflows/test-partition-clean-terminal-$$"
  classifier_ref="$fixture_ref_base/worktree-hygiene-classifier.yml"
  report_ref="$fixture_ref_base/closeout-worktree-report.yml"
  return_ref="$fixture_ref_base/lifecycle-interaction-return.json"
  override_ref="$fixture_ref_base/proposal-packet-delivery-order-override-receipt.yml"
  classifier_path="$ROOT_DIR/$classifier_ref"
  report_path="$ROOT_DIR/$report_ref"
  return_path="$ROOT_DIR/$return_ref"
  override_path="$ROOT_DIR/$override_ref"
  fingerprint="sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

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
run_id: closeout-worktree-fixture-partition-clean
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
    target_lifecycle_outcome: preserved
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
        - .octon/inputs/exploratory/proposals/architecture/example-terminal-closeout
      exclude_paths:
        - .git
    proposal_program_handoff_authorization:
      authorization_grant: fixture preserve/exclude
      child_id: example-terminal-closeout
      route_id: closeout-worktree
      interaction_request_ref: $fixture_ref_base/lifecycle-interaction-request.json
      classifier_output_ref: $classifier_ref
      classifier_output_digest: $classifier_digest
      authorized_foreign_fingerprint: $fingerprint
      foreign_fingerprint: $fingerprint
      authorized_paths:
        - .octon/inputs/exploratory/proposals/architecture/example-terminal-closeout
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
    path: .octon/inputs/exploratory/proposals/architecture/example-terminal-closeout
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
  "interaction_id": "partition-clean-terminal-fixture-return",
  "consumer": {
    "lifecycle_id": "closeout-worktree",
    "run_id": "closeout-worktree-fixture-partition-clean"
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
    ".octon/inputs/exploratory/proposals/architecture/example-terminal-closeout",
    ".octon/state/evidence/local"
  ]
}
JSON
  return_digest="$(digest_file "$return_path")"

  cat >"$override_path" <<YAML
schema_version: proposal-packet-delivery-order-override-receipt-v1
receipt_id: partition-clean-terminal-fixture
emitted_at: "2026-06-26T00:00:00Z"
target_packet:
  path: .octon/inputs/exploratory/proposals/architecture/example-terminal-closeout
  accepted_review_digest: sha256:1111111111111111111111111111111111111111111111111111111111111111
run_binding:
  delivery_run_id: partition-clean-terminal-fixture-run
  profile_id: test-terminal-profile
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
schema_version: proposal-packet-terminal-closeout-profile-v1
profile_id: test-terminal-profile
created_at: "2026-06-13T00:00:00Z"
packet:
  proposal_id: example-terminal-closeout
  path: .octon/inputs/exploratory/proposals/architecture/example-terminal-closeout
  expected_status: implemented
target_outcome: archive-ready
containment_policy:
  reason_code: RP00_CONTAINMENT_PUBLICATION_DISABLED
  publication_effects_enabled: false
  exact_work_preserved: true
route_preference: none-closeout-only
pr_policy:
  allow_pr_creation: false
  allow_branch_no_pr: false
  exact_sha_required: true
publication_freshness_policy:
  canonical_publisher_only: true
  direct_generated_edits_forbidden: true
  validator_family_map:
    - target_family: capability-publication
      validators:
        - validate-capability-publication-state.sh
hygiene_policy:
  repo_hygiene_delegation_only: true
  worktree_foreign_residue_blocks_archive_ready: true
  cleanup_authorization_required: false
expected_retained_evidence:
  - .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/validation.log
required_validators_by_target_family:
  - target_family: workflow
    validators:
      - validate-proposal-packet-terminal-closeout-workflow.sh
post_integration_architecture_review_policy:
  run_when_applicable: true
  evidence_only: true
packet_terminal_evaluator_policy:
  required_for:
    - blocked
  evidence_only: true
git_github_hosted_check_policy:
  delegate_to_closeout_routes: false
  exact_sha_required_when_hosted: true
  landing_authorization_required: false
  branch_cleanup_authorization_required: false
blocker_reporting:
  required: true
  allowed_blocker_classes:
    - none
    - stale-evidence
    - hygiene-blocker
  allowed_next_routes:
    - archive-proposal
    - closeout-worktree
    - repo-hygiene-cleanup
forbidden_authority_requests:
  archive_relocation: false
  proposal_status_mutation: false
  git_mutation: false
  residue_deletion: false
  generated_direct_publication: false
  host_state_authority: false
  chat_or_model_memory_authority: false
  tool_authority: false
YAML

state_entry() {
  local state_id="$1"
  cat <<YAML
  - state_id: $state_id
    input_refs:
      - .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/input.log
    validator_command_refs:
      - validate-proposal-packet-terminal-closeout-workflow.sh
    output_evidence_refs:
      - .octon/state/evidence/runs/workflows/20260613T000000Z-proposal-packet-terminal-closeout-test/reports/$state_id-report.md
      - .octon/state/evidence/runs/workflows/20260613T000000Z-proposal-packet-terminal-closeout-test/stages/$state_id/outcome.json
      - .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/$state_id.log
    state_verdict: pass
    retry_count: 0
    resume_cursor: complete
YAML
}

cat >"$TMP_DIR/valid-receipt.yml" <<YAML
schema_version: proposal-packet-terminal-closeout-receipt-v1
terminal_run_id: test-terminal-run
terminalized_at: "2026-06-13T00:00:00Z"
packet:
  proposal_id: example-terminal-closeout
  path: .octon/inputs/exploratory/proposals/architecture/example-terminal-closeout
  proposal_kind: architecture
  status: implemented
target_outcome: archive-ready
terminal_verdict: archive-ready
archive_ready: yes
profile:
  profile_ref: .octon/state/evidence/runs/workflows/20260613T000000Z-proposal-packet-terminal-closeout-test/profile.yml
  profile_digest: sha256:0000000000000000000000000000000000000000000000000000000000000000
  profile_validation_evidence_ref: .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/profile.log
state_ledger:
$(state_entry bind-profile)
$(state_entry verify-durable-implementation-state)
$(state_entry verify-implementation-conformance)
$(state_entry verify-post-implementation-drift)
$(state_entry validate-feature-catalog-drift)
$(state_entry validate-publication-freshness)
$(state_entry classify-repo-hygiene)
$(state_entry classify-worktree-hygiene)
$(state_entry run-evidence-only-reviews)
$(state_entry resolve-git-github-route)
$(state_entry emit-terminal-receipt)
durable_implementation_state_evidence_refs:
  - .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/durable-state.log
implementation:
  conformance_receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-terminal-closeout/support/implementation-conformance-review.md
  conformance_validator_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh
  conformance_fresh: true
  post_implementation_drift_receipt_ref: .octon/inputs/exploratory/proposals/architecture/example-terminal-closeout/support/post-implementation-drift-churn-review.md
  post_implementation_drift_validator_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh
  post_implementation_drift_fresh: true
feature_catalog_drift:
  receipt_ref: .octon/state/evidence/runs/workflows/20260613T000000Z-proposal-packet-terminal-closeout-test/feature-catalog-drift-receipt.yml
  validator_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh
  fresh: true
  verdict: pass
  outcome: documented-change
  unresolved_count: 0
  affected_feature_ids:
    - run-first-runtime-lifecycle
  required_documentation_actions: []
  authority_notes:
    - feature catalog drift receipt is evidence-only and non-authorizing
publication_freshness:
  validators:
    - validator_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
      evidence_ref: .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/generated-non-authority.log
      verdict: pass
      fresh: true
  publisher_refresh_receipts:
    - .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/publisher.log
  rerun_evidence_refs:
    - .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/rerun.log
  direct_generated_output_edit_used: false
generated_input_non_authority:
  validation_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
  proposal_inputs_non_authority: true
  generated_outputs_non_authority: true
  generated_prompts_non_authority: true
  host_state_non_authority: true
  chat_state_non_authority: true
  tool_state_non_authority: true
  model_memory_non_authority: true
run_health:
  validation_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh
  verdict: pass
capability_publication:
  validation_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
  verdict: pass
extension_publication:
  validation_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
  verdict: pass
repo_hygiene:
  classification_ref: .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/repo-hygiene.log
  cleanup_performed: false
  cleanup_authorization_refs: []
  unauthorized_deletion_performed: false
worktree_hygiene:
  classification_ref: .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/worktree.log
  verdict: pass
  foreign_or_ambiguous_count: 0
  dirty_worktree: false
evidence_only_reviews:
  post_integration_architecture_review_ref: .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/post-integration-architecture-review.md
  post_integration_architecture_review_authority: evidence-only
  packet_terminal_evaluator_ref: .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/terminal-evaluator.md
  packet_terminal_evaluator_authority: evidence-only
  lifecycle_postmortem_ref: .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/lifecycle-postmortem.md
  lifecycle_postmortem_authority: evidence-only
git_github_route:
  route_ref: closeout-change
  mutation_delegated: true
  branch_no_pr: true
  exact_sha_checks_ref: .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/exact-sha.log
  landing_authorization_ref: .octon/state/evidence/runs/skills/closeout-change/test/branch-landing-authorization.json
  branch_cleanup_required: true
  branch_cleanup_authorization_ref: .octon/state/evidence/runs/skills/closeout-change/test/branch-cleanup-authorization.json
archive_boundary:
  archive_owner_ref: .octon/framework/orchestration/runtime/workflows/meta/archive-proposal/workflow.yml
  relocation_performed: false
blocker:
  class: none
  detail: no blocker
  failing_evidence_ref: not-applicable
  next_canonical_route: archive-proposal
retained_evidence_inventory:
  - .octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/validation.log
expected_no_new_evidence_loop: true
target_owned_evidence_policy:
  cites_target_owned_evidence: true
  aggregate_receipt_replaces_target_owned_receipts: false
non_authority_declarations:
  proposal_inputs: non-authority
  generated_outputs: derived-only-non-authority
  generated_prompts: non-authority
  host_state: non-authority
  dashboards: non-authority
  chat: non-authority
  tool_state: non-authority
  model_memory: non-authority
YAML

cp "$TMP_DIR/valid-receipt.yml" "$TMP_DIR/blocked-receipt.yml"
yq -i '.terminal_verdict = "blocked" | .archive_ready = "no" | .blocker.class = "hygiene-blocker" | .blocker.detail = "worktree residue remains" | .blocker.failing_evidence_ref = ".octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/worktree.log" | .blocker.next_canonical_route = "closeout-worktree"' "$TMP_DIR/blocked-receipt.yml"

write_partition_clean_fixtures
cp "$TMP_DIR/valid-receipt.yml" "$TMP_DIR/partition-clean-receipt.yml"
PARTITION_OVERRIDE_REF="$PARTITION_OVERRIDE_REF" \
PARTITION_OVERRIDE_DIGEST="$PARTITION_OVERRIDE_DIGEST" \
PARTITION_REPORT_REF="$PARTITION_REPORT_REF" \
PARTITION_RETURN_REF="$PARTITION_RETURN_REF" \
yq -i '
  .worktree_hygiene.classification_ref = strenv(PARTITION_REPORT_REF) |
  .worktree_hygiene.verdict = "blocked" |
  .worktree_hygiene.foreign_or_ambiguous_count = 1 |
  .worktree_hygiene.dirty_worktree = true |
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
' "$TMP_DIR/partition-clean-receipt.yml"

cp "$TMP_DIR/partition-clean-receipt.yml" "$TMP_DIR/stale-partition-clean-receipt.yml"
yq -i '.partition_clean_archive_readiness.order_override_receipt_digest = "sha256:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"' "$TMP_DIR/stale-partition-clean-receipt.yml"

expect_pass "schema-only profile validator" "$PROFILE_VALIDATOR"
expect_pass "valid profile" "$PROFILE_VALIDATOR" --profile "$TMP_DIR/valid-profile.yml"
expect_pass "schema-only receipt validator" "$RECEIPT_VALIDATOR"
expect_pass "valid archive-ready receipt" "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/valid-receipt.yml"
expect_pass "valid partition-clean archive-ready receipt" "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/partition-clean-receipt.yml"
expect_pass "valid blocked receipt" "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/blocked-receipt.yml"
expect_pass "workflow validator" "$WORKFLOW_VALIDATOR"
expect_no_packet_specific_terminal_closeout_logic "generic terminal closeout production has no proposal-program-delivery hardcoding"

mutate_receipt_expect_fail "missing implementation conformance receipt" 'del(.implementation.conformance_receipt_ref)'
mutate_receipt_expect_fail "missing archive readiness flag" 'del(.archive_ready)'
mutate_receipt_expect_fail "archive-ready verdict without archive readiness flag" '.archive_ready = "no"'
mutate_receipt_expect_fail "blocked verdict with archive readiness flag" '.terminal_verdict = "blocked" | .archive_ready = "yes" | .blocker.class = "hygiene-blocker" | .blocker.detail = "worktree residue remains" | .blocker.failing_evidence_ref = ".octon/state/evidence/validation/proposals/example-terminal-closeout/20260613T000000Z/worktree.log" | .blocker.next_canonical_route = "closeout-worktree"'
mutate_receipt_expect_fail "parent summary substituted for child receipt" '.implementation.conformance_receipt_ref = ".octon/inputs/exploratory/proposals/architecture/example-terminal-closeout/support/proposal-closeout.md"'
mutate_receipt_expect_fail "stale implementation conformance evidence" '.implementation.conformance_fresh = false'
mutate_receipt_expect_fail "missing post implementation drift receipt" 'del(.implementation.post_implementation_drift_receipt_ref)'
mutate_receipt_expect_fail "unresolved feature catalog drift blocks archive-ready" '.feature_catalog_drift.outcome = "blocked-unresolved-drift" | .feature_catalog_drift.unresolved_count = 1'
mutate_receipt_expect_fail "missing feature catalog drift receipt" 'del(.feature_catalog_drift.receipt_ref)'
mutate_receipt_expect_fail "generated prompt substituted for child receipt authority" '.implementation.post_implementation_drift_receipt_ref = ".octon/generated/prompts/example-terminal-closeout.md"'
mutate_receipt_expect_fail "stale publication evidence" '.publication_freshness.validators[0].fresh = false'
mutate_receipt_expect_fail "direct generated edit used" '.publication_freshness.direct_generated_output_edit_used = true'
mutate_receipt_expect_fail "generated prompt used as non-authority validation authority" '.generated_input_non_authority.validation_ref = ".octon/generated/prompts/example-terminal-closeout.md"'
mutate_receipt_expect_fail "missing generated non-authority validation" 'del(.generated_input_non_authority.validation_ref)'
mutate_receipt_expect_fail "missing run-health validation" 'del(.run_health.validation_ref)'
mutate_receipt_expect_fail "missing capability publication validation" 'del(.capability_publication.validation_ref)'
mutate_receipt_expect_fail "missing extension publication validation" 'del(.extension_publication.validation_ref)'
mutate_receipt_expect_fail "repo cleanup without authorization" '.repo_hygiene.cleanup_performed = true | .repo_hygiene.cleanup_authorization_refs = []'
mutate_receipt_expect_fail "worktree hygiene blocked" '.worktree_hygiene.verdict = "blocked"'
expect_fail "stale partition-clean order override digest" "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/stale-partition-clean-receipt.yml"
mutate_receipt_expect_fail "architecture review not evidence only" '.evidence_only_reviews.post_integration_architecture_review_authority = "archive-authority"'
mutate_receipt_expect_fail "terminal evaluator not evidence only" '.evidence_only_reviews.packet_terminal_evaluator_authority = "archive-authority"'
mutate_receipt_expect_fail "lifecycle postmortem not evidence only" '.evidence_only_reviews.lifecycle_postmortem_authority = "archive-authority"'
mutate_receipt_expect_fail "branch no pr missing exact sha" '.git_github_route.exact_sha_checks_ref = "not-applicable"'
mutate_receipt_expect_fail "branch no pr missing landing authorization" '.git_github_route.landing_authorization_ref = "not-applicable"'
mutate_receipt_expect_fail "branch cleanup missing authorization" '.git_github_route.branch_cleanup_authorization_ref = "not-applicable"'
mutate_receipt_expect_fail "foreign worktree residue remains" '.worktree_hygiene.foreign_or_ambiguous_count = 1'
mutate_receipt_expect_fail "dirty worktree remains" '.worktree_hygiene.dirty_worktree = true'
mutate_receipt_expect_fail "archive relocation performed" '.archive_boundary.relocation_performed = true'
mutate_receipt_expect_fail "target-owned evidence replaced" '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts = true'
mutate_receipt_expect_fail "new evidence loop expected" '.expected_no_new_evidence_loop = false'
mutate_receipt_expect_fail "git github mutation not delegated" '.git_github_route.mutation_delegated = false'
mutate_receipt_expect_fail "missing stage report" 'del(.state_ledger[0].output_evidence_refs[0])'
mutate_receipt_expect_fail "missing stage outcome" 'del(.state_ledger[0].output_evidence_refs[1])'
mutate_receipt_expect_fail "executor timeout reported as success" '.state_ledger[0].output_evidence_refs[0] = ".octon/state/evidence/runs/workflows/20260613T000000Z-proposal-packet-terminal-closeout-test/stages/bind-profile/executor-timeout.yml"'
mutate_receipt_expect_fail "terminal profile outside owning lifecycle" '.profile.profile_ref = ".octon/inputs/exploratory/proposals/architecture/example-terminal-closeout/support/profile.yml"'
mutate_receipt_expect_fail "archive-ready claims cleaned before terminal proof" '.retained_evidence_inventory += [".octon/state/evidence/runs/skills/closeout-change/test/cleaned.yml"]'

echo "Test summary: passed=$pass_count failed=$fail_count"
[[ "$fail_count" -eq 0 ]]
