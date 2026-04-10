#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

CROSSWALK="$OCTON_DIR/instance/governance/closure/current-audit-crosswalk.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Current Audit Crosswalk Validation =="
[[ -f "$CROSSWALK" ]] || { fail "missing current-audit-crosswalk.yml"; echo "Validation summary: errors=$errors"; exit 1; }

count="$(yq -r '.entries | length' "$CROSSWALK")"
[[ "$count" == "3" ]] && pass "crosswalk contains all three retained audit findings" || fail "expected 3 crosswalk entries, found $count"

for finding in ODP-AUD-001 ODP-AUD-002 ODP-AUD-003; do
  if yq -e ".entries[] | select(.finding_id == \"$finding\")" "$CROSSWALK" >/dev/null 2>&1; then
    pass "crosswalk includes $finding"
  else
    fail "crosswalk missing $finding"
  fi
done

if yq -e '.entries[] | select(.current_disposition == "reopened")' "$CROSSWALK" >/dev/null 2>&1; then
  fail "crosswalk contains reopened findings"
else
  pass "crosswalk dispositions are closure-safe"
fi

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
