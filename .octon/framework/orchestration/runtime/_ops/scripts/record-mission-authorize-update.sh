#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT_WRITER="$SCRIPT_DIR/write-mission-control-receipt.sh"

MISSION_ID=""
AUTHORIZE_UPDATE_ID=""
ISSUED_BY=""
KIND=""
STATE="pending"
TTL_SECONDS=""
EXPIRES_AT=""
REASON=""

usage() {
  cat <<'USAGE'
Usage:
  record-mission-authorize-update.sh \
    --mission-id <id> \
    --authorize-update-id <id> \
    --issued-by <ref> \
    --kind approve|extend_lease|revoke_lease|raise_budget|grant_exception|reset_breaker|enter_break_glass|exit_break_glass \
    [--state pending|accepted|applied|expired] \
    [--ttl-seconds <n>] \
    [--expires-at <timestamp>] \
    [--reason <text>]
USAGE
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mission-id) MISSION_ID="$2"; shift 2 ;;
      --authorize-update-id) AUTHORIZE_UPDATE_ID="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      --kind) KIND="$2"; shift 2 ;;
      --state) STATE="$2"; shift 2 ;;
      --ttl-seconds) TTL_SECONDS="$2"; shift 2 ;;
      --expires-at) EXPIRES_AT="$2"; shift 2 ;;
      --reason) REASON="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$MISSION_ID" ]] || { echo "--mission-id is required" >&2; exit 1; }
  [[ -n "$AUTHORIZE_UPDATE_ID" ]] || { echo "--authorize-update-id is required" >&2; exit 1; }
  [[ -n "$ISSUED_BY" ]] || { echo "--issued-by is required" >&2; exit 1; }
  [[ -n "$KIND" ]] || { echo "--kind is required" >&2; exit 1; }

  local control_dir="$OCTON_DIR/state/control/execution/missions/$MISSION_ID"
  local authorize_updates_file="$control_dir/authorize-updates.yml"
  [[ -f "$authorize_updates_file" ]] || { echo "missing authorize-updates: ${authorize_updates_file#$ROOT_DIR/}" >&2; exit 1; }

  local ts revision effective_expires_at
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  revision="$(yq -r '.revision // 0' "$authorize_updates_file")"
  revision="$((revision + 1))"
  effective_expires_at="$EXPIRES_AT"

  if [[ -z "$effective_expires_at" && -n "$TTL_SECONDS" ]]; then
    effective_expires_at="$(jq -nr --arg ts "$ts" --argjson seconds "$TTL_SECONDS" '$ts | fromdateiso8601 + $seconds | todateiso8601')"
  fi

  UPDATE_ID="$AUTHORIZE_UPDATE_ID" \
  UPDATE_TYPE="$KIND" \
  UPDATE_STATE="$STATE" \
  ISSUER_REF="$ISSUED_BY" \
  ISSUED_AT="$ts" \
  EXPIRES_AT="$effective_expires_at" \
  REVISION="$revision" \
  yq -i '
    .revision = (strenv(REVISION) | tonumber) |
    .authorize_updates += [{
      "update_id": strenv(UPDATE_ID),
      "type": strenv(UPDATE_TYPE),
      "state": strenv(UPDATE_STATE),
      "issuer_ref": strenv(ISSUER_REF),
      "issued_at": strenv(ISSUED_AT),
      "expires_at": (strenv(EXPIRES_AT) | select(length > 0)),
      "payload": {},
      "applied_by_receipt_ref": null
    }]
  ' "$authorize_updates_file"

  local receipt_reason
  receipt_reason="${REASON:-Record mission authorize update $KIND}"
  bash "$RECEIPT_WRITER" \
    --mission-id "$MISSION_ID" \
    --receipt-type "authorize_update_add" \
    --issued-by "$ISSUED_BY" \
    --reason "$receipt_reason" \
    --new-state-ref ".octon/state/control/execution/missions/$MISSION_ID/authorize-updates.yml" \
    --reason-code "AUTHORIZE_UPDATE_RECORDED" \
    --policy-ref ".octon/instance/governance/policies/mission-autonomy.yml" \
    --authorize-update-ref "$AUTHORIZE_UPDATE_ID" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/authorize-updates.yml" \
    >/dev/null

  printf '%s\n' "$authorize_updates_file"
}

main "$@"
