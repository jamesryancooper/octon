#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
source "$SCRIPT_DIR/validator-result-common.sh"

FIXTURE="$OCTON_DIR/framework/assurance/runtime/_ops/fixtures/existing-lifecycle-run-admission-v1/fixture-set.yml"
TEST="$OCTON_DIR/framework/assurance/runtime/_ops/tests/test-existing-lifecycle-run-admission.sh"
MAIN_RS="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/main.rs"
COMMANDS_RS="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/commands/mod.rs"
ADMISSION_RS="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/lifecycle_run_admission.rs"
RUN_REQUIRED="$OCTON_DIR/framework/engine/runtime/policies/run-required.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found ${1#$ROOT_DIR/}" || fail "missing ${1#$ROOT_DIR/}"; }
require_text() {
  local pattern="$1" file="$2" label="$3"
  if rg -q -- "$pattern" "$file" 2>/dev/null; then pass "$label"; else fail "$label"; fi
}
require_fixture_value() {
  local expr="$1" label="$2"
  if yq -e "$expr" "$FIXTURE" >/dev/null 2>&1; then pass "$label"; else fail "$label"; fi
}

reset_validator_result_metadata
validator_result_add_evidence \
  ".octon/framework/assurance/runtime/_ops/fixtures/existing-lifecycle-run-admission-v1/fixture-set.yml"
validator_result_add_runtime_test \
  ".octon/framework/assurance/runtime/_ops/tests/test-existing-lifecycle-run-admission.sh"
validator_result_add_negative_control \
  "unknown-run-id-denied" \
  "target-and-lifecycle-mismatch-denied" \
  "stale-checkpoint-and-broken-event-chain-denied" \
  "conflicting-contract-and-widened-scope-denied" \
  "missing-rollback-and-delegation-denied" \
  "post-mutation-admission-denied" \
  "compatibility-environment-not-authority" \
  "pre-admission-execution-denied"
validator_result_add_contract \
  ".octon/framework/constitution/contracts/runtime/run-contract-v3.schema.json" \
  ".octon/framework/constitution/contracts/runtime/run-manifest-v2.schema.json" \
  ".octon/framework/constitution/contracts/runtime/runtime-state-v2.schema.json" \
  ".octon/framework/engine/runtime/policies/run-required.yml"
validator_result_add_schema_version "octon-fixture-set-v1"

echo "== Existing Lifecycle Run Admission Validation =="
command -v yq >/dev/null 2>&1 || { fail "yq is required"; }
require_file "$FIXTURE"
require_file "$TEST"
require_file "$MAIN_RS"
require_file "$COMMANDS_RS"
require_file "$ADMISSION_RS"
require_file "$RUN_REQUIRED"

if [[ -f "$FIXTURE" ]] && command -v yq >/dev/null 2>&1; then
  require_fixture_value '.schema_version == "octon-fixture-set-v1"' "fixture schema is current"
  require_fixture_value '.command_contract.invocation == "octon run bind-lifecycle --run-id <id> --rollback-posture <ref>"' "fixture binds canonical CLI"
  require_fixture_value '.command_contract.preserved_identity == true and .command_contract.caller_supplied_id_without_lifecycle_provenance_allowed == false and .command_contract.compatibility_route_allowed == false' "fixture preserves identity without caller-minted authority or compatibility"
  require_fixture_value '(.command_contract.control_artifacts | length) == 3 and (.command_contract.control_artifacts | contains(["run-contract.yml", "run-manifest.yml", "runtime-state.yml"]))' "fixture requires complete canonical control roots"
  require_fixture_value '.command_contract.admission_evidence == "admission/lifecycle-run-admission.yml"' "fixture requires retained admission evidence"
  require_fixture_value '(.positive_cases | length) >= 4' "fixture retains positive and idempotency coverage"
  require_fixture_value '(.negative_controls | length) >= 13' "fixture retains full negative-control floor"
  require_fixture_value '(.required_bindings | length) >= 10' "fixture binds all provenance digests"
fi

if [[ -f "$MAIN_RS" ]]; then
  require_text 'BindLifecycle' "$MAIN_RS" "kernel CLI declares bind-lifecycle"
  require_text 'long = "run-id"' "$MAIN_RS" "bind-lifecycle requires explicit run id"
  require_text 'long = "rollback-posture"' "$MAIN_RS" "bind-lifecycle requires rollback posture ref"
fi
if [[ -f "$COMMANDS_RS" ]]; then
  require_text 'RunCmd::BindLifecycle' "$COMMANDS_RS" "kernel dispatches bind-lifecycle through RunCmd"
fi
if [[ -f "$ADMISSION_RS" ]]; then
  require_text 'lifecycle-run-admission.yml' "$ADMISSION_RS" "runtime owns retained lifecycle admission evidence"
  require_text 'run-contract.yml' "$ADMISSION_RS" "runtime owns canonical run contract materialization"
  require_text 'run-manifest.yml' "$ADMISSION_RS" "runtime owns canonical run manifest materialization"
  require_text 'runtime-state.yml' "$ADMISSION_RS" "runtime owns canonical runtime state materialization"
  if rg -q 'OCTON_WORKFLOW_RUN_COMPAT' "$ADMISSION_RS"; then
    fail "lifecycle admission must not consult compatibility environment authority"
  else
    pass "lifecycle admission does not consult compatibility environment authority"
  fi
  for test_name in \
    valid_existing_proposal_lifecycle_run_binds \
    exact_run_id_is_preserved \
    identical_binding_replay_is_idempotent \
    valid_admission_allows_validator_and_shell_execution \
    forged_or_unknown_run_id_is_denied \
    mismatched_lifecycle_target_is_denied \
    mismatched_lifecycle_type_is_denied \
    mismatched_selected_route_is_denied \
    stale_checkpoint_is_denied \
    broken_event_chain_is_denied \
    conflicting_existing_run_contract_is_denied \
    widened_or_unauthorized_write_scope_is_denied \
    missing_rollback_posture_is_denied \
    missing_delegation_proof_is_denied \
    post_target_mutation_admission_is_denied \
    compatibility_environment_does_not_authorize_binding \
    consequential_execution_before_admission_is_denied; do
    require_text "fn ${test_name}\\(" "$ADMISSION_RS" "kernel retains ${test_name//_/ } control"
  done
fi
if [[ -f "$RUN_REQUIRED" ]]; then
  require_text 'surface: "run:bind-lifecycle"' "$RUN_REQUIRED" "run-required policy declares lifecycle admission surface"
  require_text 'route: "provenance-bound-authority-derivation"' "$RUN_REQUIRED" "run-required policy keeps admission provenance-bound"
  require_text 'never execute payload work' "$RUN_REQUIRED" "run-required policy separates admission from execution"
fi

echo "Validation summary: errors=$errors"
if [[ $errors -eq 0 ]]; then
  emit_validator_result "validate-existing-lifecycle-run-admission.sh" "existing_lifecycle_run_admission" "semantic" "semantic" "pass"
else
  emit_validator_result "validate-existing-lifecycle-run-admission.sh" "existing_lifecycle_run_admission" "semantic" "existence" "fail"
fi
[[ $errors -eq 0 ]]
