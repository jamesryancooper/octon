#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools yq

usage() {
  cat <<'EOF'
Usage:
  write-run.sh create --run-id <id> --decision-id <id> --summary <text> --workflow-group <group> --workflow-id <id> --executor-id <id> --lease-seconds <n> [options]
  write-run.sh complete --run-id <id> --status <succeeded|failed|cancelled> --summary <text>
  write-run.sh heartbeat --run-id <id> --lease-seconds <n>
  write-run.sh recovery --run-id <id> --recovery-status <status> [--recovery-reason <text>]
EOF
}

ensure_run_surface() {
  ensure_dir "$RUNTIME_RUNS_DIR"
  ensure_dir "$RUNTIME_RUNS_DIR/by-surface/workflows"
  ensure_dir "$RUNTIME_RUNS_DIR/by-surface/missions"
  ensure_dir "$RUNTIME_RUNS_DIR/by-surface/automations"
  ensure_dir "$RUNTIME_RUNS_DIR/by-surface/incidents"
  [[ -f "$RUNTIME_RUNS_DIR/index.yml" ]] || cat > "$RUNTIME_RUNS_DIR/index.yml" <<'EOF'
schema_version: "orchestration-runs-index-v1"
runs: []
EOF
}

projection_file() {
  local surface="$1"
  local key="$2"
  local encoded
  encoded="$(printf '%s' "$key" | tr '/:' '__' | tr ' ' '-')"
  printf '%s/by-surface/%s/%s.yml' "$RUNTIME_RUNS_DIR" "$surface" "$encoded"
}

upsert_projection() {
  local surface="$1"
  local key="$2"
  local run_id="$3"
  local file
  file="$(projection_file "$surface" "$key")"
  if [[ ! -f "$file" ]]; then
    cat > "$file" <<EOF
schema_version: "orchestration-run-projection-v1"
surface: "$surface"
key: "$key"
run_ids:
  - "$run_id"
EOF
    return
  fi
  projection_json="$(yq -o=json '.' "$file" | jq --arg run_id "$run_id" '.run_ids += [$run_id] | .run_ids |= unique')"
  printf '%s\n' "$projection_json" | yq -P -p=json '.' > "$file"
}

upsert_index() {
  local run_id="$1"
  local status="$2"
  local workflow_group="$3"
  local workflow_id="$4"
  local mission_id="$5"
  local automation_id="$6"
  local incident_id="$7"
  local continuity_run_path="$8"

  index_json="$(
    yq -o=json '.' "$RUNTIME_RUNS_DIR/index.yml" | jq \
      --arg run_id "$run_id" \
      --arg status "$status" \
      --arg workflow_group "$workflow_group" \
      --arg workflow_id "$workflow_id" \
      --arg mission_id "$mission_id" \
      --arg automation_id "$automation_id" \
      --arg incident_id "$incident_id" \
      --arg continuity_run_path "$continuity_run_path" '
        .runs = (.runs // []) |
        .runs |= map(select(.run_id != $run_id)) |
        .runs += [{
          run_id: $run_id,
          status: $status,
          path: ($run_id + ".yml"),
          continuity_run_path: $continuity_run_path
        }
        + (if $workflow_group != "" and $workflow_id != "" then {workflow_ref:{workflow_group:$workflow_group,workflow_id:$workflow_id}} else {} end)
        + (if $mission_id != "" then {mission_id:$mission_id} else {} end)
        + (if $automation_id != "" then {automation_id:$automation_id} else {} end)
        + (if $incident_id != "" then {incident_id:$incident_id} else {} end)]
      '
  )"
  printf '%s\n' "$index_json" | yq -P -p=json '.' > "$RUNTIME_RUNS_DIR/index.yml"
}

write_run_file() {
  local run_file="$1"
  local json="$2"
  printf '%s\n' "$json" | yq -P -p=json '.' > "$run_file"
}

cmd="${1:-}"
shift || true
ensure_run_surface

case "$cmd" in
  create)
    run_id=""
    decision_id=""
    summary=""
    workflow_group=""
    workflow_id=""
    mission_id=""
    automation_id=""
    incident_id=""
    event_id=""
    queue_item_id=""
    parent_run_id=""
    coordination_key=""
    executor_id=""
    started_at="$(now_utc)"
    executor_acknowledged_at=""
    last_heartbeat_at=""
    lease_expires_at=""
    lease_seconds=""
    recovery_status="healthy"
    recovery_reason=""
    status="running"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --run-id) run_id="$2"; shift 2 ;;
        --decision-id) decision_id="$2"; shift 2 ;;
        --summary) summary="$2"; shift 2 ;;
        --workflow-group) workflow_group="$2"; shift 2 ;;
        --workflow-id) workflow_id="$2"; shift 2 ;;
        --mission-id) mission_id="$2"; shift 2 ;;
        --automation-id) automation_id="$2"; shift 2 ;;
        --incident-id) incident_id="$2"; shift 2 ;;
        --event-id) event_id="$2"; shift 2 ;;
        --queue-item-id) queue_item_id="$2"; shift 2 ;;
        --parent-run-id) parent_run_id="$2"; shift 2 ;;
        --coordination-key) coordination_key="$2"; shift 2 ;;
        --executor-id) executor_id="$2"; shift 2 ;;
        --started-at) started_at="$2"; shift 2 ;;
        --executor-acknowledged-at) executor_acknowledged_at="$2"; shift 2 ;;
        --last-heartbeat-at) last_heartbeat_at="$2"; shift 2 ;;
        --lease-expires-at) lease_expires_at="$2"; shift 2 ;;
        --lease-seconds) lease_seconds="$2"; shift 2 ;;
        --recovery-status) recovery_status="$2"; shift 2 ;;
        --recovery-reason) recovery_reason="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done

    [[ -n "$run_id" && -n "$decision_id" && -n "$summary" && -n "$executor_id" ]] || { usage; exit 1; }
    [[ -f "$DECISIONS_DIR/$decision_id/decision.json" ]] || { echo "decision does not exist: $decision_id" >&2; exit 1; }
    if [[ -n "$workflow_group" || -n "$workflow_id" ]]; then
      [[ -n "$workflow_group" && -n "$workflow_id" ]] || { echo "workflow_group and workflow_id must be supplied together" >&2; exit 1; }
      bash "$SCRIPT_DIR/load-orchestration-discovery.sh" resolve-workflow --workflow-group "$workflow_group" --workflow-id "$workflow_id" >/dev/null
    fi
    if [[ -n "$mission_id" ]]; then
      bash "$SCRIPT_DIR/load-orchestration-discovery.sh" resolve-mission --mission-id "$mission_id" >/dev/null
    fi

    if [[ -z "$lease_expires_at" && -n "$lease_seconds" ]]; then
      lease_expires_at="$(date -u -v+"${lease_seconds}"S '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || python3 - <<PY
from datetime import datetime, timedelta, timezone
print((datetime.now(timezone.utc)+timedelta(seconds=int("${lease_seconds}"))).strftime("%Y-%m-%dT%H:%M:%SZ"))
PY
)"
    fi
    [[ -n "$lease_expires_at" ]] || { echo "lease-expires-at or lease-seconds is required" >&2; exit 1; }
    [[ -n "$executor_acknowledged_at" ]] || executor_acknowledged_at="$started_at"
    [[ -n "$last_heartbeat_at" ]] || last_heartbeat_at="$executor_acknowledged_at"

    continuity_run_path=".octon/continuity/runs/$run_id/"
    ensure_dir "$CONTINUITY_RUNS_DIR/$run_id"
    run_file="$RUNTIME_RUNS_DIR/$run_id.yml"
    [[ ! -f "$run_file" ]] || { echo "run already exists: $run_id" >&2; exit 1; }

    run_json="$(
      jq -n \
        --arg run_id "$run_id" \
        --arg status "$status" \
        --arg started_at "$started_at" \
        --arg workflow_group "$workflow_group" \
        --arg workflow_id "$workflow_id" \
        --arg mission_id "$mission_id" \
        --arg automation_id "$automation_id" \
        --arg incident_id "$incident_id" \
        --arg event_id "$event_id" \
        --arg queue_item_id "$queue_item_id" \
        --arg parent_run_id "$parent_run_id" \
        --arg coordination_key "$coordination_key" \
        --arg executor_id "$executor_id" \
        --arg executor_acknowledged_at "$executor_acknowledged_at" \
        --arg last_heartbeat_at "$last_heartbeat_at" \
        --arg lease_expires_at "$lease_expires_at" \
        --arg recovery_status "$recovery_status" \
        --arg recovery_reason "$recovery_reason" \
        --arg decision_id "$decision_id" \
        --arg continuity_run_path "$continuity_run_path" \
        --arg summary "$summary" '
          {
            run_id: $run_id,
            status: $status,
            started_at: $started_at,
            decision_id: $decision_id,
            continuity_run_path: $continuity_run_path,
            summary: $summary,
            executor_id: $executor_id,
            executor_acknowledged_at: $executor_acknowledged_at,
            last_heartbeat_at: $last_heartbeat_at,
            lease_expires_at: $lease_expires_at,
            recovery_status: $recovery_status
          }
          + (if $workflow_group != "" and $workflow_id != "" then {workflow_ref:{workflow_group:$workflow_group,workflow_id:$workflow_id}} else {} end)
          + (if $mission_id != "" then {mission_id:$mission_id} else {} end)
          + (if $automation_id != "" then {automation_id:$automation_id} else {} end)
          + (if $incident_id != "" then {incident_id:$incident_id} else {} end)
          + (if $event_id != "" then {event_id:$event_id} else {} end)
          + (if $queue_item_id != "" then {queue_item_id:$queue_item_id} else {} end)
          + (if $parent_run_id != "" then {parent_run_id:$parent_run_id} else {} end)
          + (if $coordination_key != "" then {coordination_key:$coordination_key} else {} end)
          + (if $recovery_reason != "" then {recovery_reason:$recovery_reason} else {} end)
        '
    )"
    write_run_file "$run_file" "$run_json"

    upsert_index "$run_id" "$status" "$workflow_group" "$workflow_id" "$mission_id" "$automation_id" "$incident_id" "$continuity_run_path"
    [[ -n "$workflow_group" && -n "$workflow_id" ]] && upsert_projection "workflows" "$workflow_group--$workflow_id" "$run_id"
    [[ -n "$mission_id" ]] && upsert_projection "missions" "$mission_id" "$run_id"
    [[ -n "$automation_id" ]] && upsert_projection "automations" "$automation_id" "$run_id"
    [[ -n "$incident_id" ]] && upsert_projection "incidents" "$incident_id" "$run_id"
    echo "$run_file"
    ;;
  complete)
    run_id=""
    status=""
    summary=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --run-id) run_id="$2"; shift 2 ;;
        --status) status="$2"; shift 2 ;;
        --summary) summary="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$run_id" && -n "$status" && -n "$summary" ]] || { usage; exit 1; }
    case "$status" in
      succeeded|failed|cancelled) ;;
      *) echo "invalid completion status: $status" >&2; exit 1 ;;
    esac
    run_file="$RUNTIME_RUNS_DIR/$run_id.yml"
    [[ -f "$run_file" ]] || { echo "run not found: $run_id" >&2; exit 1; }
    completed_at="$(now_utc)"
    run_json="$(yq -o=json '.' "$run_file" | jq --arg status "$status" --arg summary "$summary" --arg completed_at "$completed_at" '.status=$status | .summary=$summary | .completed_at=$completed_at')"
    printf '%s\n' "$run_json" | yq -P -p=json '.' > "$run_file"
    workflow_group="$(yq -r '.workflow_ref.workflow_group // ""' "$run_file")"
    workflow_id="$(yq -r '.workflow_ref.workflow_id // ""' "$run_file")"
    mission_id="$(yq -r '.mission_id // ""' "$run_file")"
    automation_id="$(yq -r '.automation_id // ""' "$run_file")"
    incident_id="$(yq -r '.incident_id // ""' "$run_file")"
    continuity_run_path="$(yq -r '.continuity_run_path' "$run_file")"
    upsert_index "$run_id" "$status" "$workflow_group" "$workflow_id" "$mission_id" "$automation_id" "$incident_id" "$continuity_run_path"
    echo "$run_file"
    ;;
  heartbeat)
    run_id=""
    lease_seconds=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --run-id) run_id="$2"; shift 2 ;;
        --lease-seconds) lease_seconds="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$run_id" && -n "$lease_seconds" ]] || { usage; exit 1; }
    run_file="$RUNTIME_RUNS_DIR/$run_id.yml"
    [[ -f "$run_file" ]] || { echo "run not found: $run_id" >&2; exit 1; }
    heartbeat_at="$(now_utc)"
    lease_expires_at="$(date -u -v+"${lease_seconds}"S '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || python3 - <<PY
from datetime import datetime, timedelta, timezone
print((datetime.now(timezone.utc)+timedelta(seconds=int("${lease_seconds}"))).strftime("%Y-%m-%dT%H:%M:%SZ"))
PY
)"
    run_json="$(yq -o=json '.' "$run_file" | jq --arg heartbeat_at "$heartbeat_at" --arg lease_expires_at "$lease_expires_at" '.last_heartbeat_at=$heartbeat_at | .lease_expires_at=$lease_expires_at')"
    printf '%s\n' "$run_json" | yq -P -p=json '.' > "$run_file"
    echo "$run_file"
    ;;
  recovery)
    run_id=""
    recovery_status=""
    recovery_reason=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --run-id) run_id="$2"; shift 2 ;;
        --recovery-status) recovery_status="$2"; shift 2 ;;
        --recovery-reason) recovery_reason="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$run_id" && -n "$recovery_status" ]] || { usage; exit 1; }
    run_file="$RUNTIME_RUNS_DIR/$run_id.yml"
    [[ -f "$run_file" ]] || { echo "run not found: $run_id" >&2; exit 1; }
    run_json="$(yq -o=json '.' "$run_file" | jq --arg recovery_status "$recovery_status" --arg recovery_reason "$recovery_reason" '.recovery_status=$recovery_status | (if $recovery_reason != "" then .recovery_reason=$recovery_reason else . end)')"
    printf '%s\n' "$run_json" | yq -P -p=json '.' > "$run_file"
    echo "$run_file"
    ;;
  *)
    usage
    exit 1
    ;;
esac
