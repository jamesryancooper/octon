#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh"
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

cat >"$TMP_DIR/documented-change.yml" <<'YAML'
schema_version: feature-catalog-drift-receipt-v1
receipt_id: test-documented-change
emitted_at: "2026-06-27T00:00:00Z"
target:
  path: .octon/inputs/exploratory/proposals/architecture/fixture-documented-change
  target_type: proposal-packet
  promotion_targets:
    - .octon/framework/product/features/catalog.yml
catalog_validation:
  validator_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
  catalog_ref: .octon/framework/product/features/catalog.yml
  schema_ref: .octon/framework/product/contracts/product-feature-catalog-v1.schema.json
  verdict: pass
drift_result:
  outcome: documented-change
  unresolved_count: 0
  affected_feature_ids:
    - run-first-runtime-lifecycle
  required_documentation_actions: []
findings:
  - feature_id: run-first-runtime-lifecycle
    feature_name: Run-First Runtime Lifecycle
    classification: documented-change
    status: resolved
    evidence_refs:
      - .octon/framework/engine/runtime/crates/kernel/src/run_binding.rs
    documentation_action: catalog entry and feature note are present
    authority_note: catalog navigation remains non-authority
blockers: []
non_authority_boundary:
  raw_inputs_non_authority: true
  generated_outputs_non_authority: true
  host_ui_state_non_authority: true
  chat_model_memory_non_authority: true
  tool_availability_non_authority: true
  evidence_not_authorization: true
  catalog_navigation_only: true
authority_notes:
  - feature catalog drift receipt is retained evidence only
next_route: continue-closeout
YAML

cat >"$TMP_DIR/blocked-missing.yml" <<'YAML'
schema_version: feature-catalog-drift-receipt-v1
receipt_id: test-blocked-missing
emitted_at: "2026-06-27T00:00:00Z"
target:
  path: .octon/inputs/exploratory/proposals/architecture/fixture-blocked-missing
  target_type: proposal-packet
  promotion_targets:
    - .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh
catalog_validation:
  validator_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
  catalog_ref: .octon/framework/product/features/catalog.yml
  schema_ref: .octon/framework/product/contracts/product-feature-catalog-v1.schema.json
  verdict: pass
drift_result:
  outcome: blocked-unresolved-drift
  unresolved_count: 1
  affected_feature_ids:
    - fixture-missing-feature
  required_documentation_actions:
    - add a catalog entry before closeout
findings:
  - feature_id: fixture-missing-feature
    feature_name: Fixture Missing Feature
    classification: missing-catalog-entry
    status: unresolved
    evidence_refs:
      - .octon/framework/capabilities/runtime/commands/fixture.md
    documentation_action: add a catalog entry before closeout
    authority_note: authored runtime evidence is required before the catalog can be updated
blockers:
  - class: feature-catalog-drift
    detail: missing feature catalog entry
    evidence_ref: .octon/framework/capabilities/runtime/commands/fixture.md
    status: open
non_authority_boundary:
  raw_inputs_non_authority: true
  generated_outputs_non_authority: true
  host_ui_state_non_authority: true
  chat_model_memory_non_authority: true
  tool_availability_non_authority: true
  evidence_not_authorization: true
  catalog_navigation_only: true
authority_notes:
  - unresolved drift blocks closeout claims only
next_route: revise-product-feature-catalog
YAML

cp "$TMP_DIR/documented-change.yml" "$TMP_DIR/invalid-boundary.yml"
yq -i '.non_authority_boundary.generated_outputs_non_authority = false' "$TMP_DIR/invalid-boundary.yml"

expect_pass "schema-only validator" "$VALIDATOR"
expect_pass "documented change receipt" "$VALIDATOR" --receipt "$TMP_DIR/documented-change.yml"
expect_pass "blocked missing catalog receipt" "$VALIDATOR" --receipt "$TMP_DIR/blocked-missing.yml"
expect_fail "invalid non-authority boundary" "$VALIDATOR" --receipt "$TMP_DIR/invalid-boundary.yml"

for fixture in missing-catalog-entry stale-ref status-mismatch probably-not-product-feature; do
  expect_pass "fixture $fixture" "$VALIDATOR" --fixture "$fixture"
done

echo "Test summary: passed=$pass_count failed=$fail_count"
[[ "$fail_count" -eq 0 ]]
