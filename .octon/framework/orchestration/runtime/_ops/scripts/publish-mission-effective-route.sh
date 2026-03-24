#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

MISSION_ID=""
OUTPUT_ROOT="$OCTON_DIR/generated/effective/orchestration/missions"

usage() {
  cat <<'USAGE'
Usage:
  publish-mission-effective-route.sh --mission-id <id> [--output-root <path>]
USAGE
}

yaml_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

iso_plus_seconds() {
  local ts="$1"
  local seconds="$2"
  jq -nr --arg ts "$ts" --argjson seconds "$seconds" '$ts | fromdateiso8601 + $seconds | todateiso8601'
}

iso_min() {
  printf '%s\n' "$@" | awk 'NF' | sort | head -n1
}

read_first_matching_entry() {
  local file="$1"
  local query="$2"
  yq -r "$query" "$file" 2>/dev/null | awk 'NF {print; exit}'
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mission-id) MISSION_ID="$2"; shift 2 ;;
      --output-root) OUTPUT_ROOT="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$MISSION_ID" ]] || { echo "--mission-id is required" >&2; exit 1; }

  local mission_file="$OCTON_DIR/instance/orchestration/missions/$MISSION_ID/mission.yml"
  local policy_file="$OCTON_DIR/instance/governance/policies/mission-autonomy.yml"
  local ownership_file="$OCTON_DIR/instance/governance/ownership/registry.yml"
  local deny_policy_file="$OCTON_DIR/framework/capabilities/governance/policy/deny-by-default.v2.yml"
  local root_manifest="$OCTON_DIR/octon.yml"
  local control_dir="$OCTON_DIR/state/control/execution/missions/$MISSION_ID"
  local lease_file="$control_dir/lease.yml"
  local mode_state_file="$control_dir/mode-state.yml"
  local intent_register_file="$control_dir/intent-register.yml"
  local directives_file="$control_dir/directives.yml"
  local schedule_file="$control_dir/schedule.yml"
  local autonomy_budget_file="$control_dir/autonomy-budget.yml"
  local circuit_breakers_file="$control_dir/circuit-breakers.yml"
  local subscriptions_file="$control_dir/subscriptions.yml"
  local out_dir="$OUTPUT_ROOT/$MISSION_ID"
  local out_file="$out_dir/scenario-resolution.yml"

  for path in \
    "$mission_file" \
    "$policy_file" \
    "$ownership_file" \
    "$deny_policy_file" \
    "$root_manifest" \
    "$lease_file" \
    "$mode_state_file" \
    "$intent_register_file" \
    "$directives_file" \
    "$schedule_file" \
    "$autonomy_budget_file" \
    "$circuit_breakers_file" \
    "$subscriptions_file"
  do
    [[ -f "$path" ]] || { echo "missing route input: ${path#$ROOT_DIR/}" >&2; exit 1; }
  done

  local generated_at fresh_candidate fresh_until
  generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  fresh_candidate="$(iso_plus_seconds "$generated_at" 900)"

  local mission_class risk_ceiling default_safing_subset oversight_mode execution_posture safety_state phase
  local budget_state breaker_state overlap_policy backfill_policy digest_route preview_lead next_planned_run_at lease_expires
  local current_action_class predicted_acp reversibility_class boundary_class default_on_silence primitive recovery_window
  local rollback_handle_type required_quorum break_glass_required block_finalize enter_safing digest_route_override pause_triggers_block

  mission_class="$(yq -r '.mission_class // ""' "$mission_file")"
  risk_ceiling="$(yq -r '.risk_ceiling // ""' "$mission_file")"
  default_safing_subset="$(yq -r '.default_safing_subset[]? // ""' "$mission_file" | paste -sd ',' -)"
  oversight_mode="$(yq -r '.oversight_mode // ""' "$mode_state_file")"
  execution_posture="$(yq -r '.execution_posture // ""' "$mode_state_file")"
  safety_state="$(yq -r '.safety_state // ""' "$mode_state_file")"
  phase="$(yq -r '.phase // ""' "$mode_state_file")"
  budget_state="$(yq -r '.state // ""' "$autonomy_budget_file")"
  breaker_state="$(yq -r '.state // ""' "$circuit_breakers_file")"
  overlap_policy="$(yq -r '.overlap_policy // ""' "$schedule_file")"
  backfill_policy="$(yq -r '.backfill_policy // ""' "$schedule_file")"
  next_planned_run_at="$(yq -r '.next_planned_run_at // ""' "$schedule_file")"
  preview_lead="$(yq -r '.preview_lead // ""' "$schedule_file")"
  digest_route_override="$(yq -r '.digest_route_override // ""' "$schedule_file")"
  lease_expires="$(yq -r '.expires_at // ""' "$lease_file")"

  current_action_class="$(read_first_matching_entry "$intent_register_file" '.entries[]? | select(.status == "published" or .status == "proposed") | .action_class // ""')"
  predicted_acp="$(read_first_matching_entry "$intent_register_file" '.entries[]? | select(.status == "published" or .status == "proposed") | .predicted_acp // ""')"
  reversibility_class="$(read_first_matching_entry "$intent_register_file" '.entries[]? | select(.status == "published" or .status == "proposed") | .planned_reversibility_class // ""')"
  boundary_class="$(read_first_matching_entry "$intent_register_file" '.entries[]? | select(.status == "published" or .status == "proposed") | .boundary_class // ""')"
  default_on_silence="$(read_first_matching_entry "$intent_register_file" '.entries[]? | select(.status == "published" or .status == "proposed") | .default_on_silence // ""')"

  if [[ -z "$boundary_class" ]]; then
    boundary_class="$(yq -r ".safe_interrupt_boundaries.\"$mission_class\" // \"task_boundary\"" "$policy_file")"
  fi

  if [[ -z "$current_action_class" ]]; then
    current_action_class="service.execute"
  fi
  if [[ -z "$predicted_acp" ]]; then
    predicted_acp="$risk_ceiling"
  fi
  if [[ -z "$reversibility_class" ]]; then
    reversibility_class="reversible"
  fi

  digest_route="${digest_route_override:-}"
  if [[ -z "$digest_route" ]]; then
    digest_route="$(yq -r ".digest_cadence_defaults.\"$mission_class\".route // \"digest_plus_threshold_alert\"" "$policy_file")"
  fi

  if [[ -z "$preview_lead" ]]; then
    preview_lead="$(yq -r '.preview_defaults.interval_gte_24h.preview_lead // ""' "$policy_file")"
  fi

  primitive="$(ACTION_CLASS="$current_action_class" yq -r '.acp.rules[]? | select(.match.class == strenv(ACTION_CLASS)) | .require.reversibility.primitive // ""' "$deny_policy_file" | awk 'NF {print; exit}')"
  recovery_window="$(ACTION_CLASS="$current_action_class" yq -r '.acp.rules[]? | select(.match.class == strenv(ACTION_CLASS)) | .require.reversibility.recovery_window_default // ""' "$deny_policy_file" | awk 'NF {print; exit}')"
  break_glass_required="$(ACTION_CLASS="$current_action_class" yq -r '.acp.rules[]? | select(.match.class == strenv(ACTION_CLASS)) | .require.break_glass_required // false' "$deny_policy_file" | awk 'NF {print; exit}')"
  if [[ -n "$primitive" ]]; then
    rollback_handle_type="$(PRIMITIVE="$primitive" yq -r '.reversibility.primitives[strenv(PRIMITIVE)].rollback_handle_type // ""' "$deny_policy_file")"
  else
    rollback_handle_type=""
  fi
  if [[ -z "$recovery_window" && -n "$primitive" ]]; then
    recovery_window="$(PRIMITIVE="$primitive" yq -r '.reversibility.primitives[strenv(PRIMITIVE)].default_recovery_window // ""' "$deny_policy_file")"
  fi
  if [[ -z "$recovery_window" ]]; then
    recovery_window="$(yq -r '.recovery_windows.local_reversible_repo_change // "PT72H"' "$policy_file")"
  fi

  if [[ -z "$break_glass_required" ]]; then
    break_glass_required="false"
  fi

  required_quorum="$(ACP_LEVEL="${predicted_acp:-ACP-1}" yq -r '.quorum[strenv(ACP_LEVEL)].required // 1' "$policy_file" | awk 'NF {print; exit}')"
  [[ -z "$required_quorum" ]] && required_quorum="1"

  block_finalize="$(yq -r '[.directives[]? | select((.kind == "block_finalize") and (.status == "accepted" or .status == "pending"))] | length > 0' "$directives_file")"
  enter_safing="$(yq -r '[.directives[]? | select((.kind == "enter_safing") and (.status == "accepted" or .status == "pending"))] | length > 0' "$directives_file")"

  if [[ "$enter_safing" == "true" || "$safety_state" == "safe" || "$breaker_state" != "clear" ]]; then
    if [[ "$mission_class" == "incident" ]]; then
      default_safing_subset="$(yq -r '.safing_defaults.incident_subset[]? // ""' "$policy_file" | paste -sd ',' -)"
    fi
  fi
  pause_triggers_block="$(yq -r '.pause_on_failure_rules.triggers[]? // ""' "$schedule_file" | sed 's/^/      - "/; s/$/"/')"
  [[ -n "$pause_triggers_block" ]] || pause_triggers_block='      []'

  fresh_until="$(iso_min "$fresh_candidate" "$lease_expires" "$next_planned_run_at")"

  mkdir -p "$out_dir"
  cat > "$out_file" <<EOF
schema_version: "scenario-resolution-v1"
mission_id: "$MISSION_ID"
source_refs:
  mission_charter: ".octon/instance/orchestration/missions/$MISSION_ID/mission.yml"
  mission_autonomy_policy: ".octon/instance/governance/policies/mission-autonomy.yml"
  ownership_registry: ".octon/instance/governance/ownership/registry.yml"
  deny_by_default_policy: ".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"
  root_manifest: ".octon/octon.yml"
  lease: ".octon/state/control/execution/missions/$MISSION_ID/lease.yml"
  mode_state: ".octon/state/control/execution/missions/$MISSION_ID/mode-state.yml"
  intent_register: ".octon/state/control/execution/missions/$MISSION_ID/intent-register.yml"
  directives: ".octon/state/control/execution/missions/$MISSION_ID/directives.yml"
  schedule: ".octon/state/control/execution/missions/$MISSION_ID/schedule.yml"
  autonomy_budget: ".octon/state/control/execution/missions/$MISSION_ID/autonomy-budget.yml"
  circuit_breakers: ".octon/state/control/execution/missions/$MISSION_ID/circuit-breakers.yml"
  subscriptions: ".octon/state/control/execution/missions/$MISSION_ID/subscriptions.yml"
effective:
  scenario_family: "$mission_class"
  oversight_mode: "$oversight_mode"
  execution_posture: "$execution_posture"
  preview_policy:
    lead: $(yaml_quote "$preview_lead")
    source: "mission-autonomy-policy"
  feedback_window_required: $( [[ "$oversight_mode" == "feedback_window" ]] && printf 'true' || printf 'false' )
  proceed_on_silence_allowed: $( [[ "$oversight_mode" == "proceed_on_silence" && "$budget_state" == "healthy" && "$breaker_state" == "clear" && "$reversibility_class" != "irreversible" ]] && printf 'true' || printf 'false' )
  approval_required: $( [[ "$oversight_mode" == "approval_required" || "$break_glass_required" == "true" ]] && printf 'true' || printf 'false' )
  safe_interrupt_boundary_class: "$boundary_class"
  overlap_policy: "$overlap_policy"
  backfill_policy: "$backfill_policy"
  pause_on_failure:
    enabled: $(yq -r '.pause_on_failure_rules.enabled // false' "$schedule_file")
    triggers:
${pause_triggers_block}
  digest_route: "$digest_route"
  alert_route: "$( [[ "$digest_route" == "immediate_alert" ]] && printf 'owners-first-alert' || printf 'owners-first-digest' )"
  required_quorum: "$(printf '%s' "$required_quorum")"
  recovery_profile:
    action_class: "$current_action_class"
    predicted_acp: "$predicted_acp"
    reversibility_class: "$reversibility_class"
    primitive: $(yaml_quote "$primitive")
    rollback_handle_type: $(yaml_quote "$rollback_handle_type")
    recovery_window: $(yaml_quote "$recovery_window")
  finalize_policy:
    approval_required: $( [[ "$oversight_mode" == "approval_required" ]] && printf 'true' || printf 'false' )
    block_finalize: $block_finalize
    break_glass_required: $break_glass_required
  safing_subset:
$(printf '%s\n' "$default_safing_subset" | tr ',' '\n' | awk 'NF {printf "    - \"%s\"\n", $0}')
rationale:
  - "mission class drives the scenario family"
  - "mission-autonomy defaults provide oversight, scheduling, digest, and safing baselines"
  - "deny-by-default ACP policy contributes reversibility and recovery defaults for the active action class"
  - "live control state tightens proceed-on-silence and finalize behavior"
generated_at: "$generated_at"
fresh_until: "$fresh_until"
EOF

  printf '%s\n' "$out_file"
}

main "$@"
