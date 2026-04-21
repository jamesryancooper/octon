#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-remediation/support-targets/proofing.yml"

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
    fail "yq is required for support target proofing validation"
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
  echo "== Support Target Proofing Validation =="

  require_yq
  [[ -f "$RECEIPT" ]] && pass "support target proofing receipt present" || { fail "missing receipt $RECEIPT"; echo "Validation summary: errors=$errors"; exit 1; }

  if [[ "$(yq -r '.schema_version // ""' "$RECEIPT")" == "support-target-proofing-receipt-v1" ]]; then
    pass "support target proofing receipt schema is current"
  else
    fail "support target proofing receipt schema must be support-target-proofing-receipt-v1"
  fi

  local support_target_ref
  support_target_ref="$(yq -r '.support_target_ref // ""' "$RECEIPT")"
  [[ -f "$(resolve_repo_path "$support_target_ref")" ]] && pass "support target declaration present" || fail "support target declaration missing: $support_target_ref"

  local expected_cards actual_cards
  expected_cards="$(yq -r '.proof_cards | length' "$RECEIPT")"
  actual_cards="$(yq -r '.tuple_admissions | length' "$(resolve_repo_path "$support_target_ref")")"
  if [[ "$expected_cards" == "$actual_cards" ]]; then
    pass "proof cards cover every admitted tuple"
  else
    fail "proof cards must cover every admitted tuple ($expected_cards != $actual_cards)"
  fi

  while IFS=$'\t' read -r tuple_id card_ref; do
    [[ -n "$tuple_id" ]] || continue
    local resolved_card
    resolved_card="$(resolve_repo_path "$card_ref")"
    if [[ -f "$resolved_card" ]]; then
      pass "proof card present for $tuple_id"
    else
      fail "missing proof card for $tuple_id: $card_ref"
      continue
    fi

    if [[ "$(yq -r '.schema_version // ""' "$resolved_card")" == "support-target-proof-card-v1" ]]; then
      pass "proof card schema is current for $tuple_id"
    else
      fail "proof card schema must be support-target-proof-card-v1 for $tuple_id"
    fi

    if [[ "$(yq -r '.tuple_id // ""' "$resolved_card")" == "$tuple_id" ]]; then
      pass "proof card tuple id matches receipt for $tuple_id"
    else
      fail "proof card tuple id mismatch for $tuple_id"
    fi

    local admission_ref dossier_ref representative_run_ref disclosure_ref evidence_completeness_ref denied_case_ref
    admission_ref="$(yq -r '.admission_ref // ""' "$resolved_card")"
    dossier_ref="$(yq -r '.support_dossier_ref // ""' "$resolved_card")"
    representative_run_ref="$(yq -r '.representative_run_ref // ""' "$resolved_card")"
    disclosure_ref="$(yq -r '.disclosure_ref // ""' "$resolved_card")"
    evidence_completeness_ref="$(yq -r '.evidence_completeness_ref // ""' "$resolved_card")"
    denied_case_ref="$(yq -r '.denied_case_ref // ""' "$resolved_card")"

    [[ -f "$(resolve_repo_path "$admission_ref")" ]] && pass "$tuple_id admission present" || fail "$tuple_id missing admission: $admission_ref"
    [[ -f "$(resolve_repo_path "$dossier_ref")" ]] && pass "$tuple_id support dossier present" || fail "$tuple_id missing support dossier: $dossier_ref"
    [[ -f "$(resolve_repo_path "$representative_run_ref")" ]] && pass "$tuple_id representative run present" || fail "$tuple_id missing representative run: $representative_run_ref"
    [[ -f "$(resolve_repo_path "$disclosure_ref")" ]] && pass "$tuple_id disclosure present" || fail "$tuple_id missing disclosure: $disclosure_ref"
    [[ -f "$(resolve_repo_path "$evidence_completeness_ref")" ]] && pass "$tuple_id evidence completeness receipt present" || fail "$tuple_id missing evidence completeness receipt: $evidence_completeness_ref"
    [[ -f "$(resolve_repo_path "$denied_case_ref")" ]] && pass "$tuple_id denied case reference present" || fail "$tuple_id missing denied case reference: $denied_case_ref"

    if yq -e ".tuple_admissions[] | select(.tuple_id == \"$tuple_id\" and .admission_ref == \"$admission_ref\" and .support_dossier_ref == \"$dossier_ref\")" "$(resolve_repo_path "$support_target_ref")" >/dev/null 2>&1; then
      pass "$tuple_id matches support target declaration"
    else
      fail "$tuple_id must match the support target declaration"
    fi

    if [[ "$(yq -r '.support_admission_ref // ""' "$(resolve_repo_path "$dossier_ref")")" == "$admission_ref" ]]; then
      pass "$tuple_id dossier binds the expected admission"
    else
      fail "$tuple_id dossier must bind the expected admission"
    fi

    if yq -e ".representative_retained_runs[] | select(. == \"$representative_run_ref\")" "$(resolve_repo_path "$dossier_ref")" >/dev/null 2>&1; then
      pass "$tuple_id proof card uses a representative retained run"
    else
      fail "$tuple_id proof card must use a representative retained run"
    fi

    if yq -e ".evidence_refs[] | select(. == \"$disclosure_ref\")" "$(resolve_repo_path "$admission_ref")" >/dev/null 2>&1 \
      || [[ "$(yq -r '.sufficiency.last_current_release_run_ref // ""' "$(resolve_repo_path "$dossier_ref")")" == "$disclosure_ref" ]]; then
      pass "$tuple_id proof card disclosure is backed by admission or dossier evidence"
    else
      fail "$tuple_id proof card disclosure must be backed by admission or dossier evidence"
    fi
  done < <(yq -r '.proof_cards[] | [.tuple_id, .card_ref] | @tsv' "$RECEIPT")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
