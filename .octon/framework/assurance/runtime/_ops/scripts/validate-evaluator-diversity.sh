#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Evaluator Diversity Validation =="
while IFS= read -r dossier; do
  present="$(yq -r '.sufficiency.evaluator_classes_present | length' "$dossier")"
  required="$(yq -r '.sufficiency.evaluator_classes_required | length' "$dossier")"
  if [[ "$present" -lt "$required" ]]; then
    fail "${dossier#$ROOT_DIR/} has fewer evaluator classes present than required"
  else
    pass "${dossier#$ROOT_DIR/} meets evaluator class minima"
  fi
done < <(/usr/bin/find "$OCTON_DIR/instance/governance/support-dossiers" -name dossier.yml | sort)

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
