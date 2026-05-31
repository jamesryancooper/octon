#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-lifecycle"
SCENARIO="$PACK_ROOT/validation/scenarios/proposal-program-runner-tests-fixtures.md"

pass_count=0
fail_count=0

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

assert_contains() {
  local label="$1" needle="$2"
  if rg -F -- "$needle" "$SCENARIO" >/dev/null; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_path_exists() {
  local label="$1" rel="$2"
  if [[ -e "$REPO_ROOT/$rel" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  if [[ -f "$SCENARIO" ]]; then
    pass "fixture matrix scenario exists"
  else
    fail "fixture matrix scenario is missing"
    printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
    return 1
  fi

  for coverage_class in \
    "behavior proof" \
    "boundary proof" \
    "runtime authorization proof" \
    "generated-output freshness proof" \
    "disclosure proof"; do
    assert_contains "coverage class listed: $coverage_class" "$coverage_class"
  done

  for source_id in R005 R006 R009 R016 R018 R019 R024 R033 R060 R061 R062; do
    assert_contains "source id mapped: $source_id" "$source_id"
  done

  for rel in \
    ".octon/framework/engine/runtime/crates/kernel/tests/proposal_program_cli.rs" \
    ".octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs" \
    ".octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh" \
    ".octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh" \
    ".octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-residue-fingerprint.sh" \
    ".octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-implementation-conformance.sh" \
    ".octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-post-implementation-drift.sh" \
    ".octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-authority-boundaries.sh" \
    ".octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-route-resolution.sh" \
    ".octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-pack-shape.sh"; do
    assert_contains "matrix references $rel" "$rel"
    assert_path_exists "referenced path exists: $rel" "$rel"
  done

  assert_contains "matrix declares non-authority status" "not Octon authority"
  assert_contains "matrix guards phase metadata boundary" "phase_id"
  assert_contains "matrix guards pre-dispatch failures" "block before executor dispatch"

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
