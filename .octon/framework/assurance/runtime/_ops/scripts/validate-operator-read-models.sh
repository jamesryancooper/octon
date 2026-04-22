#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
source "$SCRIPT_DIR/validator-result-common.sh"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-target-transition/operator-views/generation.yml"

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
    fail "yq is required for operator read-model validation"
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

reset_validator_result_metadata
validator_result_add_evidence \
  ".octon/state/evidence/validation/architecture/10of10-target-transition/operator-views/generation.yml"
validator_result_add_schema_version \
  "operator-read-model-publication-v1" \
  "operator-read-model-publication-v2" \
  "operator-read-model-traceability-v1"

main() {
  echo "== Operator Read Models Validation =="

  require_yq
  [[ -f "$RECEIPT" ]] && pass "operator read-model publication receipt present" || { fail "missing receipt $RECEIPT"; echo "Validation summary: errors=$errors"; exit 1; }

  case "$(yq -r '.schema_version // ""' "$RECEIPT")" in
    operator-read-model-publication-v1|operator-read-model-publication-v2|operator-read-model-traceability-v1)
      pass "operator read-model publication schema is current"
      ;;
    *)
      fail "operator read-model publication schema is unsupported"
      ;;
  esac

  local view_contract_ref
  view_contract_ref="$(yq -r '.view_contract_ref // ""' "$RECEIPT")"
  [[ -f "$(resolve_repo_path "$view_contract_ref")" ]] && pass "operator read-model contract present" || fail "missing operator read-model contract: $view_contract_ref"
  [[ -n "$view_contract_ref" ]] && validator_result_add_contract "$view_contract_ref"

  while IFS=$'\t' read -r view_kind projection_ref summary_ref; do
    [[ -n "$view_kind" ]] || continue
    local resolved_projection resolved_summary
    resolved_projection="$(resolve_repo_path "$projection_ref")"
    resolved_summary="$(resolve_repo_path "$summary_ref")"

    [[ -f "$resolved_projection" ]] && pass "$view_kind projection present" || { fail "$view_kind projection missing: $projection_ref"; continue; }
    [[ -f "$resolved_summary" ]] && pass "$view_kind summary present" || fail "$view_kind summary missing: $summary_ref"

    case "$resolved_projection" in
      *.md)
        if has_text 'derived' "$resolved_projection" || has_text 'not an authority source' "$resolved_projection"; then
          pass "$view_kind markdown projection declares non-authority status"
        else
          fail "$view_kind markdown projection must declare non-authority status"
        fi
        if has_text 'state/evidence' "$resolved_projection" || has_text 'framework/' "$resolved_projection"; then
          pass "$view_kind markdown projection cites canonical source families"
        else
          fail "$view_kind markdown projection must cite canonical source families"
        fi
        ;;
      *.yml)
        fail "$view_kind projection schema is unsupported"
        ;;
      *)
        fail "$view_kind projection has unsupported extension"
        ;;
    esac

    validator_result_add_evidence "$projection_ref" "$summary_ref"
  done < <(yq -r '.published_views[] | [.view_kind, .projection_ref, .summary_ref] | @tsv' "$RECEIPT")

  echo "Validation summary: errors=$errors"
  if [[ $errors -eq 0 ]]; then
    emit_validator_result "validate-operator-read-models.sh" "operator_read_models" "semantic" "semantic" "pass"
  else
    emit_validator_result "validate-operator-read-models.sh" "operator_read_models" "semantic" "existence" "fail"
  fi
  [[ $errors -eq 0 ]]
}

main "$@"
