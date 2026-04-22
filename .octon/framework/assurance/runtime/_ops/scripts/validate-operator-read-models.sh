#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture-target-state-transition/operator-views/publication.yml"

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

main() {
  echo "== Operator Read Models Validation =="

  require_yq
  [[ -f "$RECEIPT" ]] && pass "operator read-model publication receipt present" || { fail "missing receipt $RECEIPT"; echo "Validation summary: errors=$errors"; exit 1; }

  if [[ "$(yq -r '.schema_version // ""' "$RECEIPT")" == "operator-read-model-publication-v1" ]]; then
    pass "operator read-model publication schema is current"
  else
    fail "operator read-model publication schema must be operator-read-model-publication-v1"
  fi

  local view_contract_ref
  view_contract_ref="$(yq -r '.view_contract_ref // ""' "$RECEIPT")"
  [[ -f "$(resolve_repo_path "$view_contract_ref")" ]] && pass "operator read-model contract present" || fail "missing operator read-model contract: $view_contract_ref"

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
        if [[ "$view_kind" == "support" && "$(yq -r '.schema_version // ""' "$resolved_projection")" == "support-card-v1" ]]; then
          pass "$view_kind support projection schema is current"
          [[ -n "$(yq -r '.claim_effect // ""' "$resolved_projection")" ]] && pass "$view_kind support projection declares claim effect" || fail "$view_kind support projection must declare claim effect"
          [[ -n "$(yq -r '.proof_bundle_ref // ""' "$resolved_projection")" ]] && pass "$view_kind support projection cites proof bundle" || fail "$view_kind support projection must cite proof bundle"
          [[ -n "$(yq -r '.support_target_ref // ""' "$resolved_projection")" ]] && pass "$view_kind support projection cites support target" || fail "$view_kind support projection must cite support target"
        elif [[ "$(yq -r '.schema_version // ""' "$resolved_projection")" == "operator-read-model-v1" ]]; then
          pass "$view_kind projection schema is current"
          if [[ "$(yq -r '.view_kind // ""' "$resolved_projection")" == "$view_kind" ]]; then
            pass "$view_kind projection kind matches receipt"
          else
            fail "$view_kind projection kind must match receipt"
          fi
          if [[ "$(yq -r '.mutability // ""' "$resolved_projection")" == "generated" ]]; then
            pass "$view_kind projection is marked generated"
          else
            fail "$view_kind projection must declare mutability: generated"
          fi
          if [[ -n "$(yq -r '.non_authority_statement // ""' "$resolved_projection")" ]]; then
            pass "$view_kind projection declares non-authority status"
          else
            fail "$view_kind projection must declare non-authority status"
          fi
          if [[ "$(yq -r '.generated_from | length' "$resolved_projection")" -gt 0 ]]; then
            pass "$view_kind projection carries generated_from provenance"
          else
            fail "$view_kind projection must carry generated_from provenance"
          fi
        else
          fail "$view_kind projection schema is unsupported"
        fi
        ;;
      *)
        fail "$view_kind projection has unsupported extension"
        ;;
    esac
  done < <(yq -r '.published_views[] | [.view_kind, .projection_ref, .summary_ref] | @tsv' "$RECEIPT")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
