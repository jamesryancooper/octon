#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Raw Generated Effective Runtime Read Validation =="

pattern="generated/effective/(runtime/route-bundle|capabilities/pack-routes|governance/support-target-matrix|governance/support-envelope-reconciliation|extensions/catalog\\.effective|capabilities/routing\\.effective)"
search_rs() {
  local search_root="$1"
  local search_pattern="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -n "$search_pattern" "$search_root" -g '*.rs' || true
  else
    grep -R -n -E --include='*.rs' "$search_pattern" "$search_root" || true
  fi
}

first_cfg_test_line() {
  local file="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -n '^[[:space:]]*#\[cfg\(test\)\]' "$file" | head -1 | cut -d: -f1 || true
  else
    grep -n -E '^[[:space:]]*#\[cfg\(test\)\]' "$file" | head -1 | cut -d: -f1 || true
  fi
}

raw_hits="$(search_rs "$OCTON_DIR/framework/engine/runtime/crates" "$pattern")"
hits=""

while IFS= read -r hit; do
  [[ -n "$hit" ]] || continue
  file="${hit%%:*}"
  rest="${hit#*:}"
  line_no="${rest%%:*}"
  case "$file" in
    "$OCTON_DIR/framework/engine/runtime/crates/runtime_resolver/"*) continue ;;
    */tests.rs|*/tests/*|*/fixtures/*) continue ;;
  esac
  test_start="$(first_cfg_test_line "$file")"
  if [[ -n "$test_start" && "$line_no" -ge "$test_start" ]]; then
    continue
  fi
  hits+="$hit"$'\n'
done <<< "$raw_hits"

if [[ -z "$hits" ]]; then
  pass "runtime crates avoid raw generated/effective reads outside runtime_resolver"
else
  fail "raw generated/effective reads detected outside runtime_resolver: $hits"
fi

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
