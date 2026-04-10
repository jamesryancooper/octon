#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found $1" || fail "missing $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }
role_run_id() { yq -r ".run_roles.${1}.run_id" "$CONFIG_FILE"; }

validate_run() {
  local run_id="$1"
  local run_root="$OCTON_DIR/state/control/execution/runs/$run_id/authority"
  require_file "$run_root/grant-bundle.yml"
  require_file "$run_root/decision.yml"
  require_file "$run_root/budget-ledger.yml"
  require_yq '.schema_version == "authority-grant-bundle-v2"' "$run_root/grant-bundle.yml" "$run_id uses grant-bundle v2"
  require_yq '.schema_version == "authority-decision-artifact-v2"' "$run_root/decision.yml" "$run_id uses decision artifact v2"
  require_yq '.schema_version == "budget-ledger-v1"' "$run_root/budget-ledger.yml" "$run_id has per-run budget ledger"
}

main() {
  echo "== Authority Bundle Resolution Validation =="

  validate_run "$(role_run_id supported_run_only)"
  validate_run "$(role_run_id external_evidence)"
  validate_run "$(role_run_id github_projection)"
  validate_run "$(role_run_id ci_projection)"

  local authority_run
  authority_run="$(role_run_id authority_exercise)"
  validate_run "$authority_run"
  require_file "$OCTON_DIR/state/control/execution/exceptions/leases/lease-$authority_run.yml"
  require_file "$OCTON_DIR/state/control/execution/revocations/revoke-$authority_run.yml"
  require_yq ".exception_lease_refs[] | select(. == \".octon/state/control/execution/exceptions/leases/lease-${authority_run}.yml\")" \
    "$OCTON_DIR/state/control/execution/runs/$authority_run/authority/grant-bundle.yml" \
    "authority exercise resolves canonical lease ref"
  require_yq ".revocation_refs[] | select(. == \".octon/state/control/execution/revocations/revoke-${authority_run}.yml\")" \
    "$OCTON_DIR/state/control/execution/runs/$authority_run/authority/grant-bundle.yml" \
    "authority exercise resolves canonical revocation ref"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
