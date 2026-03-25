#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT_WRITER="$SCRIPT_DIR/write-mission-control-receipt.sh"
ROUTE_PUBLISHER="$SCRIPT_DIR/publish-mission-effective-route.sh"
SYNC_RUNTIME_ARTIFACTS="$OCTON_DIR/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh"

MISSION_ID=""
DIRECTIVE_ID=""
ISSUED_BY=""
KIND=""
STATE="pending"
EFFECTIVE_AT="immediate"
TTL_SECONDS=""
EXPIRES_AT=""
REASON=""

usage() {
  cat <<'USAGE'
Usage:
  record-mission-directive.sh \
    --mission-id <id> \
    --directive-id <id> \
    --issued-by <ref> \
    --kind pause_at_boundary|suspend_future_runs|resume_future_runs|reprioritize|narrow_scope|exclude_target|block_finalize|unblock_finalize|enter_safing \
    [--state pending|accepted|applied|expired] \
    [--effective-at immediate|next_safe_boundary] \
    [--ttl-seconds <n>] \
    [--expires-at <timestamp>] \
    [--reason <text>]
USAGE
}

effect_receipt_type() {
  local kind="$1"
  local state="$2"
  if [[ "$state" == "expired" ]]; then
    case "$kind" in
      enter_safing) printf 'safing_exit' ;;
      *) printf 'directive_expire' ;;
    esac
    return
  fi

  case "$kind" in
    block_finalize) printf 'finalize_block' ;;
    unblock_finalize) printf 'finalize_unblock' ;;
    enter_safing) printf 'safing_enter' ;;
    *) printf 'directive_apply' ;;
  esac
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mission-id) MISSION_ID="$2"; shift 2 ;;
      --directive-id) DIRECTIVE_ID="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      --kind) KIND="$2"; shift 2 ;;
      --state) STATE="$2"; shift 2 ;;
      --effective-at) EFFECTIVE_AT="$2"; shift 2 ;;
      --ttl-seconds) TTL_SECONDS="$2"; shift 2 ;;
      --expires-at) EXPIRES_AT="$2"; shift 2 ;;
      --reason) REASON="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$MISSION_ID" ]] || { echo "--mission-id is required" >&2; exit 1; }
  [[ -n "$DIRECTIVE_ID" ]] || { echo "--directive-id is required" >&2; exit 1; }
  [[ -n "$ISSUED_BY" ]] || { echo "--issued-by is required" >&2; exit 1; }
  [[ -n "$KIND" ]] || { echo "--kind is required" >&2; exit 1; }

  local control_dir="$OCTON_DIR/state/control/execution/missions/$MISSION_ID"
  local directives_file="$control_dir/directives.yml"
  local schedule_file="$control_dir/schedule.yml"
  [[ -f "$directives_file" ]] || { echo "missing directives: ${directives_file#$ROOT_DIR/}" >&2; exit 1; }

  local ts revision effective_expires_at
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  revision="$(yq -r '.revision // 0' "$directives_file")"
  revision="$((revision + 1))"
  effective_expires_at="$EXPIRES_AT"

  if [[ -z "$effective_expires_at" && -n "$TTL_SECONDS" ]]; then
    effective_expires_at="$(jq -nr --arg ts "$ts" --argjson seconds "$TTL_SECONDS" '$ts | fromdateiso8601 + $seconds | todateiso8601')"
  fi

  DIRECTIVE_ID_VAR="$DIRECTIVE_ID" \
  DIRECTIVE_TYPE="$KIND" \
  DIRECTIVE_STATE="$STATE" \
  ISSUER_REF="$ISSUED_BY" \
  ISSUED_AT="$ts" \
  EFFECTIVE_AT_VAR="$EFFECTIVE_AT" \
  EXPIRES_AT_VAR="$effective_expires_at" \
  REVISION="$revision" \
  yq -i '
    .revision = (strenv(REVISION) | tonumber) |
    .directives += [{
      "directive_id": strenv(DIRECTIVE_ID_VAR),
      "type": strenv(DIRECTIVE_TYPE),
      "kind": strenv(DIRECTIVE_TYPE),
      "state": strenv(DIRECTIVE_STATE),
      "status": strenv(DIRECTIVE_STATE),
      "issuer_ref": strenv(ISSUER_REF),
      "submitted_by": strenv(ISSUER_REF),
      "precedence_source": "mission_owner",
      "issued_at": strenv(ISSUED_AT),
      "submitted_at": strenv(ISSUED_AT),
      "effective_at": strenv(EFFECTIVE_AT_VAR),
      "expires_at": (strenv(EXPIRES_AT_VAR) | select(length > 0)),
      "payload": {},
      "rationale": "",
      "consumed_by_receipt_ref": null
    }]
  ' "$directives_file"

  local receipt_reason receipt_path effect_type schedule_receipt=""
  receipt_reason="${REASON:-Record mission directive $KIND}"
  bash "$RECEIPT_WRITER" \
    --mission-id "$MISSION_ID" \
    --receipt-type "directive_add" \
    --issued-by "$ISSUED_BY" \
    --reason "$receipt_reason" \
    --new-state-ref ".octon/state/control/execution/missions/$MISSION_ID/directives.yml" \
    --reason-code "DIRECTIVE_RECORDED" \
    --policy-ref ".octon/instance/governance/ownership/registry.yml" \
    --directive-ref "$DIRECTIVE_ID" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/directives.yml" \
    >/dev/null

  if [[ "$STATE" != "pending" ]]; then
    if [[ "$STATE" != "expired" && ( "$KIND" == "suspend_future_runs" || "$KIND" == "resume_future_runs" ) ]]; then
      [[ -f "$schedule_file" ]] || { echo "missing schedule: ${schedule_file#$ROOT_DIR/}" >&2; exit 1; }
      local suspended_flag
      suspended_flag=true
      if [[ "$KIND" == "resume_future_runs" ]]; then
        suspended_flag=false
      fi
      SUSPENDED_FLAG="$suspended_flag" yq -i '.suspended_future_runs = (strenv(SUSPENDED_FLAG) == "true")' "$schedule_file"
      schedule_receipt="$(bash "$RECEIPT_WRITER" \
        --mission-id "$MISSION_ID" \
        --receipt-type "schedule_mutation" \
        --issued-by "$ISSUED_BY" \
        --reason "Apply mission directive $KIND to schedule control truth" \
        --new-state-ref ".octon/state/control/execution/missions/$MISSION_ID/schedule.yml" \
        --reason-code "SCHEDULE_MUTATION_${KIND^^}" \
        --policy-ref ".octon/instance/governance/policies/mission-autonomy.yml" \
        --directive-ref "$DIRECTIVE_ID" \
        --affected-path ".octon/state/control/execution/missions/$MISSION_ID/schedule.yml")"
      RECEIPT_PATH="${schedule_receipt#$ROOT_DIR/}" \
      yq -i '.last_schedule_mutation_ref = strenv(RECEIPT_PATH)' "$schedule_file"
    fi

    effect_type="$(effect_receipt_type "$KIND" "$STATE")"
    receipt_path="$(bash "$RECEIPT_WRITER" \
      --mission-id "$MISSION_ID" \
      --receipt-type "$effect_type" \
      --issued-by "$ISSUED_BY" \
      --reason "${REASON:-Apply mission directive $KIND}" \
      --new-state-ref ".octon/state/control/execution/missions/$MISSION_ID/directives.yml" \
      --reason-code "DIRECTIVE_STATE_${STATE^^}" \
      --policy-ref ".octon/instance/governance/ownership/registry.yml" \
      --directive-ref "$DIRECTIVE_ID" \
      --affected-path ".octon/state/control/execution/missions/$MISSION_ID/directives.yml")"

    RECEIPT_PATH="${receipt_path#$ROOT_DIR/}" \
    DIRECTIVE_ID_VAR="$DIRECTIVE_ID" \
    yq -i '
      (.directives[] | select(.directive_id == strenv(DIRECTIVE_ID_VAR))).consumed_by_receipt_ref = strenv(RECEIPT_PATH)
    ' "$directives_file"
  fi

  if [[ -x "$ROUTE_PUBLISHER" ]]; then
    bash "$ROUTE_PUBLISHER" --mission-id "$MISSION_ID" >/dev/null
  fi
  if [[ -x "$SYNC_RUNTIME_ARTIFACTS" ]]; then
    bash "$SYNC_RUNTIME_ARTIFACTS" --target missions >/dev/null
  fi

  printf '%s\n' "$directives_file"
}

main "$@"
