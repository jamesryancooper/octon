#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools jq
ensure_dir "$LOCKS_DIR"

usage() {
  cat <<'EOF'
Usage:
  manage-coordination-lock.sh acquire --coordination-key <key> --lock-class <exclusive|shared-read|shared-compatible> --owner-run-id <run> --lease-seconds <n> [--owner-executor-id <id>]
  manage-coordination-lock.sh renew --coordination-key <key> --owner-run-id <run> --lease-seconds <n>
  manage-coordination-lock.sh release --coordination-key <key> --owner-run-id <run>
  manage-coordination-lock.sh inspect --coordination-key <key>
EOF
}

next_expiry() {
  local seconds="$1"
  date -u -v+"${seconds}"S '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || python3 - <<PY
from datetime import datetime, timedelta, timezone
print((datetime.now(timezone.utc)+timedelta(seconds=int("${seconds}"))).strftime("%Y-%m-%dT%H:%M:%SZ"))
PY
}

acquire_lock_impl() {
  local coordination_key="$1"
  local lock_class="$2"
  local owner_run_id="$3"
  local owner_executor_id="$4"
  local lease_seconds="$5"
  local now="$6"
  local lock_path version lock_id lease_expires_at

  lock_path="$(coordination_key_file "$coordination_key")"
  version=0
  if [[ -f "$lock_path" ]]; then
    local state expires
    state="$(jq -r '.lock_state' "$lock_path")"
    expires="$(jq -r '.lease_expires_at // ""' "$lock_path")"
    version="$(jq -r '.lock_version // 0' "$lock_path")"
    if [[ "$state" == "held" && "$expires" > "$now" ]]; then
      jq -n \
        --arg status "deferred" \
        --arg coordination_key "$coordination_key" \
        --arg lock_path "$lock_path" \
        '{status:$status,coordination_key:$coordination_key,lock_path:$lock_path}'
      return 2
    fi
  fi

  lock_id="lock-${owner_run_id}-$(date -u +%Y%m%dT%H%M%SZ)"
  lease_expires_at="$(next_expiry "$lease_seconds")"
  jq -n \
    --arg lock_id "$lock_id" \
    --arg coordination_key "$coordination_key" \
    --arg lock_class "$lock_class" \
    --arg owner_run_id "$owner_run_id" \
    --arg owner_executor_id "$owner_executor_id" \
    --arg acquired_at "$now" \
    --arg lease_expires_at "$lease_expires_at" \
    --argjson next_version "$((version + 1))" '
    {
      lock_id: $lock_id,
      coordination_key: $coordination_key,
      lock_class: $lock_class,
      owner_run_id: $owner_run_id,
      lock_state: "held",
      acquired_at: $acquired_at,
      lease_expires_at: $lease_expires_at,
      lock_version: $next_version
    }
    + (if $owner_executor_id != "" then {owner_executor_id:$owner_executor_id} else {} end)
  ' > "$lock_path"

  jq -n \
    --arg status "acquired" \
    --arg lock_path "$lock_path" \
    --arg lock_id "$lock_id" \
    --arg coordination_key "$coordination_key" \
    --arg lease_expires_at "$lease_expires_at" '
    {status:$status,lock_path:$lock_path,lock_id:$lock_id,coordination_key:$coordination_key,lease_expires_at:$lease_expires_at}
  '
}

renew_lock_impl() {
  local coordination_key="$1"
  local owner_run_id="$2"
  local lease_seconds="$3"
  local now="$4"
  local lock_path version lease_expires_at

  lock_path="$(coordination_key_file "$coordination_key")"
  [[ -f "$lock_path" ]] || { echo "lock not found for key: $coordination_key" >&2; return 1; }
  [[ "$(jq -r '.owner_run_id' "$lock_path")" == "$owner_run_id" ]] || { echo "lock owner mismatch" >&2; return 1; }
  version="$(jq -r '.lock_version // 0' "$lock_path")"
  lease_expires_at="$(next_expiry "$lease_seconds")"

  jq \
    --arg now "$now" \
    --arg lease_expires_at "$lease_expires_at" \
    --argjson next_version "$((version + 1))" '
    .last_heartbeat_at = $now
    | .lease_expires_at = $lease_expires_at
    | .lock_version = $next_version
  ' "$lock_path" > "$lock_path.tmp"
  mv "$lock_path.tmp" "$lock_path"

  jq -n --arg status "renewed" --arg lock_path "$lock_path" --arg lease_expires_at "$lease_expires_at" '{status:$status,lock_path:$lock_path,lease_expires_at:$lease_expires_at}'
}

release_lock_impl() {
  local coordination_key="$1"
  local owner_run_id="$2"
  local now="$3"
  local lock_path version

  lock_path="$(coordination_key_file "$coordination_key")"
  [[ -f "$lock_path" ]] || { echo "lock not found for key: $coordination_key" >&2; return 1; }
  [[ "$(jq -r '.owner_run_id' "$lock_path")" == "$owner_run_id" ]] || { echo "lock owner mismatch" >&2; return 1; }
  version="$(jq -r '.lock_version // 0' "$lock_path")"

  jq \
    --arg now "$now" \
    --argjson next_version "$((version + 1))" '
    .lock_state = "released"
    | .released_at = $now
    | .lock_version = $next_version
  ' "$lock_path" > "$lock_path.tmp"
  mv "$lock_path.tmp" "$lock_path"

  jq -n --arg status "released" --arg lock_path "$lock_path" '{status:$status,lock_path:$lock_path}'
}

cmd="${1:-}"
shift || true

case "$cmd" in
  acquire)
    coordination_key=""
    lock_class=""
    owner_run_id=""
    owner_executor_id=""
    lease_seconds=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --coordination-key) coordination_key="$2"; shift 2 ;;
        --lock-class) lock_class="$2"; shift 2 ;;
        --owner-run-id) owner_run_id="$2"; shift 2 ;;
        --owner-executor-id) owner_executor_id="$2"; shift 2 ;;
        --lease-seconds) lease_seconds="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$coordination_key" && -n "$lock_class" && -n "$owner_run_id" && -n "$lease_seconds" ]] || { usage; exit 1; }
    with_path_lock "coordination-$(basename "$(coordination_key_file "$coordination_key")" .json)" acquire_lock_impl "$coordination_key" "$lock_class" "$owner_run_id" "$owner_executor_id" "$lease_seconds" "$(now_utc)"
    ;;
  renew)
    coordination_key=""
    owner_run_id=""
    lease_seconds=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --coordination-key) coordination_key="$2"; shift 2 ;;
        --owner-run-id) owner_run_id="$2"; shift 2 ;;
        --lease-seconds) lease_seconds="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$coordination_key" && -n "$owner_run_id" && -n "$lease_seconds" ]] || { usage; exit 1; }
    with_path_lock "coordination-$(basename "$(coordination_key_file "$coordination_key")" .json)" renew_lock_impl "$coordination_key" "$owner_run_id" "$lease_seconds" "$(now_utc)"
    ;;
  release)
    coordination_key=""
    owner_run_id=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --coordination-key) coordination_key="$2"; shift 2 ;;
        --owner-run-id) owner_run_id="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$coordination_key" && -n "$owner_run_id" ]] || { usage; exit 1; }
    with_path_lock "coordination-$(basename "$(coordination_key_file "$coordination_key")" .json)" release_lock_impl "$coordination_key" "$owner_run_id" "$(now_utc)"
    ;;
  inspect)
    coordination_key=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --coordination-key) coordination_key="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$coordination_key" ]] || { usage; exit 1; }
    lock_path="$(coordination_key_file "$coordination_key")"
    [[ -f "$lock_path" ]] || { echo "lock not found for key: $coordination_key" >&2; exit 1; }
    cat "$lock_path"
    ;;
  *)
    usage
    exit 1
    ;;
esac
