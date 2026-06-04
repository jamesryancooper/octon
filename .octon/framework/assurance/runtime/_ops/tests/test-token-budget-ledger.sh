#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-token-budget-ledger.sh"
FIXTURE_ROOT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/fixtures/token-budget-ledger-v1"

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

main() {
  assert_success "valid route ledger passes" \
    bash "$VALIDATOR" --root "$FIXTURE_ROOT" --ledger "valid-route/token-budget-ledger.json"

  assert_success "proposal-program mock regression fixture passes" \
    bash "$VALIDATOR" \
      --root "$FIXTURE_ROOT" \
      --baseline "proposal-program-mock-run/baseline/token-budget-ledger.json" \
      --candidate "proposal-program-mock-run/candidate/token-budget-ledger.json" \
      --threshold-percent 30

  assert_failure "authority-widening ledger fails closed" \
    bash "$VALIDATOR" --root "$FIXTURE_ROOT" --ledger "invalid-authority/token-budget-ledger.json"

  assert_failure "regression fixture fails when candidate grows too much" \
    bash "$VALIDATOR" \
      --root "$FIXTURE_ROOT" \
      --baseline "proposal-program-mock-run/baseline/token-budget-ledger.json" \
      --candidate "proposal-program-mock-run/regression/token-budget-ledger.json" \
      --threshold-percent 30

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
