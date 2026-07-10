#!/usr/bin/env bash
# Doc/registry consistency check for the Architecture Lens Bank Foundation child.
# Verifies architecture-lens-bank.md and lens-bank.yml agree on the 18 lens ids,
# tiers (12 core + 6 extended), the six method profiles, and the Balanced
# required set. Exits non-zero on any disagreement.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../../.." && pwd)"
BANK="$ROOT/.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml"
DOC="$ROOT/.octon/framework/cognition/practices/methodology/architectural-review/architecture-lens-bank.md"
errors=0

total="$(yq -r '.lenses | length' "$BANK")"
core="$(yq -r '[.lenses[] | select(.tier == "core")] | length' "$BANK")"
extended="$(yq -r '[.lenses[] | select(.tier == "extended")] | length' "$BANK")"
echo "lens totals: total=$total core=$core extended=$extended"
[ "$total" = "18" ] || { echo "[ERROR] expected 18 lenses, got $total"; errors=$((errors+1)); }
[ "$core" = "12" ] || { echo "[ERROR] expected 12 core lenses, got $core"; errors=$((errors+1)); }
[ "$extended" = "6" ] || { echo "[ERROR] expected 6 extended lenses, got $extended"; errors=$((errors+1)); }

echo "-- every YAML lens id present in doc --"
for id in $(yq -r '.lenses[].id' "$BANK"); do
  if grep -q "\`$id\`" "$DOC"; then
    :
  else
    echo "[ERROR] lens id missing from doc: $id"
    errors=$((errors+1))
  fi
done

echo "-- every suite method present in doc profile table --"
for m in Balanced Greenfield Tradeoff Failure-Mode Evolution/Fitness Boundary/Authority; do
  if grep -q "$m" "$DOC"; then
    :
  else
    echo "[ERROR] method column missing from doc table: $m"
    errors=$((errors+1))
  fi
done

echo "-- Balanced required set (YAML) --"
balanced_required="$(yq -r '.method_profiles."balanced-architecture-review-method".required[]' "$BANK" | sort | tr '\n' ' ')"
echo "$balanced_required"
expected="authority-boundary clean-sheet-reference complexity-separation current-reality-map failure-and-recovery non-goals-deletion steelman-chestertons-fence system-job-framing tradeoff-adr validation-strategy "
if [ "$balanced_required" = "$expected" ]; then
  echo "[OK] Balanced required set equals the 10 R lens ids"
else
  echo "[ERROR] Balanced required set mismatch"
  errors=$((errors+1))
fi

echo "Consistency summary: errors=$errors"
[ "$errors" -eq 0 ]
