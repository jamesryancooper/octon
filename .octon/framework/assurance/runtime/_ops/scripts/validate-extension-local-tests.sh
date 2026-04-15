#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
EXTENSIONS_ROOT="$OCTON_DIR/inputs/additive/extensions"
EXTENSIONS_MANIFEST="$OCTON_DIR/instance/extensions.yml"

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

if [[ ! -f "$EXTENSIONS_MANIFEST" ]]; then
  fail "extension validation tests require manifest: ${EXTENSIONS_MANIFEST#$ROOT_DIR/}"
  echo "Validation summary: errors=$errors"
  exit 1
fi

while IFS=$'\t' read -r pack_id source_id; do
  [[ -n "$pack_id" ]] || continue
  while IFS= read -r test_script; do
    [[ -n "$test_script" ]] || continue
    ran=$((ran + 1))
    label="${test_script#$ROOT_DIR/}"
    if OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" bash "$test_script" >/dev/null; then
      pass "extension-local validation test passed: $label"
    else
      fail "extension-local validation test failed: $label"
    fi
  done < <(find "$EXTENSIONS_ROOT/$pack_id" -path '*/validation/tests/*.sh' -type f | sort)
done < <(
  yq -r '.selection.enabled[]? | [.pack_id, (.source_id // "")] | @tsv' \
    "$EXTENSIONS_MANIFEST" 2>/dev/null
)

if [[ "$ran" -eq 0 ]]; then
  pass "extension validation tests skipped (no selected extension-local tests found)"
fi

echo "Validation summary: errors=$errors"
if [[ $errors -gt 0 ]]; then
  exit 1
fi
