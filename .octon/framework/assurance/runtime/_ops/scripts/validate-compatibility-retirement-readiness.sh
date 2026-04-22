#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

main() {
  echo "== Compatibility Retirement Readiness Validation =="

  bash "$SCRIPT_DIR/validate-compatibility-retirement.sh" >/dev/null \
    && pass "compatibility retirement validator passes" \
    || fail "compatibility retirement validator failed"
  bash "$SCRIPT_DIR/validate-retirement-registry.sh" >/dev/null \
    && pass "retirement registry validator passes" \
    || fail "retirement registry validator failed"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
