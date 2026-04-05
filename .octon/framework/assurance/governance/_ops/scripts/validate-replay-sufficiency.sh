#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }
role_run_id() { yq -r ".run_roles.${1}.run_id" "$CONFIG_FILE"; }

validate_run() {
  local run_id="$1"
  local root="$OCTON_DIR/state/evidence/runs/$run_id"
  jq -e '.schema_version == "execution-receipt-v2" and .evidence_links.run_control_root and .evidence_links.run_receipts_root and .timestamps.started_at and .timestamps.completed_at' \
    "$root/receipts/execution-receipt.json" >/dev/null 2>&1 \
    && pass "$run_id execution receipt is replay-sufficient" \
    || fail "$run_id execution receipt is replay-sufficient"
  require_yq '.schema_version == "replay-manifest-v2"' "$root/replay/manifest.yml" "$run_id replay manifest uses v2"
  require_yq '.schema_version == "trace-pointer-v2"' "$root/trace-pointers.yml" "$run_id trace pointers use v2"
  require_yq '.external_index_refs | length > 0' "$root/replay-pointers.yml" "$run_id replay pointers retain external indexes"
}

main() {
  echo "== Replay Sufficiency Validation =="
  validate_run "$(role_run_id supported_run_only)"
  validate_run "$(role_run_id authority_exercise)"
  validate_run "$(role_run_id external_evidence)"
  validate_run "$(role_run_id intervention_control)"
  validate_run "$(role_run_id github_projection)"
  validate_run "$(role_run_id ci_projection)"
  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
