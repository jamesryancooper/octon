#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
FILE="$OCTON_DIR/framework/constitution/obligations/evidence.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Evidence Obligation ID Validation =="

[[ -f "$FILE" ]] || { fail "missing $FILE"; exit 1; }
[[ "$(yq -r '.obligation_contract.id_namespace // ""' "$FILE")" == "EVI" ]] && pass "EVI namespace declared" || fail "EVI namespace missing"
[[ "$(yq -r '.obligation_contract.uniqueness_required // "false"' "$FILE")" == "true" ]] && pass "uniqueness required" || fail "uniqueness contract missing"

mapfile -t ids < <(yq -r '.obligations[].id' "$FILE")
[[ ${#ids[@]} -gt 0 ]] && pass "obligation ids present" || fail "no evidence ids found"

dup_count="$(printf '%s\n' "${ids[@]}" | sort | uniq -d | wc -l | tr -d ' ')"
[[ "$dup_count" == "0" ]] && pass "obligation ids are unique" || fail "duplicate evidence obligation ids detected"

while IFS= read -r id; do
  [[ "$id" =~ ^EVI-[0-9]{3}$ ]] && pass "id format ok: $id" || fail "invalid id format: $id"
done < <(printf '%s\n' "${ids[@]}")

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
