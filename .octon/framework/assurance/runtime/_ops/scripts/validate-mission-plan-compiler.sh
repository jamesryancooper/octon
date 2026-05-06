#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
FIXTURE_DIR=""

usage() {
  cat <<'EOF'
Usage: validate-mission-plan-compiler.sh [--root <repo-root>] [--fixture-dir <dir>]

Validates Mission Plan Compiler v1 placement, schemas, workflow, policy, docs,
and boundary negative controls.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      OCTON_DIR="${OCTON_DIR_OVERRIDE:-$ROOT_DIR/.octon}"
      shift 2
      ;;
    --fixture-dir)
      FIXTURE_DIR="$2"
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

require_tool() {
  command -v "$1" >/dev/null 2>&1 && pass "$1 is available" || fail "$1 is required"
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] && pass "found $(rel "$file")" || fail "missing $(rel "$file")"
}

require_json_schema() {
  local file="$1"
  local label="$2"
  require_file "$file"
  [[ -f "$file" ]] || return 0
  jq -e 'type == "object" and has("$schema") and has("$id") and has("title") and (has("type") or has("allOf") or has("oneOf") or has("anyOf"))' "$file" >/dev/null 2>&1 \
    && pass "$label carries JSON Schema metadata" \
    || fail "$label must carry JSON Schema metadata"
}

require_yaml() {
  local file="$1"
  local label="$2"
  require_file "$file"
  [[ -f "$file" ]] || return 0
  yq -e '.' "$file" >/dev/null 2>&1 && pass "$label parses as YAML" || fail "$label must parse as YAML"
}

require_jq() {
  local file="$1"
  local expr="$2"
  local label="$3"
  jq -e "$expr" "$file" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

require_yq() {
  local file="$1"
  local expr="$2"
  local label="$3"
  yq -e "$expr" "$file" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

require_text() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$file" && pass "$label" || fail "$label"
  else
    grep -Eq "$pattern" "$file" && pass "$label" || fail "$label"
  fi
}

schema_path() {
  printf '%s/framework/engine/runtime/spec/%s\n' "$OCTON_DIR" "$1"
}

check_static_surfaces() {
  echo "== Mission Plan Compiler Static Surface Validation =="
  require_tool jq
  require_tool yq

  require_file "$OCTON_DIR/framework/engine/runtime/spec/mission-plan-v1.md"
  for schema in \
    mission-plan-v1.schema.json \
    plan-node-v1.schema.json \
    plan-dependency-edge-v1.schema.json \
    plan-revision-record-v1.schema.json \
    plan-compile-receipt-v1.schema.json \
    plan-drift-record-v1.schema.json; do
    require_json_schema "$(schema_path "$schema")" "$schema"
  done

  require_jq "$(schema_path mission-plan-v1.schema.json)" '.properties.authority_boundary.properties.mission_plan_authorizes_execution.const == false' "MissionPlan cannot authorize execution"
  require_jq "$(schema_path plan-node-v1.schema.json)" '.properties.execution_boundary.properties.direct_execution_allowed.const == false' "PlanNode direct execution is denied by schema"
  require_jq "$(schema_path plan-node-v1.schema.json)" '.properties.execution_boundary.properties.run_contract_required.const == true and .properties.execution_boundary.properties.context_pack_required.const == true and .properties.execution_boundary.properties.execution_authorization_required.const == true' "PlanNode schema requires run, context, and authorization boundaries"
  require_jq "$(schema_path plan-compile-receipt-v1.schema.json)" '.properties.authority_boundary.properties.compile_receipt_authorizes_execution.const == false and .properties.authority_boundary.properties.authorization_request_is_grant.const == false' "compile receipts do not authorize execution"

  require_yaml "$OCTON_DIR/instance/governance/policies/hierarchical-planning.yml" "hierarchical planning policy"
  require_yq "$OCTON_DIR/instance/governance/policies/hierarchical-planning.yml" '.schema_version == "hierarchical-planning-policy-v1"' "hierarchical planning policy schema_version valid"
  require_yq "$OCTON_DIR/instance/governance/policies/hierarchical-planning.yml" '.enablement_mode == "stage-only" or .enablement_mode == "disabled"' "hierarchical planning defaults to disabled or stage-only"
  require_yq "$OCTON_DIR/instance/governance/policies/hierarchical-planning.yml" '.authority_boundary.plan_node_direct_execution_allowed == false and .authority_boundary.run_contract_required == true and .authority_boundary.execution_authorization_required == true' "hierarchical planning policy preserves execution boundary"

  require_yq "$OCTON_DIR/framework/constitution/contracts/registry.yml" '.integration_surfaces.mission_plan_compiler_layer_contracts.rule | test("do not authorize execution")' "constitutional registry declares non-authorizing planning layer"
  require_yq "$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml" '.path_families.mission_plan_compiler_layer.forbidden_consumers[] | select(. == "execution authorization replacement")' "architecture registry forbids authorization replacement"
  require_yq "$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml" '.path_families.mission_plan_compiler_layer.canonical_paths[] | select(. == ".octon/generated/cognition/projections/materialized/planning/**")' "architecture registry declares generated planning projections as derived paths"
}

check_workflow() {
  echo "== Mission Plan Compiler Workflow Validation =="
  local workflow="$OCTON_DIR/framework/orchestration/runtime/workflows/missions/derive-mission-plan/workflow.yml"
  require_yaml "$workflow" "derive-mission-plan workflow"
  require_yq "$workflow" '.schema_version == "workflow-contract-v2" and .name == "derive-mission-plan"' "derive-mission-plan workflow contract identity valid"
  require_yq "$workflow" '.constraints.fail_closed == true and .constraints.planning_authorizes_execution == false' "derive-mission-plan workflow is fail-closed and non-authorizing"
  require_yq "$workflow" '.stages | length == 5' "derive-mission-plan workflow has five stages"
  for stage in \
    01-bind-mission.md \
    02-draft-plan.md \
    03-critic-and-readiness.md \
    04-compile-leaves.md \
    05-update-from-evidence.md; do
    require_file "$OCTON_DIR/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/$stage"
  done
  require_text "$OCTON_DIR/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/04-compile-leaves.md" "authorize_execution" "compile stage preserves authorization boundary"
  require_text "$OCTON_DIR/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/05-update-from-evidence.md" "Run Journal" "evidence update stage preserves Run Journal truth"
}

check_docs() {
  echo "== Mission Plan Compiler Documentation Boundary Validation =="
  require_text "$OCTON_DIR/framework/orchestration/runtime/missions/README.md" "Mission Plan Compiler" "missions docs mention Mission Plan Compiler boundary"
  require_text "$OCTON_DIR/framework/orchestration/runtime/runs/README.md" "planning" "runs docs mention planning linkage boundary"
  require_text "$OCTON_DIR/framework/engine/runtime/spec/context-pack-builder-v1.md" "planning refs" "context pack builder docs preserve planning source classes"
  require_text "$OCTON_DIR/framework/engine/runtime/spec/execution-authorization-v1.md" "Plan leaves" "execution authorization docs deny planning grants"
  require_text "$OCTON_DIR/framework/engine/runtime/spec/evidence-store-v1.md" "planning evidence" "evidence store docs separate planning evidence"
  require_text "$OCTON_DIR/framework/engine/runtime/spec/run-lifecycle-v1.md" "planning" "run lifecycle docs preserve planning non-authority"
}

write_valid_fixtures() {
  local dir="$1"
  mkdir -p "$dir"
  local digest="sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  cat > "$dir/mission-plan.json" <<EOF
{"schema_version":"mission-plan-v1","plan_id":"plan-demo","mission_id":"mission-demo","mission_ref":".octon/instance/orchestration/missions/mission-demo/mission.yml","mission_digest":"$digest","workspace_charter_ref":".octon/instance/charter/workspace.yml","owner_ref":"operator://octon-maintainers","status":"mission-bound","risk_ceiling":"ACP-2","allowed_action_classes":["repo.change"],"support_target_tuple_refs":["support-target://repo-shell/local-readwrite"],"scope_ids":["octon"],"success_criteria_refs":["mission-success"],"failure_condition_refs":["mission-failure"],"planning_budget":{"max_children_per_node":7,"max_open_decompositions_per_branch":3,"max_initial_executable_leaves":20,"max_revisions_without_execution_evidence":2},"decomposition_depth_budget":4,"rolling_wave_window":{"mode":"near-term","near_term_only":true,"window_description":"near-term blocking work only"},"index_refs":{},"compiled_run_refs":[],"evidence_root_ref":".octon/state/evidence/control/execution/planning/plan-demo","authority_boundary":{"mission_plan_authorizes_execution":false,"run_contract_required":true,"context_pack_required_before_authorization":true,"execution_authorization_required":true,"generated_views_authoritative":false},"created_at":"2026-05-06T00:00:00Z","updated_at":"2026-05-06T00:00:00Z"}
EOF
  cat > "$dir/plan-node.json" <<'EOF'
{"schema_version":"plan-node-v1","node_id":"node-demo","plan_id":"plan-demo","parent_node_id":null,"node_type":"action_slice_candidate","title":"Demo leaf","purpose":"Compile a checked leaf","scope":["octon"],"non_scope":["external effects"],"expected_output":"action-slice candidate","acceptance_criteria":["candidate is bounded"],"validation_method":"validator","evidence_requirements":[".octon/state/evidence/control/execution/planning/plan-demo/checks/demo.yml"],"dependencies":[],"risks":["low"],"assumptions":[],"decision_points":[],"predicted_acp":"ACP-1","reversibility":"reversible","approval_requirement":{"required":false,"approval_ref":null,"blocking_before_compile":false},"support_target_tuple_refs":["support-target://repo-shell/local-readwrite"],"readiness_state":"ready","decomposition_status":"stopped","compiled_artifact_refs":{"action_slice_candidate_ref":".octon/state/control/execution/missions/mission-demo/action-slices/demo.yml","compile_receipt_ref":".octon/state/evidence/control/execution/planning/plan-demo/compile/demo.yml"},"execution_boundary":{"direct_execution_allowed":false,"compiles_to_action_slice_candidate_only":true,"run_contract_required":true,"context_pack_required":true,"execution_authorization_required":true}}
EOF
  cat > "$dir/plan-dependency-edge.json" <<'EOF'
{"schema_version":"plan-dependency-edge-v1","edge_id":"edge-demo","plan_id":"plan-demo","source_node_id":"node-a","target_node_id":"node-b","edge_type":"depends_on","rationale":"node b needs node a evidence","status":"open","evidence_ref":".octon/state/evidence/control/execution/planning/plan-demo/checks/dependency.yml"}
EOF
  cat > "$dir/plan-revision-record.json" <<EOF
{"schema_version":"plan-revision-record-v1","revision_id":"revision-demo","plan_id":"plan-demo","previous_plan_digest":"$digest","new_plan_digest":"$digest","reason":"retained evidence update","evidence_refs":[".octon/state/evidence/runs/run-demo/events.snapshot.ndjson"],"validation_outcome":"pass","actor_ref":"orchestrator://default","created_at":"2026-05-06T00:00:00Z"}
EOF
  cat > "$dir/plan-compile-receipt.json" <<EOF
{"schema_version":"plan-compile-receipt-v1","receipt_id":"compile-demo","plan_id":"plan-demo","node_id":"node-demo","source_plan_digest":"$digest","mission_digest":"$digest","action_slice_candidate_ref":".octon/state/control/execution/missions/mission-demo/action-slices/demo.yml","context_pack_request_ref":".octon/state/control/execution/missions/mission-demo/plans/plan-demo/context-pack-request.yml","authorization_request_ref":".octon/state/control/execution/missions/mission-demo/plans/plan-demo/authorization-request.yml","evidence_requirements":[".octon/state/evidence/runs/run-demo/**"],"rollback_or_compensation_ref":".octon/state/control/execution/runs/run-demo/rollback-posture.yml","validation_result":"pass","compiler_version":"mission-plan-compiler-v1","authority_boundary":{"compile_receipt_authorizes_execution":false,"authorization_request_is_grant":false,"run_contract_required":true,"context_pack_required":true,"execution_authorization_required":true},"created_at":"2026-05-06T00:00:00Z"}
EOF
  cat > "$dir/plan-drift-record.json" <<EOF
{"schema_version":"plan-drift-record-v1","drift_id":"drift-demo","plan_id":"plan-demo","detected_at":"2026-05-06T00:00:00Z","source_ref":".octon/instance/orchestration/missions/mission-demo/mission.yml","drift_type":"mission_digest","previous_digest":"$digest","current_digest":"$digest","impact":"no current drift","disposition":"closed","evidence_refs":[".octon/state/evidence/control/execution/planning/plan-demo/drift/demo.yml"]}
EOF
}

check_fixture_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || {
    fail "fixture directory exists: $dir"
    return 0
  }
  echo "== Mission Plan Compiler Fixture Validation =="
  if [[ -f "$dir/mission-plan.json" ]]; then
    require_jq "$dir/mission-plan.json" '.schema_version == "mission-plan-v1" and .authority_boundary.mission_plan_authorizes_execution == false and .authority_boundary.run_contract_required == true and .authority_boundary.execution_authorization_required == true' "MissionPlan fixture preserves non-authority boundary"
  fi
  if [[ -f "$dir/plan-node.json" ]]; then
    require_jq "$dir/plan-node.json" '.schema_version == "plan-node-v1" and .execution_boundary.direct_execution_allowed == false and .execution_boundary.compiles_to_action_slice_candidate_only == true and .execution_boundary.run_contract_required == true and .execution_boundary.context_pack_required == true and .execution_boundary.execution_authorization_required == true' "PlanNode fixture blocks direct execution and non-bypass"
  fi
  if [[ -f "$dir/plan-dependency-edge.json" ]]; then
    require_jq "$dir/plan-dependency-edge.json" '.schema_version == "plan-dependency-edge-v1" and .source_node_id != .target_node_id' "DependencyEdge fixture separates dependency endpoints"
  fi
  if [[ -f "$dir/plan-revision-record.json" ]]; then
    require_jq "$dir/plan-revision-record.json" '.schema_version == "plan-revision-record-v1" and (.evidence_refs | length >= 1)' "PlanRevisionRecord fixture retains evidence refs"
  fi
  if [[ -f "$dir/plan-compile-receipt.json" ]]; then
    require_jq "$dir/plan-compile-receipt.json" '.schema_version == "plan-compile-receipt-v1" and .authority_boundary.compile_receipt_authorizes_execution == false and .authority_boundary.authorization_request_is_grant == false and (.evidence_requirements | length >= 1)' "PlanCompileReceipt fixture is evidence, not authority"
  fi
  if [[ -f "$dir/plan-drift-record.json" ]]; then
    require_jq "$dir/plan-drift-record.json" '.schema_version == "plan-drift-record-v1" and (.evidence_refs | length >= 1)' "PlanDriftRecord fixture retains drift evidence"
  fi
}

check_generated_fixture_validation() {
  tmp="$(mktemp -d)"
  trap 'rm -r -f "$tmp"' EXIT
  write_valid_fixtures "$tmp"
  check_fixture_dir "$tmp"
}

check_negative_controls() {
  echo "== Mission Plan Compiler Negative-Control Validation =="
  [[ ! -d "$OCTON_DIR/state/control/plans" ]] \
    && pass "no rival state/control/plans control plane" \
    || fail "planning control may exist only under state/control/execution/missions/<mission-id>/plans"
  [[ ! -d "$OCTON_DIR/state/evidence/plans" ]] \
    && pass "no unregistered state/evidence/plans evidence family" \
    || fail "planning evidence uses state/evidence/control/execution/planning"
}

check_static_surfaces
check_workflow
check_docs
check_generated_fixture_validation
if [[ -n "$FIXTURE_DIR" ]]; then
  check_fixture_dir "$FIXTURE_DIR"
fi
check_negative_controls

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
