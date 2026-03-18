#!/usr/bin/env bash
# policy-kill-switch.sh - Scoped kill-switch management for deny-by-default.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
POLICY_FILE="${OCTON_DDB_POLICY_FILE:-$CAPABILITIES_DIR/governance/policy/deny-by-default.v2.yml}"

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for policy-kill-switch.sh" >&2
    exit 1
  fi
}

usage() {
  cat <<'USAGE'
Usage:
  policy-kill-switch.sh set --scope <global|service:<id>|category:<id>> --owner <owner> --reason <reason> [--ttl-seconds <n>] [--incident-id <id>]
  policy-kill-switch.sh status [--scope <scope>]
  policy-kill-switch.sh clear (--id <record-id> | --scope <scope>)
  policy-kill-switch.sh sweep-expired
USAGE
}

policy_field() {
  local key="$1"
  awk -v key="$key" '
    /^kill_switch:/ {in_block=1; next}
    in_block && $1 == key":" {
      line=$0
      sub("^[[:space:]]*"key":[[:space:]]*", "", line)
      gsub(/["'\'' ]/, "", line)
      print line
      exit
    }
    in_block && /^[[:space:]]*[a-z_]+:/ && $1 != "state_dir:" && $1 != "fail_closed:" {
      in_block=0
    }
  ' "$POLICY_FILE"
}

now_date() {
  date -u +"%Y-%m-%d"
}

epoch_to_date() {
  local epoch="$1"
  if date -u -r "$epoch" +"%Y-%m-%d" >/dev/null 2>&1; then
    date -u -r "$epoch" +"%Y-%m-%d"
    return 0
  fi
  if date -u -d "@$epoch" +"%Y-%m-%d" >/dev/null 2>&1; then
    date -u -d "@$epoch" +"%Y-%m-%d"
    return 0
  fi
  echo "Unable to format epoch timestamp with local date implementation" >&2
  return 1
}

ensure_dirs() {
  STATE_DIR="$(policy_field "state_dir")"

  [[ -n "$STATE_DIR" ]] || { echo "kill_switch.state_dir missing in $POLICY_FILE" >&2; exit 1; }

  mkdir -p "$STATE_DIR"
}

cmd_set() {
  local scope="" owner="" reason="" ttl_seconds=3600 incident_id=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --scope) scope="$2"; shift 2 ;;
      --owner) owner="$2"; shift 2 ;;
      --reason) reason="$2"; shift 2 ;;
      --ttl-seconds) ttl_seconds="$2"; shift 2 ;;
      --incident-id) incident_id="$2"; shift 2 ;;
      *) echo "Unknown option for set: $1" >&2; exit 1 ;;
    esac
  done

  [[ -n "$scope" ]] || { echo "--scope is required" >&2; exit 1; }
  [[ -n "$owner" ]] || { echo "--owner is required" >&2; exit 1; }
  [[ -n "$reason" ]] || { echo "--reason is required" >&2; exit 1; }
  [[ "$ttl_seconds" =~ ^[0-9]+$ ]] || { echo "--ttl-seconds must be numeric" >&2; exit 1; }

  local now_epoch expires_epoch created expires record_id record_file
  now_epoch="$(date -u +%s)"
  expires_epoch=$((now_epoch + ttl_seconds))
  created="$(now_date)"
  expires="$(epoch_to_date "$expires_epoch")"
  record_id="ks-$(date -u +%Y%m%dT%H%M%SZ)-$$"
  record_file="$STATE_DIR/${record_id}.yml"

  jq -n \
    --arg id "$record_id" \
    --arg scope "$scope" \
    --arg owner "$owner" \
    --arg reason "$reason" \
    --arg created "$created" \
    --arg expires "$expires" \
    --arg incident_id "$incident_id" \
    '{id:$id,scope:$scope,state:"active",owner:$owner,reason:$reason,created:$created,expires:$expires,incident_id:(if $incident_id=="" then null else $incident_id end)}' > "$record_file"

  jq -c . "$record_file"
}

cmd_status() {
  local scope=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --scope) scope="$2"; shift 2 ;;
      *) echo "Unknown option for status: $1" >&2; exit 1 ;;
    esac
  done

  local file found=false
  for file in "$STATE_DIR"/*.yml "$STATE_DIR"/*.yaml "$STATE_DIR"/*.json; do
    [[ -e "$file" ]] || continue
    if [[ -n "$scope" ]]; then
      if ! jq -e --arg scope "$scope" '.scope == $scope' "$file" >/dev/null 2>&1; then
        continue
      fi
    fi
    jq -c . "$file"
    found=true
  done

  if [[ "$found" != true ]]; then
    echo "[]"
  fi
}

clear_record_file() {
  local file="$1"
  jq '.state="cleared" | .cleared_at=(now|strftime("%Y-%m-%d"))' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

cmd_clear() {
  local record_id="" scope=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --id) record_id="$2"; shift 2 ;;
      --scope) scope="$2"; shift 2 ;;
      *) echo "Unknown option for clear: $1" >&2; exit 1 ;;
    esac
  done

  if [[ -z "$record_id" && -z "$scope" ]]; then
    echo "clear requires --id or --scope" >&2
    exit 1
  fi

  local file changed=false
  for file in "$STATE_DIR"/*.yml "$STATE_DIR"/*.yaml "$STATE_DIR"/*.json; do
    [[ -e "$file" ]] || continue
    if [[ -n "$record_id" ]] && ! jq -e --arg id "$record_id" '.id == $id' "$file" >/dev/null 2>&1; then
      continue
    fi
    if [[ -n "$scope" ]] && ! jq -e --arg scope "$scope" '.scope == $scope' "$file" >/dev/null 2>&1; then
      continue
    fi
    clear_record_file "$file"
    changed=true
  done

  [[ "$changed" == true ]] || { echo "No matching kill-switch records found" >&2; exit 1; }
}

cmd_sweep_expired() {
  local today file expired=0
  today="$(now_date)"

  for file in "$STATE_DIR"/*.yml "$STATE_DIR"/*.yaml "$STATE_DIR"/*.json; do
    [[ -e "$file" ]] || continue
    if ! jq -e '.state == "active"' "$file" >/dev/null 2>&1; then
      continue
    fi

    local expires
    expires="$(jq -r '.expires // empty' "$file")"
    if [[ -z "$expires" || "$expires" < "$today" ]]; then
      jq '.state="expired" | .expired_at=(now|strftime("%Y-%m-%d"))' "$file" > "$file.tmp"
      mv "$file.tmp" "$file"
      expired=$((expired + 1))
    fi
  done

  echo "expired_records=$expired"
}

main() {
  require_jq
  [[ -f "$POLICY_FILE" ]] || { echo "Missing policy file: $POLICY_FILE" >&2; exit 1; }
  ensure_dirs

  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    set) cmd_set "$@" ;;
    status) cmd_status "$@" ;;
    clear) cmd_clear "$@" ;;
    sweep-expired) cmd_sweep_expired "$@" ;;
    ""|-h|--help|help) usage ;;
    *) echo "Unknown command: $cmd" >&2; usage >&2; exit 1 ;;
  esac
}

main "$@"
