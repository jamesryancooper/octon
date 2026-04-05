#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

REGISTRY="$OCTON_DIR/instance/governance/contracts/retirement-registry.yml"
LEDGER="$OCTON_DIR/instance/governance/closure/global-support-surface-ledger.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }

main() {
  echo "== Global Retirement Closure Validation =="
  require_yq '.status == "closed"' "$REGISTRY" "retirement registry is closed"
  require_yq '[.entries[] | select(.status == "registered" or .status == "active")] | length == 0' "$REGISTRY" "no registered or active retirement entry remains"
  require_yq '.retired[] | select(. == "experimental-model-surface")' "$LEDGER" "surface ledger records retired model surface"
  require_yq '.rebound[] | select(.surface_id == "deny-only-external-irreversible-surface")' "$LEDGER" "surface ledger records rebound deny-only surface"
  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
