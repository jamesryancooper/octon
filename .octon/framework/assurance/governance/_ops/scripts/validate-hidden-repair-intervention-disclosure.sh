#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"
HIDDEN_REPAIR="$OCTON_DIR/state/evidence/validation/publication/unified-execution-constitution-closure/hidden-repair-detection.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found $1" || fail "missing $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }
role_run_id() { yq -r ".run_roles.${1}.run_id" "$CONFIG_FILE"; }

validate_run() {
  local run_id="$1"
  local log="$OCTON_DIR/state/evidence/runs/$run_id/interventions/log.yml"
  require_file "$log"
  require_yq '.schema_version == "intervention-log-v1"' "$log" "$run_id intervention log schema is stable"
  require_yq '.summary | length > 0' "$log" "$run_id intervention log has summary"
}

main() {
  echo "== Hidden-Repair And Intervention Disclosure Validation =="
  validate_run "$(role_run_id supported_run_only)"
  validate_run "$(role_run_id authority_exercise)"
  validate_run "$(role_run_id external_evidence)"
  validate_run "$(role_run_id intervention_control)"
  validate_run "$(role_run_id github_projection)"
  validate_run "$(role_run_id ci_projection)"
  require_file "$HIDDEN_REPAIR"
  require_yq '.status == "pass"' "$HIDDEN_REPAIR" "hidden repair detection passes"
  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
