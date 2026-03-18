#!/usr/bin/env bash
# policy-circuit-breaker-actions.sh - Execute ACP circuit breaker actions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEFAULT_KILL_SWITCH_SCRIPT="$CAPABILITIES_DIR/_ops/scripts/policy-kill-switch.sh"

usage() {
  cat <<'USAGE'
Usage:
  policy-circuit-breaker-actions.sh run \
    --run-id <id> \
    --decision <path> \
    --request <path> \
    --rollback-dir <path> \
    [--scope <scope>] \
    [--owner <owner>] \
    [--kill-switch-script <path>]
USAGE
}

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for policy-circuit-breaker-actions.sh" >&2
    exit 1
  fi
}

trip_kill_switch() {
  local kill_switch_script="$1"
  local run_id="$2"
  local scope="$3"
  local owner="$4"
  local log_file="$5"

  if [[ ! -x "$kill_switch_script" ]]; then
    printf '%s\n' "kill-switch script unavailable: $kill_switch_script" >> "$log_file"
    return 0
  fi

  "$kill_switch_script" set \
    --scope "$scope" \
    --owner "$owner" \
    --reason "ACP circuit breaker tripped for run $run_id" \
    --incident-id "$run_id" \
    --ttl-seconds 3600 >> "$log_file" 2>&1 || true
}

maybe_auto_rollback() {
  local request_file="$1"
  local log_file="$2"

  local rollback_handle
  rollback_handle="$(jq -r '.reversibility.rollback_handle // empty' "$request_file" 2>/dev/null || true)"
  if [[ -n "$rollback_handle" ]]; then
    printf '%s\n' "rollback-handle=$rollback_handle" >> "$log_file"
  fi

  if [[ "${OCTON_ENABLE_AUTO_ROLLBACK:-false}" != "true" ]]; then
    printf '%s\n' "auto-rollback skipped (enable with OCTON_ENABLE_AUTO_ROLLBACK=true)" >> "$log_file"
    return 0
  fi

  if [[ "$rollback_handle" == git:revert:* ]]; then
    local commit
    commit="${rollback_handle#git:revert:}"
    git revert --no-edit "$commit" >> "$log_file" 2>&1 || true
    return 0
  fi

  printf '%s\n' "auto-rollback skipped (unsupported rollback handle)" >> "$log_file"
}

cmd_run() {
  local run_id="" decision_file="" request_file="" rollback_dir=""
  local scope="global"
  local owner="${OCTON_AGENT_ID:-agent-local}"
  local kill_switch_script="$DEFAULT_KILL_SWITCH_SCRIPT"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --run-id) run_id="$2"; shift 2 ;;
      --decision) decision_file="$2"; shift 2 ;;
      --request) request_file="$2"; shift 2 ;;
      --rollback-dir) rollback_dir="$2"; shift 2 ;;
      --scope) scope="$2"; shift 2 ;;
      --owner) owner="$2"; shift 2 ;;
      --kill-switch-script) kill_switch_script="$2"; shift 2 ;;
      -h|--help|help) usage; exit 0 ;;
      *) echo "Unknown option for run: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$run_id" ]] || { echo "--run-id is required" >&2; exit 1; }
  [[ -f "$decision_file" ]] || { echo "Missing --decision file: $decision_file" >&2; exit 1; }
  [[ -f "$request_file" ]] || { echo "Missing --request file: $request_file" >&2; exit 1; }
  [[ -n "$rollback_dir" ]] || { echo "--rollback-dir is required" >&2; exit 1; }

  if ! jq -e '.reason_codes[]? | select(. == "ACP_CIRCUIT_BREAKER_TRIPPED")' "$decision_file" >/dev/null 2>&1; then
    jq -n '{tripped:false,actions:[]}'
    return 0
  fi

  local actions_json
  actions_json="$(jq -c '.requirements.breaker_actions // []' "$decision_file" 2>/dev/null || echo '[]')"
  if [[ "$actions_json" == "[]" ]]; then
    actions_json='["auto_rollback_and_trip_killswitch"]'
  fi

  mkdir -p "$rollback_dir"
  local rollback_log="$rollback_dir/rollback-attempt.txt"
  printf '%s\n' "breaker-actions=$actions_json" > "$rollback_log"

  local invalid_actions
  invalid_actions="$(jq -r '.[] | select(
    . != "stop_and_stage_only" and
    . != "auto_rollback_and_trip_killswitch" and
    . != "rollback_and_trip_killswitch" and
    . != "halt_and_notify" and
    . != "deny_and_escalate" and
    . != "auto_rollback" and
    . != "trip_killswitch"
  )' <<<"$actions_json" 2>/dev/null || true)"
  if [[ -n "$invalid_actions" ]]; then
    printf '%s\n' "unsupported circuit breaker action(s): $(tr '\n' ',' <<<"$invalid_actions" | sed 's/,$//')" >> "$rollback_log"
    jq -n --argjson actions "$actions_json" --arg invalid "$invalid_actions" \
      '{tripped:true,actions:$actions,rollback:false,kill_switch:false,notify:false,error:"unsupported_action",invalid_actions:($invalid | split("\n") | map(select(length > 0)))}'
    return 13
  fi

  local should_rollback should_killswitch should_notify
  should_rollback="false"
  should_killswitch="false"
  should_notify="false"

  if jq -e '.[] | select(. == "auto_rollback_and_trip_killswitch" or . == "rollback_and_trip_killswitch" or . == "auto_rollback")' <<<"$actions_json" >/dev/null 2>&1; then
    should_rollback="true"
  fi
  if jq -e '.[] | select(. == "auto_rollback_and_trip_killswitch" or . == "rollback_and_trip_killswitch" or . == "trip_killswitch")' <<<"$actions_json" >/dev/null 2>&1; then
    should_killswitch="true"
  fi
  if jq -e '.[] | select(. == "halt_and_notify" or . == "deny_and_escalate")' <<<"$actions_json" >/dev/null 2>&1; then
    should_notify="true"
  fi

  if [[ "$should_rollback" == "false" && "$should_killswitch" == "false" ]]; then
    printf '%s\n' "stage-only action: rollback and kill-switch not requested" >> "$rollback_log"
    if [[ "$should_notify" == "true" ]]; then
      printf '%s\n' "notify-only action requested; escalation artifact recorded" >> "$rollback_log"
    fi
    jq -n --argjson actions "$actions_json" --argjson notify "$should_notify" \
      '{tripped:true,actions:$actions,rollback:false,kill_switch:false,notify:$notify}'
    return 0
  fi

  if [[ "$should_rollback" == "true" ]]; then
    maybe_auto_rollback "$request_file" "$rollback_log"
  fi

  if [[ "$should_killswitch" == "true" ]]; then
    trip_kill_switch "$kill_switch_script" "$run_id" "$scope" "$owner" "$rollback_log"
  fi

  if [[ "$should_notify" == "true" ]]; then
    printf '%s\n' "notify action requested; escalation artifact recorded" >> "$rollback_log"
  fi

  jq -n --argjson actions "$actions_json" --argjson rollback "$should_rollback" --argjson kill_switch "$should_killswitch" --argjson notify "$should_notify" \
    '{tripped:true,actions:$actions,rollback:$rollback,kill_switch:$kill_switch,notify:$notify}'
}

main() {
  require_jq
  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    run)
      cmd_run "$@"
      ;;
    ""|-h|--help|help)
      usage
      ;;
    *)
      echo "Unknown command: $cmd" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
