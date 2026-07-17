#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
DISCOVERY_ROOT_DIR="${OCTON_DISCOVERY_ROOT_DIR:-$ROOT_DIR}"
source "$SCRIPT_DIR/validator-result-common.sh"
SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/material-side-effect-inventory-v1.schema.json"
INVENTORY="$OCTON_DIR/framework/engine/runtime/spec/material-side-effect-inventory.yml"
COVERAGE_MAP="$OCTON_DIR/framework/engine/runtime/spec/authorization-boundary-coverage.yml"
DISCOVERY_SCANNER="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/discover-material-effect-entrypoints.sh"
if [[ ! -f "$DISCOVERY_SCANNER" && -n "${OCTON_DISCOVERY_ROOT_DIR:-}" ]]; then
  DISCOVERY_SCANNER="$DISCOVERY_ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/discover-material-effect-entrypoints.sh"
fi
DISCOVERY_TREEISH="${OCTON_DISCOVERY_TREEISH:-HEAD}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-target-transition/authorization-boundary/coverage.yml"
TOKEN_CONTRACT="$(pick_existing_file "$OCTON_DIR/framework/engine/runtime/spec/authorized-effect-token-v1.md" || true)"

errors=0
token_mode_active=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

token_mode_enabled() {
  if [[ "${OCTON_ENFORCE_EFFECT_TOKENS:-0}" == "1" || -n "${TOKEN_CONTRACT:-}" ]]; then
    return 0
  fi

  yq -e '.classes[]? | select((.token_type // .authorized_effect_token // .authorized_effect_token_ref // "") != "")' "$INVENTORY" >/dev/null 2>&1
}

reset_validator_result_metadata
validator_result_add_evidence \
  ".octon/framework/engine/runtime/spec/material-side-effect-inventory.yml" \
  ".octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml" \
  ".octon/framework/assurance/runtime/_ops/scripts/discover-material-effect-entrypoints.sh" \
  ".octon/state/evidence/validation/architecture/10of10-target-transition/authorization-boundary/coverage.yml"
validator_result_add_runtime_test \
  ".octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-token-bypass-denials.sh"
validator_result_add_negative_control \
  "missing-token-type-denies-when-enforced"
validator_result_add_schema_version \
  "material-side-effect-inventory-v1" \
  "material-side-effect-inventory-v2"
[[ -n "${TOKEN_CONTRACT:-}" ]] && validator_result_add_contract "${TOKEN_CONTRACT#$ROOT_DIR/}"

echo "== Material Side-Effect Inventory Validation =="

[[ -f "$SCHEMA" ]] && pass "inventory schema present" || fail "missing inventory schema"
[[ -f "$INVENTORY" ]] && pass "inventory file present" || fail "missing inventory file"
[[ -f "$COVERAGE_MAP" ]] && pass "authorization coverage map present" || fail "missing authorization coverage map"
[[ -f "$DISCOVERY_SCANNER" ]] && pass "closed-world discovery scanner present" || fail "missing closed-world discovery scanner"
[[ -f "$RECEIPT" ]] && pass "coverage receipt present" || fail "missing coverage receipt"

if command -v python3 >/dev/null 2>&1 && python3 - "$SCHEMA" "$INVENTORY" <<'PY'
import json
import sys

import jsonschema
import yaml

schema_path, inventory_path = sys.argv[1:3]
with open(schema_path, encoding="utf-8") as handle:
    schema = json.load(handle)
with open(inventory_path, encoding="utf-8") as handle:
    inventory = yaml.safe_load(handle)
jsonschema.Draft202012Validator.check_schema(schema)
jsonschema.Draft202012Validator(schema).validate(inventory)
PY
then
  pass "material inventory validates against its schema"
else
  fail "material inventory must validate against its schema"
fi

case "$(yq -r '.schema_version // ""' "$INVENTORY")" in
  material-side-effect-inventory-v1|material-side-effect-inventory-v2)
    pass "inventory schema version current"
    ;;
  *)
    fail "inventory schema_version must be a supported material-side-effect-inventory version"
    ;;
esac

if token_mode_enabled; then
  token_mode_active=1
  pass "authorized-effect token validation active"
else
  validator_result_add_limitation "authorized-effect token contract is not active in the current inventory"
fi

while IFS=$'\t' read -r id root boundary owner risk material token_ref; do
  [[ -n "$id" ]] || continue
  [[ -n "$root" ]] && pass "$id roots present" || fail "$id missing roots"
  [[ -n "$boundary" ]] && pass "$id boundary present" || fail "$id missing boundary"
  [[ -n "$owner" ]] && pass "$id owner present" || fail "$id missing owner"
  [[ -n "$risk" ]] && pass "$id risk tier present" || fail "$id missing risk tier"
  [[ "$material" == "true" || "$material" == "false" ]] && pass "$id material flag present" || fail "$id missing material flag"

  if [[ $token_mode_active -eq 1 && "$material" == "true" ]]; then
    [[ -n "$token_ref" ]] \
      && pass "$id token type present" \
      || fail "$id must declare a token type when authorized-effect tokens are active"
  fi
done < <(yq -r '.classes[] | [.id, (.roots[0] // ""), .required_boundary, .owner, .risk_tier, (.material|tostring), (.token_type // .authorized_effect_token // .authorized_effect_token_ref // "")] | @tsv' "$INVENTORY")

if yq -e '.inventory_ref == ".octon/framework/engine/runtime/spec/material-side-effect-inventory.yml"' "$RECEIPT" >/dev/null 2>&1; then
  pass "coverage receipt binds inventory"
else
  fail "coverage receipt must bind the inventory file"
fi

if [[ -f "$DISCOVERY_SCANNER" && -f "$COVERAGE_MAP" ]] && \
  bash "$DISCOVERY_SCANNER" \
    --repo "$DISCOVERY_ROOT_DIR" \
    --treeish "$DISCOVERY_TREEISH" \
    --inventory "$INVENTORY" \
    --coverage "$COVERAGE_MAP" \
    --check \
    --format summary >/dev/null; then
  pass "closed-world discovery proves D_w=M_w and D_l=M_l=A_l"
else
  fail "closed-world discovery equality or ambiguity gate failed"
fi

echo "Validation summary: errors=$errors"
if [[ $errors -eq 0 ]]; then
  emit_validator_result "validate-material-side-effect-inventory.sh" "material_side_effect_inventory" "semantic" "semantic" "pass"
  if [[ $token_mode_active -eq 1 ]]; then
    emit_validator_result "validate-material-side-effect-inventory.sh" "authorized_effect_tokens" "semantic" "semantic" "pass"
  fi
else
  emit_validator_result "validate-material-side-effect-inventory.sh" "material_side_effect_inventory" "semantic" "existence" "fail"
  if [[ $token_mode_active -eq 1 ]]; then
    emit_validator_result "validate-material-side-effect-inventory.sh" "authorized_effect_tokens" "semantic" "existence" "fail"
  fi
fi
[[ $errors -eq 0 ]]
