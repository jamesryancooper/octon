#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

CONTRACT="$OCTON_DIR/framework/engine/runtime/spec/publication-freshness-gates-v2.md"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-target-transition/publication/freshness.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

run_validator() {
  local script="$1"
  if bash "$SCRIPT_DIR/$script" >/dev/null; then
    pass "$script passes"
  else
    fail "$script failed"
  fi
}

main() {
  echo "== Publication Freshness Gates Validation =="

  [[ -f "$CONTRACT" ]] && pass "publication freshness contract present" || fail "missing publication freshness contract"
  [[ -f "$RECEIPT" ]] && pass "publication freshness receipt present" || fail "missing publication freshness receipt"

  yq -e '.generated_effective_outputs[] | select(.output_ref == ".octon/generated/effective/extensions/catalog.effective.yml")' "$RECEIPT" >/dev/null 2>&1 \
    && pass "freshness receipt covers extensions publication" \
    || fail "freshness receipt must cover extensions publication"
  yq -e '.generated_effective_outputs[] | select(.output_ref == ".octon/generated/effective/capabilities/routing.effective.yml")' "$RECEIPT" >/dev/null 2>&1 \
    && pass "freshness receipt covers capabilities publication" \
    || fail "freshness receipt must cover capabilities publication"
  yq -e '.generated_effective_outputs[] | select(.output_ref == ".octon/generated/effective/capabilities/pack-routes.effective.yml")' "$RECEIPT" >/dev/null 2>&1 \
    && pass "freshness receipt covers pack-route publication" \
    || fail "freshness receipt must cover pack-route publication"
  yq -e '.generated_effective_outputs[] | select(.output_ref == ".octon/generated/effective/runtime/route-bundle.yml")' "$RECEIPT" >/dev/null 2>&1 \
    && pass "freshness receipt covers runtime route-bundle publication" \
    || fail "freshness receipt must cover runtime route-bundle publication"

  run_validator "validate-generated-effective-freshness.sh"
  run_validator "validate-capability-publication-state.sh"
  run_validator "validate-extension-publication-state.sh"
  run_validator "validate-runtime-effective-route-bundle.sh"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
