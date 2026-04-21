#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture-target-state-transition/compatibility/retirement.yml"
REGISTRY="$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
resolve_repo_path() {
  local raw="$1"
  case "$raw" in
    /.octon/*|.octon/*) printf '%s/%s\n' "$ROOT_DIR" "${raw#/}" ;;
    *) printf '%s\n' "$raw" ;;
  esac
}

echo "== Compatibility Retirement Validation =="

[[ -f "$RECEIPT" ]] || { fail "missing retirement receipt"; exit 1; }
[[ "$(yq -r '.schema_version // ""' "$RECEIPT")" == "compatibility-retirement-receipt-v1" ]] && pass "retirement receipt schema current" || fail "retirement receipt schema mismatch"

for expr in \
  '.delegated_registries.retirement_register.path == ".octon/instance/governance/retirement-register.yml"' \
  '.path_families.compatibility_retirement.authority_class == "transitional-retirement-governance"'
do
  yq -e "$expr" "$REGISTRY" >/dev/null 2>&1 && pass "registry bridge present: $expr" || fail "missing registry bridge: $expr"
done

while IFS= read -r ref; do
  [[ -n "$ref" ]] || continue
  [[ -e "$(resolve_repo_path "$ref")" ]] && pass "retirement surface present: $ref" || fail "missing retirement surface: $ref"
done < <(yq -r '.retirement_register_ref, .retirement_policy_ref, .retirement_review_ref, .materialized_map_ref' "$RECEIPT")

OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" bash "$SCRIPT_DIR/validate-retirement-registry.sh" >/dev/null && pass "retirement registry validator passes" || fail "retirement registry validator failed"

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
