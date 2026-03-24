#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
CARGO_MANIFEST="$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml"
HELPER_TEST="$OCTON_DIR/framework/assurance/runtime/_ops/tests/test-mission-autonomy-helpers.sh"
SEED_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh"
ROUTE_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/publish-mission-effective-route.sh"
EVALUATE_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/evaluate-mission-control-state.sh"
AUTHORIZE_UPDATE_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/apply-mission-authorize-update.sh"
MISSION_POLICY="$OCTON_DIR/instance/governance/policies/mission-autonomy.yml"
OWNERSHIP_REGISTRY="$OCTON_DIR/instance/governance/ownership/registry.yml"
MISSION_PRINCIPLE="$OCTON_DIR/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md"
POLICY_DIGEST="$OCTON_DIR/framework/engine/runtime/spec/policy-digest-v2.md"
ROOT_MANIFEST="$OCTON_DIR/octon.yml"
ACP_POLICY="$OCTON_DIR/framework/capabilities/governance/policy/deny-by-default.v2.yml"
FIXTURE_SCENARIOS_DEFAULT=1
if [[ "${CI:-}" == "true" ]]; then
  FIXTURE_SCENARIOS_DEFAULT=0
fi
INCLUDE_FIXTURE_SCENARIOS="${MISSION_AUTONOMY_INCLUDE_FIXTURE_SCENARIOS:-$FIXTURE_SCENARIOS_DEFAULT}"

assert_yq() {
  local expr="$1"
  local file="$2"
  yq -e "$expr" "$file" >/dev/null
}

assert_rg() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q -- "$pattern" "$file"
  else
    grep -Eq -- "$pattern" "$file"
  fi
}

assert_sequence() {
  local file="$1"
  shift
  local query="$1"
  shift
  local expected="$*"
  local actual
  actual="$(yq -r "$query" "$file" | paste -sd ' ' -)"
  [[ "$actual" == "$expected" ]]
}

assert_break_glass_scenario() {
  assert_rg 'break-glass is exceptional' "$MISSION_PRINCIPLE"
  assert_rg 'rollback handle or compensation handle' "$POLICY_DIGEST"
}

fixture_root() {
  mktemp -d
}

cleanup_root() {
  rm -rf "$1"
}

seed_fixture_base() {
  local root="$1"
  local mission_class="$2"
  mkdir -p \
    "$root/.octon/instance/orchestration/missions/demo" \
    "$root/.octon/instance/governance/policies" \
    "$root/.octon/instance/governance/ownership" \
    "$root/.octon/framework/capabilities/governance/policy" \
    "$root/.octon/generated/effective/orchestration/missions" \
    "$root/.octon/state/evidence/control/execution"

  cp "$ROOT_MANIFEST" "$root/.octon/octon.yml"
  cp "$MISSION_POLICY" "$root/.octon/instance/governance/policies/mission-autonomy.yml"
  cp "$OWNERSHIP_REGISTRY" "$root/.octon/instance/governance/ownership/registry.yml"
  cp "$ACP_POLICY" "$root/.octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"

  cat > "$root/.octon/instance/orchestration/missions/demo/mission.yml" <<EOF
schema_version: "octon-mission-v2"
mission_id: "demo"
title: "Demo Mission"
summary: "Fixture"
status: "active"
mission_class: "$mission_class"
owner_ref: "operator://demo-owner"
created_at: "2026-03-24"
risk_ceiling: "ACP-2"
allowed_action_classes:
  - "repo-maintenance"
default_safing_subset:
  - "observe_only"
  - "stage_only"
default_schedule_hint: "interruptible_scheduled"
default_overlap_policy: "skip"
scope_ids: []
success_criteria:
  - "done"
failure_conditions: []
notes_ref: "mission.md"
EOF

  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$SEED_SCRIPT" --mission-id demo --issued-by operator://seed-tester
}

activate_fixture_mission() {
  local root="$1"
  yq -i '.state = "active"' "$root/.octon/state/control/execution/missions/demo/lease.yml"
  yq -i '.safety_state = "active" | .updated_at = "2026-03-24T00:00:00Z" | .break_glass_expires_at = null' "$root/.octon/state/control/execution/missions/demo/mode-state.yml"
  yq -i '.pause_active_run_requested = false | .suspended_future_runs = false' "$root/.octon/state/control/execution/missions/demo/schedule.yml"
}

write_published_slice() {
  local root="$1"
  local action_class="$2"
  local reversibility="$3"
  local predicted_acp="$4"
  cat > "$root/.octon/state/control/execution/missions/demo/intent-register.yml" <<EOF
schema_version: "intent-register-v1"
mission_id: "demo"
revision: 1
generated_from:
  - "scenario-fixture"
entries:
  - slice_ref:
      id: "slice-1"
    intent_ref:
      id: "intent://fixture/demo"
      version: "1.0.0"
    action_class: "$action_class"
    target_ref:
      id: "fixture"
    rationale: "scenario fixture"
    status: "published"
    predicted_acp: "$predicted_acp"
    planned_reversibility_class: "$reversibility"
    safe_interrupt_boundary_id: "task-boundary"
    boundary_class: "task_boundary"
    expected_blast_radius: "small"
    expected_budget_impact: {}
    required_authorize_updates: []
    rollback_plan_ref: "plan://rollback"
    compensation_plan_ref: null
    finalize_policy_ref: "policy://finalize"
    earliest_start_at: "2026-03-24T00:00:00Z"
    feedback_deadline_at: "2026-03-24T00:30:00Z"
    default_on_silence: "feedback_window"
EOF
}

set_budget_state() {
  local root="$1"
  local state="$2"
  yq -i '.state = "'"$state"'"' "$root/.octon/state/control/execution/missions/demo/autonomy-budget.yml"
  yq -i '.autonomy_burn_state = "'"$state"'"' "$root/.octon/state/control/execution/missions/demo/mode-state.yml"
}

set_breaker_state() {
  local root="$1"
  local state="$2"
  yq -i '.state = "'"$state"'" | .trip_reasons = ["fixture"] | .tripped_breakers = ["fixture"]' "$root/.octon/state/control/execution/missions/demo/circuit-breakers.yml"
  yq -i '.breaker_state = "'"$state"'"' "$root/.octon/state/control/execution/missions/demo/mode-state.yml"
}

write_directives() {
  local root="$1"
  local body="$2"
  cat > "$root/.octon/state/control/execution/missions/demo/directives.yml" <<EOF
schema_version: "control-directive-v1"
mission_id: "demo"
revision: 2
directives:
$body
EOF
}

set_schedule_flags() {
  local root="$1"
  local suspended="$2"
  local pause="$3"
  yq -i '.suspended_future_runs = '"$suspended"' | .pause_active_run_requested = '"$pause"'' "$root/.octon/state/control/execution/missions/demo/schedule.yml"
}

evaluate_fixture() {
  local root="$1"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$ROUTE_SCRIPT" --mission-id demo >/dev/null
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$EVALUATE_SCRIPT" --mission-id demo
}

assert_json() {
  local json="$1"
  local expr="$2"
  jq -e "$expr" <<<"$json" >/dev/null
}

case_routine_repo_housekeeping() {
  local root
  root="$(fixture_root)"
  seed_fixture_base "$root" "maintenance"
  activate_fixture_mission "$root"
  write_published_slice "$root" "service.execute" "reversible" "ACP-1"
  local json
  json="$(evaluate_fixture "$root")"
  assert_json "$json" '.allow_new_run == true and .pause_active_run == false and .overlap_policy == "skip"'
  cleanup_root "$root"
}

case_schedule_suspension_blocks_new_runs() {
  local root
  root="$(fixture_root)"
  seed_fixture_base "$root" "maintenance"
  activate_fixture_mission "$root"
  write_published_slice "$root" "service.execute" "reversible" "ACP-1"
  set_schedule_flags "$root" true false
  local json
  json="$(evaluate_fixture "$root")"
  assert_json "$json" '.allow_new_run == false and (.reasons | index("future_runs_suspended"))'
  cleanup_root "$root"
}

case_conflicting_human_input_blocks_finalize_and_pauses() {
  local root
  root="$(fixture_root)"
  seed_fixture_base "$root" "maintenance"
  activate_fixture_mission "$root"
  write_published_slice "$root" "service.execute" "reversible" "ACP-1"
  write_directives "$root" '  - directive_id: "dir-1"
    kind: "pause_at_boundary"
    target_scope: {}
    submitted_by: "operator://demo-owner"
    precedence_source: "mission_owner"
    submitted_at: "2026-03-24T00:00:00Z"
    effective_at: "next_safe_boundary"
    status: "accepted"
    rationale: "pause"
  - directive_id: "dir-2"
    kind: "block_finalize"
    target_scope: {}
    submitted_by: "operator://demo-owner"
    precedence_source: "mission_owner"
    submitted_at: "2026-03-24T00:00:00Z"
    effective_at: "immediate"
    status: "accepted"
    rationale: "block finalize"'
  local json
  json="$(evaluate_fixture "$root")"
  assert_json "$json" '.pause_active_run == true and .block_finalize == true'
  cleanup_root "$root"
}

case_breaker_trip_enters_safing() {
  local root
  root="$(fixture_root)"
  seed_fixture_base "$root" "incident"
  activate_fixture_mission "$root"
  write_published_slice "$root" "service.execute" "reversible" "ACP-2"
  set_breaker_state "$root" "tripped"
  local json
  json="$(evaluate_fixture "$root")"
  assert_json "$json" '.allow_new_run == false and .pause_active_run == true and .safing_active == true'
  cleanup_root "$root"
}

case_proceed_on_silence_warning_budget_blocks() {
  local root
  root="$(fixture_root)"
  seed_fixture_base "$root" "reconcile"
  activate_fixture_mission "$root"
  write_published_slice "$root" "service.execute" "reversible" "ACP-1"
  set_budget_state "$root" "warning"
  local json
  json="$(evaluate_fixture "$root")"
  assert_json "$json" '.allow_new_run == false and (.reasons | index("proceed_on_silence_blocked"))'
  cleanup_root "$root"
}

case_destructive_route_requires_operator_ack() {
  local root
  root="$(fixture_root)"
  seed_fixture_base "$root" "destructive"
  activate_fixture_mission "$root"
  write_published_slice "$root" "fs.hard_delete" "irreversible" "ACP-4"
  local json
  json="$(evaluate_fixture "$root")"
  assert_json "$json" '.required_operator_ack == true and .allow_new_run == false'
  cleanup_root "$root"
}

case_break_glass_authorize_update_changes_mode_and_emits_receipt() {
  local root
  root="$(fixture_root)"
  seed_fixture_base "$root" "destructive"
  activate_fixture_mission "$root"
  write_published_slice "$root" "fs.hard_delete" "irreversible" "ACP-4"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$AUTHORIZE_UPDATE_SCRIPT" \
    --mission-id demo \
    --authorize-update-id auth-break-glass \
    --issued-by operator://demo-owner \
    --kind break_glass_activate
  local json
  json="$(evaluate_fixture "$root")"
  assert_json "$json" '.break_glass_active == true'
  grep -R "auth-break-glass" "$root/.octon/state/evidence/control/execution" >/dev/null
  cleanup_root "$root"
}

run_case() {
  local label="$1"
  shift
  echo "==> $label"
  "$@"
}

run_case \
  "authorization denies autonomous execution without mission context" \
  cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel autonomous_request_requires_mission_context

run_case \
  "authorization accepts seeded autonomous mission context" \
  cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel autonomous_request_allows_seeded_mission_context

run_case \
  "approval-required autonomous execution stages without approval" \
  cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel approval_required_autonomous_request_returns_stage_only_without_human_approval

run_case \
  "proceed-on-silence blocks when autonomy budget is unhealthy" \
  cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel proceed_on_silence_blocks_when_autonomy_budget_not_healthy

run_case \
  "pipeline mission-scoped workflow bundle contract" \
  cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel mock_generic_workflow_materializes_workflow_bundle_contract

run_case \
  "pipeline prepare-only mission-scoped workflow bundle contract" \
  cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel prepare_only_generic_workflow_still_writes_bundle_contract_files

run_case \
  "pipeline mission-scoped workflow writes execution artifacts" \
  cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel mock_generic_workflow_writes_execution_artifacts

if [[ "${MISSION_AUTONOMY_INCLUDE_HELPER_SMOKE:-0}" == "1" ]]; then
  run_case \
    "mission autonomy helper scripts seed state and emit control receipts" \
    bash "$HELPER_TEST"
fi

if [[ "$INCLUDE_FIXTURE_SCENARIOS" == "1" ]]; then
  run_case \
    "scenario fixture: routine repo housekeeping" \
    case_routine_repo_housekeeping

  run_case \
    "scenario fixture: future-run suspension blocks new runs" \
    case_schedule_suspension_blocks_new_runs

  run_case \
    "scenario fixture: conflicting human input pauses and blocks finalize" \
    case_conflicting_human_input_blocks_finalize_and_pauses

  run_case \
    "scenario fixture: breaker trip enters safing" \
    case_breaker_trip_enters_safing

  run_case \
    "scenario fixture: proceed-on-silence blocks on warning budget" \
    case_proceed_on_silence_warning_budget_blocks

  run_case \
    "scenario fixture: destructive work requires operator acknowledgement" \
    case_destructive_route_requires_operator_ack

  run_case \
    "scenario fixture: break-glass authorize-update mutates mode and emits receipt" \
    case_break_glass_authorize_update_changes_mode_and_emits_receipt
fi

run_case \
  "scenario policy: routine repo housekeeping defaults declared" \
  assert_yq '.mode_defaults.maintenance == "notify" and .execution_postures.maintenance == "interruptible_scheduled" and .overlap_defaults.maintenance == "skip" and .backfill_defaults.maintenance == "latest_only"' "$MISSION_POLICY"

run_case \
  "scenario: long-running refactor" \
  assert_yq '.mode_defaults.campaign == "feedback_window" and .execution_postures.campaign == "continuous" and .digest_cadence_defaults.campaign.cadence == "PT12H"' "$MISSION_POLICY"

run_case \
  "scenario: scheduled dependency patching" \
  assert_yq '.digest_cadence_defaults.maintenance.route == "preview_plus_closure_digest" and .preview_defaults.interval_gte_1h_lt_24h.preview_lead_floor == "PT15M"' "$MISSION_POLICY"

run_case \
  "scenario: release maintenance" \
  assert_yq '.mode_defaults.destructive == "approval_required" and .execution_postures.destructive == "one_shot"' "$MISSION_POLICY"

run_case \
  "scenario: infra drift correction" \
  assert_yq '.mode_defaults.reconcile == "proceed_on_silence" and .safe_interrupt_boundaries.infra_drift == "rollout_boundary" and .overlap_defaults.reconcile == "queue_latest"' "$MISSION_POLICY"

run_case \
  "scenario: cost cleanup or soft delete" \
  assert_yq '.recovery_windows.soft_destructive_archive == "P14D" and .safe_interrupt_boundaries.destructive == "stage_boundary"' "$MISSION_POLICY"

run_case \
  "scenario: data migration or backfill" \
  assert_yq '.mode_defaults.migration == "feedback_window" and .safe_interrupt_boundaries.migration == "checkpoint_boundary" and .recovery_windows.migration_chunk == "PT72H"' "$MISSION_POLICY"

run_case \
  "scenario: external API sync" \
  assert_yq '.safe_interrupt_boundaries.external_sync == "batch_boundary" and .recovery_windows.compensable_external_sync == "PT24H"' "$MISSION_POLICY"

run_case \
  "scenario: monitoring or guard missions" \
  assert_yq '.digest_cadence_defaults.observe.route == "digest_plus_threshold_alert" and .execution_postures.observe == "continuous" and .safe_interrupt_boundaries.monitoring == "immediate"' "$MISSION_POLICY"

run_case \
  "scenario: production incident response" \
  assert_yq '.digest_cadence_defaults.incident.route == "immediate_alert" and .execution_postures.incident == "continuous" and .safing_defaults.incident_subset[] == "bounded_containment"' "$MISSION_POLICY"

run_case \
  "scenario: high-volume low-risk repetitive work" \
  assert_yq '.mode_defaults.reconcile == "proceed_on_silence" and .autonomy_burn.states[] == "healthy"' "$MISSION_POLICY"

run_case \
  "scenario: destructive high-impact work" \
  assert_yq '.mode_defaults.destructive == "approval_required" and .digest_cadence_defaults.destructive.cadence == "no_batching"' "$MISSION_POLICY"

run_case \
  "scenario: absent operator behavior" \
  assert_yq '.proceed_on_silence.denied_burn_states[] == "warning" and .proceed_on_silence.denied_burn_states[] == "exhausted"' "$MISSION_POLICY"

run_case \
  "scenario: late feedback" \
  assert_rg 'after promote inside recovery window: rollback or compensate' "$MISSION_PRINCIPLE"

run_case \
  "scenario: conflicting human input" \
  assert_sequence "$OWNERSHIP_REGISTRY" '.directive_precedence[]' break_glass_or_kill_switch mission_owner ownership_registry codeowners subscribers

run_case \
  "scenario: rollback-path failure" \
  assert_yq '.pause_on_failure.default_triggers[] == "rollback_path_failure" and .autonomy_burn.exhausted_thresholds.rollback_path_failures == 1' "$MISSION_POLICY"

run_case \
  "scenario: breaker trip and safing entry" \
  assert_yq '.circuit_breakers.actions[] == "enter_safing" and .circuit_breakers.actions[] == "force_stage_only"' "$MISSION_POLICY"

run_case \
  "scenario: break-glass activation" \
  assert_break_glass_scenario
