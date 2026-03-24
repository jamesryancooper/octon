#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT_WRITER="$SCRIPT_DIR/write-mission-control-receipt.sh"
ROUTE_PUBLISHER="$SCRIPT_DIR/publish-mission-effective-route.sh"

MISSION_ID=""
AUTHORIZE_UPDATE_ID=""
ISSUED_BY=""
KIND=""
TTL_SECONDS=3600

usage() {
  cat <<'USAGE'
Usage:
  apply-mission-authorize-update.sh --mission-id <id> --authorize-update-id <id> --issued-by <ref> --kind break_glass_activate|break_glass_clear [--ttl-seconds <n>]
USAGE
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mission-id) MISSION_ID="$2"; shift 2 ;;
      --authorize-update-id) AUTHORIZE_UPDATE_ID="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      --kind) KIND="$2"; shift 2 ;;
      --ttl-seconds) TTL_SECONDS="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$MISSION_ID" ]] || { echo "--mission-id is required" >&2; exit 1; }
  [[ -n "$AUTHORIZE_UPDATE_ID" ]] || { echo "--authorize-update-id is required" >&2; exit 1; }
  [[ -n "$ISSUED_BY" ]] || { echo "--issued-by is required" >&2; exit 1; }
  [[ -n "$KIND" ]] || { echo "--kind is required" >&2; exit 1; }

  local mode_state_file="$OCTON_DIR/state/control/execution/missions/$MISSION_ID/mode-state.yml"
  [[ -f "$mode_state_file" ]] || { echo "missing mode-state: ${mode_state_file#$ROOT_DIR/}" >&2; exit 1; }

  local ts expires_at receipt_kind reason_code prior_state_ref
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  expires_at="$(jq -nr --arg ts "$ts" --argjson seconds "$TTL_SECONDS" '$ts | fromdateiso8601 + $seconds | todateiso8601')"
  prior_state_ref=".octon/state/control/execution/missions/$MISSION_ID/mode-state.yml"

  case "$KIND" in
    break_glass_activate)
      yq -i '.safety_state = "break_glass" | .updated_at = "'"$ts"'" | .break_glass_expires_at = "'"$expires_at"'"' "$mode_state_file"
      receipt_kind="authorize_update_applied"
      reason_code="BREAK_GLASS_ACTIVATED"
      ;;
    break_glass_clear)
      yq -i '.safety_state = "paused" | .updated_at = "'"$ts"'" | .break_glass_expires_at = null' "$mode_state_file"
      receipt_kind="break_glass_cleared"
      reason_code="BREAK_GLASS_CLEARED"
      ;;
    *)
      echo "unsupported authorize-update kind: $KIND" >&2
      exit 1
      ;;
  esac

  bash "$ROUTE_PUBLISHER" --mission-id "$MISSION_ID" >/dev/null

  bash "$RECEIPT_WRITER" \
    --mission-id "$MISSION_ID" \
    --receipt-type "$receipt_kind" \
    --issued-by "$ISSUED_BY" \
    --prior-state-ref "$prior_state_ref" \
    --new-state-ref ".octon/state/control/execution/missions/$MISSION_ID/mode-state.yml" \
    --reason "Apply mission authorize update $KIND" \
    --reason-code "$reason_code" \
    --policy-ref ".octon/instance/governance/policies/mission-autonomy.yml" \
    --policy-ref ".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml" \
    --authorize-update-ref "$AUTHORIZE_UPDATE_ID" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/mode-state.yml" \
    --affected-path ".octon/generated/effective/orchestration/missions/$MISSION_ID/scenario-resolution.yml" \
    >/dev/null
}

main "$@"
