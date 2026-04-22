#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
source "$SCRIPT_DIR/validator-result-common.sh"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-target-transition/publication/freshness.yml"
FRESHNESS_CONTRACT="$(pick_existing_file \
  "$OCTON_DIR/framework/engine/runtime/spec/publication-freshness-gates-v4.md" \
  "$OCTON_DIR/framework/engine/runtime/spec/publication-freshness-gates-v3.md")"

errors=0
validated_runtime_freshness=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
resolve_repo_path() {
  local raw="$1"
  case "$raw" in
    /.octon/*|.octon/*) printf '%s/%s\n' "$ROOT_DIR" "${raw#/}" ;;
    *) printf '%s\n' "$raw" ;;
  esac
}

hash_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

validate_handle_freshness() {
  local file="$1" label="$2"
  local mode legacy_fresh_until

  mode="$(yq -r '.freshness.mode // ""' "$file")"
  legacy_fresh_until="$(yq -r '.legacy_fresh_until // ""' "$file")"

  if [[ -n "$mode" && "$mode" != "null" ]]; then
    validated_runtime_freshness=1
    case "$mode" in
      digest_bound|ttl_bound|receipt_bound)
        pass "$label freshness mode valid"
        ;;
      *)
        fail "$label freshness mode invalid"
        ;;
    esac
    yq -e '.freshness.invalidation_conditions | length > 0' "$file" >/dev/null 2>&1 \
      && pass "$label invalidation conditions declared" \
      || fail "$label must declare invalidation conditions"

    if [[ -n "$legacy_fresh_until" && "$legacy_fresh_until" != "null" ]]; then
      validator_result_add_limitation "$label retains legacy_fresh_until alongside explicit freshness.mode"
    fi
    return 0
  fi

  if [[ -n "$legacy_fresh_until" && "$legacy_fresh_until" != "null" ]]; then
    fail "$label relies on legacy_fresh_until without explicit freshness.mode"
    return 0
  fi

  validator_result_add_limitation "$label has no freshness block and was treated as non-runtime publication evidence"
}

validate_publication_receipt_linkage() {
  local file="$1" label="$2"
  local receipt_ref receipt_sha receipt_abs actual_sha

  receipt_ref="$(yq -r '.publication_receipt_path // .publication_receipt_ref // ""' "$file")"
  [[ -n "$receipt_ref" && "$receipt_ref" != "null" ]] || return 0

  receipt_abs="$(resolve_repo_path "$receipt_ref")"
  [[ -f "$receipt_abs" ]] && pass "$label publication receipt present" || {
    fail "$label publication receipt missing"
    return 0
  }

  receipt_sha="$(yq -r '.publication_receipt_sha256 // ""' "$file")"
  if [[ -n "$receipt_sha" && "$receipt_sha" != "null" ]]; then
    actual_sha="$(hash_file "$receipt_abs")"
    [[ "$receipt_sha" == "$actual_sha" ]] \
      && pass "$label publication receipt digest current" \
      || fail "$label publication receipt digest drift"
  fi
}

reset_validator_result_metadata
validator_result_add_evidence \
  ".octon/state/evidence/validation/architecture/10of10-target-transition/publication/freshness.yml"
validator_result_add_runtime_test \
  ".octon/framework/assurance/runtime/_ops/tests/test-runtime-effective-freshness-hard-gate.sh"
validator_result_add_negative_control \
  "invalid-freshness-mode-denies" \
  "missing-invalidation-conditions-denies" \
  "legacy-fresh-until-without-mode-denies"
validator_result_add_schema_version \
  "generated-effective-freshness-receipt-v1" \
  "generated-effective-freshness-receipt-v2"
[[ -n "${FRESHNESS_CONTRACT:-}" ]] && validator_result_add_contract "${FRESHNESS_CONTRACT#$ROOT_DIR/}"

echo "== Generated Effective Freshness Validation =="

[[ -f "$RECEIPT" ]] || { fail "missing freshness receipt"; exit 1; }
case "$(yq -r '.schema_version // ""' "$RECEIPT")" in
  generated-effective-freshness-receipt-v1|generated-effective-freshness-receipt-v2)
    pass "freshness receipt schema current"
    ;;
  *)
    fail "freshness receipt schema mismatch"
    ;;
esac
[[ -n "${FRESHNESS_CONTRACT:-}" ]] && pass "publication freshness contract present" || fail "missing publication freshness contract"

while IFS=$'\t' read -r output_ref evidence_ref; do
  [[ -n "$output_ref" ]] || continue
  [[ -e "$(resolve_repo_path "$output_ref")" ]] && pass "output present: $output_ref" || fail "missing output: $output_ref"
  [[ -e "$(resolve_repo_path "$evidence_ref")" ]] && pass "evidence present: $evidence_ref" || fail "missing evidence: $evidence_ref"
done < <(yq -r '.generated_effective_outputs[] | [.output_ref, .evidence_ref] | @tsv' "$RECEIPT")

while IFS= read -r freshness_ref; do
  [[ -n "$freshness_ref" ]] || continue
  freshness_abs="$(resolve_repo_path "$freshness_ref")"
  [[ -e "$freshness_abs" ]] && pass "freshness artifact present: $freshness_ref" || {
    fail "missing freshness artifact: $freshness_ref"
    continue
  }
  validate_handle_freshness "$freshness_abs" "$freshness_ref"
  validate_publication_receipt_linkage "$freshness_abs" "$freshness_ref"
done < <(yq -r '.generated_effective_outputs[].freshness_refs[]' "$RECEIPT")

echo "Validation summary: errors=$errors"
if [[ $errors -eq 0 ]]; then
  if [[ $validated_runtime_freshness -eq 1 ]]; then
    emit_validator_result "validate-generated-effective-freshness.sh" "freshness_modes" "runtime" "runtime" "pass"
  else
    emit_validator_result "validate-generated-effective-freshness.sh" "freshness_modes" "runtime" "semantic" "pass"
  fi
else
  emit_validator_result "validate-generated-effective-freshness.sh" "freshness_modes" "runtime" "existence" "fail"
fi
[[ $errors -eq 0 ]]
