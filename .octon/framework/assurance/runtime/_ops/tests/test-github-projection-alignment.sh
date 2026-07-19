#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-github-projection-alignment.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/octon-github-projection-test.XXXXXX")"
trap 'rm -rf -- "$TEST_ROOT"' EXIT
passed=0
failed=0

pass() { echo "PASS: $1"; passed=$((passed + 1)); }
fail() { echo "FAIL: $1" >&2; failed=$((failed + 1)); }
assert_success() { local label="$1"; shift; if "$@"; then pass "$label"; else fail "$label"; fi; }

copy_ref() {
  local fixture="$1" ref="$2"
  mkdir -p "$fixture/$(dirname "$ref")"
  cp "$ROOT_DIR/$ref" "$fixture/$ref"
}

create_fixture() {
  local name="$1" fixture
  fixture="$TEST_ROOT/$name"
  mkdir -p "$fixture"
  for ref in \
    .github/workflows/commit-and-branch-standards.yml \
    .github/workflows/pr-quality.yml \
    .octon/framework/execution-roles/practices/standards/github-control-plane-contract.json \
    .octon/framework/execution-roles/practices/github-autonomy-runbook.md \
    .octon/framework/execution-roles/_ops/scripts/github/capture-github-control-plane-snapshot.sh \
    .octon/framework/assurance/runtime/_ops/tests/test-github-control-plane-snapshot.sh \
    .octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh; do
    copy_ref "$fixture" "$ref"
  done
  printf '%s\n' "$fixture"
}

run_fixture() { bash "$VALIDATOR" --root "$1" >/dev/null; }

case_live_passes() { bash "$VALIDATOR" >/dev/null; }

case_effect_route_denies() {
  local fixture tmp
  fixture="$(create_fixture effect-route)"
  tmp="$fixture/contract.tmp"
  jq '.si00_containment.current_effect_routes = ["direct-main"]' "$fixture/.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json" >"$tmp"
  mv "$tmp" "$fixture/.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json"
  ! run_fixture "$fixture"
}

case_extra_check_denies() {
  local fixture tmp
  fixture="$(create_fixture extra-check)"
  tmp="$fixture/contract.tmp"
  jq '.rulesets.si00_bootstrap_main.required_checks += ["unsafe"]' "$fixture/.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json" >"$tmp"
  mv "$tmp" "$fixture/.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json"
  ! run_fixture "$fixture"
}

case_safe_producer_checkout_denies() {
  local fixture
  fixture="$(create_fixture checkout)"
  printf '\n# uses: actions/checkout@v4\n' >>"$fixture/.github/workflows/pr-quality.yml"
  ! run_fixture "$fixture"
}

case_missing_unsafe_disposition_denies() {
  local fixture tmp
  fixture="$(create_fixture disposition)"
  tmp="$fixture/contract.tmp"
  jq '.workflow_disposition.unsafe_until_rp06 -= [".github/workflows/pr-auto-merge.yml"]' "$fixture/.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json" >"$tmp"
  mv "$tmp" "$fixture/.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json"
  ! run_fixture "$fixture"
}

case_runbook_terminalization_gap_denies() {
  local fixture
  fixture="$(create_fixture runbook)"
  perl -0pi -e 's/no-resend/no resend/g' "$fixture/.octon/framework/execution-roles/practices/github-autonomy-runbook.md"
  ! run_fixture "$fixture"
}

case_capture_mutation_syntax_denies() {
  local fixture
  fixture="$(create_fixture capture-mutation)"
  printf '\n# gh api --method POST\n' >>"$fixture/.octon/framework/execution-roles/_ops/scripts/github/capture-github-control-plane-snapshot.sh"
  ! run_fixture "$fixture"
}

assert_success "live SI-00 projection passes" case_live_passes
assert_success "current provider effect route is denied" case_effect_route_denies
assert_success "extra bootstrap check is denied" case_extra_check_denies
assert_success "bootstrap producer checkout is denied" case_safe_producer_checkout_denies
assert_success "missing unsafe workflow disposition is denied" case_missing_unsafe_disposition_denies
assert_success "missing no-resend runbook boundary is denied" case_runbook_terminalization_gap_denies
assert_success "snapshot helper provider mutation syntax is denied" case_capture_mutation_syntax_denies

echo "Passed: $passed"
echo "Failed: $failed"
[[ "$failed" -eq 0 ]]
