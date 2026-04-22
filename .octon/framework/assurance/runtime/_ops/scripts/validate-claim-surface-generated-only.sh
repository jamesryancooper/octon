#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

errors=0
fail(){ echo "[ERROR] $1"; errors=$((errors+1)); }
pass(){ echo "[OK] $1"; }

echo "== Claim Surface Generated-Only Validation =="

for path in \
  "$OCTON_DIR/generated/cognition/projections/materialized/architecture-map.md" \
  "$OCTON_DIR/generated/cognition/projections/materialized/runtime-route-map.md" \
  "$OCTON_DIR/generated/cognition/projections/materialized/support-pack-route-map.md"
do
  [[ -f "$path" ]] && pass "generated claim projection present: ${path#$OCTON_DIR/}" || fail "missing generated claim projection: ${path#$OCTON_DIR/}"
  if grep -Eiq 'derived|non-authority|not an authority source' "$path"; then
    pass "generated claim projection declares non-authority status: ${path#$OCTON_DIR/}"
  else
    fail "generated claim projection must declare non-authority status: ${path#$OCTON_DIR/}"
  fi
done

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
