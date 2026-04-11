#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT_WRITER="$SCRIPT_DIR/write-mission-control-receipt.sh"
ROUTE_PUBLISHER="$SCRIPT_DIR/publish-mission-effective-route.sh"
SYNC_RUNTIME_ARTIFACTS="$OCTON_DIR/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh"

MISSION_ID=""
ISSUED_BY=""

usage() {
  cat <<'USAGE'
Usage:
  seed-mission-autonomy-state.sh --mission-id <id> [--issued-by <ref>]
USAGE
}

read_array_yaml() {
  local file="$1"
  local query="$2"
  yq -r "$query[]?" "$file" 2>/dev/null || true
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mission-id) MISSION_ID="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$MISSION_ID" ]] || { echo "--mission-id is required" >&2; exit 1; }

  local mission_dir="$OCTON_DIR/instance/orchestration/missions/$MISSION_ID"
  local mission_file="$mission_dir/mission.yml"
  local policy_file="$OCTON_DIR/instance/governance/policies/mission-autonomy.yml"
  local control_dir="$OCTON_DIR/state/control/execution/missions/$MISSION_ID"
  local continuity_dir="$OCTON_DIR/state/continuity/repo/missions/$MISSION_ID"
  local route_file="$OCTON_DIR/generated/effective/orchestration/missions/$MISSION_ID/scenario-resolution.yml"
  [[ -f "$mission_file" ]] || { echo "missing mission charter: ${mission_file#$ROOT_DIR/}" >&2; exit 1; }
  [[ -f "$policy_file" ]] || { echo "missing mission autonomy policy: ${policy_file#$ROOT_DIR/}" >&2; exit 1; }

  local mission_class owner_ref overlap_policy backfill_policy oversight_mode execution_posture
  local classification_id ambiguity_level novelty_level proposal_requirement
  local owner_slug
  mission_class="$(yq -r '.mission_class // ""' "$mission_file")"
  owner_ref="$(yq -r '.owner_ref // ""' "$mission_file")"
  [[ -n "$mission_class" ]] || { echo "mission_class missing in ${mission_file#$ROOT_DIR/}" >&2; exit 1; }
  [[ -n "$owner_ref" ]] || { echo "owner_ref missing in ${mission_file#$ROOT_DIR/}" >&2; exit 1; }
  [[ -n "$ISSUED_BY" ]] || ISSUED_BY="$owner_ref"
  owner_slug="$(printf '%s' "${owner_ref#operator://}" | tr '/:@' '---')"

  oversight_mode="$(yq -r ".mode_defaults.\"$mission_class\" // \"notify\"" "$policy_file")"
  execution_posture="$(yq -r ".execution_postures.\"$mission_class\" // \"interruptible_scheduled\"" "$policy_file")"
  overlap_policy="$(yq -r ".overlap_defaults.\"$mission_class\" // .default_overlap_policy // \"skip\"" "$policy_file")"
  backfill_policy="$(yq -r ".backfill_defaults.\"$mission_class\" // \"none\"" "$policy_file")"
  classification_id="$(yq -r ".proposal_classification_defaults.by_mission_class.\"$mission_class\".classification_id // \"$mission_class-default\"" "$policy_file")"
  ambiguity_level="$(yq -r ".proposal_classification_defaults.by_mission_class.\"$mission_class\".ambiguity_level // \"bounded\"" "$policy_file")"
  novelty_level="$(yq -r ".proposal_classification_defaults.by_mission_class.\"$mission_class\".novelty_level // \"known-pattern\"" "$policy_file")"
  proposal_requirement="$(yq -r ".proposal_classification_defaults.by_mission_class.\"$mission_class\".proposal_requirement // \"not_required\"" "$policy_file")"

  mkdir -p "$control_dir/action-slices" "$continuity_dir"

  local ts
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  {
    printf 'schema_version: "mission-control-lease-v1"\n'
    printf 'mission_id: "%s"\n' "$MISSION_ID"
    printf 'lease_id: "seed-%s"\n' "$MISSION_ID"
    printf 'state: "paused"\n'
    printf 'issued_by: "%s"\n' "$ISSUED_BY"
    printf 'issued_at: "%s"\n' "$ts"
    printf 'expires_at: "2099-01-01T00:00:00Z"\n'
    printf 'continuation_scope:\n'
    printf '  summary: "Seeded mission autonomy continuation scope"\n'
    printf '  allowed_execution_postures:\n'
    printf '    - "%s"\n' "$execution_posture"
    printf '  max_concurrent_runs: 1\n'
    printf '  allowed_action_classes:\n'
    while IFS= read -r value; do
      [[ -n "$value" ]] || continue
      printf '    - "%s"\n' "$value"
    done < <(read_array_yaml "$mission_file" '.allowed_action_classes')
    printf '  default_safing_subset:\n'
    while IFS= read -r value; do
      [[ -n "$value" ]] || continue
      printf '    - "%s"\n' "$value"
    done < <(read_array_yaml "$mission_file" '.default_safing_subset')
    printf 'revocation_reason: null\n'
    printf 'last_reviewed_at: "%s"\n' "$ts"
  } > "$control_dir/lease.yml"

  cat > "$control_dir/mode-state.yml" <<EOF
schema_version: "mode-state-v1"
mission_id: "$MISSION_ID"
oversight_mode: "$oversight_mode"
execution_posture: "$execution_posture"
safety_state: "paused"
phase: "planning"
active_run_ref: null
current_slice_ref: null
next_safe_interrupt_boundary_id: null
effective_scenario_resolution_ref: null
autonomy_burn_state: "healthy"
breaker_state: "clear"
break_glass_expires_at: null
updated_at: "$ts"
EOF

  cat > "$control_dir/intent-register.yml" <<EOF
schema_version: "intent-register-v1"
mission_id: "$MISSION_ID"
revision: 1
generated_from:
  - "framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh"
entries: []
EOF

  cat > "$control_dir/mission-classification.yml" <<EOF
schema_version: "mission-classification-v1"
mission_id: "$MISSION_ID"
mission_class: "$mission_class"
classification_id: "$classification_id"
ambiguity_level: "$ambiguity_level"
novelty_level: "$novelty_level"
proposal_requirement: "$proposal_requirement"
proposal_refs: []
acceptance_basis:
  - "Seeded from mission charter and mission autonomy policy defaults."
policy_ref: ".octon/instance/governance/policies/mission-autonomy.yml#proposal_classification_defaults.by_mission_class.$mission_class"
recorded_at: "$ts"
EOF

  : > "$control_dir/action-slices/.gitkeep"

  cat > "$control_dir/directives.yml" <<EOF
schema_version: "control-directive-v1"
mission_id: "$MISSION_ID"
revision: 1
directives: []
EOF

  cat > "$control_dir/authorize-updates.yml" <<EOF
schema_version: "authorize-update-v1"
mission_id: "$MISSION_ID"
revision: 1
authorize_updates: []
EOF

  cat > "$control_dir/schedule.yml" <<EOF
schema_version: "schedule-control-v1"
mission_id: "$MISSION_ID"
schedule_source: "mission-autonomy-policy"
cadence_or_trigger: "$execution_posture"
next_planned_run_at: null
suspended_future_runs: false
pause_active_run_requested: true
overlap_policy: "$overlap_policy"
backfill_policy: "$backfill_policy"
pause_on_failure_rules:
  enabled: true
  triggers:
EOF
  while IFS= read -r trigger; do
    [[ -n "$trigger" ]] || continue
    printf '    - "%s"\n' "$trigger" >> "$control_dir/schedule.yml"
  done < <(read_array_yaml "$policy_file" '.pause_on_failure.default_triggers')
  cat >> "$control_dir/schedule.yml" <<EOF
preview_lead: null
feedback_window_default: null
quiet_hours: null
digest_route_override: null
last_schedule_mutation_ref: null
EOF

  cat > "$control_dir/autonomy-budget.yml" <<EOF
schema_version: "autonomy-budget-v1"
mission_id: "$MISSION_ID"
state: "healthy"
window: "PT24H"
threshold_profile_ref: "mission-autonomy.default"
last_state_change_at: "$ts"
applied_mode_adjustments: []
updated_at: "$ts"
last_recomputed_at: "$ts"
last_recomputation_receipt_ref: null
counters: {}
EOF

  cat > "$control_dir/circuit-breakers.yml" <<EOF
schema_version: "circuit-breaker-v1"
mission_id: "$MISSION_ID"
state: "clear"
trip_reasons: []
trip_conditions_snapshot: {}
applied_actions: []
tripped_at: null
reset_requirements: []
reset_ref: null
reset_receipt_ref: null
updated_at: "$ts"
tripped_breakers: []
EOF

  cat > "$control_dir/subscriptions.yml" <<EOF
schema_version: "subscriptions-v1"
mission_id: "$MISSION_ID"
owners:
  - "$owner_ref"
watchers: []
digest_recipients:
  - "$owner_ref"
alert_recipients:
  - "$owner_ref"
routing_policy_ref: ".octon/instance/governance/ownership/registry.yml"
last_routing_evaluation_at: "$ts"
EOF

  cat > "$continuity_dir/next-actions.yml" <<EOF
schema_version: "mission-next-actions-v1"
mission_id: "$MISSION_ID"
next_actions: []
EOF

  cat > "$continuity_dir/handoff.md" <<EOF
# Mission Handoff

- mission_id: \`$MISSION_ID\`
- status: \`seeded\`
- next_safe_action: \`review mission charter, add or confirm the first action slice, and resume intentionally\`
EOF

  bash "$ROUTE_PUBLISHER" --mission-id "$MISSION_ID" >/dev/null
  if [[ -x "$SYNC_RUNTIME_ARTIFACTS" ]]; then
    bash "$SYNC_RUNTIME_ARTIFACTS" --target missions >/dev/null
  fi

  bash "$RECEIPT_WRITER" \
    --mission-id "$MISSION_ID" \
    --receipt-type "mission_seed" \
    --issued-by "$ISSUED_BY" \
    --reason "Seed mission autonomy control, continuity, and generated awareness state" \
    --new-state-ref ".octon/state/control/execution/missions/$MISSION_ID/lease.yml" \
    --reason-code "MISSION_CONTROL_SEEDED" \
    --policy-ref ".octon/instance/governance/policies/mission-autonomy.yml" \
    --policy-ref ".octon/instance/governance/ownership/registry.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/lease.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/mode-state.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/intent-register.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/mission-classification.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/action-slices/.gitkeep" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/directives.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/authorize-updates.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/schedule.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/autonomy-budget.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/circuit-breakers.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/subscriptions.yml" \
    --affected-path ".octon/state/continuity/repo/missions/$MISSION_ID/next-actions.yml" \
    --affected-path ".octon/state/continuity/repo/missions/$MISSION_ID/handoff.md" \
    --affected-path ".octon/generated/effective/orchestration/missions/$MISSION_ID/scenario-resolution.yml" \
    --affected-path ".octon/generated/cognition/summaries/missions/$MISSION_ID/now.md" \
    --affected-path ".octon/generated/cognition/summaries/missions/$MISSION_ID/next.md" \
    --affected-path ".octon/generated/cognition/summaries/missions/$MISSION_ID/recent.md" \
    --affected-path ".octon/generated/cognition/summaries/missions/$MISSION_ID/recover.md" \
    --affected-path ".octon/generated/cognition/summaries/operators/$owner_slug/$MISSION_ID.md" \
    --affected-path ".octon/generated/cognition/projections/materialized/missions/$MISSION_ID/mission-view.yml" \
    >/dev/null
}

main "$@"
