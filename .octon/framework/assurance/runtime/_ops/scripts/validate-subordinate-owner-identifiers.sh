#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

if command -v rg >/dev/null 2>&1; then
  if rg -n --glob '*.md' --glob '*.yml' '@you|@teammate' "$OCTON_DIR/framework/cognition/governance"; then
    echo "[ERROR] placeholder subordinate owner identifiers remain under framework/cognition/governance"
    exit 1
  fi
else
  if grep -RInE --include='*.md' --include='*.yml' '@you|@teammate' "$OCTON_DIR/framework/cognition/governance"; then
    echo "[ERROR] placeholder subordinate owner identifiers remain under framework/cognition/governance"
    exit 1
  fi
fi

echo "[OK] subordinate governance surfaces no longer use placeholder owner identifiers"
