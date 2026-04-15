#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
EXTENSIONS_ROOT="$OCTON_DIR/inputs/additive/extensions"

errors=0
ran=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

if [[ ! -d "$EXTENSIONS_ROOT" ]]; then
  pass "extension validation tests skipped (no extensions root)"
  exit 0
fi

while IFS= read -r test_script; do
  [[ -n "$test_script" ]] || continue
  ran=$((ran + 1))
  label="${test_script#$ROOT_DIR/}"
  if OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" bash "$test_script" >/dev/null; then
    pass "extension-local validation test passed: $label"
  else
    fail "extension-local validation test failed: $label"
  fi
done < <(find "$EXTENSIONS_ROOT" -path '*/validation/tests/*.sh' -type f | sort)

if [[ "$ran" -eq 0 ]]; then
  pass "extension validation tests skipped (no extension-local tests found)"
fi

echo "Validation summary: errors=$errors"
if [[ $errors -gt 0 ]]; then
  exit 1
fi
