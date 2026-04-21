#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/material-side-effect-inventory-v1.schema.json"
INVENTORY="$OCTON_DIR/framework/engine/runtime/spec/material-side-effect-inventory.yml"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture-target-state-transition/authorization-boundary/coverage.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Material Side-Effect Inventory Validation =="

[[ -f "$SCHEMA" ]] && pass "inventory schema present" || fail "missing inventory schema"
[[ -f "$INVENTORY" ]] && pass "inventory file present" || fail "missing inventory file"
[[ -f "$RECEIPT" ]] && pass "coverage receipt present" || fail "missing coverage receipt"

[[ "$(yq -r '.schema_version // ""' "$INVENTORY")" == "material-side-effect-inventory-v1" ]] && pass "inventory schema version current" || fail "inventory schema_version must be material-side-effect-inventory-v1"

while IFS=$'\t' read -r id root boundary owner risk material; do
  [[ -n "$id" ]] || continue
  [[ -n "$root" ]] && pass "$id roots present" || fail "$id missing roots"
  [[ -n "$boundary" ]] && pass "$id boundary present" || fail "$id missing boundary"
  [[ -n "$owner" ]] && pass "$id owner present" || fail "$id missing owner"
  [[ -n "$risk" ]] && pass "$id risk tier present" || fail "$id missing risk tier"
  [[ "$material" == "true" || "$material" == "false" ]] && pass "$id material flag present" || fail "$id missing material flag"
done < <(yq -r '.classes[] | [.id, (.roots[0] // ""), .required_boundary, .owner, .risk_tier, (.material|tostring)] | @tsv' "$INVENTORY")

if yq -e '.inventory_ref == ".octon/framework/engine/runtime/spec/material-side-effect-inventory.yml"' "$RECEIPT" >/dev/null 2>&1; then
  pass "coverage receipt binds inventory"
else
  fail "coverage receipt must bind the inventory file"
fi

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
