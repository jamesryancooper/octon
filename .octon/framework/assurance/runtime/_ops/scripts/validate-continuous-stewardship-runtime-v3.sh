#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
PROGRAM_ID=""
CLI_HELP_ARG=""

usage() {
  cat <<'EOF'
Usage: validate-continuous-stewardship-runtime-v3.sh [--root <repo-root>] [--program-id <id>] [--cli-help <path>]

Validates Continuous Stewardship Runtime v3 contracts, root placement,
stewardship gates, evidence, generated non-authority, campaign boundaries,
and no direct material execution from stewardship.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      OCTON_DIR="${OCTON_DIR_OVERRIDE:-$ROOT_DIR/.octon}"
      shift 2
      ;;
    --program-id)
      PROGRAM_ID="$2"
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

require_json_schema() {
  local file="$1"
  local label="$2"
  require_file "$file"
  [[ -f "$file" ]] || return 0
  jq -e 'type == "object" and has("$schema") and has("$id") and has("title") and (has("type") or has("allOf") or has("anyOf") or has("oneOf"))' "$file" >/dev/null 2>&1 \
    && pass "$label is a JSON Schema" \
    || fail "$label must be a JSON Schema"
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

check_tools() {
  command -v yq >/dev/null 2>&1 || fail "yq is required"
  command -v jq >/dev/null 2>&1 || fail "jq is required"
}

check_schema_strength_match() {
  local runtime="$1"
  local mirror="$2"
  local label="$3"
  local missing=0
  while IFS= read -r required; do
    [[ -n "$required" ]] || continue
    if ! jq -e --arg required "$required" '(.required // []) | index($required)' "$mirror" >/dev/null 2>&1; then
      missing=1
    fi
  done < <(jq -r '.required[]?' "$runtime")
  [[ "$missing" == "0" ]] && pass "$label constitutional mirror carries runtime required fields" || fail "$label constitutional mirror is weaker than runtime schema"
}

check_static_contracts() {
  echo "== Continuous Stewardship Runtime v3 Contract Validation =="
  local schemas=(
    stewardship-program-v1
    stewardship-epoch-v1
    stewardship-trigger-v1
    stewardship-admission-decision-v1
    stewardship-idle-decision-v1
    stewardship-renewal-decision-v1
    stewardship-ledger-v1
    stewardship-evidence-profile-v1
    stewardship-epoch-closeout-v1
    stewardship-campaign-coordination-hook-v1
  )
  local schema
  for schema in "${schemas[@]}"; do
    require_json_schema "$OCTON_DIR/framework/engine/runtime/spec/${schema}.schema.json" "$schema runtime schema"
    require_json_schema "$OCTON_DIR/framework/constitution/contracts/runtime/${schema}.schema.json" "$schema constitutional runtime schema"
    check_schema_strength_match \
      "$OCTON_DIR/framework/engine/runtime/spec/${schema}.schema.json" \
      "$OCTON_DIR/framework/constitution/contracts/runtime/${schema}.schema.json" \
      "$schema"
  done
  require_json_schema "$OCTON_DIR/framework/engine/runtime/spec/stewardship-aware-decision-request-v1.schema.json" "stewardship-aware Decision Request runtime schema"
  require_json_schema "$OCTON_DIR/framework/constitution/contracts/authority/stewardship-aware-decision-request-v1.schema.json" "stewardship-aware Decision Request constitutional schema"
  check_schema_strength_match \
    "$OCTON_DIR/framework/engine/runtime/spec/stewardship-aware-decision-request-v1.schema.json" \
    "$OCTON_DIR/framework/constitution/contracts/authority/stewardship-aware-decision-request-v1.schema.json" \
    "stewardship-aware Decision Request"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/continuous-stewardship-runtime-v3.md"
  require_file "$OCTON_DIR/framework/orchestration/practices/stewardship-lifecycle-standards.md"

  require_jq "$OCTON_DIR/framework/engine/runtime/spec/stewardship-campaign-coordination-hook-v1.schema.json" '.properties.authority_boundary.required | index("campaign_launches_workflows") and index("campaign_claims_queue_items") and index("campaign_owns_runs") and index("campaign_owns_incidents") and index("campaign_replaces_missions") and index("campaign_replaces_stewardship")' "campaign hook schema enforces non-execution boundary fields"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/stewardship-aware-decision-request-v1.schema.json" '.required | index("decision_request_id") and index("question") and index("subject_refs") and index("canonical_resolution_targets") and index("evidence_root") and index("decision_request_authorizes_material_execution")' "stewardship-aware Decision Request carries base request fields"

  require_yq "$OCTON_DIR/framework/constitution/contracts/registry.yml" '.integration_surfaces.continuous_stewardship_runtime_v3_contracts.rule | test("do not authorize material execution")' "constitutional registry preserves no-execution stewardship rule"
  require_yq "$OCTON_DIR/framework/constitution/contracts/runtime/family.yml" '.continuous_stewardship_runtime.stewardship_aware_decision_request.rule | test("do not authorize material execution")' "runtime family lists stewardship-aware Decision Request"
  require_yq "$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml" '.path_families.continuous_stewardship_runtime_v3.forbidden_consumers[] | select(. == "infinite agent loops")' "architecture registry forbids infinite agent loops"
}

check_v1_v2_dependencies() {
  echo "== v1/v2 Dependency Validation =="
  local required=(
    framework/engine/runtime/spec/engagement-v1.schema.json
    framework/engine/runtime/spec/work-package-v1.schema.json
    framework/engine/runtime/spec/decision-request-v1.schema.json
    framework/engine/runtime/spec/evidence-profile-v1.schema.json
    framework/engine/runtime/spec/autonomy-window-v1.schema.json
    framework/engine/runtime/spec/mission-queue-v1.schema.json
    framework/engine/runtime/spec/mission-continuation-decision-v1.schema.json
    framework/engine/runtime/spec/mission-run-ledger-v1.schema.json
    framework/engine/runtime/spec/mission-evidence-profile-v1.schema.json
    framework/engine/runtime/spec/mission-autonomy-runtime-v2.md
  )
  local item
  for item in "${required[@]}"; do
    require_file "$OCTON_DIR/$item"
  done
}

check_instance_authority() {
  echo "== Stewardship Instance Authority Validation =="
  [[ -n "$PROGRAM_ID" ]] || return 0
  local root="$OCTON_DIR/instance/stewardship/programs/$PROGRAM_ID"
  require_yaml_schema "$root/program.yml" "stewardship-program-v1"
  require_yaml_schema "$root/policy.yml" "stewardship-policy-v1"
  require_yaml_schema "$root/trigger-rules.yml" "stewardship-trigger-rules-v1"
  require_yaml_schema "$root/review-cadence.yml" "stewardship-review-cadence-v1"
  require_yaml_schema "$root/campaign-policy.yml" "stewardship-campaign-policy-v1"
  require_yq "$root/program.yml" '.authority_boundary.program_executes_work_directly == false and .authority_boundary.triggers_authorize_work == false and .authority_boundary.admission_authorizes_material_execution == false and .authority_boundary.run_lifecycle_required == true' "Stewardship Program authority cannot execute work"
  require_yq "$root/campaign-policy.yml" '.campaign_promotion_criteria_ref == ".octon/framework/orchestration/practices/campaign-promotion-criteria.md" and .standing_decision == "deferred_by_default" and .campaigns_are_execution_containers == false and .campaigns_may_launch_workflows == false and .campaigns_may_claim_queue_items == false and .campaigns_may_own_runs == false and .campaigns_may_own_incidents == false and .campaigns_may_replace_missions == false and .campaigns_may_replace_stewardship == false and .campaigns_required_for_normal_stewardship == false and .campaign_candidate_requires_evidence_backed_go_decision == true' "campaign policy preserves deferred non-execution boundary"
  require_yq "$OCTON_DIR/framework/overlay-points/registry.yml" '.overlay_points[] | select(.overlay_point_id == "instance-stewardship-programs" and .instance_glob == ".octon/instance/stewardship/programs/**")' "stewardship instance authority root has overlay point"
  require_yq "$OCTON_DIR/instance/manifest.yml" '.enabled_overlay_points[] | select(. == "instance-stewardship-programs")' "stewardship overlay point is enabled"
}

check_runtime_no_bypass() {
  echo "== Runtime Bypass Validation =="
  local runtime_file="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/commands/stewardship.rs"
  require_file "$runtime_file"
  if rg -n 'run_descriptor_start|ProcessCommand|std::process|cmd_run|cmd_tool|cmd_publish|cmd_protected_ci|workflow::' "$runtime_file" >/tmp/octon-steward-forbidden.$$ 2>/dev/null; then
    fail "stewardship runtime must not invoke direct execution, workflow, publication, or tool paths"
    cat /tmp/octon-steward-forbidden.$$
  else
    pass "stewardship runtime contains no direct execution/workflow/tool invocation"
  fi
  rm -f /tmp/octon-steward-forbidden.$$

  if rg -n '\.octon/inputs/' "$runtime_file" "$OCTON_DIR/instance/stewardship" "$OCTON_DIR/state/control/stewardship" >/tmp/octon-steward-inputs.$$ 2>/dev/null; then
    fail "stewardship runtime/control/policy must not depend on inputs/**"
    cat /tmp/octon-steward-inputs.$$
  else
    pass "no inputs/** runtime, policy, or control dependency in stewardship"
  fi
  rm -f /tmp/octon-steward-inputs.$$
}

check_live_program() {
  [[ -n "$PROGRAM_ID" ]] || return 0
  echo "== Live Stewardship Program Validation =="
  local root="$OCTON_DIR/state/control/stewardship/programs/$PROGRAM_ID"
  local evidence_root="$OCTON_DIR/state/evidence/stewardship/programs/$PROGRAM_ID"
  local continuity_root="$OCTON_DIR/state/continuity/stewardship/programs/$PROGRAM_ID"
  local generated_root="$OCTON_DIR/generated/cognition/projections/materialized/stewardship"
  require_yaml_schema "$root/status.yml" "stewardship-program-status-v1"
  require_yaml_schema "$root/evidence-profile.yml" "stewardship-evidence-profile-v1"
  require_yaml_schema "$root/ledger.yml" "stewardship-ledger-v1"
  require_dir "$evidence_root"
  require_yaml_schema "$continuity_root/summary.yml" "stewardship-continuity-summary-v1"
  require_yq "$continuity_root/summary.yml" '.non_authority_notice != null' "stewardship continuity declares non-authority"
  require_yq "$root/status.yml" '.service_may_be_indefinite == true and .work_may_be_unbounded == false and .one_active_program_per_workspace == true' "program status preserves indefinite-service bounded-work rule"
  require_yq "$root/ledger.yml" '.role == "stewardship-level-index-not-mission-or-run-evidence" and .run_journal_authority_ref == ".octon/state/control/execution/runs/<run-id>/events.ndjson"' "Stewardship Ledger does not replace mission/run evidence"

  local active_programs
  active_programs="$(find "$OCTON_DIR/state/control/stewardship/programs" -name status.yml -print 2>/dev/null | while IFS= read -r file; do yq -r '.status // ""' "$file"; done | grep -Ec '^(active|idle|paused)$' || true)"
  [[ "$active_programs" -le 1 ]] && pass "at most one active Stewardship Program" || fail "more than one active Stewardship Program"

  if [[ -d "$root/epochs" ]]; then
    local active_epochs
    active_epochs="$(find "$root/epochs" -name epoch.yml -print | while IFS= read -r file; do yq -r '.status // ""' "$file"; done | grep -Ec '^(active|idle|paused)$' || true)"
    [[ "$active_epochs" -le 1 ]] && pass "at most one active Stewardship Epoch" || fail "more than one active Stewardship Epoch"
    while IFS= read -r epoch; do
      require_yaml_schema "$epoch" "stewardship-epoch-v1"
      require_yq "$epoch" '.material_execution_allowed == false and .epoch_replaces_mission_control_lease == false and .renewal_eligibility.operator_command_required == true' "Stewardship Epoch does not execute or replace mission lease"
      require_yaml_schema "$(dirname "$epoch")/closeout.yml" "stewardship-epoch-closeout-v1"
    done < <(find "$root/epochs" -name epoch.yml -print | sort)
  fi

  validate_trigger_records "$root"
  validate_admission_records "$root"
  validate_idle_records "$root"
  validate_renewal_records "$root"
  validate_decision_records "$root" "$evidence_root"
  validate_evidence_profile "$root/evidence-profile.yml" "$evidence_root"
  validate_generated_projection "$root/status.yml" "$generated_root"
}

validate_trigger_records() {
  local root="$1"
  [[ -d "$root/triggers" ]] || return 0
  while IFS= read -r item; do
    require_yaml_schema "$item" "stewardship-trigger-v1"
    require_yq "$item" '.trigger_authorizes_work == false and .material_execution_allowed == false and .admission_required_before_work == true and .source_authority == "non_authoritative_observation_input"' "Stewardship Trigger never authorizes work"
  done < <(find "$root/triggers" -type f -name '*.yml' | sort)
}

validate_admission_records() {
  local root="$1"
  [[ -d "$root/admission-decisions" ]] || return 0
  while IFS= read -r item; do
    require_yaml_schema "$item" "stewardship-admission-decision-v1"
    require_yq "$item" '.governance_constraints.stewardship_trigger_authorizes_work == false and .governance_constraints.admission_decision_authorizes_material_execution == false and .governance_constraints.run_gate_required == true and .governance_constraints.v2_mission_gate_required == true and .campaign_candidate_allowed_without_go_decision == false' "Admission Decision never authorizes material execution"
  done < <(find "$root/admission-decisions" -type f -name '*.yml' | sort)
}

validate_idle_records() {
  local root="$1"
  [[ -d "$root/idle-decisions" ]] || return 0
  while IFS= read -r item; do
    require_yaml_schema "$item" "stewardship-idle-decision-v1"
    require_yq "$item" '.no_work_executed == true and .idle_is_successful_governed_state == true' "Idle Decision records successful no-work state"
  done < <(find "$root/idle-decisions" -type f -name '*.yml' | sort)
}

validate_renewal_records() {
  local root="$1"
  [[ -d "$root/renewal-decisions" ]] || return 0
  while IFS= read -r item; do
    require_yaml_schema "$item" "stewardship-renewal-decision-v1"
    require_yq "$item" '.silent_authority_widening == false and .renewal_decision_authorizes_material_execution == false' "Renewal Decision cannot widen authority or authorize execution"
  done < <(find "$root/renewal-decisions" -type f -name '*.yml' | sort)
}

validate_decision_records() {
  local root="$1"
  local evidence_root="$2"
  [[ -d "$root/decisions" ]] || return 0
  while IFS= read -r item; do
    require_yaml_schema "$item" "decision-request-v1"
    require_yq "$item" '.decision_request_id != null and .program_id != null and .stewardship_decision_type != null and .question != null and .subject_refs != null and .canonical_resolution_targets != null and .evidence_root != null and .host_comments_labels_chat_are_authority == false and .generated_summaries_are_authority == false and .decision_request_authorizes_material_execution == false' "stewardship-aware Decision Request carries base fields and no-authority flags"
    if yq -e '.status == "resolved" or .status == "denied" or .status == "revoked"' "$item" >/dev/null 2>&1; then
      local decision_id
      decision_id="$(yq -r '.decision_request_id' "$item")"
      require_yaml_schema "$evidence_root/decision-requests/$decision_id/resolution.yml" "stewardship-decision-request-resolution-v1"
      require_yq "$evidence_root/decision-requests/$decision_id/resolution.yml" '.material_execution_authorized == false and .stewardship_admission_authorized == false' "stewardship Decision Request resolution remains non-executing"
    fi
  done < <(find "$root/decisions" -type f -name '*.yml' | sort)
}

validate_evidence_profile() {
  local profile="$1"
  local evidence_root="$2"
  local missing=0
  while IFS= read -r requirement; do
    [[ -n "$requirement" ]] || continue
    local family="$requirement"
    case "$requirement" in
      program-snapshots) family="program" ;;
      epoch-snapshots) family="epochs" ;;
      trigger-evidence) family="triggers" ;;
      admission-decisions) family="admission-decisions" ;;
      idle-decisions) family="idle-decisions" ;;
      mission-handoff) family="mission-handoff" ;;
      campaign-coordination-if-used)
        if [[ ! -d "$evidence_root/campaign-coordination-if-used" ]]; then
          pass "campaign coordination evidence not required when no campaign hook is used"
          continue
        fi
        family="campaign-coordination-if-used"
        ;;
      renewal-decisions) family="renewal-decisions" ;;
      stewardship-ledger) family="stewardship-ledger" ;;
      continuity-update) family="continuity" ;;
      disclosure-status) family="disclosure-status" ;;
      closeout-evidence) family="closeout-evidence" ;;
    esac
    if [[ -z "$(find "$evidence_root/$family" -type f -name '*.yml' -print -quit 2>/dev/null || true)" ]]; then
      fail "selected Stewardship Evidence Profile is missing retained evidence family: $family"
      missing=1
    else
      pass "selected Stewardship Evidence Profile has retained evidence family: $family"
    fi
  done < <(yq -r '.required_evidence[]?' "$profile")

  while IFS= read -r receipt; do
    if [[ "$(yq -r '.schema_version // ""' "$receipt")" == "stewardship-evidence-receipt-v1" ]]; then
      require_yq "$receipt" '.retained_evidence == true and .generated_projection_substitute == false and .command_provenance != null and .control_snapshot_ref != null and .captured_at != null' "stewardship evidence receipt is replay-grade enough for control-plane validation"
    fi
  done < <(find "$evidence_root" -type f -name '*.yml' | sort)

  [[ "$missing" == "0" ]] || true
}

validate_generated_projection() {
  local status_file="$1"
  local generated_root="$2"
  require_yaml_schema "$generated_root/status.yml" "stewardship-generated-projection-v1"
  require_yq "$generated_root/status.yml" '.non_authority_notice != null' "generated stewardship projection declares non-authority"
  local control_status generated_status
  control_status="$(yq -r '.status // ""' "$status_file")"
  generated_status="$(yq -r '.status // ""' "$generated_root/status.yml")"
  [[ "$control_status" == "$generated_status" ]] \
    && pass "generated stewardship status mirrors canonical control status" \
    || fail "generated stewardship status must mirror canonical control status"
}

check_cli_help() {
  [[ -n "$CLI_HELP_ARG" ]] || return 0
  local help_path="$CLI_HELP_ARG"
  [[ "$help_path" = /* ]] || help_path="$ROOT_DIR/$help_path"
  require_file "$help_path"
  for token in steward open observe admit idle renew ledger triggers epochs decisions; do
    grep -q "$token" "$help_path" && pass "CLI help contains $token" || fail "CLI help missing $token"
  done
}

check_tools
check_static_contracts
check_v1_v2_dependencies
check_instance_authority
check_runtime_no_bypass
check_live_program
check_cli_help

if [[ "$errors" -gt 0 ]]; then
  echo "[FAIL] Continuous Stewardship Runtime v3 validation failed with $errors error(s)."
  exit 1
fi

echo "[OK] Continuous Stewardship Runtime v3 validation passed."
