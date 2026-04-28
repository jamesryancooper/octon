#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
MISSION_ID=""
CLI_HELP_ARG=""

usage() {
  cat <<'EOF'
Usage: validate-mission-autonomy-runtime-v2.sh [--root <repo-root>] [--mission-id <id>] [--cli-help <path>]

Validates Mission Autonomy Runtime v2 contracts, placement, gates, connector
posture, and non-bypass guarantees.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      OCTON_DIR="${OCTON_DIR_OVERRIDE:-$ROOT_DIR/.octon}"
      shift 2
      ;;
    --mission-id)
      MISSION_ID="$2"
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
  jq -e 'type == "object" and has("$schema") and has("$id") and has("title") and (has("type") or has("allOf"))' "$file" >/dev/null 2>&1 \
    && pass "$label is a JSON Schema" \
    || fail "$label must be a JSON Schema"
}

require_yq() {
  local file="$1"
  local expr="$2"
  local label="$3"
  yq -e "$expr" "$file" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

check_tools() {
  command -v yq >/dev/null 2>&1 || fail "yq is required"
  command -v jq >/dev/null 2>&1 || fail "jq is required"
}

check_static_contracts() {
  echo "== Mission Autonomy Runtime v2 Contract Validation =="
  for schema in \
    autonomy-window-v1 \
    mission-queue-v1 \
    mission-continuation-decision-v1 \
    mission-run-ledger-v1 \
    mission-closeout-v1 \
    mission-evidence-profile-v1 \
    mission-aware-decision-request-v1 \
    connector-operation-v1 \
    connector-admission-v1; do
    require_json_schema "$OCTON_DIR/framework/engine/runtime/spec/${schema}.schema.json" "$schema runtime schema"
  done
  for schema in \
    autonomy-window-v1 \
    mission-queue-v1 \
    mission-continuation-decision-v1 \
    mission-run-ledger-v1 \
    mission-closeout-v1 \
    mission-evidence-profile-v1; do
    require_json_schema "$OCTON_DIR/framework/constitution/contracts/runtime/${schema}.schema.json" "$schema constitutional runtime schema"
  done
  require_json_schema "$OCTON_DIR/framework/constitution/contracts/authority/mission-aware-decision-request-v1.schema.json" "mission-aware Decision Request constitutional schema"
  require_json_schema "$OCTON_DIR/framework/constitution/contracts/adapters/connector-operation-v1.schema.json" "connector operation constitutional schema"
  require_json_schema "$OCTON_DIR/framework/constitution/contracts/adapters/connector-admission-v1.schema.json" "connector admission constitutional schema"
  require_json_schema "$OCTON_DIR/framework/constitution/contracts/objective/mission-charter-v2.schema.json" "mission charter v2 constitutional schema"

  require_yaml_schema "$OCTON_DIR/instance/governance/policies/mission-continuation.yml" "mission-continuation-policy-v1"
  require_yaml_schema "$OCTON_DIR/instance/governance/policies/autonomy-window.yml" "autonomy-window-policy-v1"
  require_yaml_schema "$OCTON_DIR/instance/governance/policies/connector-admission.yml" "connector-admission-policy-v1"
  require_yaml_schema "$OCTON_DIR/instance/governance/policies/mission-closeout.yml" "mission-closeout-policy-v1"

  require_yq "$OCTON_DIR/framework/constitution/contracts/registry.yml" '.integration_surfaces.mission_autonomy_runtime_v2_contracts.rule | test("do not replace run contracts")' "constitutional registry declares no run lifecycle replacement"
  require_yq "$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml" '.path_families.mission_autonomy_runtime_v2.forbidden_consumers[] | select(. == "execution authorization replacement")' "architecture registry forbids authorization replacement"
}

check_placement() {
  echo "== Mission Autonomy Runtime v2 Placement Validation =="
  [[ ! -d "$OCTON_DIR/state/control/missions" ]] \
    && pass "no rival state/control/missions control plane" \
    || fail "mission control may exist only under state/control/execution/missions"
  [[ ! -d "$OCTON_DIR/state/evidence/missions" ]] \
    && pass "no unregistered state/evidence/missions evidence family" \
    || fail "mission evidence uses state/evidence/control/execution/missions"
  require_yaml_schema "$OCTON_DIR/instance/orchestration/missions/registry.yml" "octon-mission-registry-v2"
  require_yq "$OCTON_DIR/instance/orchestration/missions/registry.yml" '.control_root == ".octon/state/control/execution/missions"' "mission registry uses execution mission control root"
  require_yq "$OCTON_DIR/instance/orchestration/missions/registry.yml" '.continuity_root == ".octon/state/continuity/repo/missions"' "mission registry uses repo mission continuity root"
}

check_live_mission() {
  [[ -n "$MISSION_ID" ]] || return 0
  echo "== Mission Autonomy Runtime v2 Live Mission Validation =="
  local root="$OCTON_DIR/state/control/execution/missions/$MISSION_ID"
  local evidence_root="$OCTON_DIR/state/evidence/control/execution/missions/$MISSION_ID"
  local continuity_root="$OCTON_DIR/state/continuity/repo/missions/$MISSION_ID"
  require_yaml_schema "$root/mission.yml" "mission-runtime-state-v1"
  require_yaml_schema "$root/autonomy-window.yml" "autonomy-window-v1"
  require_yaml_schema "$root/lease.yml" "mission-control-lease-v1"
  require_yaml_schema "$root/autonomy-budget.yml" "autonomy-budget-v1"
  require_yaml_schema "$root/circuit-breakers.yml" "circuit-breaker-v1"
  require_yaml_schema "$root/queue.yml" "mission-queue-v1"
  require_yaml_schema "$root/runs.yml" "mission-run-ledger-v1"
  require_yaml_schema "$root/closeout.yml" "mission-closeout-v1"
  require_yaml_schema "$root/evidence-profile.yml" "mission-evidence-profile-v1"
  require_file "$continuity_root/summary.yml"
  require_file "$continuity_root/next-actions.yml"
  [[ -d "$evidence_root" ]] && pass "mission control evidence root exists" || fail "mission control evidence root missing"

  require_yq "$root/autonomy-window.yml" '.authority_boundary.autonomy_window_authorizes_execution == false and .authority_boundary.run_contract_required == true and .authority_boundary.execution_authorization_required == true' "Autonomy Window does not authorize execution"
  require_yq "$root/autonomy-window.yml" '.max_concurrent_runs == 1' "Autonomy Window enforces one active run"
  require_yq "$root/lease.yml" '.continuation_scope.max_concurrent_runs == 1 and .engagement_id != null and .work_package_ref != null' "lease is scoped to Engagement and Work Package"
  require_yq "$root/autonomy-budget.yml" '.last_recomputed_at != null' "budget has recompute receipt field"
  require_yq "$root/circuit-breakers.yml" '.last_recomputed_at != null and (.state == "clear" or .state == "tripped" or .state == "latched")' "breakers carry recompute state"
  require_yq "$root/queue.yml" '.selection_policy.one_active_run_at_a_time == true and (.action_slices | length >= 1)' "Mission Queue selects bounded Action Slices"
  require_yq "$root/runs.yml" '.role == "mission-level-index-not-run-journal" and .run_journal_authority_ref == ".octon/state/control/execution/runs/<run-id>/events.ndjson"' "Mission Run Ledger does not replace run journals"
  require_yq "$root/closeout.yml" '.policy_ref == ".octon/instance/governance/policies/mission-closeout.yml"' "mission closeout binds closeout policy"
  validate_ledger_rows "$root/runs.yml"
  validate_closeout_semantics "$root/runs.yml" "$root/queue.yml" "$root/closeout.yml"
  validate_mission_evidence_requirements "$root/evidence-profile.yml" "$evidence_root"

  if [[ -d "$root/continuation-decisions" ]]; then
    while IFS= read -r decision; do
      require_yaml_schema "$decision" "mission-continuation-decision-v1"
      require_yq "$decision" '.authorization_boundary.continuation_decision_authorizes_execution == false and .authorization_boundary.execution_authorization_required == true' "Continuation Decision does not authorize execution"
    done < <(find "$root/continuation-decisions" -type f -name '*.yml' | sort)
  fi
  if [[ -d "$root/decisions" ]]; then
    while IFS= read -r decision; do
      [[ "$(basename "$decision")" == "index.yml" ]] && continue
      require_yq "$decision" '.schema_version == "decision-request-v1" and .mission_id != null and .mission_decision_type != null' "mission-aware Decision Request carries mission fields"
    done < <(find "$root/decisions" -type f -name '*.yml' | sort)
  fi
}

validate_ledger_rows() {
  local ledger="$1"
  local bad=0
  while IFS=$'\t' read -r run_id canonical_ref run_status; do
    [[ -n "$run_id" ]] || continue
    if [[ "$canonical_ref" != "-" && "$canonical_ref" != *"/$run_id/"* ]]; then
      bad=1
    fi
    if [[ "$run_status" == "canonical_contract_prepared" && "$canonical_ref" == "-" ]]; then
      bad=1
    fi
  done < <(yq -r '.runs[]? | [.run_id, (.canonical_run_contract_ref // "-"), (.run_status // "")] | @tsv' "$ledger")
  [[ "$bad" == "0" ]] && pass "Mission Run Ledger canonical refs match run ids" || fail "Mission Run Ledger canonical refs must match indexed run ids"
}

validate_closeout_semantics() {
  local ledger="$1"
  local queue="$2"
  local closeout="$3"
  if yq -e '.status != "closed" and .all_relevant_runs_terminal == true and .run_level_closeout_complete == true and .mission_queue_resolved == true and .mission_evidence_bundle_complete == true' "$closeout" >/dev/null 2>&1; then
    fail "open or blocked mission closeout must not claim all closure gates complete"
  else
    pass "open or blocked mission closeout does not claim all closure gates complete"
  fi
  if yq -e '.all_relevant_runs_terminal == true' "$closeout" >/dev/null 2>&1; then
    require_yq "$ledger" '([.runs[]? | select((.run_status != "succeeded") and (.run_status != "failed") and (.run_status != "closed") and (.run_status != "denied"))] | length) == 0' "mission closeout terminal-run claim matches ledger"
  fi
  if yq -e '.mission_queue_resolved == true' "$closeout" >/dev/null 2>&1; then
    require_yq "$queue" '([.action_slices[]? | select((.status != "done") and (.status != "skipped") and (.status != "denied"))] | length) == 0' "mission closeout queue claim matches queue"
  fi
}

validate_mission_evidence_requirements() {
  local profile="$1"
  local evidence_root="$2"
  local missing=0
  while IFS= read -r requirement; do
    [[ -n "$requirement" ]] || continue
    local family="$requirement"
    case "$requirement" in
      autonomy-window-snapshots) family="autonomy-window" ;;
      lease-snapshots) family="lease" ;;
      budget-snapshots) family="budget" ;;
      breaker-snapshots) family="circuit-breakers" ;;
      mission-queue-snapshots) family="queue" ;;
      continuation-decisions) family="continuation-decisions" ;;
      decision-request-trail) family="decision-requests" ;;
      connector-posture-trail) family="connectors" ;;
      mission-run-ledger) family="mission-run-ledger" ;;
      rollback-aggregation) family="rollback" ;;
      mission-level-disclosure) family="disclosure" ;;
      continuity-update) family="continuity" ;;
      closeout-evidence) family="closeout" ;;
    esac
    if ! find "$evidence_root/$family" -type f -name '*.yml' >/dev/null 2>&1; then
      missing=1
    elif [[ -z "$(find "$evidence_root/$family" -type f -name '*.yml' -print -quit 2>/dev/null)" ]]; then
      missing=1
    fi
  done < <(yq -r '.required_evidence[]?' "$profile")
  [[ "$missing" == "0" ]] && pass "selected Mission Evidence Profile has retained evidence families" || fail "selected Mission Evidence Profile is missing retained evidence families"
}

check_connector_admissions() {
  echo "== Connector Admission Validation =="
  require_yq "$OCTON_DIR/instance/governance/policies/connector-admission.yml" '(.v2_mvp_live_effectful_connector_admission // .v4_mvp_live_effectful_connector_admission) == "blocked"' "live connector admission is blocked in current MVP"
  local admissions="$OCTON_DIR/instance/governance/connector-admissions"
  [[ -d "$admissions" ]] || return 0
  while IFS= read -r admission; do
    require_yaml_schema "$admission" "connector-admission-v1"
    require_yq "$admission" '.live_effects_authorized == false and .authorization_grant_required_for_material_effects == true and .effect_token_verification_required_for_material_operations == true' "connector admission remains non-effectful and authorization-bound"
    require_yq "$admission" '.operation_contract_ref != null and .side_effect_class != null and .support_posture != null and .evidence_obligations != null' "connector admission records operation posture fields"
  done < <(find "$admissions" -type f -name 'admission.yml' | sort)
}

check_non_authority() {
  echo "== Non-Authority and Bypass Validation =="
  if command -v rg >/dev/null 2>&1; then
    rg -n '\.octon/inputs/' \
      "$OCTON_DIR/state/control/execution/missions" \
      "$OCTON_DIR/instance/governance/policies/mission-continuation.yml" \
      "$OCTON_DIR/instance/governance/policies/autonomy-window.yml" \
      "$OCTON_DIR/instance/governance/policies/connector-admission.yml" \
      "$OCTON_DIR/instance/governance/policies/mission-closeout.yml" \
      >/tmp/octon-mar-v2-inputs.$$ 2>/dev/null || true
    [[ ! -s /tmp/octon-mar-v2-inputs.$$ ]] && pass "no inputs/** runtime or policy dependency in mission control/policies" || fail "inputs/** dependency found in mission control/policies"
    rm -f /tmp/octon-mar-v2-inputs.$$
  fi
  if [[ -d "$OCTON_DIR/generated/cognition/projections/materialized/missions" ]]; then
    while IFS= read -r projection; do
      require_yq "$projection" '.non_authority_notice != null' "generated mission projection declares non-authority"
    done < <(find "$OCTON_DIR/generated/cognition/projections/materialized/missions" -type f -name '*.yml' | sort)
  fi
}

check_cli_help() {
  [[ -n "$CLI_HELP_ARG" ]] || return 0
  local help_path="$CLI_HELP_ARG"
  [[ "$help_path" = /* ]] || help_path="$ROOT_DIR/$help_path"
  require_file "$help_path"
  for token in "continue" "mission" "connector" "decide"; do
    grep -q "$token" "$help_path" && pass "CLI help contains $token" || fail "CLI help missing $token"
  done
}

check_tools
check_static_contracts
check_placement
check_live_mission
check_connector_admissions
check_non_authority
check_cli_help

if [[ "$errors" -gt 0 ]]; then
  echo "[FAIL] Mission Autonomy Runtime v2 validation failed with $errors error(s)."
  exit 1
fi

echo "[OK] Mission Autonomy Runtime v2 validation passed."
