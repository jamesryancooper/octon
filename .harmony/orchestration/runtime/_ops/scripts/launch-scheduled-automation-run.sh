#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools yq jq python3

automation_id=""
transition_file=""
executor_id=""
lease_seconds="300"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --automation-id) automation_id="$2"; shift 2 ;;
    --transition-file) transition_file="$2"; shift 2 ;;
    --executor-id) executor_id="$2"; shift 2 ;;
    --lease-seconds) lease_seconds="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$automation_id" && -n "$transition_file" && -n "$executor_id" ]] || { echo "automation-id, transition-file, and executor-id are required" >&2; exit 1; }
automation_dir="$RUNTIME_DIR/automations/$automation_id"
[[ -f "$automation_dir/automation.yml" ]] || { echo "automation not found: $automation_id" >&2; exit 1; }
[[ "$(yq -r '.kind' "$automation_dir/trigger.yml")" == "schedule" ]] || { echo "automation is not scheduled: $automation_id" >&2; exit 1; }

schedule_eval="$(python3 "$SCRIPT_DIR/evaluate-automation-schedule.py" --automation-id "$automation_id" --trigger-file "$automation_dir/trigger.yml" --transition-file "$transition_file")"
schedule_window_id="$(jq -r '.schedule_window_id' <<<"$schedule_eval")"
workflow_group="$(yq -r '.workflow_ref.workflow_group' "$automation_dir/automation.yml")"
workflow_id="$(yq -r '.workflow_ref.workflow_id' "$automation_dir/automation.yml")"
decision_id="dec-${automation_id}-${schedule_window_id}-allow"
run_id="run-${automation_id}-${schedule_window_id}"

if [[ -d "$DECISIONS_DIR/$decision_id" || -f "$RUNTIME_RUNS_DIR/$run_id.yml" ]]; then
  echo "scheduled window already admitted: $schedule_window_id" >&2
  exit 1
fi

policy_file="$automation_dir/policy.yml"
[[ "$(yq -r '.idempotency_strategy.kind' "$policy_file")" == "schedule-window" ]] || { echo "scheduled automation must use schedule-window idempotency" >&2; exit 1; }
[[ "$(yq -r '.concurrency_mode' "$policy_file")" != "replace" ]] || { echo "replace is not supported for scheduled sample path" >&2; exit 1; }

decision_path="$(bash "$SCRIPT_DIR/write-decision.sh" \
  --decision-id "$decision_id" \
  --outcome "allow" \
  --surface "automations" \
  --action "launch-workflow" \
  --actor "$automation_id" \
  --workflow-group "$workflow_group" \
  --workflow-id "$workflow_id" \
  --automation-id "$automation_id" \
  --reason-code "schedule-window-due" \
  --reason-code "policy-allowed" \
  --summary "Scheduled automation launch admitted for ${automation_id}.")"

run_path="$(bash "$SCRIPT_DIR/write-run.sh" create \
  --run-id "$run_id" \
  --decision-id "$decision_id" \
  --summary "Scheduled automation ${automation_id} launched workflow ${workflow_id}." \
  --workflow-group "$workflow_group" \
  --workflow-id "$workflow_id" \
  --automation-id "$automation_id" \
  --executor-id "$executor_id" \
  --lease-seconds "$lease_seconds")"

cat > "$automation_dir/state/last-run.json" <<EOF
{
  "run_id": "${run_id}",
  "decision_id": "${decision_id}",
  "schedule_window_id": "${schedule_window_id}"
}
EOF

jq '.admitted += 1' "$automation_dir/state/counters.json" > "$automation_dir/state/counters.json.tmp"
mv "$automation_dir/state/counters.json.tmp" "$automation_dir/state/counters.json"

jq -n \
  --arg automation_id "$automation_id" \
  --arg decision_id "$decision_id" \
  --arg run_id "$run_id" \
  --arg schedule_window_id "$schedule_window_id" \
  --arg decision_path "$decision_path" \
  --arg run_path "$run_path" \
  '{automation_id:$automation_id,decision_id:$decision_id,run_id:$run_id,schedule_window_id:$schedule_window_id,decision_path:$decision_path,run_path:$run_path}'
