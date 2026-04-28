#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
source "$SCRIPT_DIR/validator-result-common.sh"

WORK_PACKAGE_ARG=""
CLI_HELP_ARG=""

usage() {
  cat <<'EOF'
Usage: validate-engagement-work-package-compiler.sh [--root <repo-root>] [--work-package <path>] [--cli-help <path>]

Validates Engagement / Project Profile / Work Package Compiler governance gates.
Relative --work-package and --cli-help paths resolve from --root.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      if [[ $# -lt 2 || "${2:-}" == --* ]]; then
        echo "[ERROR] --root requires a repo-root path" >&2
        usage >&2
        exit 2
      fi
      ROOT_DIR="$2"
      OCTON_DIR="${OCTON_DIR_OVERRIDE:-$ROOT_DIR/.octon}"
      shift 2
      ;;
    --work-package)
      if [[ $# -lt 2 || "${2:-}" == --* ]]; then
        echo "[ERROR] --work-package requires a path" >&2
        usage >&2
        exit 2
      fi
      WORK_PACKAGE_ARG="$2"
      shift 2
      ;;
    --cli-help)
      if [[ $# -lt 2 || "${2:-}" == --* ]]; then
        echo "[ERROR] --cli-help requires a path" >&2
        usage >&2
        exit 2
      fi
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

COMPILER_POLICY="$OCTON_DIR/instance/governance/policies/engagement-work-package-compiler.yml"
EVIDENCE_PROFILES="$OCTON_DIR/instance/governance/policies/evidence-profiles.yml"
PREFLIGHT_LANE="$OCTON_DIR/instance/governance/policies/preflight-evidence-lane.yml"
CONNECTOR_POSTURE="$OCTON_DIR/instance/governance/connectors/posture.yml"
CONNECTOR_REGISTRY="$OCTON_DIR/instance/governance/connectors/registry.yml"
CONNECTOR_README="$OCTON_DIR/instance/governance/connectors/README.md"
PATH_FAMILIES="$OCTON_DIR/instance/governance/engagements/path-families.yml"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
EXCLUSIONS="$OCTON_DIR/instance/governance/exclusions/action-classes.yml"
PACK_REGISTRY="$OCTON_DIR/instance/governance/capability-packs/registry.yml"
RUNTIME_PACK_REGISTRY="$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml"
WORK_PACKAGE_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/work-package-v1.schema.json"
ARCH_REGISTRY="$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml"
CONTRACT_REGISTRY="$OCTON_DIR/framework/constitution/contracts/registry.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_yaml_file() {
  local file="$1"
  local schema="$2"
  if [[ ! -f "$file" ]]; then
    fail "missing ${file#$ROOT_DIR/}"
    return 1
  fi
  pass "found ${file#$ROOT_DIR/}"
  if yq -e '.' "$file" >/dev/null 2>&1; then
    pass "${file#$ROOT_DIR/} parses as YAML"
  else
    fail "${file#$ROOT_DIR/} must parse as YAML"
    return 1
  fi
  [[ "$(yq -r '.schema_version // ""' "$file")" == "$schema" ]] \
    && pass "${file#$ROOT_DIR/} schema version valid" \
    || fail "${file#$ROOT_DIR/} schema_version must be $schema"
}

require_yaml_file_one_of() {
  local file="$1"
  shift
  if [[ ! -f "$file" ]]; then
    fail "missing ${file#$ROOT_DIR/}"
    return 1
  fi
  pass "found ${file#$ROOT_DIR/}"
  if yq -e '.' "$file" >/dev/null 2>&1; then
    pass "${file#$ROOT_DIR/} parses as YAML"
  else
    fail "${file#$ROOT_DIR/} must parse as YAML"
    return 1
  fi
  local actual expected
  actual="$(yq -r '.schema_version // ""' "$file")"
  for expected in "$@"; do
    if [[ "$actual" == "$expected" ]]; then
      pass "${file#$ROOT_DIR/} schema version valid"
      return 0
    fi
  done
  fail "${file#$ROOT_DIR/} schema_version must be one of: $*"
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] && pass "found ${file#$ROOT_DIR/}" || fail "missing ${file#$ROOT_DIR/}"
}

require_json_schema_file() {
  local file="$1"
  local label="$2"
  if [[ ! -f "$file" ]]; then
    fail "missing ${file#$ROOT_DIR/}"
    return 1
  fi
  pass "found ${file#$ROOT_DIR/}"
  if jq -e '.' "$file" >/dev/null 2>&1; then
    pass "$label parses as JSON"
  else
    fail "$label must parse as JSON"
    return 1
  fi
  if jq -e 'type == "object" and has("$schema") and has("$id") and has("title") and (has("type") or has("allOf") or has("oneOf") or has("anyOf") or has("$defs"))' "$file" >/dev/null 2>&1; then
    pass "$label carries JSON Schema metadata"
  else
    fail "$label must carry JSON Schema metadata"
  fi
}

require_yq() {
  local file="$1"
  local expr="$2"
  local label="$3"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_list_value() {
  local file="$1"
  local expr="$2"
  local expected="$3"
  local label="$4"
  require_yq "$file" "$expr[]? | select(. == \"$expected\")" "$label"
}

resolve_root_path() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$ROOT_DIR" "$path"
  fi
}

contains_proposal_path() {
  local file="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -n '\.octon/inputs/exploratory/proposals' "$file" >/dev/null 2>&1
  else
    grep -En '\.octon/inputs/exploratory/proposals' "$file" >/dev/null 2>&1
  fi
}

pack_governance_status() {
  local pack_id="$1"
  yq -r ".packs[]? | select(.pack_id == \"$pack_id\") | .manifest_ref // \"\"" "$PACK_REGISTRY" \
    | while IFS= read -r manifest_ref; do
        [[ -n "$manifest_ref" ]] || continue
        yq -r '.status // ""' "$ROOT_DIR/$manifest_ref" 2>/dev/null || true
      done \
    | awk 'NF' \
    | head -n 1
}

pack_runtime_status() {
  local pack_id="$1"
  yq -r ".packs[]? | select(.pack_id == \"$pack_id\") | .admission_status // \"\"" "$RUNTIME_PACK_REGISTRY" 2>/dev/null | head -n 1
}

check_static_policy_surfaces() {
  echo "== Engagement Work Package Compiler Policy Validation =="

  command -v yq >/dev/null 2>&1 || {
    fail "yq is required"
    return 0
  }

  require_yaml_file "$COMPILER_POLICY" "engagement-work-package-compiler-governance-v1"
  require_yaml_file "$EVIDENCE_PROFILES" "octon-evidence-profiles-policy-v1"
  require_yaml_file "$PREFLIGHT_LANE" "preflight-evidence-lane-policy-v1"
  require_yaml_file "$CONNECTOR_POSTURE" "engagement-connector-posture-v1"
  require_yaml_file_one_of "$CONNECTOR_REGISTRY" "engagement-connector-posture-registry-v1" "connector-registry-v4"
  require_file "$CONNECTOR_README"
  require_yaml_file "$PATH_FAMILIES" "engagement-path-family-registry-v1"
  require_yaml_file "$SUPPORT_TARGETS" "octon-support-targets-v1"
  require_yaml_file "$EXCLUSIONS" "repo-governance-action-exclusions-v1"
  require_yaml_file "$PACK_REGISTRY" "governance-capability-pack-registry-v1"
  require_yaml_file "$RUNTIME_PACK_REGISTRY" "octon-runtime-capability-pack-registry-v1"
  require_json_schema_file "$OCTON_DIR/framework/engine/runtime/spec/engagement-v1.schema.json" "Engagement runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/engine/runtime/spec/project-profile-v1.schema.json" "Project Profile runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/engine/runtime/spec/work-package-v1.schema.json" "Work Package runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/engine/runtime/spec/decision-request-v1.schema.json" "Decision Request runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/engine/runtime/spec/evidence-profile-v1.schema.json" "Evidence Profile runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/engine/runtime/spec/tool-connector-posture-v1.schema.json" "Tool connector posture runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/engine/runtime/spec/engagement-objective-brief-v1.schema.json" "Engagement Objective Brief runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/constitution/contracts/runtime/engagement-v1.schema.json" "Engagement constitutional runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/constitution/contracts/runtime/project-profile-v1.schema.json" "Project Profile constitutional runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/constitution/contracts/runtime/work-package-v1.schema.json" "Work Package constitutional runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/constitution/contracts/authority/decision-request-v1.schema.json" "Decision Request constitutional authority schema"
  require_json_schema_file "$OCTON_DIR/framework/constitution/contracts/runtime/evidence-profile-v1.schema.json" "Evidence Profile constitutional runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/constitution/contracts/runtime/tool-connector-posture-v1.schema.json" "Tool connector posture constitutional runtime schema"
  require_json_schema_file "$OCTON_DIR/framework/constitution/contracts/adapters/tool-connector-posture-v1.schema.json" "Tool connector posture constitutional adapter schema"
  require_json_schema_file "$OCTON_DIR/framework/constitution/contracts/runtime/engagement-objective-brief-v1.schema.json" "Engagement Objective Brief constitutional runtime schema"
  require_yq "$WORK_PACKAGE_SCHEMA" 'has("$schema") and (.required | length > 0)' "work-package schema carries JSON Schema metadata and required fields"
  require_yq "$CONTRACT_REGISTRY" '.integration_surfaces.engagement_work_package_compiler_contracts.engagement_objective_brief_schema == ".octon/framework/constitution/contracts/runtime/engagement-objective-brief-v1.schema.json"' "constitutional registry places Engagement Objective Brief under runtime contracts"
  require_yq "$ARCH_REGISTRY" '.path_families.engagement_work_package_compiler.canonical_paths[]? | select(. == ".octon/framework/constitution/contracts/runtime/engagement-objective-brief-v1.schema.json")' "architecture registry includes runtime Objective Brief contract"
  if yq -e '.path_families.engagement_work_package_compiler.canonical_paths[]? | select(. == ".octon/framework/constitution/contracts/objective/engagement-objective-brief-v1.schema.json")' "$ARCH_REGISTRY" >/dev/null 2>&1; then
    fail "architecture registry must not classify per-engagement Objective Brief as workspace objective authority"
  else
    pass "architecture registry avoids objective-family authority for Engagement Objective Brief"
  fi
  require_yq "$ARCH_REGISTRY" '.path_families.state_continuity.canonical_paths[]? | select(. == ".octon/state/continuity/engagements/**")' "architecture registry includes engagement continuity root"

  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    if [[ "$ref" == .octon/inputs/* ]]; then
      fail "canonical refs must not depend on inputs/**: $ref"
    elif [[ -e "$ROOT_DIR/$ref" ]]; then
      pass "canonical ref exists: $ref"
    else
      fail "canonical ref missing: $ref"
    fi
  done < <(yq -r '.canonical_refs | to_entries[]? | .value | select(tag == "!!str")' "$COMPILER_POLICY" 2>/dev/null || true)
}

check_compiler_gates() {
  local gate
  local required_gates=(
    approval
    runtime_authorization
    support_target_reconciliation
    capability_admission
    connector_posture
    context_pack_readiness
    rollback
    evidence_profile_selection
    decision_request_generation
    generated_and_input_non_authority
    placement_cartography
    stage_block_outcome
  )

  for gate in "${required_gates[@]}"; do
    require_yq "$COMPILER_POLICY" ".gate_matrix[]? | select(.gate_id == \"$gate\")" "compiler gate declared: $gate"
    require_yq "$COMPILER_POLICY" ".gate_matrix[]? | select(.gate_id == \"$gate\" and (.reason_refs | length > 0))" "compiler gate carries reason refs: $gate"
  done

  for outcome in ready_for_authorization stage_only requires_decision blocked denied escalate; do
    require_list_value "$COMPILER_POLICY" '.allowed_final_outcomes' "$outcome" "compiler allows explicit outcome: $outcome"
  done

  for section in engagement_ref project_profile_ref objective_brief_schema_ref objective_control_root objective_brief_ref objective_brief_evidence_refs objective_brief_authority_boundary authority_binding support_posture capability_posture connector_posture evidence_profile context_pack decision_requests rollback validation risk_materiality placement run_contract_candidate run_contract_readiness_evidence_refs outcome; do
    require_list_value "$COMPILER_POLICY" '.work_package_required_sections' "$section" "work package required section declared: $section"
  done

  require_yq "$COMPILER_POLICY" '.gate_matrix[]? | select(.gate_id == "approval" and .missing_route == "requires_decision" and .attempted_live_effect_route == "denied")' "approval gate fails closed"
  require_yq "$COMPILER_POLICY" '.gate_matrix[]? | select(.gate_id == "runtime_authorization" and .missing_route == "stage_only" and .attempted_live_effect_route == "denied")' "runtime authorization gate fails closed"
  require_yq "$COMPILER_POLICY" '.gate_matrix[]? | select(.gate_id == "support_target_reconciliation" and .invalid_tuple_route == "denied" and .stage_only_tuple_route == "stage_only")' "support-target gate fails closed"
  require_yq "$COMPILER_POLICY" '.gate_matrix[]? | select(.gate_id == "connector_posture" and .non_admitted_prepare_route == "stage_only" and .non_admitted_live_effect_route == "denied" and .unsupported_connector_route == "blocked")' "connector gate stages or blocks non-admitted connectors"
  require_yq "$COMPILER_POLICY" '.gate_matrix[]? | select(.gate_id == "context_pack_readiness" and .missing_request_route == "blocked" and .missing_receipt_route == "stage_only" and .stale_receipt_route == "blocked")' "context-pack gate fails closed"
  require_yq "$COMPILER_POLICY" '.gate_matrix[]? | select(.gate_id == "rollback" and .missing_route == "blocked" and .irreversible_route == "requires_decision")' "rollback gate fails closed"
  require_yq "$COMPILER_POLICY" '.gate_matrix[]? | select(.gate_id == "evidence_profile_selection" and .missing_route == "blocked" and .downgrade_route == "denied")' "evidence profile gate fails closed"
  require_yq "$COMPILER_POLICY" '.gate_matrix[]? | select(.gate_id == "decision_request_generation" and .missing_route == "blocked" and .attempted_bypass_route == "denied")' "Decision Request gate fails closed"
  require_yq "$COMPILER_POLICY" '.gate_matrix[]? | select(.gate_id == "placement_cartography" and .missing_registry_route == "blocked" and .unregistered_runtime_write_route == "denied" and .misplaced_runtime_write_route == "denied")' "placement cartography gate fails closed"
  require_yq "$COMPILER_POLICY" '.stage_block_behavior.non_admitted_connectors.prepare_only == "stage_only" and .stage_block_behavior.non_admitted_connectors.live_effectful_use == "denied" and .stage_block_behavior.non_admitted_connectors.unsupported_connector == "blocked"' "stage/block behavior for non-admitted connectors declared"
}

check_evidence_profiles() {
  local profile
  for profile in orientation-only stage-only repo-consequential; do
    require_yq "$EVIDENCE_PROFILES" ".profiles[]? | select((.profile_id // .profile) == \"$profile\")" "evidence profile declared: $profile"
    require_yq "$EVIDENCE_PROFILES" ".profiles[]? | select((.profile_id // .profile) == \"$profile\" and ((.required_evidence // .required_artifact_classes) | length > 0))" "evidence profile requires evidence: $profile"
    require_yq "$EVIDENCE_PROFILES" ".profiles[]? | select((.profile_id // .profile) == \"$profile\" and ((.missing_evidence_route // .missing_required_evidence_route) == \"blocked\" or (.missing_evidence_route // .missing_required_evidence_route) == \"stage_only\"))" "evidence profile fails closed on missing evidence: $profile"
  done

  require_yq "$EVIDENCE_PROFILES" '.profiles[]? | select((.profile_id // .profile) == "orientation-only" and ((.material_effects_allowed == false and (.ready_for_authorization_allowed // false) == false) or .allowed_effect_scope == "preflight-evidence-only"))' "orientation-only profile cannot authorize effects"
  require_yq "$EVIDENCE_PROFILES" '.profiles[]? | select((.profile_id // .profile) == "stage-only" and ((.material_effects_allowed == false and (.ready_for_authorization_allowed // false) == false) or .allowed_effect_scope == "prepare-only"))' "stage-only profile cannot authorize effects"
  require_yq "$EVIDENCE_PROFILES" '.profiles[]? | select((.profile_id // .profile) == "repo-consequential" and ((.material_effects_allowed == true and (.runtime_authorization_required // true) == true and (.ready_for_authorization_allowed // true) == true) or .allowed_effect_scope == "authorized-run-required"))' "repo-consequential profile requires runtime authorization"
  if yq -e '.selection_rules[]? | select(.rule_id == "EPR-004" and .select_profile == "stage-only" and .live_effect_route == "denied")' "$EVIDENCE_PROFILES" >/dev/null 2>&1; then
    pass "non-admitted connector profile rule stages and denies live use"
  else
    pass "non-admitted connector staging is enforced by connector posture registry"
  fi
}

require_preflight_allowed() {
  local label="$1"
  shift
  local candidate
  for candidate in "$@"; do
    if yq -e ".allowed_actions[]? | select((.action_id // .action) == \"$candidate\" and (.route == \"allow\" or .route == \"ALLOW\" or .route == \"stage_only\" or .route == \"STAGE_ONLY\") and (((.required_evidence // []) | length > 0) or ((.allowed_roots // []) | length > 0)))" "$PREFLIGHT_LANE" >/dev/null 2>&1; then
      pass "preflight allowed action is bounded: $label"
      return 0
    fi
  done
  fail "preflight allowed action is bounded: $label"
}

require_preflight_forbidden() {
  local label="$1"
  shift
  local candidate
  for candidate in "$@"; do
    if yq -e ".forbidden_actions[]? | select(. == \"$candidate\")" "$PREFLIGHT_LANE" >/dev/null 2>&1 \
      || yq -e ".forbidden_actions[]? | select((.action_id // .action) == \"$candidate\" and (.route == \"deny\" or .route == \"DENY\"))" "$PREFLIGHT_LANE" >/dev/null 2>&1; then
      pass "preflight forbidden action denies: $label"
      return 0
    fi
  done
  fail "preflight forbidden action denies: $label"
}

check_preflight_lane() {
  local action
  if yq -e '.lane_posture.material_effects_allowed == false and .lane_posture.live_connector_invocation_allowed == false and .lane_posture.capability_activation_allowed == false and .lane_posture.support_target_widening_allowed == false and .lane_posture.generated_effective_publication_allowed == false and .lane_posture.credential_use_allowed == false' "$PREFLIGHT_LANE" >/dev/null 2>&1; then
    pass "preflight lane forbids material effects"
  else
    for action in project-code-mutation generated-effective-publication service-invocation tool-invocation mcp-effectful-invocation api-egress browser-ui-execution credential-use support-target-widening capability-pack-activation run-execution; do
      require_yq "$PREFLIGHT_LANE" ".forbidden_actions[]? | select(. == \"$action\")" "preflight forbidden action declared: $action"
    done
  fi

  require_preflight_allowed "adoption-classification" adoption-classification
  require_preflight_allowed "orientation-scan" orientation-scan
  require_preflight_allowed "project-profile-source-evidence" project-profile-source-evidence project-profile-source-fact-capture
  require_preflight_allowed "compiler-control-preparation" compiler-control-preparation context-pack-request-preparation
  require_preflight_allowed "generated-operator-read-model" generated-operator-read-model operator-visible-diagnostics

  require_preflight_forbidden "project-code-mutation" project-code-mutation
  require_preflight_forbidden "generated-effective-publication" generated-effective-publication
  require_preflight_forbidden "service-invocation" service-invocation service-tool-mcp-effectful-invocation
  require_preflight_forbidden "tool-invocation" tool-invocation service-tool-mcp-effectful-invocation
  require_preflight_forbidden "mcp-effectful-invocation" mcp-effectful-invocation service-tool-mcp-effectful-invocation
  require_preflight_forbidden "api-egress" api-egress external-network-egress
  require_preflight_forbidden "browser-ui-execution" browser-ui-execution external-network-egress
  require_preflight_forbidden "credential-use" credential-use credential-or-secret-use
  require_preflight_forbidden "support-target-widening" support-target-widening
  require_preflight_forbidden "capability-pack-activation" capability-pack-activation
  require_preflight_forbidden "run-execution" run-execution runtime-executor-launch

  require_yq "$PREFLIGHT_LANE" '(.fail_closed_routes.unsupported_connector // "") == "STAGE_ONLY" or (.exit_gates[]? | select(.gate_id == "preflight-context-request" and .missing_or_stale_route == "stage_only"))' "preflight context or unsupported connector route stages"
}

check_connector_posture() {
  local connector status pack_id gov_status runtime_status requirement

  for connector in mcp api browser; do
    require_yq "$CONNECTOR_POSTURE" ".connector_classes[]? | select(.connector_class_id == \"$connector\")" "connector class declared in posture: $connector"
    require_yq "$CONNECTOR_REGISTRY" ".connector_entries[]? | select(.connector_class_id == \"$connector\")" "connector class declared in registry: $connector"
    status="$(yq -r ".connector_classes[]? | select(.connector_class_id == \"$connector\") | .support_status // \"\"" "$CONNECTOR_POSTURE")"
    case "$status" in
      admitted|supported)
        fail "$connector connector must not be live-supported in v1"
        ;;
      *)
        pass "$connector connector remains non-live: $status"
        ;;
    esac
    require_yq "$CONNECTOR_POSTURE" ".connector_classes[]? | select(.connector_class_id == \"$connector\" and .prepare_route == \"stage_only\" and .live_effect_route == \"denied\" and (.required_before_live | length > 0))" "connector stages prepare-only and denies live use: $connector"
    require_yq "$CONNECTOR_REGISTRY" ".connector_entries[]? | select(.connector_class_id == \"$connector\" and .prepare_only_posture == \"stage_only\" and .runtime_live_effect_posture == \"denied\" and .unknown_or_unmapped_posture == \"blocked\")" "connector registry stages, denies, or blocks: $connector"
  done

  for requirement in support-target-admission capability-pack-admission network-egress-policy-and-lease credential-posture evidence-profile-selection rollback-or-compensation-posture "runtime authorization"; do
    require_list_value "$CONNECTOR_REGISTRY" '.required_before_any_live_connector_effect' "$requirement" "connector registry requires before live effect: $requirement"
  done

  for pack_id in api browser; do
    gov_status="$(pack_governance_status "$pack_id")"
    runtime_status="$(pack_runtime_status "$pack_id")"
    [[ "$gov_status" == "unadmitted" ]] && pass "$pack_id governance pack is unadmitted" || fail "$pack_id governance pack must be unadmitted"
    [[ "$runtime_status" == "unadmitted" ]] && pass "$pack_id runtime pack is unadmitted" || fail "$pack_id runtime pack must be unadmitted"
    require_yq "$CONNECTOR_POSTURE" ".connector_classes[]? | select(.connector_class_id == \"$pack_id\" and .capability_pack_ref == \"$pack_id\")" "$pack_id connector binds unadmitted capability pack"
  done

  require_list_value "$SUPPORT_TARGETS" '.resolved_non_live_surfaces.capability_packs' "browser" "browser pack is resolved non-live"
  require_list_value "$SUPPORT_TARGETS" '.resolved_non_live_surfaces.capability_packs' "api" "api pack is resolved non-live"
  require_yq "$EXCLUSIONS" '.prohibited_action_classes[]? | select(.action_class_id == "non-admitted-external-effect-channel" and .route == "deny")' "non-admitted external effect channel is denied"
  require_yq "$CONNECTOR_POSTURE" '.outcome_mapping.live_use_requested_without_admission == "denied" and .outcome_mapping.connector_unknown_to_policy == "blocked" and .outcome_mapping.prepare_only_with_non_admitted_connector == "stage_only"' "connector outcome mapping is fail-closed"
}

check_path_family_registry() {
  local family

  while IFS= read -r family; do
    [[ -n "$family" ]] || continue
    require_list_value "$PATH_FAMILIES" '.runtime_write_requires_registered_families' "$family" "runtime writes require registered family: $family"
    require_yq "$PATH_FAMILIES" ".path_families[]? | select(.family_id == \"$family\")" "path family registered: $family"
    require_yq "$PATH_FAMILIES" ".path_families[]? | select(.family_id == \"$family\" and .runtime_write_gate == \"registered-path-family-required\")" "path family gates runtime writes: $family"
  done < <(yq -r '.runtime_write_requires_registered_families[]?' "$PATH_FAMILIES")

  for family in engagement-control work-package-control objective-brief-control decision-request-control engagement-evidence objective-brief-evidence orientation-evidence project-profile-source-fact-evidence work-package-compilation-evidence decision-evidence run-contract-readiness-evidence engagement-continuity project-profile-authority; do
    require_yq "$PATH_FAMILIES" ".path_families[]? | select(.family_id == \"$family\")" "compiler path family registered: $family"
  done

  require_yq "$PATH_FAMILIES" '.path_families[]? | select(.family_id == "engagement-generated-read-model" and .class_root == "generated" and .authority_posture == "derived-non-authority" and .runtime_write_gate == "forbidden-as-runtime-authority")' "generated engagement read models are non-authority"

  while IFS= read -r family; do
    [[ -n "$family" ]] || continue
    if yq -e ".path_families[]? | select(.family_id == \"$family\") | .canonical_paths[]? | select(test(\"^\\\\.octon/inputs/\"))" "$PATH_FAMILIES" >/dev/null 2>&1; then
      fail "path family must not register inputs/** runtime paths: $family"
    else
      pass "path family avoids inputs/** runtime paths: $family"
    fi
  done < <(yq -r '.path_families[]?.family_id // ""' "$PATH_FAMILIES")
}

work_package_paths() {
  if [[ -n "$WORK_PACKAGE_ARG" ]]; then
    resolve_root_path "$WORK_PACKAGE_ARG"
    return 0
  fi

  if [[ -n "${OCTON_ENGAGEMENT_WORK_PACKAGE:-}" ]]; then
    resolve_root_path "$OCTON_ENGAGEMENT_WORK_PACKAGE"
    return 0
  fi

  local engagements_root="$OCTON_DIR/state/control/engagements"
  [[ -d "$engagements_root" ]] || return 0
  find "$engagements_root" -type f -name 'work-package.yml' -print
}

is_known_profile() {
  local profile="$1"
  yq -e ".profiles[]? | select((.profile_id // .profile) == \"$profile\")" "$EVIDENCE_PROFILES" >/dev/null 2>&1
}

profile_allows_ready() {
  local profile="$1"
  yq -e ".profiles[]? | select((.profile_id // .profile) == \"$profile\" and ((.ready_for_authorization_allowed == true) or .allowed_effect_scope == \"authorized-run-required\"))" "$EVIDENCE_PROFILES" >/dev/null 2>&1
}

check_work_package_support_tuple() {
  local work_package="$1"
  local tuple_id="$2"
  local claim_effect="$3"

  [[ "$claim_effect" == "admitted-live-claim" ]] \
    && pass "ready Work Package claims admitted live support" \
    || fail "ready Work Package must claim admitted-live-claim support"

  if [[ -z "$tuple_id" ]]; then
    fail "ready Work Package missing support tuple id"
    return 0
  fi

  require_yq "$SUPPORT_TARGETS" ".tuple_admissions[]? | select(.tuple_id == \"$tuple_id\" and .claim_effect == \"admitted-live-claim\")" "ready Work Package support tuple is admitted live: ${work_package#$ROOT_DIR/}"
}

check_work_package_capabilities() {
  local work_package="$1"
  local pack_id status

  while IFS= read -r pack_id; do
    [[ -n "$pack_id" ]] || continue
    status="$(pack_governance_status "$pack_id")"
    [[ "$status" == "admitted" ]] \
      && pass "ready Work Package capability pack admitted: $pack_id" \
      || fail "ready Work Package capability pack is not admitted: $pack_id"
  done < <(yq -r '.capability_posture.pack_ids[]? // ""' "$work_package" 2>/dev/null || true)
}

check_work_package_connectors() {
  local work_package="$1"
  local outcome="$2"
  local connector requested_live_effect requested_use operation_mode operation support_status live_route

  while IFS=$'\t' read -r connector requested_live_effect requested_use operation_mode operation support_status; do
    [[ -n "$connector" ]] || continue
    if [[ "$requested_live_effect" == "true" ]]; then
      requested_use="live_effect"
    elif [[ -n "$requested_use" && "$requested_use" != "null" ]]; then
      requested_use="$requested_use"
    elif [[ -n "$operation_mode" && "$operation_mode" != "null" ]]; then
      requested_use="$operation_mode"
    elif [[ -n "$operation" && "$operation" != "null" ]]; then
      requested_use="$operation"
    else
      requested_use="prepare_only"
    fi
    live_route="$(yq -r ".connector_classes[]? | select(.connector_class_id == \"$connector\") | .live_effect_route // \"blocked\"" "$CONNECTOR_POSTURE")"
    if [[ -z "$live_route" || "$live_route" == "null" ]]; then
      fail "Work Package references unknown connector: $connector"
      continue
    fi
    if [[ "$requested_use" == "live_effect" || "$requested_use" == "effectful" ]]; then
      [[ "$live_route" == "denied" ]] \
        && fail "Work Package requests live effectful non-admitted connector use: $connector" \
        || fail "Work Package connector live route is not fail-closed: $connector"
    elif [[ "$outcome" == "ready_for_authorization" && "$support_status" != "admitted" && "$support_status" != "supported" ]]; then
      fail "ready Work Package includes non-admitted connector: $connector"
    else
      pass "Work Package connector posture is non-live or staged: $connector"
    fi
  done < <(yq -r '((.connector_posture.connectors // []) + (.connector_posture.requested_connectors // []))[]? | [(.connector_class_id // .connector_id // ""), (.requested_live_effect // false), (.requested_use // ""), (.operation_mode // ""), (.operation // ""), (.support_status // "unadmitted")] | @tsv' "$work_package" 2>/dev/null || true)
}

check_ready_work_package_placement() {
  local work_package="$1"
  local family

  require_yq "$work_package" '.placement.path_family_registry_ref == ".octon/instance/governance/engagements/path-families.yml"' "ready Work Package binds engagement path-family registry"
  while IFS= read -r family; do
    [[ -n "$family" ]] || continue
    require_yq "$work_package" ".placement.runtime_write_family_refs[]? | select(. == \"$family\")" "ready Work Package declares runtime-write family: $family"
  done < <(yq -r '.runtime_write_requires_registered_families[]?' "$PATH_FAMILIES")
}

check_cli_handoff() {
  [[ -n "$CLI_HELP_ARG" ]] || return 0
  local cli_help
  cli_help="$(resolve_root_path "$CLI_HELP_ARG")"
  if [[ ! -f "$cli_help" ]]; then
    fail "CLI help evidence missing: ${cli_help#$ROOT_DIR/}"
    return 0
  fi
  if grep -Fq "octon run start --contract" "$cli_help"; then
    pass "CLI help preserves run start handoff"
  else
    fail "CLI help must disclose octon run start --contract handoff"
  fi
}

check_authority_binding_sources() {
  local work_package="$1"
  if yq -r '.authority_binding | .. | select(tag == "!!str")' "$work_package" 2>/dev/null | grep -E '^\.octon/generated/' >/dev/null 2>&1; then
    fail "authority binding must not cite generated projections as authority"
  else
    pass "authority binding avoids generated projection authority"
  fi
}

check_objective_brief_placement() {
  local work_package="$1"
  local objective_ref objective_path
  objective_ref="$(yq -r '.objective_brief_ref // ""' "$work_package")"
  if [[ "$objective_ref" == .octon/state/control/engagements/*/objective/*.yml || "$objective_ref" == .octon/state/control/engagements/*/objective/*.yaml || "$objective_ref" == .octon/state/control/engagements/*/objective/*.json ]]; then
    pass "Objective Brief stays under engagement control"
  else
    fail "Objective Brief must live under engagement control: $objective_ref"
  fi
  require_yq "$work_package" '.objective_brief_authority_boundary.objective_brief_is_workspace_charter_authority == false and .objective_brief_authority_boundary.material_execution_authorized_by_objective_brief == false' "Work Package preserves Objective Brief non-authority boundary"
  require_yq "$work_package" '(.objective_brief_evidence_refs | length) > 0 and (.objective_brief_evidence_refs[]? | test("^\\.octon/state/evidence/engagements/[^/]+/objective/"))' "Work Package binds retained Objective Brief evidence"
  objective_path="$(resolve_root_path "$objective_ref")"
  if [[ -f "$objective_path" ]]; then
    require_yq "$objective_path" '.schema_version == "engagement-objective-brief-v1"' "Objective Brief uses engagement objective schema"
    require_yq "$objective_path" '.authority_boundary.objective_brief_is_workspace_charter_authority == false and .authority_boundary.may_rewrite_workspace_charter == false and .authority_boundary.material_execution_authorized_by_objective_brief == false' "Objective Brief file is not workspace-charter authority"
    require_yq "$objective_path" '(.backing_evidence_refs | length) > 0 and (.backing_evidence_refs[]? | test("^\\.octon/state/evidence/engagements/[^/]+/objective/"))' "Objective Brief file binds objective evidence"
  else
    pass "Objective Brief artifact not present in this validation scope"
  fi
}

check_run_contract_readiness_evidence() {
  local work_package="$1"
  require_yq "$work_package" '(.run_contract_readiness_evidence_refs | length) > 0 and (.run_contract_readiness_evidence_refs[]? | test("^\\.octon/state/evidence/engagements/[^/]+/run-contract-readiness/"))' "Work Package binds run-contract readiness evidence"
}

check_run_contract_candidate() {
  local work_package="$1"
  local candidate_ref candidate_path
  candidate_ref="$(yq -r '.run_contract_candidate.ref // .run_contract_candidate.candidate_ref // .run_contract_candidate.path // ""' "$work_package")"
  [[ -n "$candidate_ref" ]] || return 0
  candidate_path="$(resolve_root_path "$candidate_ref")"
  if [[ ! -f "$candidate_path" ]]; then
    fail "run-contract candidate missing: $candidate_ref"
    return 0
  fi
  if contains_proposal_path "$candidate_path"; then
    fail "run-contract candidate must not depend on proposal-local paths: $candidate_ref"
  else
    pass "run-contract candidate has no proposal-local dependency"
  fi
  if yq -e '(.direct_execution_allowed == true) or (.handoff.bypass_run_start == true)' "$candidate_path" >/dev/null 2>&1; then
    fail "run-contract candidate must not bypass octon run start --contract"
  else
    pass "run-contract candidate preserves run-start handoff"
  fi
}

check_decision_request_state() {
  local work_package="$1"
  local decision_ref decision_path status
  while IFS= read -r decision_ref; do
    [[ -n "$decision_ref" ]] || continue
    decision_path="$(resolve_root_path "$decision_ref")"
    if [[ ! -f "$decision_path" ]]; then
      fail "Decision Request missing: $decision_ref"
      continue
    fi
    status="$(yq -r '.status // .lifecycle.status // ""' "$decision_path")"
    if [[ "$status" == "open" ]]; then
      fail "ready Work Package must not have unresolved Decision Request: $decision_ref"
    else
      pass "Decision Request is not open: $decision_ref"
    fi
  done < <(yq -r '.decision_requests[]? | .decision_ref // .decision_request_ref // .ref // .path // .' "$work_package" 2>/dev/null || true)
}

check_decision_request_shapes() {
  local work_package="$1"
  local decision_ref decision_path
  while IFS= read -r decision_ref; do
    [[ -n "$decision_ref" ]] || continue
    decision_path="$(resolve_root_path "$decision_ref")"
    if [[ ! -f "$decision_path" ]]; then
      fail "Decision Request missing: $decision_ref"
      continue
    fi
    require_yq "$decision_path" '.schema_version == "decision-request-v1" and ((.canonical_resolution_targets // {}) | type == "!!map") and ((.evidence_root // "") | test("^\\.octon/state/evidence/decisions/"))' "Decision Request is a wrapper with canonical resolution targets: $decision_ref"
    require_yq "$decision_path" '((.canonical_resolution_targets.approval_request_ref // "") | test("^\\.octon/state/control/execution/approvals/")) or ((.canonical_resolution_targets.exception_lease_root // "") | test("^\\.octon/state/control/execution/exceptions/")) or ((.canonical_resolution_targets.revocation_root // "") | test("^\\.octon/state/control/execution/revocations/"))' "Decision Request points to canonical low-level control roots: $decision_ref"
  done < <(yq -r '.decision_requests[]? | .decision_ref // .decision_request_ref // .ref // .path // .' "$work_package" 2>/dev/null || true)
}

check_non_ready_reasoning() {
  local work_package="$1"
  local outcome="$2"
  case "$outcome" in
    stage_only|blocked|denied|requires_decision|escalate)
      if yq -e '((.outcome.blockers // []) | length > 0) or ((.outcome.reason_refs // []) | length > 0) or ((.blockers // []) | length > 0) or ((.reason_refs // []) | length > 0)' "$work_package" >/dev/null 2>&1; then
        pass "non-ready Work Package carries blocker or reason refs"
      else
        fail "non-ready Work Package must carry blocker or reason refs"
      fi
      ;;
  esac
}

validate_work_package() {
  local work_package="$1"
  local outcome profile tuple_id claim_effect

  if [[ ! -f "$work_package" ]]; then
    fail "Work Package missing: $work_package"
    return 0
  fi
  yq -e '.' "$work_package" >/dev/null 2>&1 \
    && pass "Work Package parses as YAML: ${work_package#$ROOT_DIR/}" \
    || { fail "Work Package must parse as YAML: ${work_package#$ROOT_DIR/}"; return 0; }

  while IFS= read -r section; do
    [[ -n "$section" ]] || continue
    require_yq "$work_package" "has(\"$section\")" "Work Package includes required section $section: ${work_package#$ROOT_DIR/}"
  done < <(yq -r '.work_package_required_sections[]?' "$COMPILER_POLICY")

  if contains_proposal_path "$work_package"; then
    fail "Work Package must not depend on proposal-local paths: ${work_package#$ROOT_DIR/}"
  else
    pass "Work Package has no proposal-local runtime dependency: ${work_package#$ROOT_DIR/}"
  fi

  check_objective_brief_placement "$work_package"
  check_run_contract_readiness_evidence "$work_package"
  check_decision_request_shapes "$work_package"
  check_authority_binding_sources "$work_package"
  check_run_contract_candidate "$work_package"

  outcome="$(yq -r '.outcome.status // .outcome // ""' "$work_package")"
  require_yq "$COMPILER_POLICY" ".allowed_final_outcomes[]? | select(. == \"$outcome\")" "Work Package outcome is explicit: $outcome"
  check_non_ready_reasoning "$work_package" "$outcome"

  profile="$(yq -r '.evidence_profile.profile_id // .evidence_profile.selected_profile // ""' "$work_package")"
  if [[ -z "$profile" ]]; then
    fail "Work Package must select an evidence profile"
  elif is_known_profile "$profile"; then
    pass "Work Package selected known evidence profile: $profile"
  else
    fail "Work Package selected unknown evidence profile: $profile"
  fi

  if [[ "$outcome" == "requires_decision" ]]; then
    require_yq "$work_package" '(.decision_requests | length) > 0' "requires_decision Work Package emits Decision Requests"
  fi

  check_work_package_connectors "$work_package" "$outcome"

  if [[ "$outcome" == "ready_for_authorization" ]]; then
    profile_allows_ready "$profile" \
      && pass "selected profile allows ready_for_authorization" \
      || fail "selected profile cannot reach ready_for_authorization: $profile"

    check_ready_work_package_placement "$work_package"
    require_yq "$work_package" '(.context_pack.receipt_ref // "") != ""' "ready Work Package binds context-pack receipt"
    require_yq "$work_package" '((.rollback.plan_ref // .rollback.rollback_plan_ref // .rollback.ref // "") != "")' "ready Work Package binds rollback plan"
    require_yq "$work_package" '(.runtime_authorization.grant_bundle_ref // .authority_binding.grant_bundle_ref // "") != ""' "ready Work Package binds grant bundle"

    tuple_id="$(yq -r '.support_posture.tuple_id // .support_posture.support_target_tuple_ref // ""' "$work_package")"
    claim_effect="$(yq -r '.support_posture.claim_effect // ""' "$work_package")"
    check_work_package_support_tuple "$work_package" "$tuple_id" "$claim_effect"
    check_work_package_capabilities "$work_package"
    check_decision_request_state "$work_package"
  fi
}

check_work_packages() {
  local found=0
  local work_package

  while IFS= read -r work_package; do
    [[ -n "$work_package" ]] || continue
    found=1
    validate_work_package "$work_package"
  done < <(work_package_paths)

  if [[ "$found" -eq 0 ]]; then
    pass "no live Engagement Work Packages present; static gates are active"
  fi
}

reset_validator_result_metadata
validator_result_add_evidence \
  ".octon/instance/governance/policies/engagement-work-package-compiler.yml" \
  ".octon/instance/governance/policies/evidence-profiles.yml" \
  ".octon/instance/governance/policies/preflight-evidence-lane.yml" \
  ".octon/instance/governance/connectors/posture.yml" \
  ".octon/instance/governance/connectors/registry.yml" \
  ".octon/instance/governance/engagements/path-families.yml"
validator_result_add_runtime_test \
  ".octon/framework/assurance/runtime/_ops/tests/test-engagement-work-package-compiler.sh"
validator_result_add_negative_control \
  "objective-brief-authority-claim-fails" \
  "missing-run-contract-readiness-evidence-fails" \
  "missing-approval-gate-fails" \
  "api-connector-live-route-fails" \
  "preflight-mutation-allow-fails" \
  "missing-path-family-registration-fails" \
  "ready-work-package-with-non-admitted-connector-fails" \
  "ready-work-package-missing-rollback-fails"
validator_result_add_contract \
  ".octon/instance/governance/support-targets.yml" \
  ".octon/instance/governance/exclusions/action-classes.yml" \
  ".octon/instance/governance/capability-packs/registry.yml" \
  ".octon/instance/governance/policies/context-packing.yml"
validator_result_add_schema_version \
  "engagement-work-package-compiler-governance-v1" \
  "octon-evidence-profiles-policy-v1" \
  "octon-preflight-evidence-lane-policy-v1" \
  "engagement-connector-posture-v1" \
  "engagement-connector-posture-registry-v1" \
  "connector-registry-v4" \
  "engagement-path-family-registry-v1"

check_static_policy_surfaces
check_compiler_gates
check_evidence_profiles
check_preflight_lane
check_connector_posture
check_path_family_registry
check_work_packages
check_cli_handoff

echo "Validation summary: errors=$errors"
if [[ "$errors" -eq 0 ]]; then
  emit_validator_result "validate-engagement-work-package-compiler.sh" "engagement_work_package_compiler_governance" "semantic" "semantic" "pass"
else
  emit_validator_result "validate-engagement-work-package-compiler.sh" "engagement_work_package_compiler_governance" "semantic" "existence" "fail"
fi
[[ "$errors" -eq 0 ]]
