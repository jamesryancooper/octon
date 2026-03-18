#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools yq jq

queue_item_id=""
claim_token=""
executor_id=""
lease_seconds="300"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --queue-item-id) queue_item_id="$2"; shift 2 ;;
    --claim-token) claim_token="$2"; shift 2 ;;
    --executor-id) executor_id="$2"; shift 2 ;;
    --lease-seconds) lease_seconds="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$queue_item_id" && -n "$claim_token" && -n "$executor_id" ]] || { echo "queue-item-id, claim-token, and executor-id are required" >&2; exit 1; }
queue_file="$QUEUE_DIR/claimed/$queue_item_id.json"
[[ -f "$queue_file" ]] || { echo "claimed queue item not found: $queue_item_id" >&2; exit 1; }
[[ "$(jq -r '.claim_token' "$queue_file")" == "$claim_token" ]] || { echo "claim token mismatch for $queue_item_id" >&2; exit 1; }

automation_id="$(jq -r '.target_automation_id' "$queue_file")"
event_id="$(jq -r '.event_id // ""' "$queue_file")"
event_file="$(jq -r '.payload_ref // ""' "$queue_file")"
automation_dir="$RUNTIME_DIR/automations/$automation_id"
[[ -f "$automation_dir/automation.yml" ]] || { echo "automation not found: $automation_id" >&2; exit 1; }
[[ "$(yq -r '.status' "$automation_dir/automation.yml")" == "active" ]] || { echo "automation is not active: $automation_id" >&2; exit 1; }

workflow_group="$(yq -r '.workflow_ref.workflow_group' "$automation_dir/automation.yml")"
workflow_id="$(yq -r '.workflow_ref.workflow_id' "$automation_dir/automation.yml")"
trigger_kind="$(yq -r '.kind' "$automation_dir/trigger.yml")"
[[ "$trigger_kind" == "event" ]] || { echo "automation is not event-triggered: $automation_id" >&2; exit 1; }
bindings_file="$automation_dir/bindings.yml"
[[ -f "$bindings_file" ]] || { echo "bindings missing for automation: $automation_id" >&2; exit 1; }
policy_file="$automation_dir/policy.yml"
[[ -f "$policy_file" ]] || { echo "policy missing for automation: $automation_id" >&2; exit 1; }
concurrency_mode="$(yq -r '.concurrency_mode' "$policy_file")"
max_concurrency="$(yq -r '.max_concurrency' "$policy_file")"
idempotency_kind="$(yq -r '.idempotency_strategy.kind' "$policy_file")"
existing_active_runs=0
while IFS= read -r run_file; do
  [[ "$(yq -r '.automation_id // \"\"' "$run_file")" == "$automation_id" ]] || continue
  [[ "$(yq -r '.status // \"\"' "$run_file")" == "running" ]] || continue
  existing_active_runs=$((existing_active_runs + 1))
done < <(find "$RUNTIME_RUNS_DIR" -maxdepth 1 -type f -name '*.yml' ! -name 'index.yml' | sort)

[[ "$idempotency_kind" == "event-dedupe" ]] || { echo "event-triggered automation must use event-dedupe idempotency: $automation_id" >&2; exit 1; }
if [[ -d "$DECISIONS_DIR/dec-${automation_id}-${event_id:-manual}-allow" || -f "$RUNTIME_RUNS_DIR/run-${automation_id}-${event_id:-manual}.yml" ]]; then
  echo "duplicate event launch suppressed for $automation_id and $event_id" >&2
  exit 1
fi
if [[ "$concurrency_mode" == "serialize" || "$concurrency_mode" == "drop" || "$concurrency_mode" == "replace" ]]; then
  [[ "$max_concurrency" == "1" ]] || { echo "$concurrency_mode requires max_concurrency=1" >&2; exit 1; }
fi
if (( existing_active_runs >= max_concurrency )); then
  echo "automation concurrency limit reached for $automation_id" >&2
  exit 1
fi

if [[ -n "$event_file" && -f "$event_file" ]]; then
  binding_count="$(yq -r '.event_to_param_map | length // 0' "$bindings_file")"
  if [[ "$binding_count" -gt 0 ]]; then
    while IFS= read -r param; do
      from="$(jq -r '.from' <<<"$param")"
      required="$(jq -r '.required' <<<"$param")"
      value_type="$(jq -r '.value_type' <<<"$param")"
      default_present="$(jq -r 'has("default")' <<<"$param")"
      default_value="$(jq -r '.default // empty' <<<"$param")"
      event_path="${from#event.}"
      value="$(jq -r ".$event_path // empty" "$event_file")"
      if [[ "$required" == "true" && "$default_present" == "true" ]]; then
        echo "required binding must not declare default: $from" >&2
        exit 1
      fi
      if [[ "$required" == "true" && -z "$value" ]]; then
        echo "required binding path missing: $from" >&2
        exit 1
      fi
      if [[ -z "$value" && "$required" == "false" && "$default_present" == "true" ]]; then
        value="$default_value"
      fi
      case "$value_type" in
        string) : ;;
        integer) [[ "$value" =~ ^-?[0-9]+$ ]] || { echo "binding type mismatch for $from: expected integer" >&2; exit 1; } ;;
        number) [[ "$value" =~ ^-?[0-9]+([.][0-9]+)?$ ]] || { echo "binding type mismatch for $from: expected number" >&2; exit 1; } ;;
        boolean) [[ "$value" == "true" || "$value" == "false" ]] || { echo "binding type mismatch for $from: expected boolean" >&2; exit 1; } ;;
        *) echo "unsupported binding value_type: $value_type" >&2; exit 1 ;;
      esac
    done < <(yq -o=json '.event_to_param_map // {}' "$bindings_file" | jq -c 'to_entries[] | .value')
  fi
fi

workflow_json="$(bash "$SCRIPT_DIR/load-orchestration-discovery.sh" resolve-workflow --workflow-group "$workflow_group" --workflow-id "$workflow_id")"
coordination_kind="$(jq -r '.coordination_key_strategy.kind' <<<"$workflow_json")"
lock_required="false"
lock_status="not-required"
coordination_key=""
lock_id=""

if [[ "$coordination_kind" != "none" ]]; then
  coordination_key="$(jq -r '.coordination_key_strategy.format' <<<"$workflow_json" | sed "s/{workflow_group}/$workflow_group/g" | sed "s/{workflow_id}/$workflow_id/g")"
  lock_output="$(bash "$SCRIPT_DIR/manage-coordination-lock.sh" acquire \
    --coordination-key "$coordination_key" \
    --lock-class exclusive \
    --owner-run-id "run-${automation_id}-${event_id}" \
    --owner-executor-id "$executor_id" \
    --lease-seconds "$lease_seconds")"
  lock_required="true"
  lock_status="$(jq -r '.status' <<<"$lock_output")"
  [[ "$lock_status" == "acquired" ]] || { echo "coordination lock not acquired for $automation_id" >&2; exit 1; }
  lock_id="$(jq -r '.lock_id' <<<"$lock_output")"
fi

decision_id="dec-${automation_id}-${event_id:-manual}-allow"
run_id="run-${automation_id}-${event_id:-manual}"
decision_path="$(bash "$SCRIPT_DIR/write-decision.sh" \
  --decision-id "$decision_id" \
  --outcome "allow" \
  --surface "automations" \
  --action "launch-workflow" \
  --actor "$automation_id" \
  --workflow-group "$workflow_group" \
  --workflow-id "$workflow_id" \
  --automation-id "$automation_id" \
  --event-id "$event_id" \
  --queue-item-id "$queue_item_id" \
  --run-id "$run_id" \
  --coordination-key "$coordination_key" \
  --lock-required "$lock_required" \
  --lock-status "$lock_status" \
  --reason-code "target-resolved" \
  --reason-code "bindings-valid" \
  --reason-code "policy-allowed" \
  --reason-code "coordination-lock-acquired" \
  --summary "Automation launch admitted for ${automation_id}.")"
run_path="$(bash "$SCRIPT_DIR/write-run.sh" create \
  --run-id "$run_id" \
  --decision-id "$decision_id" \
  --summary "Automation ${automation_id} launched workflow ${workflow_id}." \
  --workflow-group "$workflow_group" \
  --workflow-id "$workflow_id" \
  --automation-id "$automation_id" \
  --event-id "$event_id" \
  --queue-item-id "$queue_item_id" \
  --coordination-key "$coordination_key" \
  --executor-id "$executor_id" \
  --lease-seconds "$lease_seconds")"

cat > "$automation_dir/state/last-run.json" <<EOF
{
  "run_id": "${run_id}",
  "decision_id": "${decision_id}"
}
EOF

jq '.admitted += 1' "$automation_dir/state/counters.json" > "$automation_dir/state/counters.json.tmp"
mv "$automation_dir/state/counters.json.tmp" "$automation_dir/state/counters.json"

jq -n \
  --arg automation_id "$automation_id" \
  --arg decision_path "$decision_path" \
  --arg run_path "$run_path" \
  --arg decision_id "$decision_id" \
  --arg run_id "$run_id" \
  --arg coordination_key "$coordination_key" \
  --arg lock_id "$lock_id" \
  '{automation_id:$automation_id,decision_id:$decision_id,run_id:$run_id,decision_path:$decision_path,run_path:$run_path,coordination_key:$coordination_key,lock_id:$lock_id}'
