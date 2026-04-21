#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-remediation/evidence-store/completeness.yml"

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
    fail "yq is required for evidence completeness validation"
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

has_text() {
  local text="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -Fq -- "$text" "$file"
  else
    grep -Fq -- "$text" "$file"
  fi
}

require_receipt_path() {
  local raw="$1"
  local label="$2"
  local resolved
  resolved="$(resolve_repo_path "$raw")"
  if [[ -e "$resolved" ]]; then
    pass "$label exists"
  else
    fail "$label missing: $raw"
  fi
}

main() {
  echo "== Evidence Completeness Validation =="

  require_yq
  [[ -f "$RECEIPT" ]] && pass "evidence completeness receipt present" || { fail "missing receipt $RECEIPT"; echo "Validation summary: errors=$errors"; exit 1; }

  if [[ "$(yq -r '.schema_version // ""' "$RECEIPT")" == "evidence-completeness-receipt-v1" ]]; then
    pass "evidence completeness receipt schema is current"
  else
    fail "evidence completeness receipt schema must be evidence-completeness-receipt-v1"
  fi

  while IFS= read -r run_id; do
    [[ -n "$run_id" ]] || continue

    local run_contract_ref run_manifest_ref runtime_state_ref rollback_posture_ref retained_evidence_ref
    local evidence_classification_ref replay_pointers_ref trace_pointers_ref run_card_ref disclosure_root_ref
    local decision_artifact_ref grant_bundle_ref
    run_contract_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .run_contract_ref" "$RECEIPT")"
    run_manifest_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .run_manifest_ref" "$RECEIPT")"
    runtime_state_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .runtime_state_ref" "$RECEIPT")"
    rollback_posture_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .rollback_posture_ref" "$RECEIPT")"
    retained_evidence_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .retained_evidence_ref" "$RECEIPT")"
    evidence_classification_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .evidence_classification_ref" "$RECEIPT")"
    replay_pointers_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .replay_pointers_ref" "$RECEIPT")"
    trace_pointers_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .trace_pointers_ref" "$RECEIPT")"
    run_card_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .run_card_ref" "$RECEIPT")"
    disclosure_root_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .disclosure_root_ref" "$RECEIPT")"
    decision_artifact_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .decision_artifact_ref" "$RECEIPT")"
    grant_bundle_ref="$(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .grant_bundle_ref" "$RECEIPT")"

    require_receipt_path "$run_contract_ref" "$run_id run contract"
    require_receipt_path "$run_manifest_ref" "$run_id run manifest"
    require_receipt_path "$runtime_state_ref" "$run_id runtime state"
    require_receipt_path "$rollback_posture_ref" "$run_id rollback posture"
    require_receipt_path "$retained_evidence_ref" "$run_id retained evidence bundle"
    require_receipt_path "$evidence_classification_ref" "$run_id evidence classification"
    require_receipt_path "$replay_pointers_ref" "$run_id replay pointers"
    require_receipt_path "$trace_pointers_ref" "$run_id trace pointers"
    require_receipt_path "$run_card_ref" "$run_id run card"
    require_receipt_path "$disclosure_root_ref" "$run_id disclosure root"
    require_receipt_path "$decision_artifact_ref" "$run_id authority decision"
    require_receipt_path "$grant_bundle_ref" "$run_id grant bundle"

    while IFS= read -r ref; do
      [[ -n "$ref" ]] || continue
      require_receipt_path "$ref" "$run_id required receipt"
    done < <(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .required_receipts[]? // \"\"" "$RECEIPT")

    while IFS= read -r ref; do
      [[ -n "$ref" ]] || continue
      require_receipt_path "$ref" "$run_id assurance evidence"
    done < <(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .required_assurance[]? // \"\"" "$RECEIPT")

    while IFS= read -r ref; do
      [[ -n "$ref" ]] || continue
      require_receipt_path "$ref" "$run_id measurement evidence"
    done < <(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .required_measurements[]? // \"\"" "$RECEIPT")

    while IFS= read -r ref; do
      [[ -n "$ref" ]] || continue
      require_receipt_path "$ref" "$run_id intervention evidence"
    done < <(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .required_interventions[]? // \"\"" "$RECEIPT")

    local resolved_retained resolved_runtime_state resolved_run_manifest resolved_run_card
    resolved_retained="$(resolve_repo_path "$retained_evidence_ref")"
    resolved_runtime_state="$(resolve_repo_path "$runtime_state_ref")"
    resolved_run_manifest="$(resolve_repo_path "$run_manifest_ref")"
    resolved_run_card="$(resolve_repo_path "$run_card_ref")"

    if has_text "$run_contract_ref" "$resolved_retained"; then
      pass "$run_id retained evidence cites run contract"
    else
      fail "$run_id retained evidence must cite run contract"
    fi

    if has_text "$run_card_ref" "$resolved_retained"; then
      pass "$run_id retained evidence cites run card"
    else
      fail "$run_id retained evidence must cite run card"
    fi

    if [[ "$(yq -r '.run_contract_ref // ""' "$resolved_run_manifest")" == "$run_contract_ref" ]]; then
      pass "$run_id run manifest binds the expected run contract"
    else
      fail "$run_id run manifest must bind the expected run contract"
    fi

    if [[ "$(yq -r '.authority_refs.run_contract // ""' "$resolved_run_card")" == "$run_contract_ref" ]]; then
      pass "$run_id run card cites the expected run contract"
    else
      fail "$run_id run card must cite the expected run contract"
    fi

    if [[ "$(yq -r '.authority_refs.retained_run_evidence // ""' "$resolved_run_card")" == "$retained_evidence_ref" ]]; then
      pass "$run_id run card cites the retained evidence bundle"
    else
      fail "$run_id run card must cite the retained evidence bundle"
    fi

    local runtime_status allowed_status
    runtime_status="$(yq -r '.status // ""' "$resolved_runtime_state")"
    local allowed=false
    while IFS= read -r allowed_status; do
      [[ -n "$allowed_status" ]] || continue
      if [[ "$runtime_status" == "$allowed_status" ]]; then
        allowed=true
        break
      fi
    done < <(yq -r ".representative_runs[] | select(.run_id == \"$run_id\") | .allowed_runtime_statuses[]? // \"\"" "$RECEIPT")
    if [[ "$allowed" == "true" ]]; then
      pass "$run_id runtime status is allowed for closeout evidence"
    else
      fail "$run_id runtime status is not allowed for closeout evidence: $runtime_status"
    fi
  done < <(yq -r '.representative_runs[]?.run_id // ""' "$RECEIPT")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
