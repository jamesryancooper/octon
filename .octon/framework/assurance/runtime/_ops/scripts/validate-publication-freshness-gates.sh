#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
source "$SCRIPT_DIR/validator-result-common.sh"

CONTRACT="$(pick_existing_file \
  "$OCTON_DIR/framework/engine/runtime/spec/publication-freshness-gates-v4.md" \
  "$OCTON_DIR/framework/engine/runtime/spec/publication-freshness-gates-v3.md")"
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

reset_validator_result_metadata
validator_result_add_evidence \
  ".octon/state/evidence/validation/architecture/10of10-target-transition/publication/freshness.yml"
validator_result_add_runtime_test \
  ".octon/framework/assurance/runtime/_ops/tests/test-runtime-effective-freshness-hard-gate.sh" \
  ".octon/framework/assurance/runtime/_ops/tests/test-stale-digest-bound-route-bundle-denial.sh"
validator_result_add_negative_control \
  "missing-publication-receipt-denies" \
  "stale-runtime-route-bundle-denies" \
  "invalid-freshness-mode-denies"
validator_result_add_schema_version \
  "generated-effective-freshness-receipt-v1" \
  "generated-effective-freshness-receipt-v2"
[[ -n "${CONTRACT:-}" ]] && validator_result_add_contract "${CONTRACT#$ROOT_DIR/}"

main() {
  echo "== Publication Freshness Gates Validation =="

  [[ -f "$CONTRACT" ]] && pass "publication freshness contract present" || fail "missing publication freshness contract"
  [[ -f "$RECEIPT" ]] && pass "publication freshness receipt present" || fail "missing publication freshness receipt"
  case "$(yq -r '.schema_version // ""' "$RECEIPT")" in
    generated-effective-freshness-receipt-v1|generated-effective-freshness-receipt-v2)
      pass "publication freshness receipt schema current"
      ;;
    *)
      fail "publication freshness receipt schema mismatch"
      ;;
  esac

  while IFS=$'\t' read -r output_ref evidence_ref freshness_count; do
    [[ -n "$output_ref" ]] || continue
    [[ -n "$evidence_ref" && "$evidence_ref" != "null" ]] \
      && pass "$output_ref carries evidence ref" \
      || fail "$output_ref must carry evidence ref"
    [[ "$freshness_count" != "0" ]] \
      && pass "$output_ref carries freshness refs" \
      || fail "$output_ref must carry freshness refs"
  done < <(yq -r '.generated_effective_outputs[] | [.output_ref, (.evidence_ref // ""), ((.freshness_refs // []) | length)] | @tsv' "$RECEIPT")

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
  run_validator "validate-runtime-effective-artifact-handles.sh"
  run_validator "validate-no-raw-generated-effective-runtime-reads.sh"
  run_validator "validate-capability-publication-state.sh"
  run_validator "validate-extension-publication-state.sh"
  run_validator "validate-runtime-effective-route-bundle.sh"

  echo "Validation summary: errors=$errors"
  if [[ $errors -eq 0 ]]; then
    emit_validator_result "validate-publication-freshness-gates.sh" "freshness_modes" "runtime" "runtime" "pass"
    emit_validator_result "validate-publication-freshness-gates.sh" "publication_receipts" "runtime" "runtime" "pass"
  else
    emit_validator_result "validate-publication-freshness-gates.sh" "freshness_modes" "runtime" "existence" "fail"
    emit_validator_result "validate-publication-freshness-gates.sh" "publication_receipts" "runtime" "existence" "fail"
  fi
  [[ $errors -eq 0 ]]
}

main "$@"
