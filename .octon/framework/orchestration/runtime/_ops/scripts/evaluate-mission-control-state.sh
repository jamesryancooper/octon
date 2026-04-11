#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

MISSION_ID=""

usage() {
  cat <<'USAGE'
Usage:
  evaluate-mission-control-state.sh --mission-id <id>
USAGE
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mission-id) MISSION_ID="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$MISSION_ID" ]] || { echo "--mission-id is required" >&2; exit 1; }

  local control_dir="$OCTON_DIR/state/control/execution/missions/$MISSION_ID"
  local lease_file="$control_dir/lease.yml"
  local mode_state_file="$control_dir/mode-state.yml"
  local directives_file="$control_dir/directives.yml"
  local authorize_updates_file="$control_dir/authorize-updates.yml"
  local schedule_file="$control_dir/schedule.yml"
  local circuit_breakers_file="$control_dir/circuit-breakers.yml"
  local route_file="$OCTON_DIR/generated/effective/orchestration/missions/$MISSION_ID/scenario-resolution.yml"
  local intent_register_file="$control_dir/intent-register.yml"

  for path in "$lease_file" "$mode_state_file" "$directives_file" "$authorize_updates_file" "$schedule_file" "$circuit_breakers_file" "$route_file" "$intent_register_file"; do
    [[ -f "$path" ]] || { echo "missing mission control runtime input: ${path#$ROOT_DIR/}" >&2; exit 1; }
  done

  local lease_state safety_state breaker_state oversight_mode route_family mission_class action_class
  local suspended_future_runs pause_active_run_requested approval_required break_glass_required block_finalize
  local route_fresh_until break_glass_expires_at required_quorum overlap_policy backfill_policy proposal_requirement proposal_refs_present
  local pause_boundary suspend_future_runs_directive resume_future_runs_directive stop_after_slice reprioritize_pending narrow_scope_active exclude_target_active enter_safing
  local allow_new_run=true pause_active_run=false safing_active=false
  local required_operator_ack=false break_glass_active=false grant_exception_active=false observe_to_operate_required=false approve_update_present=false
  local current_slice_ref route_ref route_missing_link=false now_ts active_intent_count active_slice_ref has_material_intent=false
  now_ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  lease_state="$(yq -r '.state // ""' "$lease_file")"
  safety_state="$(yq -r '.safety_state // ""' "$mode_state_file")"
  break_glass_expires_at="$(yq -r '.break_glass_expires_at // ""' "$mode_state_file")"
  current_slice_ref="$(yq -r '.current_slice_ref.path // .current_slice_ref // ""' "$mode_state_file")"
  route_ref="$(yq -r '.effective_scenario_resolution_ref // ""' "$mode_state_file")"
  breaker_state="$(yq -r '.state // ""' "$circuit_breakers_file")"
  oversight_mode="$(yq -r '.effective.oversight_mode // ""' "$route_file")"
  route_family="$(yq -r '.effective.effective_scenario_family // .effective.scenario_family // ""' "$route_file")"
  mission_class="$(yq -r '.effective.mission_class // ""' "$route_file")"
  route_fresh_until="$(yq -r '.fresh_until // ""' "$route_file")"
  action_class="$(yq -r '.effective.effective_action_class // .effective.recovery_profile.action_class // ""' "$route_file")"
  required_quorum="$(yq -r '.effective.required_quorum // ""' "$route_file")"
  overlap_policy="$(yq -r '.effective.overlap_policy // ""' "$route_file")"
  backfill_policy="$(yq -r '.effective.backfill_policy // ""' "$route_file")"
  proposal_requirement="$(yq -r '.effective.proposal_requirement // "not_required"' "$route_file")"
  proposal_refs_present="$(yq -r '.effective.proposal_refs_present // false' "$route_file")"

  suspended_future_runs="$(yq -r '.suspended_future_runs // false' "$schedule_file")"
  pause_active_run_requested="$(yq -r '.pause_active_run_requested // false' "$schedule_file")"
  approval_required="$(yq -r '.effective.approval_required // false' "$route_file")"
  break_glass_required="$(yq -r '.effective.finalize_policy.break_glass_required // false' "$route_file")"
  block_finalize="$(yq -r '.effective.finalize_policy.block_finalize // false' "$route_file")"

  pause_boundary="$(yq -r '[.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select((.type // .kind) == "pause_at_boundary")] | length > 0' "$directives_file")"
  local schedule_override
  schedule_override="$(yq -r '.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select(((.type // .kind) == "suspend_future_runs") or ((.type // .kind) == "resume_future_runs")) | (.type // .kind // "")' "$directives_file" 2>/dev/null | awk 'NF {value=$0} END {print value}')"
  suspend_future_runs_directive="false"
  resume_future_runs_directive="false"
  if [[ "$schedule_override" == "suspend_future_runs" ]]; then
    suspend_future_runs_directive="true"
  elif [[ "$schedule_override" == "resume_future_runs" ]]; then
    resume_future_runs_directive="true"
  fi
  stop_after_slice="$(yq -r '[.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select((.type // .kind) == "stop_after_slice")] | length > 0' "$directives_file")"
  reprioritize_pending="$(yq -r '[.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select((.type // .kind) == "reprioritize")] | length > 0' "$directives_file")"
  narrow_scope_active="$(yq -r '[.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select((.type // .kind) == "narrow_scope")] | length > 0' "$directives_file")"
  exclude_target_active="$(yq -r '[.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select((.type // .kind) == "exclude_target")] | length > 0' "$directives_file")"
  enter_safing="$(yq -r '[.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select((.type // .kind) == "enter_safing")] | length > 0' "$directives_file")"
  approve_update_present="$(yq -r '[.authorize_updates[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied")) | select(.type == "approve")] | length > 0' "$authorize_updates_file")"
  break_glass_active="$(yq -r '[.authorize_updates[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied")) | select(.type == "enter_break_glass")] | length > 0' "$authorize_updates_file")"
  local exception_grant_ref exception_grant_expires_at
  exception_grant_ref="$(yq -r '.exception_grant_ref // ""' "$mode_state_file")"
  exception_grant_expires_at="$(yq -r '.exception_grant_expires_at // ""' "$mode_state_file")"
  if [[ -n "$exception_grant_ref" && ( -z "$exception_grant_expires_at" || "$exception_grant_expires_at" > "$now_ts" ) ]]; then
    grant_exception_active=true
  fi
  active_intent_count="$(yq -r '[.entries[]? | select((.state // .status) == "active" or (.state // .status) == "queued" or (.state // .status) == "published")] | length' "$intent_register_file")"
  active_slice_ref="$(yq -r '.entries[]? | select((.state // .status) == "active" or (.state // .status) == "queued" or (.state // .status) == "published") | .action_slice_ref // .slice_ref.path // .slice_ref.id // ""' "$intent_register_file" 2>/dev/null | awk 'NF {print; exit}')"
  if [[ -n "$active_slice_ref" && "$active_slice_ref" != .octon/* && "$active_slice_ref" != */*.yml ]]; then
    active_slice_ref=".octon/state/control/execution/missions/$MISSION_ID/action-slices/$active_slice_ref.yml"
  fi

  local -a reasons=()

  if [[ "$lease_state" != "active" ]]; then
    allow_new_run=false
    reasons+=("lease_not_active")
  fi
  if [[ "$suspended_future_runs" == "true" && "$resume_future_runs_directive" != "true" ]]; then
    allow_new_run=false
    reasons+=("future_runs_suspended")
  fi
  if [[ "$suspend_future_runs_directive" == "true" ]]; then
    allow_new_run=false
    reasons+=("future_runs_suspended_by_directive")
  fi
  if [[ "$route_ref" != ".octon/generated/effective/orchestration/missions/$MISSION_ID/scenario-resolution.yml" ]]; then
    route_missing_link=true
    allow_new_run=false
    reasons+=("scenario_route_link_missing")
  fi
  if [[ -n "$route_fresh_until" ]]; then
    if [[ "$(jq -nr --arg now "$now_ts" --arg expiry "$route_fresh_until" '$now | fromdateiso8601 >= ($expiry | fromdateiso8601)')" == "true" ]]; then
      allow_new_run=false
      reasons+=("scenario_route_stale")
    fi
  else
    allow_new_run=false
    reasons+=("scenario_route_missing_freshness")
  fi

  if [[ "$breaker_state" == "tripped" || "$breaker_state" == "latched" || "$safety_state" == "break_glass" ]]; then
    pause_active_run=true
  fi
  if [[ "$pause_active_run_requested" == "true" || "$pause_boundary" == "true" || "$stop_after_slice" == "true" || "$reprioritize_pending" == "true" || "$narrow_scope_active" == "true" ]]; then
    pause_active_run=true
  fi
  if [[ "$exclude_target_active" == "true" && -n "$current_slice_ref" ]]; then
    pause_active_run=true
  fi

  if [[ "$enter_safing" == "true" || "$safety_state" == "safe" || "$safety_state" == "degraded" || "$breaker_state" == "tripped" || "$breaker_state" == "latched" ]]; then
    safing_active=true
  fi

  if [[ "$safety_state" == "break_glass" ]]; then
    break_glass_active=true
    if [[ -n "$break_glass_expires_at" && "$(jq -nr --arg now "$now_ts" --arg expiry "$break_glass_expires_at" '$now | fromdateiso8601 >= ($expiry | fromdateiso8601)')" == "true" ]]; then
      allow_new_run=false
      reasons+=("break_glass_expired")
    fi
  fi

  if [[ -n "$action_class" && "$action_class" != "mission.idle" ]]; then
    has_material_intent=true
  fi
  if [[ "$active_intent_count" -gt 0 && -n "$active_slice_ref" ]]; then
    has_material_intent=true
  fi

  if [[ "$oversight_mode" == "notify" || "$oversight_mode" == "feedback_window" || "$oversight_mode" == "proceed_on_silence" || "$oversight_mode" == "approval_required" ]]; then
    if [[ "$has_material_intent" != "true" && "$mission_class" != "observe" ]]; then
      allow_new_run=false
      reasons+=("material_intent_missing")
    fi
  fi

  if [[ "$active_intent_count" -gt 0 && -z "$active_slice_ref" ]]; then
    allow_new_run=false
    reasons+=("action_slice_ref_missing")
  fi
  if [[ "$reprioritize_pending" == "true" ]]; then
    allow_new_run=false
    reasons+=("reprioritize_pending")
  fi
  if [[ "$narrow_scope_active" == "true" ]]; then
    allow_new_run=false
    reasons+=("scope_narrowing_active")
  fi
  if [[ "$exclude_target_active" == "true" ]]; then
    allow_new_run=false
    reasons+=("target_excluded_by_directive")
  fi
  if [[ -n "$active_slice_ref" && -n "$current_slice_ref" && "$active_slice_ref" != "$current_slice_ref" ]]; then
    allow_new_run=false
    reasons+=("current_slice_link_mismatch")
  fi
  if [[ "$action_class" == "service.execute" && "$active_intent_count" -eq 0 ]]; then
    allow_new_run=false
    reasons+=("generic_route_recovery_fallback")
  fi

  if [[ "$approval_required" == "true" && "$approve_update_present" != "true" && "$grant_exception_active" != "true" ]]; then
    required_operator_ack=true
    allow_new_run=false
    reasons+=("operator_ack_required")
  fi
  if [[ "$proposal_requirement" == "required" && "$proposal_refs_present" != "true" ]]; then
    allow_new_run=false
    reasons+=("proposal_refs_required")
  fi
  if [[ "$break_glass_required" == "true" && "$break_glass_active" != "true" && "$grant_exception_active" != "true" ]]; then
    required_operator_ack=true
    allow_new_run=false
    reasons+=("break_glass_required")
  fi
  if [[ "$oversight_mode" == "proceed_on_silence" && "$(yq -r '.effective.proceed_on_silence_allowed // false' "$route_file")" != "true" ]]; then
    allow_new_run=false
    reasons+=("proceed_on_silence_blocked")
  fi
  if [[ "$breaker_state" == "tripped" || "$breaker_state" == "latched" ]]; then
    allow_new_run=false
    reasons+=("breaker_not_clear")
  fi
  if [[ "$route_family" == "observe" && "$action_class" != "mission.idle" ]]; then
    observe_to_operate_required=true
  fi

  local reasons_json
  if [[ "${#reasons[@]}" -eq 0 ]]; then
    reasons_json='[]'
  else
    reasons_json="$(printf '%s\n' "${reasons[@]}" | jq -R . | jq -s .)"
  fi

  jq -n \
    --arg mission_id "$MISSION_ID" \
    --arg route_file ".octon/generated/effective/orchestration/missions/$MISSION_ID/scenario-resolution.yml" \
    --arg route_family "$route_family" \
    --arg mission_class "$mission_class" \
    --arg action_class "$action_class" \
    --arg oversight_mode "$oversight_mode" \
    --arg required_quorum "$required_quorum" \
    --arg overlap_policy "$overlap_policy" \
    --arg backfill_policy "$backfill_policy" \
    --arg safety_state "$safety_state" \
    --arg breaker_state "$breaker_state" \
    --arg allow_new_run "$allow_new_run" \
    --arg pause_active_run "$pause_active_run" \
    --arg required_operator_ack "$required_operator_ack" \
    --arg block_finalize "$block_finalize" \
    --arg safing_active "$safing_active" \
    --arg break_glass_active "$break_glass_active" \
    --arg grant_exception_active "$grant_exception_active" \
    --arg observe_to_operate_required "$observe_to_operate_required" \
    --arg suspended_future_runs "$suspended_future_runs" \
    --arg pause_active_run_requested "$pause_active_run_requested" \
    --arg suspend_future_runs_directive "$suspend_future_runs_directive" \
    --arg resume_future_runs_directive "$resume_future_runs_directive" \
    --arg reprioritize_pending "$reprioritize_pending" \
    --arg narrow_scope_active "$narrow_scope_active" \
    --arg exclude_target_active "$exclude_target_active" \
    --arg current_slice_ref "$current_slice_ref" \
    --arg route_link_missing "$route_missing_link" \
    --argjson reasons "$reasons_json" \
    '{
      mission_id: $mission_id,
      route_file: $route_file,
      mission_class: $mission_class,
      route_family: $route_family,
      action_class: $action_class,
      oversight_mode: $oversight_mode,
      allow_new_run: ($allow_new_run == "true"),
      pause_active_run: ($pause_active_run == "true"),
      suspended_future_runs: ($suspended_future_runs == "true"),
      pause_active_run_requested: ($pause_active_run_requested == "true"),
      suspend_future_runs_directive: ($suspend_future_runs_directive == "true"),
      resume_future_runs_directive: ($resume_future_runs_directive == "true"),
      reprioritize_pending: ($reprioritize_pending == "true"),
      scope_narrowing_active: ($narrow_scope_active == "true"),
      exclude_target_active: ($exclude_target_active == "true"),
      block_finalize: ($block_finalize == "true"),
      required_operator_ack: ($required_operator_ack == "true"),
      safing_active: ($safing_active == "true"),
      break_glass_active: ($break_glass_active == "true"),
      grant_exception_active: ($grant_exception_active == "true"),
      observe_to_operate_required: ($observe_to_operate_required == "true"),
      route_link_missing: ($route_link_missing == "true"),
      current_slice_ref: $current_slice_ref,
      safety_state: $safety_state,
      breaker_state: $breaker_state,
      required_quorum: $required_quorum,
      overlap_policy: $overlap_policy,
      backfill_policy: $backfill_policy,
      reasons: $reasons
    }'
}

main "$@"
