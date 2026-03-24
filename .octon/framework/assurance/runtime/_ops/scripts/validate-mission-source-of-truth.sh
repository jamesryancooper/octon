#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
has_pattern() {
  local pattern="$1"
  shift
  if command -v rg >/dev/null 2>&1; then
    rg -n -- "$pattern" "$@" >/dev/null 2>&1
  else
    grep -ERn -- "$pattern" "$@" >/dev/null 2>&1
  fi
}

main() {
  echo "== Mission Source-Of-Truth Validation =="

  if find "$OCTON_DIR/state/control" -type d -name missions | grep -v "/state/control/execution/missions$" >/dev/null 2>&1; then
    fail "mission control may exist only under .octon/state/control/execution/missions"
  else
    pass "no shadow mission control directory exists"
  fi

  if find "$OCTON_DIR/state/evidence/control" -type d -name execution >/dev/null 2>&1; then
    pass "retained mission control evidence uses canonical execution family"
  else
    fail "missing retained mission control evidence family"
  fi

  if has_pattern 'inputs/exploratory/proposals/.*/mission-scoped-reversible-autonomy' "$OCTON_DIR/generated/cognition/summaries" "$OCTON_DIR/generated/cognition/projections/materialized"; then
    fail "generated mission summaries must not depend on proposal inputs"
  else
    pass "generated mission summaries do not depend on proposal inputs"
  fi

  if find "$OCTON_DIR/generated" -type f \( -name '*journal*' -o -name '*activity-log*' \) | grep -q .; then
    fail "generated mission surfaces must not introduce a second journal"
  else
    pass "no second authoritative activity journal detected"
  fi

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
