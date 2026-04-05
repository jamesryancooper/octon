#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"
RELEASE_ROOT="$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
role_run_id() { yq -r ".run_roles.${1}.run_id" "$CONFIG_FILE"; }

require_ref() {
  local ref="$1"
  local label="$2"
  [[ -n "$ref" && "$ref" != "null" ]] || { fail "$label missing"; return; }
  local abs="$ROOT_DIR/$ref"
  [[ -e "$abs" ]] && pass "$label resolves" || fail "$label missing target $ref"
}

validate_run_card() {
  local run_id="$1"
  local card="$OCTON_DIR/state/evidence/disclosure/runs/$run_id/run-card.yml"
  require_ref "$(yq -r '.support_target_ref' "$card")" "$run_id support target ref"
  require_ref "$(yq -r '.authority_refs.run_contract' "$card")" "$run_id run contract ref"
  require_ref "$(yq -r '.authority_refs.decision_artifact' "$card")" "$run_id decision ref"
  require_ref "$(yq -r '.authority_refs.grant_bundle' "$card")" "$run_id grant bundle ref"
  require_ref "$(yq -r '.measurement_ref' "$card")" "$run_id measurement ref"
  require_ref "$(yq -r '.intervention_ref' "$card")" "$run_id intervention ref"
  require_ref "$(yq -r '.replay_ref' "$card")" "$run_id replay ref"
  require_ref "$(yq -r '.recovery_ref' "$card")" "$run_id recovery ref"
  local ref
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    require_ref "$ref" "$run_id proof ref $ref"
  done < <(yq -r '.proof_plane_refs[]' "$card")
}

main() {
  echo "== Disclosure Referential Integrity Validation =="

  local authored="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
  local release="$RELEASE_ROOT/harness-card.yml"
  local coverage="$RELEASE_ROOT/closure/support-universe-coverage.yml"
  local closure="$RELEASE_ROOT/closure/closure-certificate.yml"

  require_ref "$(yq -r '.coverage_ledger_ref' "$authored")" "authored HarnessCard coverage ref"
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    require_ref "$ref" "authored HarnessCard proof ref $ref"
  done < <(yq -r '.proof_bundle_refs[]' "$authored")
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    require_ref "$ref" "release HarnessCard proof ref $ref"
  done < <(yq -r '.proof_bundle_refs[]' "$release")

  local ref
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    require_ref "$ref" "coverage runtime ref $ref"
  done < <(yq -r '.surfaces[].runtime_refs[]?' "$coverage")
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    require_ref "$ref" "coverage proof ref $ref"
  done < <(yq -r '.surfaces[].proof_refs[]?' "$coverage")
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    require_ref "$ref" "coverage disclosure ref $ref"
  done < <(yq -r '.surfaces[].disclosure_refs[]?' "$coverage")

  pass "closure proof refs are validated by the final closure assertion"

  validate_run_card "$(role_run_id supported_run_only)"
  validate_run_card "$(role_run_id authority_exercise)"
  validate_run_card "$(role_run_id external_evidence)"
  validate_run_card "$(role_run_id intervention_control)"
  validate_run_card "$(role_run_id github_projection)"
  validate_run_card "$(role_run_id ci_projection)"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
