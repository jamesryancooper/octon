#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

FAMILY_DIR="$OCTON_DIR/framework/constitution/contracts/objective"
FAMILY_FILE="$FAMILY_DIR/family.yml"
WORKSPACE_FILE="$FAMILY_DIR/workspace-charter-pair.yml"
RUN_SCHEMA="$FAMILY_DIR/run-contract-v1.schema.json"
STAGE_SCHEMA="$FAMILY_DIR/stage-attempt-v1.schema.json"
CONTRACT_REGISTRY="$OCTON_DIR/framework/constitution/contracts/registry.yml"
OBJECTIVE_FILE="$OCTON_DIR/instance/bootstrap/OBJECTIVE.md"
INTENT_FILE="$OCTON_DIR/instance/cognition/context/shared/intent.contract.yml"
MISSION_REGISTRY="$OCTON_DIR/instance/orchestration/missions/registry.yml"
MISSION_TEMPLATE="$OCTON_DIR/instance/orchestration/missions/_scaffold/template/mission.yml"
LIVE_MISSION="$OCTON_DIR/instance/orchestration/missions/mission-autonomy-live-validation/mission.yml"
RUN_CONTROL_ROOT="$OCTON_DIR/state/control/execution/runs"
RUN_CONTROL_README="$RUN_CONTROL_ROOT/README.md"
RUN_PROJECTION_README="$OCTON_DIR/framework/orchestration/runtime/runs/README.md"
RUN_LINKAGE_GUIDE="$OCTON_DIR/framework/orchestration/practices/run-linkage-standards.md"
WRITE_RUN_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/write-run.sh"
ROOT_MANIFEST="$OCTON_DIR/octon.yml"
POLICY_CONFIG="$OCTON_DIR/framework/engine/runtime/config/policy-interface.yml"
MIGRATION_PLAN="$OCTON_DIR/instance/cognition/context/shared/migrations/2026-03-26-objective-binding-cutover/plan.md"

errors=0

fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

frontmatter_field() {
  local file_path="$1"
  local key="$2"
  awk -v key="$key" '
    NR == 1 && $0 == "---" {in_frontmatter=1; next}
    in_frontmatter && $0 == "---" {exit}
    in_frontmatter && $0 ~ "^[[:space:]]*" key ":[[:space:]]*" {
      line=$0
      sub("^[[:space:]]*" key ":[[:space:]]*", "", line)
      sub(/[[:space:]]+#.*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      print line
      exit
    }
  ' "$file_path"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

require_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
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

require_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if rg -Fq "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  echo "== Objective Binding Cutover Validation =="

  require_file "$FAMILY_FILE"
  require_file "$WORKSPACE_FILE"
  require_file "$RUN_SCHEMA"
  require_file "$STAGE_SCHEMA"
  require_file "$CONTRACT_REGISTRY"
  require_file "$OBJECTIVE_FILE"
  require_file "$INTENT_FILE"
  require_file "$MISSION_REGISTRY"
  require_file "$MISSION_TEMPLATE"
  require_file "$LIVE_MISSION"
  require_dir "$RUN_CONTROL_ROOT"
  require_file "$RUN_CONTROL_README"
  require_file "$RUN_PROJECTION_README"
  require_file "$RUN_LINKAGE_GUIDE"
  require_file "$WRITE_RUN_SCRIPT"
  require_file "$ROOT_MANIFEST"
  require_file "$POLICY_CONFIG"
  require_file "$MIGRATION_PLAN"

  require_yq '.families[] | select(.family_id == "objective" and .status == "active-transitional")' "$CONTRACT_REGISTRY" "constitutional contract registry activates objective family as transitional"
  require_yq '.integration_surfaces.run_control_root.path == ".octon/state/control/execution/runs/**"' "$CONTRACT_REGISTRY" "constitutional contract registry records canonical run-control root"

  require_yq '.schema_version == "octon-constitutional-objective-family-v1"' "$FAMILY_FILE" "objective family schema version is correct"
  require_yq '.release_state == "pre-1.0"' "$FAMILY_FILE" "objective family records release_state"
  require_yq '.change_profile == "transitional"' "$FAMILY_FILE" "objective family records transitional change profile"
  require_yq '.profile_selection_receipt_ref == ".octon/instance/cognition/context/shared/migrations/2026-03-26-objective-binding-cutover/plan.md"' "$FAMILY_FILE" "objective family points to the profile selection receipt"
  require_yq '.objective_stack.run_contract.control_root == ".octon/state/control/execution/runs"' "$FAMILY_FILE" "objective family binds the run control root"
  require_yq '.objective_stack.stage_attempt_contract.canonical_dir == "stage-attempts"' "$FAMILY_FILE" "objective family defines stage-attempt placement"
  require_yq '.mission_only_execution.status == "transitional"' "$FAMILY_FILE" "objective family marks mission-only execution as transitional"

  require_yq '.narrative_ref == ".octon/instance/bootstrap/OBJECTIVE.md"' "$WORKSPACE_FILE" "workspace charter pair narrative ref is canonical"
  require_yq '.machine_ref == ".octon/instance/cognition/context/shared/intent.contract.yml"' "$WORKSPACE_FILE" "workspace charter pair machine ref is canonical"
  require_yq '.execution_binding.run_contract_control_root == ".octon/state/control/execution/runs"' "$WORKSPACE_FILE" "workspace charter pair points to the run control root"

  [[ "$(frontmatter_field "$OBJECTIVE_FILE" "objective_layer")" == "workspace-charter-pair" ]] \
    && pass "objective brief declares workspace-charter layer" \
    || fail "objective brief must declare objective_layer: workspace-charter-pair"
  [[ "$(frontmatter_field "$OBJECTIVE_FILE" "constitutional_role")" == "workspace-charter-narrative" ]] \
    && pass "objective brief declares narrative constitutional role" \
    || fail "objective brief must declare workspace-charter-narrative role"
  [[ "$(frontmatter_field "$OBJECTIVE_FILE" "constitutional_objective_ref")" == ".octon/framework/constitution/contracts/objective/workspace-charter-pair.yml" ]] \
    && pass "objective brief points to workspace-charter pair contract" \
    || fail "objective brief must point to workspace-charter-pair.yml"
  [[ "$(frontmatter_field "$OBJECTIVE_FILE" "release_state")" == "pre-1.0" ]] \
    && pass "objective brief records release_state" \
    || fail "objective brief must record release_state"
  [[ "$(frontmatter_field "$OBJECTIVE_FILE" "change_profile")" == "transitional" ]] \
    && pass "objective brief records change_profile" \
    || fail "objective brief must record change_profile"

  require_yq '.objective_layer == "workspace-charter-pair"' "$INTENT_FILE" "intent contract declares workspace-charter layer"
  require_yq '.constitutional_role == "workspace-charter-machine"' "$INTENT_FILE" "intent contract declares machine constitutional role"
  require_yq '.constitutional_objective_ref == ".octon/framework/constitution/contracts/objective/workspace-charter-pair.yml"' "$INTENT_FILE" "intent contract points to workspace-charter pair contract"
  require_yq '.release_state == "pre-1.0"' "$INTENT_FILE" "intent contract records release_state"
  require_yq '.change_profile == "transitional"' "$INTENT_FILE" "intent contract records change_profile"
  require_yq '.execution_binding.run_contract_control_root == ".octon/state/control/execution/runs"' "$INTENT_FILE" "intent contract binds the run control root"
  require_yq '.execution_binding.mission_authority_root == ".octon/instance/orchestration/missions"' "$INTENT_FILE" "intent contract binds mission authority root"
  require_yq '.execution_binding.silent_missionless_fallback == "deny"' "$INTENT_FILE" "intent contract denies silent mission-less fallback"

  require_yq '.run_control_root == ".octon/state/control/execution/runs"' "$MISSION_REGISTRY" "mission registry records canonical run control root"
  require_yq '.execution_unit == "run-contract"' "$MISSION_REGISTRY" "mission registry records run-contract execution unit"
  require_yq '.mission_role == "continuity-container"' "$MISSION_REGISTRY" "mission registry records continuity-container role"
  require_yq '.mission_only_execution == "transitional"' "$MISSION_REGISTRY" "mission registry records transitional mission-only execution"

  for file in "$MISSION_TEMPLATE" "$LIVE_MISSION"; do
    local label="${file#$ROOT_DIR/}"
    require_yq '.objective_binding.execution_unit == "run-contract"' "$file" "$label binds run-contract execution unit"
    require_yq '.objective_binding.run_control_root == ".octon/state/control/execution/runs"' "$file" "$label points to run control root"
    require_yq '.objective_binding.mission_role == "continuity-container"' "$file" "$label records continuity-container role"
    require_yq '.transitional_execution_model.mission_only_execution == "transitional"' "$file" "$label records transitional mission-only execution"
    require_yq '.transitional_execution_model.retirement_gate != ""' "$file" "$label records retirement gate"
  done

  require_yq '.resolution.runtime_inputs.objective_contract_family == ".octon/framework/constitution/contracts/objective"' "$ROOT_MANIFEST" "root manifest exposes objective contract family runtime input"
  require_yq '.resolution.runtime_inputs.workspace_objective_brief == ".octon/instance/bootstrap/OBJECTIVE.md"' "$ROOT_MANIFEST" "root manifest exposes workspace objective brief runtime input"
  require_yq '.resolution.runtime_inputs.workspace_intent_contract == ".octon/instance/cognition/context/shared/intent.contract.yml"' "$ROOT_MANIFEST" "root manifest exposes workspace intent contract runtime input"
  require_yq '.resolution.runtime_inputs.run_control_root == ".octon/state/control/execution/runs"' "$ROOT_MANIFEST" "root manifest exposes run control root runtime input"

  require_yq '.paths.objective_contract_family == ".octon/framework/constitution/contracts/objective"' "$POLICY_CONFIG" "policy interface config exposes objective contract family"
  require_yq '.paths.workspace_objective_brief == ".octon/instance/bootstrap/OBJECTIVE.md"' "$POLICY_CONFIG" "policy interface config exposes workspace objective brief"
  require_yq '.paths.workspace_intent_contract == ".octon/instance/cognition/context/shared/intent.contract.yml"' "$POLICY_CONFIG" "policy interface config exposes workspace intent contract"
  require_yq '.paths.run_control_root == ".octon/state/control/execution/runs"' "$POLICY_CONFIG" "policy interface config exposes run control root"

  require_text "run-contract.yml" "$RUN_CONTROL_README" "run control README documents run-contract.yml"
  require_text "stage-attempts/" "$RUN_CONTROL_README" "run control README documents stage-attempts placement"
  require_text "orchestration-facing projection" "$RUN_PROJECTION_README" "run projection README demotes framework runs to projection status"
  require_text "state/control/execution/runs/<run-id>/run-contract.yml" "$RUN_PROJECTION_README" "run projection README references canonical run contract"
  require_text "run_contract_path" "$RUN_LINKAGE_GUIDE" "run linkage guide requires run_contract_path linkage"
  require_text "run-contract.yml" "$WRITE_RUN_SCRIPT" "write-run script seeds canonical run-contract roots"
  require_text ".octon/framework/constitution/contracts/objective/" "$OCTON_DIR/README.md" "super-root README references constitutional objective family"
  require_text ".octon/state/control/execution/runs/<run-id>/run-contract.yml" "$OCTON_DIR/instance/bootstrap/START.md" "bootstrap START references canonical run-contract path"
  require_text "continuity container" "$OCTON_DIR/instance/orchestration/missions/README.md" "mission README describes mission as continuity container"
  require_text ".octon/state/control/execution/runs" "$OCTON_DIR/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md" "mission-scoped autonomy principle references run control root"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
