#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"
AUTHORED="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
PROOF_COVERAGE="$OCTON_DIR/../$(yq -r '.proof_bundle_refs[] | select(test("proof-plane-coverage.yml$"))' "$AUTHORED" | head -n1)"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found $1" || fail "missing $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }
role_run_id() { yq -r ".run_roles.${1}.run_id" "$CONFIG_FILE"; }

validate_planes() {
  local run_id="$1"
  local root="$OCTON_DIR/state/evidence/runs/$run_id/assurance"
  local plane
  for plane in structural functional behavioral governance recovery maintainability; do
    require_file "$root/$plane.yml"
    require_yq '.outcome == "pass"' "$root/$plane.yml" "$run_id $plane proof passes"
  done
  require_file "$root/evaluator.yml"
}

main() {
  echo "== Proof-Plane Coverage Validation =="

  require_file "$OCTON_DIR/framework/constitution/contracts/assurance/proof-plane-coverage-v1.schema.json"
  require_file "$OCTON_DIR/framework/constitution/contracts/assurance/evaluator-independence-manifest-v1.schema.json"
  require_file "$OCTON_DIR/framework/assurance/evaluators/conformance/global-support-universe.yml"
  require_file "$OCTON_DIR/framework/assurance/evaluators/conformance/evaluator-independence.yml"
  require_file "$PROOF_COVERAGE"

  validate_planes "$(role_run_id supported_run_only)"
  validate_planes "$(role_run_id authority_exercise)"
  validate_planes "$(role_run_id intervention_control)"
  validate_planes "$(role_run_id github_projection)"
  validate_planes "$(role_run_id ci_projection)"
  validate_planes "$(role_run_id external_evidence)"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
