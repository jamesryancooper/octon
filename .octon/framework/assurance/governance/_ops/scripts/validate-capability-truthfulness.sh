#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"
RELEASE_ROOT="$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found $1" || fail "missing $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }
role_run_id() { yq -r ".run_roles.${1}.run_id" "$CONFIG_FILE"; }

main() {
  echo "== Capability Truthfulness Validation =="

  require_file "$OCTON_DIR/framework/capabilities/runtime/services/browser-session/contract.yml"
  require_file "$OCTON_DIR/framework/capabilities/runtime/services/api-client/contract.yml"
  require_yq '.runtime_service_contract_refs[] | select(. == ".octon/framework/capabilities/runtime/services/browser-session/contract.yml")' \
    "$OCTON_DIR/framework/capabilities/packs/browser/manifest.yml" "browser pack cites browser-session runtime contract"
  require_yq '.runtime_service_contract_refs[] | select(. == ".octon/framework/capabilities/runtime/services/api-client/contract.yml")' \
    "$OCTON_DIR/framework/capabilities/packs/api/manifest.yml" "api pack cites api-client runtime contract"
  require_yq '.packs[] | select(.pack_id == "browser" and .runtime_service_contract_refs[] == ".octon/framework/capabilities/runtime/services/browser-session/contract.yml")' \
    "$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml" "browser registry binds runtime contract"
  require_yq '.packs[] | select(.pack_id == "api" and .runtime_service_contract_refs[] == ".octon/framework/capabilities/runtime/services/api-client/contract.yml")' \
    "$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml" "api registry binds runtime contract"

  local browser_run api_run
  browser_run="$(role_run_id external_evidence)"
  api_run="$(role_run_id github_projection)"
  require_yq '.requested_capability_packs | contains(["browser"])' "$OCTON_DIR/state/evidence/disclosure/runs/$browser_run/run-card.yml" "browser run card records browser pack"
  require_yq '.requested_capability_packs | contains(["api"])' "$OCTON_DIR/state/evidence/disclosure/runs/$browser_run/run-card.yml" "boundary-sensitive run card records api pack"
  require_yq '.requested_capability_packs | contains(["api"])' "$OCTON_DIR/state/evidence/disclosure/runs/$api_run/run-card.yml" "repo consequential run card records api pack"
  require_yq '.surfaces[] | select(.surface_id == "browser") | .runtime_refs | length > 0' "$RELEASE_ROOT/closure/support-universe-coverage.yml" "coverage ledger retains browser runtime refs"
  require_yq '.surfaces[] | select(.surface_id == "api") | .runtime_refs | length > 0' "$RELEASE_ROOT/closure/support-universe-coverage.yml" "coverage ledger retains api runtime refs"
  require_yq '.surfaces[] | select(.surface_id == "browser") | .proof_refs | length > 0' "$RELEASE_ROOT/closure/support-universe-coverage.yml" "coverage ledger retains browser proof refs"
  require_yq '.surfaces[] | select(.surface_id == "api") | .proof_refs | length > 0' "$RELEASE_ROOT/closure/support-universe-coverage.yml" "coverage ledger retains api proof refs"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
