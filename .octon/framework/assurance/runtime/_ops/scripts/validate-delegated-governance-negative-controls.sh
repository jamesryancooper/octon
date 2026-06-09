#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${OCTON_ROOT_DIR:-$(pwd)}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

pass_count=0
fail_count=0

pass() {
  pass_count=$((pass_count + 1))
  printf '[OK] %s\n' "$1"
}

fail() {
  fail_count=$((fail_count + 1))
  printf '[ERROR] %s\n' "$1" >&2
}

finish() {
  printf 'Validation summary: errors=%s warnings=0\n' "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

repo_path() {
  printf '%s/%s\n' "$ROOT_DIR" "$1"
}

require_file() {
  local path="$1"
  local label="$2"
  [[ -f "$(repo_path "$path")" ]] && pass "$label exists" || fail "$label missing: $path"
}

require_yq() {
  local path="$1"
  local expression="$2"
  local label="$3"
  yq -e "$expression" "$(repo_path "$path")" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

require_jq() {
  local path="$1"
  local expression="$2"
  local label="$3"
  jq -e "$expression" "$(repo_path "$path")" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

require_text() {
  local needle="$1"
  local path="$2"
  local label="$3"
  grep -Fq "$needle" "$(repo_path "$path")" && pass "$label" || fail "$label"
}

require_child_implemented() {
  local child="$1"
  local path=".octon/inputs/exploratory/proposals/architecture/$child/proposal.yml"
  require_yq "$path" '.status == "implemented"' "predecessor child implemented: $child"
  require_file ".octon/inputs/exploratory/proposals/architecture/$child/support/implementation-run.md" "implementation receipt for $child"
}

require_negative_control_class() {
  local class="$1"
  local schema=".octon/framework/constitution/contracts/authority/delegated-governance-contract-v1.schema.json"
  jq -e --arg class "$class" '.properties.negative_control_requirements.properties.failure_classes.items["$ref"] == "#/$defs/negative_control_failure_class" and (."$defs".negative_control_failure_class.enum | index($class))' "$(repo_path "$schema")" >/dev/null 2>&1 \
    && pass "negative-control class declared: $class" \
    || fail "negative-control class declared: $class"
}

validate_repo() {
  local delegated_schema=".octon/framework/constitution/contracts/authority/delegated-governance-contract-v1.schema.json"
  local approval_request_schema=".octon/framework/constitution/contracts/authority/approval-request-v1.schema.json"
  local approval_grant_schema=".octon/framework/constitution/contracts/authority/approval-grant-v1.schema.json"
  local grant_bundle_schema=".octon/framework/constitution/contracts/authority/grant-bundle-v2.schema.json"
  local run_health_schema=".octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json"
  local connector_schema=".octon/framework/engine/runtime/spec/connector-operation-v1.schema.json"
  local connector_boundaries=".octon/instance/governance/connectors/external-effect-delegation-boundaries.yml"
  local capability_map=".octon/framework/orchestration/governance/capability-map-v1.yml"
  local capability_schema=".octon/framework/orchestration/governance/capability-map-v1.schema.json"
  local mission_spec=".octon/framework/engine/runtime/spec/mission-autonomy-runtime-v2.md"

  require_child_implemented "authority-engine-typed-exception-grants"
  require_child_implemented "mission-runtime-proof-first-posture"
  require_child_implemented "connector-external-effect-delegation-boundaries"
  require_child_implemented "run-health-proof-state-read-models"
  require_child_implemented "workflow-capability-human-boundary-classification"

  require_file "$delegated_schema" "delegated governance contract schema"
  require_file "$approval_request_schema" "approval request schema"
  require_file "$approval_grant_schema" "approval grant schema"
  require_file "$grant_bundle_schema" "grant bundle schema"
  require_file "$run_health_schema" "run-health read-model schema"
  require_file "$connector_schema" "connector operation schema"
  require_file "$connector_boundaries" "connector external-effect boundaries"
  require_file "$capability_map" "workflow capability map"
  require_file "$capability_schema" "workflow capability map schema"
  require_file "$mission_spec" "mission autonomy runtime spec"

  require_jq "$delegated_schema" '.required | index("negative_control_requirements")' "delegated contract requires negative-control requirements"
  require_jq "$delegated_schema" '.properties.negative_control_requirements.properties.default_approval_denied.const == true' "default approval primitive denied"
  require_jq "$delegated_schema" '.properties.negative_control_requirements.properties.dispatch_requires_retained_proof.const == true' "dispatch requires retained proof"
  require_jq "$delegated_schema" '.properties.negative_control_requirements.properties.generated_authority_denied.const == true' "generated authority denied"
  require_jq "$delegated_schema" '.properties.negative_control_requirements.properties.read_model_authority_denied.const == true' "read-model authority denied"
  require_jq "$delegated_schema" '.properties.negative_control_requirements.properties.child_authority_takeover_denied.const == true' "child-authority takeover denied"
  require_jq "$delegated_schema" '.properties.negative_control_requirements.properties.external_irreversible_effect_requires_explicit_proof.const == true' "external irreversible effect requires explicit proof"

  for class in \
    approval-default-primitive \
    dispatch-without-retained-proof \
    missing-proof \
    stale-digest \
    scope-mismatch \
    generated-output-authority-misuse \
    read-model-authority-misuse \
    child-authority-takeover \
    unsupported-mode \
    unsafe-resume \
    policy-override \
    governance-mutation-without-typed-exception \
    external-irreversible-effect-without-proof; do
    require_negative_control_class "$class"
  done

  require_jq "$delegated_schema" '.properties.fail_closed_behavior.required | index("on_missing_evidence") and index("on_stale_evidence") and index("on_scope_mismatch") and index("on_contradictory_evidence")' "fail-closed evidence routes required"
  require_jq "$delegated_schema" '.properties.fail_closed_behavior.properties.on_generated_authority_attempt.const == "deny"' "generated authority attempts deny"
  require_jq "$delegated_schema" '.properties.fail_closed_behavior.properties.on_unsupported_mode.const == "deny"' "unsupported modes deny"
  require_jq "$delegated_schema" '.properties.fail_closed_behavior.properties.on_external_irreversible_effect.const == "deny"' "external irreversible effects deny by default"
  require_jq "$delegated_schema" '.properties.approval_posture_derivation.properties.route_shape_can_derive_approval.const == false and .properties.approval_posture_derivation.properties.workflow_shape_can_derive_approval.const == false and .properties.approval_posture_derivation.properties.extension_shape_can_derive_approval.const == false and .properties.approval_posture_derivation.properties.generic_importance_can_derive_approval.const == false' "shape-derived approval denied"
  require_jq "$delegated_schema" '.properties.non_authority_surfaces.properties.generated_outputs_can_grant_authority.const == false and .properties.non_authority_surfaces.properties.read_models_can_grant_authority.const == false' "generated and read-model authority denied"

  require_jq "$approval_request_schema" '.properties.approval_authority_source.not.enum | index("generated-output") and index("read-model")' "approval requests reject generated/read-model authority sources"
  require_jq "$approval_grant_schema" '."$defs".typed_exception_boundary.enum | index("external-irreversible-effect") and index("policy-override") and index("unsafe-resume") and index("governance-mutation")' "approval grants expose typed exception boundaries"
  require_jq "$grant_bundle_schema" '.properties.grant_consumption.properties.mints_fresh_authority.const == false' "grant bundle consumption cannot mint fresh authority"

  require_jq "$run_health_schema" '.properties.authorization.required | index("proof_state") and index("human_boundary_state")' "run-health requires proof and human-boundary state"
  require_jq "$run_health_schema" '.properties.authorization.properties.proof_state.enum | index("proof-missing") and index("proof-stale") and index("proof-contradictory") and index("proof-scope-mismatch")' "run-health proof states cover missing stale contradictory scope mismatch"
  require_jq "$run_health_schema" '.properties.authorization.properties.status.enum | index("authority-ambiguity") and index("denied") and index("review-required")' "run-health status covers ambiguity and denial"

  require_yq "$connector_boundaries" '.irreversible_external_effect_machine_delegation_allowed == false and .missing_proof_route == "deny" and .generated_connector_summaries_authorize_execution == false and .generated_read_models_authorize_execution == false' "connector boundaries deny generated authority and missing proof"
  require_yq "$connector_boundaries" '.required_negative_controls[] | select(. == "irreversible external effect without explicit rollback or compensation proof")' "connector irreversible-effect negative control declared"
  require_jq "$connector_schema" '.properties.effect_delegation_boundaries.required | index("authorized_effect_token_required") and index("scope_proof_required") and index("egress_proof_required") and index("replay_or_compensation_proof_required") and index("retained_receipt_proof_required")' "connector schema requires concrete proof gates"
  require_jq "$connector_schema" '.properties.effect_delegation_boundaries.properties.generated_outputs_authorize_execution.const == false' "connector generated outputs cannot authorize execution"

  require_yq "$capability_map" '.classification_policy.proof_first == true and .classification_policy.generated_capability_index_authority_allowed == false' "workflow capability classification is proof-first and generated-index non-authority"
  require_yq "$capability_map" '.classification_policy.approval_derivation_denials[] | select(. == "route-shape")' "workflow capability denies route-shape approval"
  require_yq "$capability_map" '.classification_policy.approval_derivation_denials[] | select(. == "workflow-shape")' "workflow capability denies workflow-shape approval"
  require_yq "$capability_map" '.classification_policy.approval_derivation_denials[] | select(. == "extension-shape")' "workflow capability denies extension-shape approval"
  require_yq "$capability_map" '.classification_policy.approval_derivation_denials[] | select(. == "generated-capability-index")' "workflow capability denies generated-index approval"
  require_yq "$capability_map" '.classification_policy.approval_derivation_denials[] | select(. == "generic-importance")' "workflow capability denies generic-importance approval"
  require_yq "$capability_map" '.classification_policy.classes."role-mediated".decision_class == "grant-consumption" and .classification_policy.classes."role-mediated".autonomous_allowed == false' "role-mediated class consumes grants only"
  require_yq "$capability_map" '.classification_policy.classes."human-only".decision_class == "typed-human-exception" and .classification_policy.classes."human-only".autonomous_allowed == false' "human-only class requires typed exception"
  require_yq "$capability_map" '.workflows[] | select(.classification == "human-only") | .typed_human_boundary.machine_provable == false' "human-only workflows name non-machine-provable typed boundary"
  require_jq "$capability_schema" '.properties.classification_policy.properties.generated_capability_index_authority_allowed.const == false' "capability schema denies generated-index authority"

  require_text "Unsupported mode, missing proof," "$mission_spec" "mission runtime documents unsupported and missing proof fail-closed cases"
  require_text "stale proof, contradictory evidence, scope mismatch, generated/read-model" "$mission_spec" "mission runtime documents stale contradictory scope generated/read-model fail-closed cases"
  require_text "authority use, and unsafe resume fail closed" "$mission_spec" "mission runtime documents unsafe resume fail-closed case"
}

validate_fixture() {
  local fixture="$1"
  local value

  [[ -f "$fixture" ]] && pass "fixture exists: $fixture" || fail "fixture missing: $fixture"
  [[ "$fail_count" -eq 0 ]] || return 0

  require_fixture_value() {
    local expression="$1"
    local label="$2"
    yq -e "$expression" "$fixture" >/dev/null 2>&1 && pass "$label" || fail "$label"
  }

  require_fixture_value '.schema_version == "delegated-governance-negative-control-fixture-v1"' "fixture schema version valid"
  require_fixture_value '.case_id != null and .failure_class != null' "fixture identifies failure class"
  require_fixture_value '.expected_result == "deny"' "fixture expects deny"
  require_fixture_value '.dispatch_allowed == false' "fixture dispatch is denied"
  require_fixture_value '.fallback_to_generic_approval == false' "fixture has no generic approval fallback"
  require_fixture_value '.generated_authority_used == false' "fixture does not use generated authority"
  require_fixture_value '.read_model_authority_used == false' "fixture does not use read-model authority"
  require_fixture_value '.child_authority_takeover == false' "fixture does not let child take over authority"
  require_fixture_value '.external_irreversible_effect_without_proof == false' "fixture blocks irreversible external effects without proof"

  value="$(yq -r '.proof_state // ""' "$fixture" 2>/dev/null || true)"
  case "$value" in
    proof-missing|proof-stale|proof-contradictory|proof-scope-mismatch|proof-failed|not-applicable)
      pass "fixture proof state is fail-closed: $value"
      ;;
    *)
      fail "fixture proof state must be fail-closed: $value"
      ;;
  esac
}

usage() {
  cat <<'USAGE'
Usage:
  validate-delegated-governance-negative-controls.sh
  validate-delegated-governance-negative-controls.sh --fixture <fixture.yml>
USAGE
}

case "${1:-}" in
  "")
    validate_repo
    finish
    ;;
  --fixture)
    if [[ -z "${2:-}" ]]; then
      usage >&2
      exit 2
    fi
    validate_fixture "$2"
    finish
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
