#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Support Dossier Evidence Depth Validation =="
while IFS= read -r dossier; do
  dossier_status="$(yq -r '.status // ""' "$dossier")"
  if [[ "$dossier_status" != "supported" ]]; then
    pass "${dossier#$ROOT_DIR/} is explicitly non-live and skipped"
    continue
  fi
  status="$(yq -r '.sufficiency.status // ""' "$dossier")"
  if [[ "$status" != "qualified" ]]; then
    fail "${dossier#$ROOT_DIR/} is not qualified"
    continue
  fi
  workload="$(yq -r '.tuple.workload_tier' "$dossier")"
  naturalistic="$(yq -r '.sufficiency.naturalistic_representative_run_present // "false"' "$dossier")"
  if [[ "$workload" != "observe-and-read" && "$naturalistic" != "true" ]]; then
    fail "${dossier#$ROOT_DIR/} lacks a naturalistic consequential representative run"
  else
    pass "${dossier#$ROOT_DIR/} carries sufficiency metadata"
  fi
done < <(/usr/bin/find "$OCTON_DIR/instance/governance/support-dossiers" -name dossier.yml | sort)

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
