#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-remediation/registry/input-non-authority-scan.yml"

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
    fail "yq is required for input non-authority validation"
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

is_allowed_file() {
  local candidate="$1"
  while IFS= read -r allowed; do
    [[ -n "$allowed" ]] || continue
    if [[ "$candidate" == "$(resolve_repo_path "$allowed")" ]]; then
      return 0
    fi
  done < <(yq -r '.allowed_reference_files[]? // ""' "$RECEIPT")
  return 1
}

main() {
  echo "== Input Non-Authority Validation =="

  require_yq
  [[ -f "$RECEIPT" ]] && pass "input non-authority receipt present" || { fail "missing receipt $RECEIPT"; echo "Validation summary: errors=$errors"; exit 1; }

  if [[ "$(yq -r '.schema_version // ""' "$RECEIPT")" == "input-non-authority-scan-v1" ]]; then
    pass "input non-authority receipt schema is current"
  else
    fail "input non-authority receipt schema must be input-non-authority-scan-v1"
  fi

  while IFS= read -r file_ref; do
    [[ -n "$file_ref" ]] || continue
    local resolved_file
    resolved_file="$(resolve_repo_path "$file_ref")"
    if [[ -f "$resolved_file" ]]; then
      pass "allowed reference file present: $file_ref"
    else
      fail "missing allowed reference file: $file_ref"
      continue
    fi
    while IFS= read -r required_text; do
      [[ -n "$required_text" ]] || continue
      if has_text "$required_text" "$resolved_file"; then
        pass "$file_ref documents allowed input handling: $required_text"
      else
        fail "$file_ref must justify allowed input handling with: $required_text"
      fi
    done < <(yq -r ".allowed_reference_assertions[] | select(.file == \"$file_ref\") | .required_text[]? // \"\"" "$RECEIPT")
  done < <(yq -r '.allowed_reference_assertions[]?.file // ""' "$RECEIPT")

  while IFS= read -r pattern; do
    [[ -n "$pattern" ]] || continue
    while IFS=: read -r file _rest; do
      [[ -n "$file" ]] || continue
      if is_allowed_file "$file"; then
        pass "allowed inputs reference: ${file#$ROOT_DIR/}"
      else
        fail "forbidden runtime or policy dependency on inputs/**: ${file#$ROOT_DIR/}"
      fi
    done < <(
      while IFS= read -r scan_root; do
        [[ -n "$scan_root" ]] || continue
        local resolved_root
        resolved_root="$(resolve_repo_path "$scan_root")"
        if [[ -e "$resolved_root" ]]; then
          if command -v rg >/dev/null 2>&1; then
            rg -n -F -- "$pattern" "$resolved_root" || true
          else
            grep -RFn -- "$pattern" "$resolved_root" || true
          fi
        fi
      done < <(yq -r '.scan_roots[]? // ""' "$RECEIPT")
    )
  done < <(yq -r '.scan_patterns[]? // ""' "$RECEIPT")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
