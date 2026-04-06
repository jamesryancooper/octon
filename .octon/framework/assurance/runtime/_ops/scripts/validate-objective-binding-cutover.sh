#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
CHARTER_FILE="$OCTON_DIR/framework/constitution/charter.yml"

FAMILY_DIR="$OCTON_DIR/framework/constitution/contracts/objective"
RUNTIME_FAMILY_DIR="$OCTON_DIR/framework/constitution/contracts/runtime"
FAMILY_FILE="$FAMILY_DIR/family.yml"
WORKSPACE_FILE="$FAMILY_DIR/workspace-charter-pair.yml"
WORKSPACE_SCHEMA="$FAMILY_DIR/workspace-charter-v1.schema.json"
MISSION_SCHEMA="$FAMILY_DIR/mission-charter-v1.schema.json"
RUN_SCHEMA="$RUNTIME_FAMILY_DIR/run-contract-v3.schema.json"
STAGE_SCHEMA="$RUNTIME_FAMILY_DIR/stage-attempt-v2.schema.json"
CONTRACT_REGISTRY="$OCTON_DIR/framework/constitution/contracts/registry.yml"
WORKSPACE_BRIEF_FILE="$OCTON_DIR/instance/charter/workspace.md"
WORKSPACE_MACHINE_FILE="$OCTON_DIR/instance/charter/workspace.yml"
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
MIGRATION_PLAN="$OCTON_DIR/instance/cognition/context/shared/migrations/2026-04-06-target-state-closure-provable-closure/plan.md"

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
  if command -v rg >/dev/null 2>&1; then
    if rg -Fq "$needle" "$file"; then
      pass "$label"
    else
      fail "$label"
    fi
  else
    if grep -Fq -- "$needle" "$file"; then
      pass "$label"
    else
      fail "$label"
    fi
  fi
}

main() {
  echo "== Objective Binding Cutover Validation =="

  require_file "$FAMILY_FILE"
  require_file "$CHARTER_FILE"
  require_file "$WORKSPACE_FILE"
  require_file "$WORKSPACE_SCHEMA"
  require_file "$MISSION_SCHEMA"
  require_file "$RUN_SCHEMA"
  require_file "$STAGE_SCHEMA"
  require_file "$CONTRACT_REGISTRY"
  require_file "$WORKSPACE_BRIEF_FILE"
  require_file "$WORKSPACE_MACHINE_FILE"
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

  require_yq '.families[] | select(.family_id == "objective" and .status == "active")' "$CONTRACT_REGISTRY" "constitutional contract registry activates objective family"
  require_yq '.integration_surfaces.run_control_root.path == ".octon/state/control/execution/runs/**"' "$CONTRACT_REGISTRY" "constitutional contract registry records canonical run-control root"

  require_yq '.schema_version == "octon-constitutional-objective-family-v1"' "$FAMILY_FILE" "objective family schema version is correct"
  require_yq '.release_state == "pre-1.0"' "$FAMILY_FILE" "objective family records release_state"
  require_yq '.change_profile == "atomic"' "$FAMILY_FILE" "objective family records atomic change profile"
  local live_selector
  live_selector="$(yq -r '.live_model.profile_selection_receipt_ref' "$CHARTER_FILE")"
  if [[ "$(yq -r '.profile_selection_receipt_ref' "$FAMILY_FILE")" == "$live_selector" || "$(yq -r '.profile_selection_receipt_ref' "$FAMILY_FILE")" == ".octon/instance/cognition/context/shared/migrations/2026-04-06-target-state-closure-provable-closure/plan.md" ]]; then
    pass "objective family points to a valid live selector"
  else
    fail "objective family points to a valid live selector"
  fi
  require_yq '.activation_lineage_refs[] | select(. == ".octon/instance/cognition/context/shared/migrations/2026-03-28-unified-execution-constitution-phase2-objective-authority-cutover/plan.md")' "$FAMILY_FILE" "objective family preserves the Phase 2 receipt as lineage"
  require_yq '.activation_lineage_refs[] | select(. == ".octon/instance/cognition/context/shared/migrations/2026-04-06-target-state-closure-provable-closure/plan.md")' "$FAMILY_FILE" "objective family preserves the target-state closure receipt as lineage"
  require_yq '.objective_stack.mission_charter_pair.machine_schema_ref == ".octon/framework/constitution/contracts/objective/mission-charter-v1.schema.json"' "$FAMILY_FILE" "objective family binds mission-charter-v1"
  require_yq '.objective_stack.workspace_charter_pair.machine_schema_ref == ".octon/framework/constitution/contracts/objective/workspace-charter-v1.schema.json"' "$FAMILY_FILE" "objective family binds the workspace-charter machine schema"
  require_yq '.objective_stack.run_contract.control_root == ".octon/state/control/execution/runs"' "$FAMILY_FILE" "objective family binds the run control root"
  require_yq '.objective_stack.run_contract.schema_ref == ".octon/framework/constitution/contracts/runtime/run-contract-v3.schema.json"' "$FAMILY_FILE" "objective family binds run-contract-v3"
  require_yq '.objective_stack.stage_attempt_contract.schema_ref == ".octon/framework/constitution/contracts/runtime/stage-attempt-v2.schema.json"' "$FAMILY_FILE" "objective family binds stage-attempt-v2"
  require_yq '.objective_stack.stage_attempt_contract.canonical_dir == "stage-attempts"' "$FAMILY_FILE" "objective family defines stage-attempt placement"
  require_yq 'has("mission_only_execution") | not' "$FAMILY_FILE" "objective family no longer carries mission-only execution shims"

  require_yq '.narrative_ref == ".octon/instance/charter/workspace.md"' "$WORKSPACE_FILE" "workspace charter pair narrative ref is canonical"
  require_yq '.machine_ref == ".octon/instance/charter/workspace.yml"' "$WORKSPACE_FILE" "workspace charter pair machine ref is canonical"
  require_yq '.machine_schema_ref == ".octon/framework/constitution/contracts/objective/workspace-charter-v1.schema.json"' "$WORKSPACE_FILE" "workspace charter pair points to workspace-charter-v1"
  require_yq '.historical_shims[] | select(. == ".octon/instance/bootstrap/OBJECTIVE.md")' "$WORKSPACE_FILE" "workspace charter pair records bootstrap objective shim as historical"
  require_yq '.historical_shims[] | select(. == ".octon/instance/cognition/context/shared/intent.contract.yml")' "$WORKSPACE_FILE" "workspace charter pair records intent shim as historical"
  require_yq '.execution_binding.run_contract_control_root == ".octon/state/control/execution/runs"' "$WORKSPACE_FILE" "workspace charter pair points to the run control root"
  require_yq '.execution_binding.run_contract_schema_ref == ".octon/framework/constitution/contracts/runtime/run-contract-v3.schema.json"' "$WORKSPACE_FILE" "workspace charter pair points to run-contract-v3"
  require_yq '.execution_binding.stage_attempt_schema_ref == ".octon/framework/constitution/contracts/runtime/stage-attempt-v2.schema.json"' "$WORKSPACE_FILE" "workspace charter pair points to stage-attempt-v2"

  [[ "$(frontmatter_field "$WORKSPACE_BRIEF_FILE" "objective_layer")" == "workspace-charter-pair" ]] \
    && pass "workspace charter narrative declares workspace-charter layer" \
    || fail "workspace charter narrative must declare objective_layer: workspace-charter-pair"
  [[ "$(frontmatter_field "$WORKSPACE_BRIEF_FILE" "constitutional_role")" == "workspace-charter-narrative" ]] \
    && pass "workspace charter narrative declares narrative constitutional role" \
    || fail "workspace charter narrative must declare workspace-charter-narrative role"
  [[ "$(frontmatter_field "$WORKSPACE_BRIEF_FILE" "constitutional_objective_ref")" == ".octon/framework/constitution/contracts/objective/workspace-charter-pair.yml" ]] \
    && pass "workspace charter narrative points to workspace-charter pair contract" \
    || fail "workspace charter narrative must point to workspace-charter-pair.yml"
  [[ "$(frontmatter_field "$WORKSPACE_BRIEF_FILE" "change_profile")" == "atomic" ]] \
    && pass "workspace charter narrative records change_profile" \
    || fail "workspace charter narrative must record atomic change_profile"
  [[ "$(frontmatter_field "$WORKSPACE_BRIEF_FILE" "profile_selection_receipt_ref")" =~ ^\.octon/instance/cognition/context/shared/migrations/2026-04-(05-unified-execution-constitution-proposal-packet-implementation|06-target-state-closure-provable-closure)/plan\.md$ ]] \
    && pass "workspace charter narrative points to a valid closure migration receipt" \
    || fail "workspace charter narrative must point to a valid closure migration receipt"

  require_yq '.schema_version == "workspace-charter-v1"' "$WORKSPACE_MACHINE_FILE" "workspace charter machine uses workspace-charter-v1"
  require_yq '.workspace_charter_id == "workspace-charter://octon/octon-governed-harness"' "$WORKSPACE_MACHINE_FILE" "workspace charter machine declares a canonical workspace charter id"
  require_yq 'has("intent_id") | not' "$WORKSPACE_MACHINE_FILE" "workspace charter machine no longer uses top-level intent semantics"
  require_yq '.objective_layer == "workspace-charter-pair"' "$WORKSPACE_MACHINE_FILE" "workspace charter machine declares workspace-charter layer"
  require_yq '.constitutional_role == "workspace-charter-machine"' "$WORKSPACE_MACHINE_FILE" "workspace charter machine declares machine constitutional role"
  require_yq '.constitutional_objective_ref == ".octon/framework/constitution/contracts/objective/workspace-charter-pair.yml"' "$WORKSPACE_MACHINE_FILE" "workspace charter machine points to workspace-charter pair contract"
  require_yq '.change_profile == "atomic"' "$WORKSPACE_MACHINE_FILE" "workspace charter machine records atomic change profile"
  require_yq '.profile_selection_receipt_ref == ".octon/instance/cognition/context/shared/migrations/2026-04-05-unified-execution-constitution-proposal-packet-implementation/plan.md"' "$WORKSPACE_MACHINE_FILE" "workspace charter machine points to the bounded proposal-packet receipt"
  require_yq '.execution_binding.run_contract_control_root == ".octon/state/control/execution/runs"' "$WORKSPACE_MACHINE_FILE" "workspace charter machine binds the run control root"
  require_yq '.execution_binding.run_contract_schema_ref == ".octon/framework/constitution/contracts/runtime/run-contract-v3.schema.json"' "$WORKSPACE_MACHINE_FILE" "workspace charter machine points to run-contract-v3"
  require_yq '.execution_binding.stage_attempt_schema_ref == ".octon/framework/constitution/contracts/runtime/stage-attempt-v2.schema.json"' "$WORKSPACE_MACHINE_FILE" "workspace charter machine points to stage-attempt-v2"

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
  [[ "$(frontmatter_field "$OBJECTIVE_FILE" "shim_status")" == "compatibility-shim" ]] \
    && pass "bootstrap objective brief is marked as compatibility shim" \
    || fail "bootstrap objective brief must be marked as compatibility shim"
  [[ "$(frontmatter_field "$OBJECTIVE_FILE" "canonical_ref")" == ".octon/instance/charter/workspace.md" ]] \
    && pass "bootstrap objective brief points to canonical workspace charter" \
    || fail "bootstrap objective brief must point to canonical workspace charter"

  require_yq '.shim_status == "compatibility-shim"' "$INTENT_FILE" "intent contract is marked as compatibility shim"
  require_yq '.canonical_ref == ".octon/instance/charter/workspace.yml"' "$INTENT_FILE" "intent contract points to canonical workspace machine charter"

  require_yq '.run_control_root == ".octon/state/control/execution/runs"' "$MISSION_REGISTRY" "mission registry records canonical run control root"
  require_yq '.execution_unit == "run-contract"' "$MISSION_REGISTRY" "mission registry records run-contract execution unit"
  require_yq '.mission_role == "continuity-container"' "$MISSION_REGISTRY" "mission registry records continuity-container role"
  require_yq '.profile_selection_receipt_ref == ".octon/instance/cognition/context/shared/migrations/2026-03-28-wave6-retirement-cutover/plan.md"' "$MISSION_REGISTRY" "mission registry points to the Wave 6 receipt"
  require_yq 'has("mission_only_execution") | not' "$MISSION_REGISTRY" "mission registry no longer carries mission-only execution state"

  for file in "$MISSION_TEMPLATE" "$LIVE_MISSION"; do
    local label="${file#$ROOT_DIR/}"
  require_yq '.objective_binding.execution_unit == "run-contract"' "$file" "$label binds run-contract execution unit"
  require_yq '.objective_binding.run_control_root == ".octon/state/control/execution/runs"' "$file" "$label points to run control root"
  require_yq '.objective_binding.mission_role == "continuity-container"' "$file" "$label records continuity-container role"
  require_yq 'has("transitional_execution_model") | not' "$file" "$label no longer carries transitional execution metadata"
  done

  require_yq '.resolution.runtime_inputs.objective_contract_family == ".octon/framework/constitution/contracts/objective"' "$ROOT_MANIFEST" "root manifest exposes objective contract family runtime input"
  require_yq '.resolution.runtime_inputs.workspace_objective_brief == ".octon/instance/charter/workspace.md"' "$ROOT_MANIFEST" "root manifest exposes canonical workspace charter narrative runtime input"
  require_yq '.resolution.runtime_inputs.workspace_machine_charter == ".octon/instance/charter/workspace.yml"' "$ROOT_MANIFEST" "root manifest exposes canonical workspace charter machine runtime input"
  require_yq '.resolution.runtime_inputs | has("workspace_objective_shim") | not' "$ROOT_MANIFEST" "root manifest excludes bootstrap objective shim from live runtime inputs"
  require_yq '.resolution.runtime_inputs | has("workspace_intent_shim") | not' "$ROOT_MANIFEST" "root manifest excludes intent shim from live runtime inputs"
  require_yq '.resolution.runtime_inputs.run_control_root == ".octon/state/control/execution/runs"' "$ROOT_MANIFEST" "root manifest exposes run control root runtime input"

  require_yq '.paths.objective_contract_family == ".octon/framework/constitution/contracts/objective"' "$POLICY_CONFIG" "policy interface config exposes objective contract family"
  require_yq '.paths.workspace_objective_brief == ".octon/instance/charter/workspace.md"' "$POLICY_CONFIG" "policy interface config exposes canonical workspace charter narrative"
  require_yq '.paths.workspace_machine_charter == ".octon/instance/charter/workspace.yml"' "$POLICY_CONFIG" "policy interface config exposes canonical workspace charter machine"
  require_yq '.paths | has("workspace_objective_shim") | not' "$POLICY_CONFIG" "policy interface config excludes bootstrap objective shim from the live path"
  require_yq '.paths | has("workspace_intent_shim") | not' "$POLICY_CONFIG" "policy interface config excludes intent shim from the live path"
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
