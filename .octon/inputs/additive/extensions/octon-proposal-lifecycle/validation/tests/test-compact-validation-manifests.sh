#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"

pass_count=0
fail_count=0

pass() {
  printf 'PASS: %s\n' "$1"
  pass_count=$((pass_count + 1))
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  fail_count=$((fail_count + 1))
}

assert_contains() {
  local label="$1" file="$2" needle="$3"
  if rg -F -- "$needle" "$file" >/dev/null; then
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
  local helper generator validator spec publication_test run_health_test
  helper="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validator-result-common.sh"
  generator="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh"
  validator="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh"
  spec="$REPO_ROOT/.octon/framework/engine/runtime/spec/operator-read-models-v1.md"
  publication_test="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/tests/test-validate-publication-freshness-gates.sh"
  run_health_test="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/tests/test-run-health-read-model.sh"

  assert_path_exists "validator result manifest test exists" ".octon/framework/assurance/runtime/_ops/tests/test-validator-result-manifest.sh"
  assert_contains "validator helper emits manifest schema" "$helper" "octon-validator-result-manifest-v1"
  assert_contains "validator helper emits source digests" "$helper" "source_digests"
  assert_contains "validator helper records failing slices" "$helper" "failing_slice_refs"

  assert_contains "run-health generator emits compact manifest schema" "$generator" "run-health-compact-manifest-v1"
  assert_contains "run-health generator emits compact manifest filename" "$generator" "run-health-compact-manifest.yml"
  assert_contains "run-health validator checks compact manifest schema" "$validator" "validate_compact_manifest"
  assert_contains "run-health validator checks compact digest drift" "$validator" "compact_manifest_digest drift"

  assert_contains "publication test checks manifest schema" "$publication_test" "octon-validator-result-manifest-v1"
  assert_contains "publication test checks stale freshness fail-closed behavior" "$publication_test" "stale-freshness"
  assert_contains "run-health test checks compact manifest receipt" "$run_health_test" "compact_manifest_ref"
  assert_contains "run-health test checks compact source digest mutation" "$run_health_test" "case_compact_manifest_source_digest_mutation_fails"

  assert_contains "operator read-model spec documents compact manifest preference" "$spec" "Compact Manifest Preference"
  assert_contains "operator read-model spec names compact manifest" "$spec" "run-health-compact-manifest.yml"
  assert_contains "operator read-model spec preserves non-authority boundary" "$spec" "It is not authority"

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
