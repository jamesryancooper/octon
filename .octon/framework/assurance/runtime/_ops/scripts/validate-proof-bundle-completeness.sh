#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"

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

echo "== Proof Bundle Completeness Validation =="

OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" bash "$SCRIPT_DIR/validate-evidence-completeness.sh" >/dev/null && pass "evidence completeness validator passes" || fail "evidence completeness validator failed"
OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" bash "$SCRIPT_DIR/validate-support-target-proofing.sh" >/dev/null && pass "support target proofing validator passes" || fail "support target proofing validator failed"

while IFS=$'\t' read -r tuple_id bundle_ref support_card_ref; do
  [[ -n "$tuple_id" ]] || continue
  bundle_path="$(resolve_repo_path "$bundle_ref")"
  card_path="$(resolve_repo_path "$support_card_ref")"
  [[ -f "$bundle_path" ]] && pass "bundle present for $tuple_id" || fail "missing bundle for $tuple_id"
  [[ -f "$card_path" ]] && pass "support card present for $tuple_id" || fail "missing support card for $tuple_id"
  [[ "$(yq -r '.schema_version // ""' "$bundle_path")" == "support-target-proof-bundle-v1" ]] && pass "bundle schema current for $tuple_id" || fail "bundle schema mismatch for $tuple_id"
  [[ "$(yq -r '.tuple_id // ""' "$bundle_path")" == "$tuple_id" ]] && pass "bundle tuple matches for $tuple_id" || fail "bundle tuple mismatch for $tuple_id"
  [[ "$(yq -r '.proof_bundle_ref // ""' "$card_path")" == "$bundle_ref" ]] && pass "support card matches bundle for $tuple_id" || fail "support card bundle mismatch for $tuple_id"
done < <(yq -r '.tuple_admissions[] | [.tuple_id, .proof_bundle_ref, .support_card_ref] | @tsv' "$SUPPORT_TARGETS")

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
