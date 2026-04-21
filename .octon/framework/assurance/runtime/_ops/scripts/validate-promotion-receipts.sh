#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-remediation/promotion/receipt-ledger.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_yq() {
  if command -v yq >/dev/null 2>&1; then
    pass "yq available"
  else
    fail "yq is required for promotion receipt validation"
    exit 1
  fi
}

resolve_repo_path() {
  local raw="$1"
  case "$raw" in
    /.octon/*|/.github/*)
      printf '%s/%s\n' "$ROOT_DIR" "${raw#/}"
      ;;
    .octon/*|.github/*)
      printf '%s/%s\n' "$ROOT_DIR" "$raw"
      ;;
    *)
      printf '%s\n' "$raw"
      ;;
  esac
}

main() {
  echo "== Promotion Receipts Validation =="

  require_yq
  [[ -f "$RECEIPT" ]] && pass "promotion receipt ledger present" || { fail "missing receipt $RECEIPT"; echo "Validation summary: errors=$errors"; exit 1; }

  if [[ "$(yq -r '.schema_version // ""' "$RECEIPT")" == "promotion-receipt-ledger-v1" ]]; then
    pass "promotion receipt ledger schema is current"
  else
    fail "promotion receipt ledger schema must be promotion-receipt-ledger-v1"
  fi

  if [[ -n "$(yq -r '.rationale // ""' "$RECEIPT")" ]]; then
    pass "promotion receipt ledger includes rationale"
  else
    fail "promotion receipt ledger must include rationale"
  fi

  if [[ "$(yq -r '.receipts_required_for | length' "$RECEIPT")" -gt 0 ]]; then
    pass "promotion receipt ledger enumerates receipt-triggering flows"
  else
    fail "promotion receipt ledger must enumerate receipt-triggering flows"
  fi

  local observed_count
  observed_count="$(yq -r '.observed_promotions | length' "$RECEIPT")"
  if [[ "$observed_count" == "0" ]]; then
    if [[ "$(yq -r '.slice_status // ""' "$RECEIPT")" == "no-live-promotions-required" ]]; then
      pass "slice explicitly records that no live promotions were required"
    else
      fail "slice_status must be no-live-promotions-required when no promotions are observed"
    fi
  else
    while IFS=$'\t' read -r promotion_id source_ref target_ref receipt_ref; do
      [[ -n "$promotion_id" ]] || continue
      [[ -e "$(resolve_repo_path "$source_ref")" ]] && pass "$promotion_id source exists" || fail "$promotion_id source missing: $source_ref"
      [[ -e "$(resolve_repo_path "$target_ref")" ]] && pass "$promotion_id target exists" || fail "$promotion_id target missing: $target_ref"
      [[ -f "$(resolve_repo_path "$receipt_ref")" ]] && pass "$promotion_id receipt exists" || fail "$promotion_id receipt missing: $receipt_ref"
    done < <(yq -r '.observed_promotions[] | [.promotion_id, .source_ref, .target_ref, .receipt_ref] | @tsv' "$RECEIPT")
  fi

  while IFS= read -r root_ref; do
    [[ -n "$root_ref" ]] || continue
    local resolved_root
    resolved_root="$(resolve_repo_path "$root_ref")"
    if [[ -e "$resolved_root" ]]; then
      pass "non-authority publication root present: $root_ref"
    else
      fail "non-authority publication root missing: $root_ref"
    fi
    case "$root_ref" in
      .octon/generated/*|/.octon/generated/*|.octon/state/evidence/validation/*|/.octon/state/evidence/validation/*)
        pass "non-authority publication root stays outside authority/control promotion targets: $root_ref"
        ;;
      *)
        fail "non-authority publication root must stay in generated/** or state/evidence/validation/**: $root_ref"
        ;;
    esac
  done < <(yq -r '.non_authority_publication_roots[]? // ""' "$RECEIPT")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
