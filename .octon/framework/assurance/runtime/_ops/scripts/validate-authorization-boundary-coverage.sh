#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-remediation/authorization-boundary/coverage.yml"

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
    fail "yq is required for authorization boundary coverage validation"
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
  echo "== Authorization Boundary Coverage Validation =="

  require_yq
  [[ -f "$RECEIPT" ]] && pass "authorization coverage receipt present" || { fail "missing receipt $RECEIPT"; echo "Validation summary: errors=$errors"; exit 1; }

  if [[ "$(yq -r '.schema_version // ""' "$RECEIPT")" == "authorization-boundary-coverage-v1" ]]; then
    pass "authorization coverage receipt schema is current"
  else
    fail "authorization coverage receipt schema must be authorization-boundary-coverage-v1"
  fi

  local spec_ref
  spec_ref="$(yq -r '.spec_ref // ""' "$RECEIPT")"
  if [[ -n "$spec_ref" && -f "$(resolve_repo_path "$spec_ref")" ]]; then
    pass "authorization boundary spec present"
    while IFS= read -r required_text; do
      [[ -n "$required_text" ]] || continue
      if has_text "$required_text" "$(resolve_repo_path "$spec_ref")"; then
        pass "authorization spec covers: $required_text"
      else
        fail "authorization spec must cover: $required_text"
      fi
    done < <(yq -r '.spec_assertions[]? // ""' "$RECEIPT")
  else
    fail "authorization boundary spec missing: $spec_ref"
  fi

  while IFS= read -r path_id; do
    [[ -n "$path_id" ]] || continue
    local file_ref
    file_ref="$(yq -r ".inventory[] | select(.path_id == \"$path_id\") | .file" "$RECEIPT")"
    local resolved_file
    resolved_file="$(resolve_repo_path "$file_ref")"
    if [[ -f "$resolved_file" ]]; then
      pass "$path_id file present"
    else
      fail "$path_id file missing: $file_ref"
      continue
    fi

    while IFS= read -r required_pattern; do
      [[ -n "$required_pattern" ]] || continue
      if has_text "$required_pattern" "$resolved_file"; then
        pass "$path_id contains pattern: $required_pattern"
      else
        fail "$path_id missing pattern: $required_pattern"
      fi
    done < <(yq -r ".inventory[] | select(.path_id == \"$path_id\") | .required_patterns[]? // \"\"" "$RECEIPT")
  done < <(yq -r '.inventory[]?.path_id // ""' "$RECEIPT")

  while IFS= read -r workflow_ref; do
    [[ -n "$workflow_ref" ]] || continue
    local resolved_workflow
    resolved_workflow="$(resolve_repo_path "$workflow_ref")"
    if [[ -f "$resolved_workflow" ]]; then
      pass "workflow gate present: $workflow_ref"
    else
      fail "workflow gate missing: $workflow_ref"
      continue
    fi
    while IFS= read -r required_text; do
      [[ -n "$required_text" ]] || continue
      if has_text "$required_text" "$resolved_workflow"; then
        pass "$workflow_ref contains gate text: $required_text"
      else
        fail "$workflow_ref must contain gate text: $required_text"
      fi
    done < <(yq -r ".workflow_gates[] | select(.workflow_ref == \"$workflow_ref\") | .required_text[]? // \"\"" "$RECEIPT")
  done < <(yq -r '.workflow_gates[]?.workflow_ref // ""' "$RECEIPT")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
