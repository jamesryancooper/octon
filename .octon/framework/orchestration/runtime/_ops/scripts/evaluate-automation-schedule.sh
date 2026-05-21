#!/usr/bin/env bash
set -euo pipefail

automation_id=""
trigger_file=""
transition_file=""

usage() {
  echo "usage: $0 --automation-id <id> --trigger-file <path> --transition-file <path>" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --automation-id) automation_id="${2:-}"; shift 2 ;;
    --trigger-file) trigger_file="${2:-}"; shift 2 ;;
    --transition-file) transition_file="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

[[ -n "$automation_id" && -n "$trigger_file" ]] || { usage; exit 1; }
[[ -n "$transition_file" ]] || { echo "transition-file is required for deterministic schedule evaluation in v1" >&2; exit 1; }
[[ -f "$trigger_file" ]] || { echo "trigger-file not found: $trigger_file" >&2; exit 1; }
[[ -f "$transition_file" ]] || { echo "transition-file not found: $transition_file" >&2; exit 1; }
command -v yq >/dev/null 2>&1 || { echo "missing required tool: yq" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "missing required tool: jq" >&2; exit 1; }

parse_hhmm() {
  local value="$1" hour minute
  IFS=: read -r hour minute <<<"$value"
  [[ "$hour" =~ ^[0-9]{2}$ && "$minute" =~ ^[0-9]{2}$ ]] || {
    echo "invalid HH:MM value: $value" >&2
    return 1
  }
  echo $((10#$hour * 60 + 10#$minute))
}

format_hhmm() {
  local total_minutes="$1"
  printf '%02d:%02d\n' "$((total_minutes / 60))" "$((total_minutes % 60))"
}

schedule_window_id() {
  local local_date="$1" resolved_local_time="$2"
  printf '%s:%s:%s\n' "$automation_id" "$local_date" "$resolved_local_time"
}

[[ "$(yq -r '.kind // ""' "$trigger_file")" == "schedule" ]] || {
  echo "trigger-file must be a schedule automation" >&2
  exit 1
}

scheduled_at="$(yq -r '.schedule.at // ""' "$trigger_file")"
[[ -n "$scheduled_at" && "$scheduled_at" != "null" ]] || { echo "trigger schedule.at is required" >&2; exit 1; }
scheduled_minutes="$(parse_hhmm "$scheduled_at")"

kind="$(jq -r '.transition.kind // ""' "$transition_file")"
local_date="$(jq -r '.transition.local_date // ""' "$transition_file")"
[[ -n "$kind" && "$kind" != "null" ]] || { echo "transition.kind is required" >&2; exit 1; }
[[ -n "$local_date" && "$local_date" != "null" ]] || { echo "transition.local_date is required" >&2; exit 1; }

case "$kind" in
  spring_forward)
    gap_start="$(parse_hhmm "$(jq -r '.transition.gap_start // ""' "$transition_file")")"
    gap_end="$(parse_hhmm "$(jq -r '.transition.gap_end // ""' "$transition_file")")"
    if (( scheduled_minutes >= gap_start && scheduled_minutes <= gap_end )); then
      resolved_minutes=$((gap_end + 1))
    else
      resolved_minutes="$scheduled_minutes"
    fi
    resolved_local_time="$(format_hhmm "$resolved_minutes")"
    jq -n \
      --arg resolved_local_time "$resolved_local_time" \
      --arg schedule_window_id "$(schedule_window_id "$local_date" "$resolved_local_time")" \
      '{resolved_local_time:$resolved_local_time,window_count:1,schedule_window_id:$schedule_window_id}'
    ;;
  fall_back)
    resolved_local_time="$scheduled_at"
    jq -n \
      --arg resolved_local_time "$resolved_local_time" \
      --arg schedule_window_id "$(schedule_window_id "$local_date" "$resolved_local_time")" \
      '{resolved_local_time:$resolved_local_time,window_count:1,selected_occurrence:"first",schedule_window_id:$schedule_window_id}'
    ;;
  *)
    echo "unsupported transition kind: $kind" >&2
    exit 1
    ;;
esac
