#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools yq jq

now="$(now_utc)"
retry_delay_seconds="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --now) now="$2"; shift 2 ;;
    --retry-delay-seconds) retry_delay_seconds="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

bash "$SCRIPT_DIR/manage-queue.sh" expire --retry-delay-seconds "$retry_delay_seconds" >/dev/null || true

changes=()
while IFS= read -r run_file; do
  run_id="$(yq -r '.run_id' "$run_file")"
  status="$(yq -r '.status' "$run_file")"
  [[ "$status" == "running" ]] || continue
  ack="$(yq -r '.executor_acknowledged_at // ""' "$run_file")"
  lease_expires_at="$(yq -r '.lease_expires_at // ""' "$run_file")"
  if [[ -z "$ack" || "$ack" == "null" ]]; then
    bash "$SCRIPT_DIR/write-run.sh" recovery --run-id "$run_id" --recovery-status "recovery_pending" --recovery-reason "missing-executor-ack" >/dev/null
    changes+=("$(jq -n --arg run_id "$run_id" --arg reason "missing-executor-ack" '{run_id:$run_id,reason:$reason}')")
    continue
  fi
  if [[ -n "$lease_expires_at" && "$lease_expires_at" < "$now" ]]; then
    bash "$SCRIPT_DIR/write-run.sh" recovery --run-id "$run_id" --recovery-status "recovery_pending" --recovery-reason "heartbeat-expired" >/dev/null
    changes+=("$(jq -n --arg run_id "$run_id" --arg reason "heartbeat-expired" '{run_id:$run_id,reason:$reason}')")
  fi
done < <(find "$RUNTIME_RUNS_DIR" -maxdepth 1 -type f -name '*.yml' ! -name 'index.yml' | sort)

printf '%s\n' "${changes[@]:-}" | jq -s '.'
