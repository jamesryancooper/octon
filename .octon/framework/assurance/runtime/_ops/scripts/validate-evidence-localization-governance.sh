#!/usr/bin/env bash
set -euo pipefail
ROOT="${OCTON_ROOT_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)}"
files=(
  .octon/instance/governance/policies/evidence-localization.yml
  .octon/framework/product/contracts/evidence-localization-manifest-v1.schema.json
  .octon/framework/product/contracts/evidence-localization-receipt-v1.schema.json
  .octon/framework/product/contracts/evidence-localization-cleanup-authorization-v1.schema.json
  .octon/framework/assurance/runtime/_ops/scripts/evidence-localization.py
  .octon/framework/assurance/runtime/_ops/tests/test-evidence-localization.sh
)
for f in "${files[@]}"; do [[ -f "$ROOT/$f" ]] || { echo "[ERROR] missing $f"; exit 1; }; done
for f in "$ROOT"/.octon/framework/product/contracts/evidence-localization-*.schema.json; do jq -e . "$f" >/dev/null; done
yq -e '.archive_root.caller_override_allowed == false and .retention.require_rollback_posture == true and .compact_receipt.protected_from_generic_cleanup == true' "$ROOT/.octon/instance/governance/policies/evidence-localization.yml" >/dev/null
yq -e '.commands[] | select(.id == "evidence-localization" and .access == "agent")' "$ROOT/.octon/instance/capabilities/runtime/commands/manifest.yml" >/dev/null
rg -F 'protected_terminal_or_inactive_operational_evidence' "$ROOT/.octon/framework/product/contracts/change-closeout-state-machine.yml" >/dev/null
bash "$ROOT/.octon/framework/assurance/runtime/_ops/tests/test-evidence-localization.sh"
echo '[OK] evidence localization governance validates'
