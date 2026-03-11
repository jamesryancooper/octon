#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools jq

decision_id=""
outcome=""
surface=""
action=""
actor=""
summary=""
workflow_group=""
workflow_id=""
mission_id=""
automation_id=""
incident_id=""
event_id=""
queue_item_id=""
run_id=""
coordination_key=""
lock_required="false"
lock_status=""
override_ref=""
approval_scope_hash=""
approval_refs=()
reason_codes=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --decision-id) decision_id="$2"; shift 2 ;;
    --outcome) outcome="$2"; shift 2 ;;
    --surface) surface="$2"; shift 2 ;;
    --action) action="$2"; shift 2 ;;
    --actor) actor="$2"; shift 2 ;;
    --summary) summary="$2"; shift 2 ;;
    --workflow-group) workflow_group="$2"; shift 2 ;;
    --workflow-id) workflow_id="$2"; shift 2 ;;
    --mission-id) mission_id="$2"; shift 2 ;;
    --automation-id) automation_id="$2"; shift 2 ;;
    --incident-id) incident_id="$2"; shift 2 ;;
    --event-id) event_id="$2"; shift 2 ;;
    --queue-item-id) queue_item_id="$2"; shift 2 ;;
    --run-id) run_id="$2"; shift 2 ;;
    --coordination-key) coordination_key="$2"; shift 2 ;;
    --lock-required) lock_required="$2"; shift 2 ;;
    --lock-status) lock_status="$2"; shift 2 ;;
    --approval-ref) approval_refs+=("$2"); shift 2 ;;
    --override-ref) override_ref="$2"; shift 2 ;;
    --approval-scope-hash) approval_scope_hash="$2"; shift 2 ;;
    --reason-code) reason_codes+=("$2"); shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$decision_id" && -n "$outcome" && -n "$surface" && -n "$action" && -n "$actor" && -n "$summary" ]] || {
  echo "missing required decision fields" >&2
  exit 1
}
[[ "${#reason_codes[@]}" -gt 0 ]] || { echo "at least one --reason-code is required" >&2; exit 1; }
case "$outcome" in
  allow|block|escalate) ;;
  *) echo "invalid outcome: $outcome" >&2; exit 1 ;;
esac
if [[ -n "$run_id" && "$outcome" != "allow" ]]; then
  echo "run_id is allowed only for outcome=allow" >&2
  exit 1
fi
if [[ "$lock_required" == "true" && ( -z "$coordination_key" || -z "$lock_status" ) ]]; then
  echo "lock evidence requires coordination key and lock status" >&2
  exit 1
fi

decision_dir="$DECISIONS_DIR/$decision_id"
[[ ! -e "$decision_dir" ]] || { echo "decision already exists: $decision_id" >&2; exit 1; }
ensure_dir "$decision_dir"
decided_at="$(now_utc)"

reason_json="$(printf '%s\n' "${reason_codes[@]}" | jq -R . | jq -s .)"
approval_json="$(printf '%s\n' "${approval_refs[@]}" | jq -R . | jq -s 'map(select(length > 0))')"

jq -n \
  --arg decision_id "$decision_id" \
  --arg outcome "$outcome" \
  --arg surface "$surface" \
  --arg action "$action" \
  --arg actor "$actor" \
  --arg decided_at "$decided_at" \
  --arg summary "$summary" \
  --arg workflow_group "$workflow_group" \
  --arg workflow_id "$workflow_id" \
  --arg mission_id "$mission_id" \
  --arg automation_id "$automation_id" \
  --arg incident_id "$incident_id" \
  --arg event_id "$event_id" \
  --arg queue_item_id "$queue_item_id" \
  --arg run_id "$run_id" \
  --arg coordination_key "$coordination_key" \
  --argjson lock_required "$lock_required" \
  --arg lock_status "$lock_status" \
  --arg override_ref "$override_ref" \
  --arg approval_scope_hash "$approval_scope_hash" \
  --argjson reason_codes "$reason_json" \
  --argjson approval_refs "$approval_json" '
  {
    decision_id: $decision_id,
    outcome: $outcome,
    surface: $surface,
    action: $action,
    actor: $actor,
    decided_at: $decided_at,
    reason_codes: $reason_codes,
    summary: $summary
  }
  + (if $workflow_group != "" and $workflow_id != "" then {workflow_ref:{workflow_group:$workflow_group,workflow_id:$workflow_id}} else {} end)
  + (if $mission_id != "" then {mission_id:$mission_id} else {} end)
  + (if $automation_id != "" then {automation_id:$automation_id} else {} end)
  + (if $incident_id != "" then {incident_id:$incident_id} else {} end)
  + (if $event_id != "" then {event_id:$event_id} else {} end)
  + (if $queue_item_id != "" then {queue_item_id:$queue_item_id} else {} end)
  + (if $run_id != "" then {run_id:$run_id} else {} end)
  + (if $coordination_key != "" then {coordination_key:$coordination_key} else {} end)
  + (if $lock_required == true or $lock_status != "" then {lock_required:$lock_required,lock_status:$lock_status} else {} end)
  + (if ($approval_refs | length) > 0 then {approval_refs:$approval_refs} else {} end)
  + (if $override_ref != "" then {override_ref:$override_ref} else {} end)
  + (if $approval_scope_hash != "" then {approval_scope_hash:$approval_scope_hash} else {} end)
  ' > "$decision_dir/decision.json"

cat > "$decision_dir/digest.md" <<EOF
# Decision ${decision_id}

- Outcome: \`${outcome}\`
- Surface: \`${surface}\`
- Action: \`${action}\`
- Actor: \`${actor}\`
- Decided At: \`${decided_at}\`

${summary}
EOF

echo "$decision_dir/decision.json"
