#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

MANIFEST="$OCTON_DIR/instance/ingress/manifest.yml"
OCTON_ADAPTER="$OCTON_DIR/AGENTS.md"
ROOT_ADAPTER="$ROOT_DIR/AGENTS.md"
CLAUDE_ADAPTER="$ROOT_DIR/CLAUDE.md"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Ingress Manifest Parity Validation =="
[[ -f "$MANIFEST" ]] && pass "ingress manifest exists" || fail "missing ingress manifest"

for target in "$OCTON_ADAPTER" "$ROOT_ADAPTER" "$CLAUDE_ADAPTER"; do
  if cmp -s "$OCTON_ADAPTER" "$target"; then
    pass "${target#$ROOT_DIR/} matches .octon adapter text"
  else
    fail "${target#$ROOT_DIR/} does not match .octon adapter text"
  fi
done

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
