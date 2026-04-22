#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ACTIVE_STATE="$OCTON_DIR/state/control/extensions/active.yml"

errors=0
fail(){ echo "[ERROR] $1"; errors=$((errors+1)); }
pass(){ echo "[OK] $1"; }

echo "== Extension Active State Compactness Validation =="

[[ -f "$ACTIVE_STATE" ]] && pass "active state present" || fail "missing active state"
[[ "$(yq -r '.schema_version // ""' "$ACTIVE_STATE")" == "octon-extension-active-state-v4" ]] && pass "active state schema current" || fail "active state schema invalid"

if yq -e '.dependency_closure' "$ACTIVE_STATE" >/dev/null 2>&1; then
  fail "dependency_closure must move out of active state"
else
  pass "dependency_closure removed from active state"
fi

if yq -e '.required_inputs' "$ACTIVE_STATE" >/dev/null 2>&1; then
  fail "required_inputs must move out of active state"
else
  pass "required_inputs removed from active state"
fi

for query in \
  '.desired_config_revision.path' \
  '.desired_config_revision.sha256' \
  '.published_effective_catalog' \
  '.published_artifact_map' \
  '.published_generation_lock' \
  '.publication_receipt_path' \
  '.compatibility_receipt_path' \
  '.status'
do
  value="$(yq -r "$query // \"\"" "$ACTIVE_STATE")"
  [[ -n "$value" ]] && pass "active state retains $query" || fail "active state missing $query"
done

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
