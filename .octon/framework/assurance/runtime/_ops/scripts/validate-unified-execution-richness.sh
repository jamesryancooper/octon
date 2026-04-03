#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

require_yq() {
  local expr="$1"
  local file="$2"
  local label="$3"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

validate_run_bundle() {
  local run_id="$1"
  local run_root="$OCTON_DIR/state/control/execution/runs/$run_id"
  local evidence_root="$OCTON_DIR/state/evidence/runs/$run_id"
  local contract="$run_root/run-contract.yml"
  local stage="$run_root/stage-attempts/initial.yml"
  local rollback="$run_root/rollback-posture.yml"
  local retry="$run_root/retry-records/baseline.yml"
  local contamination="$run_root/contamination/current.yml"
  local measurement_summary="$evidence_root/measurements/summary.yml"
  local measurement_record="$evidence_root/measurements/records/runtime-lifecycle.yml"
  local intervention_log="$evidence_root/interventions/log.yml"
  local intervention_record="$evidence_root/interventions/records/no-human-intervention.yml"
  local classification="$evidence_root/evidence-classification.yml"

  require_file "$contract"
  require_file "$stage"
  require_file "$rollback"
  require_file "$retry"
  require_file "$contamination"
  require_file "$measurement_summary"
  require_file "$measurement_record"
  require_file "$intervention_log"
  require_file "$intervention_record"
  require_file "$classification"

  require_yq '.mission_mode == "none" or .mission_mode == "required" or .mission_mode == "optional"' "$contract" "$run_id run contract declares mission_mode"
  require_yq '.objective_summary != null and .objective_summary != ""' "$contract" "$run_id run contract declares objective_summary"
  require_yq '.done_when | length > 0' "$contract" "$run_id run contract declares done_when"
  require_yq '.acceptance_criteria | length > 0' "$contract" "$run_id run contract declares acceptance criteria"
  require_yq '.protected_zones | length > 0' "$contract" "$run_id run contract declares protected zones"
  require_yq '.start_conditions | length > 0 and .stop_conditions | length > 0' "$contract" "$run_id run contract declares start/stop conditions"
  require_yq '.retry_class != null and .contract_version != null and .issued_at != null' "$contract" "$run_id run contract declares retry/disclosure versioning fields"

  require_yq '.objective_slice != null and .entry_criteria | length > 0 and .exit_criteria | length > 0' "$stage" "$run_id stage attempt declares entry/exit criteria"
  require_yq '.allowed_capabilities | length > 0 and .allowed_zones | length > 0' "$stage" "$run_id stage attempt declares allowed capabilities and zones"
  require_yq '.retry_class != null and .completion_status != null and .issued_by != null and .validated_by != null' "$stage" "$run_id stage attempt declares retry and issuance metadata"

  require_yq '.retry_record_ref != null and .contamination_record_ref != null and .resume_allowed == true' "$rollback" "$run_id rollback posture binds retry/contamination state"
  require_yq '.retry_class != null and .route_taken != null' "$retry" "$run_id retry record is typed"
  require_yq '.contamination_state == "clean" and .contamination_class == "none"' "$contamination" "$run_id contamination record is typed"

  require_yq '.metrics[] | select(.metric_id == "measurement-record-count")' "$measurement_summary" "$run_id measurement summary cites detailed records"
  require_yq '.metric_id == "lifecycle-artifact-count"' "$measurement_record" "$run_id measurement record exists"
  require_yq '.summary | test("intervention record family")' "$intervention_log" "$run_id intervention log acknowledges detailed records"
  require_yq '.kind == "no-material-intervention" and .disclosed == true' "$intervention_record" "$run_id intervention record exists"

  require_yq '.artifacts[] | select(.artifact_id == "retry-record")' "$classification" "$run_id evidence classification covers retry record"
  require_yq '.artifacts[] | select(.artifact_id == "contamination-record")' "$classification" "$run_id evidence classification covers contamination record"
  require_yq '.artifacts[] | select(.artifact_id == "measurement-record")' "$classification" "$run_id evidence classification covers measurement record"
  require_yq '.artifacts[] | select(.artifact_id == "intervention-record")' "$classification" "$run_id evidence classification covers intervention record"
}

main() {
  echo "== Unified Execution Richness Validation =="

  require_file "$OCTON_DIR/framework/constitution/contracts/objective/run-contract-v1.schema.json"
  require_file "$OCTON_DIR/framework/constitution/contracts/objective/stage-attempt-v1.schema.json"
  require_file "$OCTON_DIR/framework/constitution/contracts/runtime/retry-record-v1.schema.json"
  require_file "$OCTON_DIR/framework/constitution/contracts/runtime/contamination-record-v1.schema.json"
  require_file "$OCTON_DIR/framework/constitution/contracts/runtime/trace-pointers-v1.schema.json"
  require_file "$OCTON_DIR/framework/observability/runtime/contracts/measurement-record-v1.schema.json"
  require_file "$OCTON_DIR/framework/observability/runtime/contracts/intervention-record-v1.schema.json"
  require_file "$OCTON_DIR/framework/observability/runtime/contracts/drift-incident-v1.schema.json"
  require_file "$OCTON_DIR/framework/assurance/behavioral/suites/held-out-supported-envelope.yml"
  require_file "$OCTON_DIR/framework/assurance/governance/anti-overfitting-policy.yml"
  require_file "$OCTON_DIR/instance/governance/contracts/agency-surface-classification-ledger.yml"
  require_file "$OCTON_DIR/state/evidence/lab/scenarios/scn-held-out-supported-20260402/scenario-proof.yml"
  require_file "$OCTON_DIR/state/evidence/lab/adversarial/adv-supported-envelope-20260402/adversarial-report.yml"
  require_file "$OCTON_DIR/state/evidence/validation/publication/build-to-delete/2026-04-02/drift-runtime-disclosure-mismatch.yml"

  validate_run_bundle "uec-validate-proposal-20260401-agent-augmented-3"
  validate_run_bundle "uec-evaluate-harness-20260401-agent-augmented-1"
  validate_run_bundle "uec-audit-workflow-system-20260401-agent-augmented-1"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
