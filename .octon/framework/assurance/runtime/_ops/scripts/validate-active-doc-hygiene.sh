#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture-target-state-transition/docs/active-doc-hygiene.yml"

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

echo "== Active Doc Hygiene Validation =="

[[ -f "$RECEIPT" ]] || { fail "missing active-doc hygiene receipt"; exit 1; }

while IFS= read -r doc_ref; do
  [[ -n "$doc_ref" ]] || continue
  doc_path="$(resolve_repo_path "$doc_ref")"
  [[ -f "$doc_path" ]] && pass "doc present: $doc_ref" || fail "missing doc: $doc_ref"
  while IFS= read -r pattern; do
    [[ -n "$pattern" ]] || continue
    if rg -Fq -- "$pattern" "$doc_path"; then
      fail "$doc_ref contains forbidden pattern: $pattern"
    else
      pass "$doc_ref excludes forbidden pattern: $pattern"
    fi
  done < <(yq -r '.required_absent_patterns[]' "$RECEIPT")
done < <(yq -r '.checked_docs[]' "$RECEIPT")

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
