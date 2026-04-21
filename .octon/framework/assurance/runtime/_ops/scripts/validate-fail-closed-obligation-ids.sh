#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
FILE="$OCTON_DIR/framework/constitution/obligations/fail-closed.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Fail-Closed Obligation ID Validation =="

[[ -f "$FILE" ]] || { fail "missing $FILE"; exit 1; }
[[ "$(yq -r '.reason_code_contract.id_namespace // ""' "$FILE")" == "FCR" ]] && pass "FCR namespace declared" || fail "FCR namespace missing"
[[ "$(yq -r '.reason_code_contract.uniqueness_required // "false"' "$FILE")" == "true" ]] && pass "uniqueness required" || fail "uniqueness contract missing"

mapfile -t ids < <(yq -r '.rules[].id' "$FILE")
[[ ${#ids[@]} -gt 0 ]] && pass "rule ids present" || fail "no rule ids found"

dup_count="$(printf '%s\n' "${ids[@]}" | sort | uniq -d | wc -l | tr -d ' ')"
[[ "$dup_count" == "0" ]] && pass "rule ids are unique" || fail "duplicate fail-closed rule ids detected"

while IFS= read -r id; do
  [[ "$id" =~ ^FCR-[0-9]{3}$ ]] && pass "id format ok: $id" || fail "invalid id format: $id"
done < <(printf '%s\n' "${ids[@]}")

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
