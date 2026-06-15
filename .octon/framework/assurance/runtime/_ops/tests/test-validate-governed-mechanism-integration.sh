#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
PROFILE_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-profile.sh"
RECEIPT_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-receipt.sh"
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
  target="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.profile.yml"
  cp "$TMP_DIR/valid-profile.yml" "$target"
  yq -i "$expression" "$target"
  expect_fail "$description" bash "$PROFILE_VALIDATOR" --profile "$target"
}

mutate_receipt_expect_fail() {
  local description="$1" expression="$2" target
  target="$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.receipt.yml"
  cp "$TMP_DIR/valid-receipt.yml" "$target"
  yq -i "$expression" "$target"
  expect_fail "$description" bash "$RECEIPT_VALIDATOR" --receipt "$target" --package "$TMP_DIR/package"
}

require_tool yq

mkdir -p "$TMP_DIR/package"

cat >"$TMP_DIR/valid-profile.yml" <<'YAML'
schema_version: governed-mechanism-integration-profile-v1
profile_id: governed-mechanism-integration-verification
mechanism:
  mechanism_id: governed-mechanism-integration-verification
  display_name: Governed Mechanism Integration Verification
  index_ref: .octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/index.yml
owners:
  - ref: .octon/framework/product/features/governed-mechanism-integration-verification.md
    role: product navigation owner
    authority_class: navigation-only
product_feature_refs:
  - ref: .octon/framework/product/features/governed-mechanism-integration-verification.md
    role: feature note
    authority_class: navigation-only
doctrine_refs:
  - ref: .octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/README.md
    role: governed mechanism index guidance
    authority_class: architecture-governance-navigation
documentation_refs:
  - ref: .octon/framework/orchestration/runtime/workflows/meta/verify-governed-mechanism-integration/README.md
    role: workflow docs
    authority_class: runtime-workflow
workflows:
  - ref: .octon/framework/orchestration/runtime/workflows/meta/verify-governed-mechanism-integration/workflow.yml
    role: integration verification workflow
    authority_class: runtime-workflow
skills:
  - ref: .octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle/SKILL.md
    role: lifecycle hook guidance
    authority_class: publication-input-only
commands:
  - ref: .octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/run-packet-implementation/stages/01-run-packet-implementation.md
    role: implementation prompt hook
    authority_class: publication-input-only
schemas:
  - ref: .octon/framework/product/contracts/governed-mechanism-integration-profile-v1.schema.json
    role: profile schema
    authority_class: product-contract
validators:
  - ref: .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-profile.sh
    role: profile validator
    authority_class: runtime-validator
generated_projections:
  - ref: .octon/generated/proposals/registry.yml
    role: generated proposal registry
    authority_class: generated-operator-read-model
evidence_roots:
  - ref: .octon/state/evidence/runs/workflows/<run-id>/governed-mechanism-integration/<mechanism-id>/
    role: retained workflow evidence
    authority_class: evidence
lifecycle_hooks:
  - ref: .octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/closeout-packet/stages/01-closeout-packet.md
    role: closeout hook
    authority_class: publication-input-only
extension_boundaries:
  - ref: .octon/inputs/additive/extensions/octon-proposal-lifecycle/
    role: proposal lifecycle extension inputs
    authority_class: publication-input-only
authority_boundaries:
  durable_authority: framework, product, extension input, and mechanism index targets only
  proposal_support: evidence only
non_authority_boundaries:
  proposal_inputs: non-authority
  generated_outputs: derived-only-non-authority
  generated_prompts: non-authority
  host_state: non-authority
  dashboards: non-authority
  chat: non-authority
  tool_state: non-authority
  model_memory: non-authority
  current_state_architecture_review: evidence-only
  lifecycle_postmortem: evidence-only
not_applicable: []
YAML

cat >"$TMP_DIR/valid-receipt.yml" <<YAML
schema_version: governed-mechanism-integration-receipt-v1
mechanism_id: governed-mechanism-integration-verification
proposal_path: $TMP_DIR/package
verdict: pass
unresolved_items_count: 0
blockers: []
mechanism_profile_ref: .octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/profiles/governed-mechanism-integration-verification.profile.yml
implemented_packet_digest: sha256:1111111111111111111111111111111111111111111111111111111111111111
current_state_architecture_review_ref: .octon/state/evidence/validation/proposals/example/20260613T000000Z/current-state-architecture-review.yml
implementation_conformance_ref: .octon/inputs/exploratory/proposals/architecture/example/support/implementation-conformance-review.md
post_implementation_drift_ref: .octon/inputs/exploratory/proposals/architecture/example/support/post-implementation-drift-churn-review.md
generated_publication_refs:
  - .octon/state/evidence/validation/proposals/example/20260613T000000Z/proposal-registry-check.log
terminal_freshness_refs:
  - .octon/state/evidence/validation/proposals/example/20260613T000000Z/terminal-freshness.log
validator_refs:
  - .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-receipt.sh
  - .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh
evidence_refs:
  - .octon/state/evidence/runs/workflows/test-run/governed-mechanism-integration/governed-mechanism-integration-verification/receipt.yml
authority_boundary_verdict: pass
surface_coverage:
  - surface_class: workflows
    status: covered
    evidence_ref: .octon/framework/orchestration/runtime/workflows/meta/verify-governed-mechanism-integration/workflow.yml
  - surface_class: lifecycle-postmortem
    status: not_applicable
    evidence_ref: evidence-only-not-run
    rationale: Not run for fixture; authority remains evidence-only.
non_authority_classification:
  proposal_inputs: non-authority
  generated_outputs: derived-only-non-authority
  generated_prompts: non-authority
  host_state: non-authority
  dashboards: non-authority
  chat: non-authority
  tool_state: non-authority
  model_memory: non-authority
  current_state_architecture_review: evidence-only
  lifecycle_postmortem: evidence-only
mode_specific_coverage:
  mode: closeout
  terminal_freshness_required: true
  terminal_freshness_status: pass
  current_state_architecture_review_role: evidence-only
  lifecycle_postmortem_authority: evidence-only
YAML

expect_pass "schema-only profile validator" bash "$PROFILE_VALIDATOR"
expect_pass "schema-only receipt validator" bash "$RECEIPT_VALIDATOR"
expect_pass "valid profile" bash "$PROFILE_VALIDATOR" --profile "$TMP_DIR/valid-profile.yml"
expect_pass "valid receipt" bash "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/valid-receipt.yml" --package "$TMP_DIR/package"

mkdir -p "$TMP_DIR/archive-package"
cat >"$TMP_DIR/archive-package/proposal.yml" <<YAML
schema_version: proposal-v1
proposal_id: governed-mechanism-integration-verification
proposal_kind: architecture
status: archived
archive:
  original_path: $TMP_DIR/original-package
  disposition: implemented
YAML
cp "$TMP_DIR/valid-receipt.yml" "$TMP_DIR/archived-source-receipt.yml"
ORIGINAL_PACKAGE="$TMP_DIR/original-package" yq -i '.proposal_path = strenv(ORIGINAL_PACKAGE)' "$TMP_DIR/archived-source-receipt.yml"
expect_pass "archived receipt may bind original package path" bash "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/archived-source-receipt.yml" --package "$TMP_DIR/archive-package"

cp "$TMP_DIR/archive-package/proposal.yml" "$TMP_DIR/archive-package/proposal-mismatch.yml"
MISMATCH_PACKAGE="$TMP_DIR/other-package" yq -i '.archive.original_path = strenv(MISMATCH_PACKAGE)' "$TMP_DIR/archive-package/proposal.yml"
expect_fail "archived receipt rejects mismatched original path" bash "$RECEIPT_VALIDATOR" --receipt "$TMP_DIR/archived-source-receipt.yml" --package "$TMP_DIR/archive-package"
mv "$TMP_DIR/archive-package/proposal-mismatch.yml" "$TMP_DIR/archive-package/proposal.yml"

mutate_profile_expect_fail "profile missing required surface without rationale" '.workflows = [] | .not_applicable = []'
mutate_profile_expect_fail "profile stale placeholder marker" '.documentation_refs[0].role = "placeholder"'
mutate_profile_expect_fail "profile generated output authority" '.non_authority_boundaries.generated_outputs = "authority"'

mutate_receipt_expect_fail "receipt missing validator refs" '.validator_refs = []'
mutate_receipt_expect_fail "receipt stale digest binding" '.implemented_packet_digest = "sha256:0000000000000000000000000000000000000000000000000000000000000000"'
mutate_receipt_expect_fail "receipt stale aliases" '.evidence_refs += ["stale alias"]'
mutate_receipt_expect_fail "receipt stale proposal backrefs" '.evidence_refs += ["stale proposal backref"]'
mutate_receipt_expect_fail "receipt placeholder marker" '.evidence_refs += ["placeholder-marker"]'
mutate_receipt_expect_fail "receipt generated output authority" '.non_authority_classification.generated_outputs = "authority"'
mutate_receipt_expect_fail "receipt proposal local authority" '.non_authority_classification.proposal_inputs = "authority"'
mutate_receipt_expect_fail "receipt lifecycle postmortem gate authority" '.mode_specific_coverage.lifecycle_postmortem_authority = "acceptance-gate"'
mutate_receipt_expect_fail "receipt current-state architecture review whole gate" '.mode_specific_coverage.current_state_architecture_review_role = "whole-gate"'
mutate_receipt_expect_fail "receipt missing conformance ref" '.implementation_conformance_ref = "not-applicable"'
mutate_receipt_expect_fail "receipt missing drift ref" '.post_implementation_drift_ref = "not-applicable"'
mutate_receipt_expect_fail "receipt missing generated publication refs" '.generated_publication_refs = []'
mutate_receipt_expect_fail "receipt missing terminal freshness refs when required" '.terminal_freshness_refs = []'

echo "Test summary: passed=$pass_count failed=$fail_count"
[[ "$fail_count" -eq 0 ]]
