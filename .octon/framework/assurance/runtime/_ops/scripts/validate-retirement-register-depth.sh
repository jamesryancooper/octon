#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

REGISTER="$OCTON_DIR/instance/governance/retirement-register.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Retirement Register Depth Validation =="
[[ -f "$REGISTER" ]] || { fail "missing retirement register"; echo "Validation summary: errors=$errors"; exit 1; }

for field in canonical_successor_ref certificate_blocker future_widening_blocker latest_review_packet_ref rationale next_review_due; do
  if yq -e ".entries[] | has(\"$field\")" "$REGISTER" >/dev/null 2>&1; then
    pass "retirement entries carry $field"
  else
    fail "retirement register missing $field on one or more entries"
  fi
done

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
