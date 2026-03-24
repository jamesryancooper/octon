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
  local schedule_file="$control_dir/schedule.yml"
  local circuit_breakers_file="$control_dir/circuit-breakers.yml"
  local route_file="$OCTON_DIR/generated/effective/orchestration/missions/$MISSION_ID/scenario-resolution.yml"
  local intent_register_file="$control_dir/intent-register.yml"

  for path in "$lease_file" "$mode_state_file" "$directives_file" "$schedule_file" "$circuit_breakers_file" "$route_file" "$intent_register_file"; do
    [[ -f "$path" ]] || { echo "missing mission control runtime input: ${path#$ROOT_DIR/}" >&2; exit 1; }
  done

  local lease_state safety_state breaker_state oversight_mode action_class route_family
  local suspended_future_runs pause_active_run_requested approval_required break_glass_required block_finalize
  local route_fresh_until break_glass_expires_at required_quorum overlap_policy backfill_policy
  local pause_boundary stop_after_slice enter_safing allow_new_run=true pause_active_run=false safing_active=false
  local required_operator_ack=false break_glass_active=false observe_to_operate_required=false
  local now_ts

  lease_state="$(yq -r '.state // ""' "$lease_file")"
  safety_state="$(yq -r '.safety_state // ""' "$mode_state_file")"
  break_glass_expires_at="$(yq -r '.break_glass_expires_at // ""' "$mode_state_file")"
  breaker_state="$(yq -r '.state // ""' "$circuit_breakers_file")"
  oversight_mode="$(yq -r '.effective.oversight_mode // ""' "$route_file")"
  route_family="$(yq -r '.effective.scenario_family // ""' "$route_file")"
  route_fresh_until="$(yq -r '.fresh_until // ""' "$route_file")"
  action_class="$(yq -r '.effective.recovery_profile.action_class // ""' "$route_file")"
  required_quorum="$(yq -r '.effective.required_quorum // ""' "$route_file")"
  overlap_policy="$(yq -r '.effective.overlap_policy // ""' "$route_file")"
  backfill_policy="$(yq -r '.effective.backfill_policy // ""' "$route_file")"

  suspended_future_runs="$(yq -r '.suspended_future_runs // false' "$schedule_file")"
  pause_active_run_requested="$(yq -r '.pause_active_run_requested // false' "$schedule_file")"
  approval_required="$(yq -r '.effective.approval_required // false' "$route_file")"
  break_glass_required="$(yq -r '.effective.finalize_policy.break_glass_required // false' "$route_file")"
  block_finalize="$(yq -r '.effective.finalize_policy.block_finalize // false' "$route_file")"

  pause_boundary="$(yq -r '[.directives[]? | select((.kind == "pause_at_boundary") and (.status == "accepted" or .status == "pending"))] | length > 0' "$directives_file")"
  stop_after_slice="$(yq -r '[.directives[]? | select((.kind == "stop_after_slice") and (.status == "accepted" or .status == "pending"))] | length > 0' "$directives_file")"
  enter_safing="$(yq -r '[.directives[]? | select((.kind == "enter_safing") and (.status == "accepted" or .status == "pending"))] | length > 0' "$directives_file")"

  local -a reasons=()

  if [[ "$lease_state" != "active" ]]; then
    allow_new_run=false
    reasons+=("lease_not_active")
  fi
  if [[ "$suspended_future_runs" == "true" ]]; then
    allow_new_run=false
    reasons+=("future_runs_suspended")
  fi
  if [[ "$approval_required" == "true" || "$break_glass_required" == "true" ]]; then
    required_operator_ack=true
    allow_new_run=false
    reasons+=("operator_ack_required")
  fi
  if [[ "$oversight_mode" == "proceed_on_silence" ]] && [[ "$(yq -r '.effective.proceed_on_silence_allowed // false' "$route_file")" != "true" ]]; then
    allow_new_run=false
    reasons+=("proceed_on_silence_blocked")
  fi
  if [[ "$breaker_state" == "tripped" || "$breaker_state" == "latched" ]]; then
    allow_new_run=false
    reasons+=("breaker_not_clear")
  fi
  if [[ "$safety_state" == "break_glass" ]]; then
    break_glass_active=true
    if [[ -n "$break_glass_expires_at" ]]; then
      now_ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
      if [[ "$(jq -nr --arg now "$now_ts" --arg expiry "$break_glass_expires_at" '$now | fromdateiso8601 >= ($expiry | fromdateiso8601)')" == "true" ]]; then
        allow_new_run=false
        reasons+=("break_glass_expired")
      fi
    fi
  fi
  if [[ -n "$route_fresh_until" ]]; then
    now_ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    if [[ "$(jq -nr --arg now "$now_ts" --arg expiry "$route_fresh_until" '$now | fromdateiso8601 >= ($expiry | fromdateiso8601)')" == "true" ]]; then
      allow_new_run=false
      reasons+=("scenario_route_stale")
    fi
  fi

  if [[ "$pause_active_run_requested" == "true" || "$pause_boundary" == "true" || "$stop_after_slice" == "true" || "$breaker_state" == "tripped" || "$breaker_state" == "latched" || "$enter_safing" == "true" ]]; then
    pause_active_run=true
  fi
  if [[ "$enter_safing" == "true" || "$safety_state" == "safe" || "$safety_state" == "degraded" || "$breaker_state" == "tripped" || "$breaker_state" == "latched" ]]; then
    safing_active=true
  fi
  if [[ "$route_family" == "observe" && "$action_class" != observe* ]]; then
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
    --arg observe_to_operate_required "$observe_to_operate_required" \
    --arg suspended_future_runs "$suspended_future_runs" \
    --arg pause_active_run_requested "$pause_active_run_requested" \
    --argjson reasons "$reasons_json" \
    '{
      mission_id: $mission_id,
      route_file: $route_file,
      route_family: $route_family,
      oversight_mode: $oversight_mode,
      allow_new_run: ($allow_new_run == "true"),
      pause_active_run: ($pause_active_run == "true"),
      suspended_future_runs: ($suspended_future_runs == "true"),
      pause_active_run_requested: ($pause_active_run_requested == "true"),
      block_finalize: ($block_finalize == "true"),
      required_operator_ack: ($required_operator_ack == "true"),
      safing_active: ($safing_active == "true"),
      break_glass_active: ($break_glass_active == "true"),
      observe_to_operate_required: ($observe_to_operate_required == "true"),
      safety_state: $safety_state,
      breaker_state: $breaker_state,
      required_quorum: $required_quorum,
      overlap_policy: $overlap_policy,
      backfill_policy: $backfill_policy,
      reasons: $reasons
    }'
}

main "$@"
