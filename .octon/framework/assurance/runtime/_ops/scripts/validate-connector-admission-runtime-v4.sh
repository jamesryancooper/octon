#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
CONNECTOR_ID="mcp"
OPERATION_ID="observe-context"
CLI_HELP_ARG=""

usage() {
  cat <<'EOF'
Usage: validate-connector-admission-runtime-v4.sh [--root <repo-root>] [--connector <id>] [--operation <id>] [--cli-help <path>]

Validates Connector Admission Runtime v4 contracts, placement, operation-level
admission gates, support/capability mapping, drift/quarantine state, evidence,
generated non-authority, and no connector bypass around run authorization.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      OCTON_DIR="${OCTON_DIR_OVERRIDE:-$ROOT_DIR/.octon}"
      shift 2
      ;;
    --connector)
      CONNECTOR_ID="$2"
      shift 2
      ;;
    --operation)
      OPERATION_ID="$2"
      shift 2
      ;;
    --cli-help)
      CLI_HELP_ARG="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

rel() {
  local path="$1"
  printf '%s\n' "${path#$ROOT_DIR/}"
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] && pass "found $(rel "$file")" || fail "missing $(rel "$file")"
}

require_dir() {
  local dir="$1"
  [[ -d "$dir" ]] && pass "found $(rel "$dir")" || fail "missing $(rel "$dir")"
}

require_json_schema() {
  local file="$1"
  local label="$2"
  require_file "$file"
  [[ -f "$file" ]] || return 0
  jq -e 'type == "object" and has("$schema") and has("$id") and has("title") and (has("type") or has("allOf") or has("anyOf") or has("oneOf"))' "$file" >/dev/null 2>&1 \
    && pass "$label is a JSON Schema" \
    || fail "$label must be a JSON Schema"
}

require_yaml_schema() {
  local file="$1"
  local schema="$2"
  require_file "$file"
  [[ -f "$file" ]] || return 0
  yq -e '.' "$file" >/dev/null 2>&1 || {
    fail "$(rel "$file") must parse as YAML"
    return 0
  }
  [[ "$(yq -r '.schema_version // ""' "$file")" == "$schema" ]] \
    && pass "$(rel "$file") schema_version is $schema" \
    || fail "$(rel "$file") schema_version must be $schema"
}

require_yq() {
  local file="$1"
  local expr="$2"
  local label="$3"
  yq -e "$expr" "$file" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

require_jq() {
  local file="$1"
  local expr="$2"
  local label="$3"
  jq -e "$expr" "$file" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

connector_posture_digest() {
  local paths=(
    ".octon/instance/governance/connectors/$CONNECTOR_ID/connector.yml"
    ".octon/instance/governance/connectors/$CONNECTOR_ID/operations/$OPERATION_ID.yml"
    ".octon/instance/governance/connector-admissions/$CONNECTOR_ID/$OPERATION_ID/admission.yml"
    ".octon/instance/governance/connectors/$CONNECTOR_ID/trust-dossiers/$OPERATION_ID/dossier.yml"
    ".octon/instance/governance/connectors/$CONNECTOR_ID/capability-maps/$OPERATION_ID.yml"
    ".octon/instance/governance/connectors/$CONNECTOR_ID/support-proof-maps/$OPERATION_ID.yml"
    ".octon/instance/governance/connectors/registry.yml"
    ".octon/instance/governance/connectors/posture.yml"
    ".octon/instance/governance/policies/connector-admission.yml"
    ".octon/instance/governance/policies/connector-credentials.yml"
    ".octon/instance/governance/policies/connector-data-boundaries.yml"
    ".octon/instance/governance/policies/connector-evidence-profiles.yml"
    ".octon/instance/governance/policies/network-egress.yml"
    ".octon/instance/governance/policies/execution-budgets.yml"
    ".octon/instance/governance/support-targets.yml"
    ".octon/instance/governance/capability-packs/registry.yml"
    ".octon/framework/engine/runtime/spec/material-side-effect-inventory.yml"
    ".octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml"
  )
  local path
  for path in "${paths[@]}"; do
    [[ -f "$ROOT_DIR/$path" ]] && cat "$ROOT_DIR/$path"
  done | shasum -a 256 | awk '{print $1}'
}

check_tools() {
  command -v yq >/dev/null 2>&1 || fail "yq is required"
  command -v jq >/dev/null 2>&1 || fail "jq is required"
}

check_static_contracts() {
  echo "== Connector Admission Runtime v4 Contract Validation =="
  local schemas=(
    connector-identity-v1
    connector-operation-v1
    connector-admission-v1
    connector-trust-dossier-v1
    connector-evidence-profile-v1
    connector-drift-record-v1
    connector-quarantine-v1
    connector-capability-mapping-v1
    connector-support-proof-map-v1
    connector-operation-posture-v1
    connector-credential-class-v1
    connector-egress-class-v1
    connector-failure-taxonomy-v1
    connector-replay-rollback-posture-v1
    connector-execution-receipt-v1
    connector-evidence-receipt-v1
    connector-validation-receipt-v1
    connector-trust-dossier-proof-bundle-v1
    connector-aware-decision-request-v1
  )
  local schema
  for schema in "${schemas[@]}"; do
    require_json_schema "$OCTON_DIR/framework/engine/runtime/spec/${schema}.schema.json" "$schema runtime schema"
  done

  for schema in \
    connector-identity-v1 \
    connector-operation-v1 \
    connector-admission-v1 \
    connector-trust-dossier-v1 \
    connector-capability-mapping-v1 \
    connector-credential-class-v1 \
    connector-egress-class-v1 \
    connector-failure-taxonomy-v1; do
    require_json_schema "$OCTON_DIR/framework/constitution/contracts/adapters/${schema}.schema.json" "$schema constitutional adapter schema"
  done
  require_json_schema "$OCTON_DIR/framework/constitution/contracts/assurance/connector-support-proof-map-v1.schema.json" "connector support proof constitutional schema"
  require_json_schema "$OCTON_DIR/framework/constitution/contracts/assurance/connector-drift-record-v1.schema.json" "connector drift constitutional schema"
  require_json_schema "$OCTON_DIR/framework/constitution/contracts/runtime/connector-quarantine-v1.schema.json" "connector quarantine constitutional schema"
  require_json_schema "$OCTON_DIR/framework/constitution/contracts/runtime/connector-evidence-profile-v1.schema.json" "connector evidence profile constitutional schema"
  require_json_schema "$OCTON_DIR/framework/constitution/contracts/runtime/connector-execution-receipt-v1.schema.json" "connector execution receipt constitutional schema"
  require_json_schema "$OCTON_DIR/framework/constitution/contracts/authority/connector-aware-decision-request-v1.schema.json" "connector-aware Decision Request constitutional schema"

  require_jq "$OCTON_DIR/framework/engine/runtime/spec/connector-admission-v1.schema.json" '.properties.admission_mode.enum | index("observe_only") and index("read_only") and index("stage_only") and index("live_effectful") and index("quarantined") and index("retired") and index("denied")' "connector admission schema enumerates v4 modes"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/connector-operation-v1.schema.json" '.required | index("material_effect_class") and index("capability_packs_consumed") and index("credential_class") and index("egress_requirements") and index("privacy_data_handling") and index("failure_taxonomy")' "connector operation schema requires v4 operation posture fields"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/connector-trust-dossier-v1.schema.json" '.required | index("support_target_tuple") and index("rollback_compensation_posture") and index("security_review") and index("retained_admission_evidence") and index("drift_quarantine_state")' "connector trust dossier schema requires proof-backed trust fields"
  require_yq "$OCTON_DIR/framework/constitution/contracts/registry.yml" '(.integration_surfaces.connector_admission_runtime_v4_contracts.rule | test("do not replace capability packs")) and (.integration_surfaces.connector_admission_runtime_v4_contracts.rule | test("do not replace support targets")) and (.integration_surfaces.connector_admission_runtime_v4_contracts.rule | test("do not authorize execution"))' "constitutional registry preserves connector non-authority boundaries"
  require_yq "$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml" '.path_families.connector_admission_runtime_v4.forbidden_consumers[] | select(. == "MCP or tool availability as permission")' "architecture registry rejects connector availability as permission"
}

check_instance_authority() {
  echo "== Connector Instance Authority Validation =="
  local base="$OCTON_DIR/instance/governance/connectors/$CONNECTOR_ID"
  require_yaml_schema "$base/connector.yml" "connector-identity-v1"
  require_yaml_schema "$base/operations/$OPERATION_ID.yml" "connector-operation-v1"
  require_yaml_schema "$base/capability-maps/$OPERATION_ID.yml" "connector-capability-mapping-v1"
  require_yaml_schema "$base/support-proof-maps/$OPERATION_ID.yml" "connector-support-proof-map-v1"
  require_yaml_schema "$base/trust-dossiers/$OPERATION_ID/dossier.yml" "connector-trust-dossier-v1"
  require_yaml_schema "$base/admissions/$OPERATION_ID.yml" "connector-admission-v1"
  require_yaml_schema "$OCTON_DIR/instance/governance/connector-admissions/$CONNECTOR_ID/$OPERATION_ID/admission.yml" "connector-admission-v1"
  require_yaml_schema "$OCTON_DIR/instance/governance/policies/connector-admission.yml" "connector-admission-policy-v1"
  require_yaml_schema "$OCTON_DIR/instance/governance/policies/connector-credentials.yml" "connector-credential-policy-v1"
  require_yaml_schema "$OCTON_DIR/instance/governance/policies/connector-data-boundaries.yml" "connector-data-boundary-policy-v1"
  require_yaml_schema "$OCTON_DIR/instance/governance/policies/connector-evidence-profiles.yml" "connector-evidence-profile-policy-v1"

  require_yq "$base/connector.yml" '.connector_availability_is_authority == false and .connector_identity_authorizes_execution == false' "connector identity is not execution authority"
  require_yq "$base/operations/$OPERATION_ID.yml" '.operation_authorizes_execution == false and .connector_availability_is_authority == false' "connector operation is not execution authority"
  require_yq "$base/operations/$OPERATION_ID.yml" '[(.capability_packs_consumed // [])[] | select(. == "mcp")] | length == 0' "MCP is not modeled as a capability pack"
  require_yq "$base/operations/$OPERATION_ID.yml" '.material_effect_class != null and .side_effect_class != null' "operation declares side effect and material-effect classes"
  require_yq "$base/operations/$OPERATION_ID.yml" '.credential_class != null and .egress_requirements != null and .privacy_data_handling != null' "operation declares credential, egress, and data posture"
  local admission_mode
  admission_mode="$(yq -r '.admission_mode // .admission_state // ""' "$OCTON_DIR/instance/governance/connector-admissions/$CONNECTOR_ID/$OPERATION_ID/admission.yml")"
  if yq -e ".allowed_modes[]? | select(. == \"$admission_mode\")" "$base/operations/$OPERATION_ID.yml" >/dev/null 2>&1; then
    pass "connector admission mode is allowed by operation contract"
  else
    fail "connector admission mode must be present in operation allowed_modes"
  fi
  require_yq "$base/capability-maps/$OPERATION_ID.yml" '.connector_replaces_capability_packs == false and .capability_mapping_authorizes_execution == false' "capability mapping does not replace packs or authorize execution"
  require_yq "$base/support-proof-maps/$OPERATION_ID.yml" '.generated_support_matrix_can_widen_support == false and .support_proof_map_authorizes_execution == false' "support proof map cannot widen support"
  require_yq "$base/trust-dossiers/$OPERATION_ID/dossier.yml" '.dossier_authorizes_execution == false and .live_effectful_requires_human_approval == true and .current_admission_status == "stage_only"' "trust dossier is stage-only and non-authorizing"
  require_yq "$OCTON_DIR/instance/governance/connector-admissions/$CONNECTOR_ID/$OPERATION_ID/admission.yml" '.live_effects_authorized == false and .admission_authorizes_execution == false and .connector_availability_is_authority == false' "admission does not authorize live effects"
  require_yq "$OCTON_DIR/instance/governance/support-targets.yml" '.connector_admission_root == ".octon/instance/governance/connector-admissions" and .connector_evidence_root == ".octon/state/evidence/connectors"' "support targets register connector admission proof hook"
}

check_control_evidence_and_generated() {
  echo "== Connector Control, Evidence, and Projection Validation =="
  local control="$OCTON_DIR/state/control/connectors/$CONNECTOR_ID/operations/$OPERATION_ID"
  require_yaml_schema "$OCTON_DIR/state/control/connectors/$CONNECTOR_ID/status.yml" "connector-status-v1"
  require_yaml_schema "$control/status.yml" "connector-operation-status-v1"
  require_yaml_schema "$control/admission-state.yml" "connector-operation-admission-state-v1"
  require_yaml_schema "$control/quarantine.yml" "connector-quarantine-v1"
  require_yaml_schema "$control/drift.yml" "connector-drift-record-v1"
  require_yq "$control/status.yml" '.live_effects_authorized == false' "connector operation control state denies live effects"
  require_yq "$control/admission-state.yml" '.run_lifecycle_bypass_allowed == false and .execution_authorization_bypass_allowed == false' "connector admission state forbids run/auth bypass"
  require_yq "$control/quarantine.yml" '.reset_requires_evidence == true and .reset_requires_human_approval == true' "quarantine reset requires evidence and approval"
  require_yq "$control/quarantine.yml" 'has("reset_evidence_refs") and has("reset_approval_refs")' "quarantine state declares reset evidence and approval refs"
  if yq -e '.active == true or .status == "quarantined"' "$control/quarantine.yml" >/dev/null 2>&1; then
    require_yq "$control/status.yml" '.status == "quarantined"' "active quarantine forces operation status to quarantined"
    require_yq "$control/admission-state.yml" '.admission_state == "quarantined"' "active quarantine forces admission state to quarantined"
  fi
  require_yq "$control/drift.yml" '.connector_availability_is_authority == false and .admission_decision_authorizes_execution == false and .drift_dimensions[] | select(. == "capability mapping")' "drift record covers v4 drift dimensions"
  require_yq "$control/drift.yml" '.current_digest != "baseline-stage-only"' "drift record uses real posture digest"
  local expected_digest current_digest
  expected_digest="$(connector_posture_digest)"
  current_digest="$(yq -r '.current_digest // ""' "$control/drift.yml")"
  [[ "$current_digest" == "$expected_digest" ]] \
    && pass "drift record digest matches current connector posture" \
    || fail "drift record digest must match current connector posture"

  require_yaml_schema "$OCTON_DIR/state/evidence/connectors/$CONNECTOR_ID/admissions/$OPERATION_ID/receipt.yml" "connector-evidence-receipt-v1"
  require_yaml_schema "$OCTON_DIR/state/evidence/connectors/$CONNECTOR_ID/trust-dossiers/$OPERATION_ID/proof-bundle.yml" "connector-trust-dossier-proof-bundle-v1"
  require_yaml_schema "$OCTON_DIR/state/evidence/connectors/$CONNECTOR_ID/validation/$OPERATION_ID/validation.yml" "connector-validation-receipt-v1"
  require_yq "$OCTON_DIR/state/evidence/connectors/$CONNECTOR_ID/admissions/$OPERATION_ID/receipt.yml" '.connector_evidence_replaces_run_evidence == false and .run_evidence_link_required_for_material_operations == true' "connector evidence does not replace run evidence"
  require_yq "$OCTON_DIR/state/evidence/connectors/$CONNECTOR_ID/validation/$OPERATION_ID/validation.yml" '.live_effectful_execution_authorized == false' "connector validation does not authorize live execution"

  require_yaml_schema "$OCTON_DIR/state/continuity/connectors/$CONNECTOR_ID/summary.yml" "connector-continuity-summary-v1"
  require_yq "$OCTON_DIR/state/continuity/connectors/$CONNECTOR_ID/summary.yml" '.continuity_is_authority == false' "connector continuity is not authority"
  require_yaml_schema "$OCTON_DIR/generated/cognition/projections/materialized/connectors/status.yml" "connector-generated-status-v1"
  require_yaml_schema "$OCTON_DIR/generated/cognition/projections/materialized/connectors/support-cards/$CONNECTOR_ID-$OPERATION_ID.yml" "connector-support-card-projection-v1"
  require_yq "$OCTON_DIR/generated/cognition/projections/materialized/connectors/support-cards/$CONNECTOR_ID-$OPERATION_ID.yml" '.generated_support_matrix_can_widen_support == false' "generated connector support card cannot widen support"
}

check_cli_and_runtime_boundaries() {
  echo "== Connector CLI and Runtime Boundary Validation =="
  if [[ -n "$CLI_HELP_ARG" ]]; then
    require_file "$CLI_HELP_ARG"
    for token in "connector" "support" "capability"; do
      grep -q "$token" "$CLI_HELP_ARG" \
        && pass "CLI help includes $token command family" \
        || fail "CLI help must include $token command family"
    done
  fi

  local mission_rs="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/commands/mission.rs"
  require_file "$mission_rs"
  if sed -n '/fn list_connectors/,/fn ensure_required_v1/p' "$mission_rs" | grep -E 'invoke_service|ProcessCommand|run_descriptor_start|write_execution_start' >/dev/null 2>&1; then
    fail "connector CLI implementation must not directly execute service/process/run start paths"
  else
    pass "connector CLI implementation is administrative and non-effectful"
  fi
  if grep -R "octon-connector-admission-runtime-v4" "$OCTON_DIR/framework/engine/runtime/crates/kernel/src" >/dev/null 2>&1; then
    fail "runtime source must not depend on inputs/** proposal packet"
  else
    pass "runtime source has no proposal-packet dependency"
  fi
}

check_root_registration() {
  echo "== Connector Root Registration Validation =="
  require_yq "$OCTON_DIR/framework/overlay-points/registry.yml" '.overlay_points[] | select(.overlay_point_id == "instance-governance-connectors") | .validator == ".octon/framework/assurance/runtime/_ops/scripts/validate-connector-admission-runtime-v4.sh"' "connector overlay point is registered"
  require_yq "$OCTON_DIR/instance/manifest.yml" '.enabled_overlay_points[] | select(. == "instance-governance-connectors")' "instance manifest enables connector overlay point"
  require_yq "$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml" '.execution.write_roots.connector_control_root == ".octon/state/control/connectors" and .execution.write_roots.connector_evidence_root == ".octon/state/evidence/connectors"' "architecture registry declares connector control/evidence roots"
}

check_tools
check_static_contracts
check_instance_authority
check_control_evidence_and_generated
check_cli_and_runtime_boundaries
check_root_registration

if [[ "$errors" -gt 0 ]]; then
  echo "[FAIL] Connector Admission Runtime v4 validation found $errors error(s)."
  exit 1
fi

echo "[OK] Connector Admission Runtime v4 validation passed."
