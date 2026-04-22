#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
REGISTER="$OCTON_DIR/instance/governance/retirement-register.yml"
source "$SCRIPT_DIR/validator-result-common.sh"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RETIREMENT_CONTRACT="$(pick_existing_file "$OCTON_DIR/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md" || true)"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

reset_validator_result_metadata
validator_result_add_evidence ".octon/instance/governance/retirement-register.yml"
validator_result_add_schema_version "compatibility-retirement-cutover-v2"
[[ -n "${RETIREMENT_CONTRACT:-}" ]] && validator_result_add_contract "${RETIREMENT_CONTRACT#$ROOT_DIR/}"

echo "== Compatibility Retirement Cutover Validation =="

[[ -f "$REGISTER" ]] && pass "retirement register present" || fail "missing retirement register"
[[ -n "${RETIREMENT_CONTRACT:-}" ]] || validator_result_add_limitation "compatibility-retirement-cutover-v2 contract is not present"

for surface in ingress-projection-adapters runtime-capability-pack-projection; do
  yq -e ".entries[] | select(.surface == \"$surface\")" "$REGISTER" >/dev/null 2>&1 \
    && pass "$surface entry present" \
    || fail "$surface entry missing"
done

yq -e '.entries[] | select(.surface == "runtime-capability-pack-projection") | select(.canonical_successor_ref == ".octon/generated/effective/capabilities/pack-routes.effective.yml")' "$REGISTER" >/dev/null 2>&1 \
  && pass "runtime capability pack projection successor current" \
  || fail "runtime capability pack projection successor invalid"
yq -e '.entries[] | select(.surface == "runtime-capability-pack-projection") | select(.future_widening_blocker == true)' "$REGISTER" >/dev/null 2>&1 \
  && pass "runtime capability pack projection widening blocker active" \
  || fail "runtime capability pack projection widening blocker missing"

echo "Validation summary: errors=$errors"
if [[ $errors -eq 0 ]]; then
  emit_validator_result "validate-compatibility-retirement-cutover.sh" "compatibility_retirement" "semantic" "semantic" "pass"
else
  emit_validator_result "validate-compatibility-retirement-cutover.sh" "compatibility_retirement" "semantic" "existence" "fail"
fi
[[ $errors -eq 0 ]]
