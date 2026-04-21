#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-remediation/docs-simplification/runtime-docs-consistency.yml"
TARGET_PARITY_SCRIPT="$SCRIPT_DIR/validate-runtime-target-parity.sh"

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
    fail "yq is required for runtime docs consistency validation"
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
  echo "== Runtime Docs Consistency Validation =="

  require_yq
  [[ -f "$RECEIPT" ]] && pass "runtime docs consistency receipt present" || { fail "missing receipt $RECEIPT"; echo "Validation summary: errors=$errors"; exit 1; }

  if [[ "$(yq -r '.schema_version // ""' "$RECEIPT")" == "runtime-docs-consistency-receipt-v1" ]]; then
    pass "runtime docs consistency receipt schema is current"
  else
    fail "runtime docs consistency receipt schema must be runtime-docs-consistency-receipt-v1"
  fi

  if OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" bash "$TARGET_PARITY_SCRIPT" >/dev/null; then
    pass "runtime target parity validation passed"
  else
    fail "runtime target parity validation failed"
  fi

  while IFS=$'\t' read -r label left_file left_query right_file right_query; do
    [[ -n "$label" ]] || continue
    local left_value right_value
    left_value="$(yq -r "$left_query // \"\"" "$(resolve_repo_path "$left_file")")"
    right_value="$(yq -r "$right_query // \"\"" "$(resolve_repo_path "$right_file")")"
    if [[ "$left_value" == "$right_value" && -n "$left_value" ]]; then
      pass "$label"
    else
      fail "$label mismatch ($left_value != $right_value)"
    fi
  done < <(yq -r '.config_alignment[] | [.label, .left_file, .left_query, .right_file, .right_query] | @tsv' "$RECEIPT")

  while IFS= read -r doc_ref; do
    [[ -n "$doc_ref" ]] || continue
    local resolved_doc
    resolved_doc="$(resolve_repo_path "$doc_ref")"
    if [[ -f "$resolved_doc" ]]; then
      pass "doc surface present: $doc_ref"
    else
      fail "missing doc surface: $doc_ref"
      continue
    fi
    while IFS= read -r required_text; do
      [[ -n "$required_text" ]] || continue
      if has_text "$required_text" "$resolved_doc"; then
        pass "$doc_ref contains: $required_text"
      else
        fail "$doc_ref must contain: $required_text"
      fi
    done < <(yq -r ".doc_assertions[] | select(.doc_ref == \"$doc_ref\") | .required_text[]? // \"\"" "$RECEIPT")
  done < <(yq -r '.doc_assertions[]?.doc_ref // ""' "$RECEIPT")

  while IFS= read -r workflow_ref; do
    [[ -n "$workflow_ref" ]] || continue
    local resolved_workflow
    resolved_workflow="$(resolve_repo_path "$workflow_ref")"
    if [[ -f "$resolved_workflow" ]]; then
      pass "workflow present: $workflow_ref"
    else
      fail "missing workflow: $workflow_ref"
      continue
    fi
    while IFS= read -r required_text; do
      [[ -n "$required_text" ]] || continue
      if has_text "$required_text" "$resolved_workflow"; then
        pass "$workflow_ref contains: $required_text"
      else
        fail "$workflow_ref must contain: $required_text"
      fi
    done < <(yq -r ".workflow_assertions[] | select(.workflow_ref == \"$workflow_ref\") | .required_text[]? // \"\"" "$RECEIPT")
  done < <(yq -r '.workflow_assertions[]?.workflow_ref // ""' "$RECEIPT")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
