#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

REGISTER="$OCTON_DIR/instance/governance/non-authority-register.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Non-Authority Register Validation =="
[[ -f "$REGISTER" ]] || { fail "missing non-authority register"; echo "Validation summary: errors=$errors"; exit 1; }

entries="$(yq -r '.entries | length' "$REGISTER")"
[[ "$entries" -ge 3 ]] && pass "non-authority register inventories permanent derived surfaces" || fail "non-authority register has too few entries"

while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  [[ -e "$ROOT_DIR/$path" ]] && pass "registered path exists: $path" || fail "registered path missing: $path"
done < <(yq -r '.entries[].paths[]' "$REGISTER")

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
