#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
CARGO_MANIFEST="$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml"
HELPER_TEST="$OCTON_DIR/framework/assurance/runtime/_ops/tests/test-mission-autonomy-helpers.sh"
MISSION_POLICY="$OCTON_DIR/instance/governance/policies/mission-autonomy.yml"
OWNERSHIP_REGISTRY="$OCTON_DIR/instance/governance/ownership/registry.yml"
MISSION_PRINCIPLE="$OCTON_DIR/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md"
POLICY_DIGEST="$OCTON_DIR/framework/engine/runtime/spec/policy-digest-v2.md"

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

run_case \
  "mission autonomy helper scripts seed state and emit control receipts" \
  bash "$HELPER_TEST"

run_case \
  "scenario: routine repo housekeeping" \
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
