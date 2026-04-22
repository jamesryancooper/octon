#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-target-transition/publication/freshness.yml"

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

echo "== Generated Effective Freshness Validation =="

[[ -f "$RECEIPT" ]] || { fail "missing freshness receipt"; exit 1; }
[[ "$(yq -r '.schema_version // ""' "$RECEIPT")" == "generated-effective-freshness-receipt-v1" ]] && pass "freshness receipt schema current" || fail "freshness receipt schema mismatch"

while IFS=$'\t' read -r output_ref evidence_ref; do
  [[ -n "$output_ref" ]] || continue
  [[ -e "$(resolve_repo_path "$output_ref")" ]] && pass "output present: $output_ref" || fail "missing output: $output_ref"
  [[ -e "$(resolve_repo_path "$evidence_ref")" ]] && pass "evidence present: $evidence_ref" || fail "missing evidence: $evidence_ref"
done < <(yq -r '.generated_effective_outputs[] | [.output_ref, .evidence_ref] | @tsv' "$RECEIPT")

while IFS= read -r freshness_ref; do
  [[ -n "$freshness_ref" ]] || continue
  [[ -e "$(resolve_repo_path "$freshness_ref")" ]] && pass "freshness artifact present: $freshness_ref" || fail "missing freshness artifact: $freshness_ref"
done < <(yq -r '.generated_effective_outputs[].freshness_refs[]' "$RECEIPT")

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
