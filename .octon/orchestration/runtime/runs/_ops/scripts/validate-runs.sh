#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SCRIPT="$SCRIPT_DIR/../../../_ops/scripts/validate-surface-common.sh"
source "$COMMON_SCRIPT"

surface_common_init "${BASH_SOURCE[0]}" "runs"

if ! command -v yq >/dev/null 2>&1; then
  fail "yq is required for runs validation"
  finish_surface_validation "runs"
fi

if ! surface_has_any_marker "README.md" "index.yml"; then
  surface_skip_not_promoted
fi

require_file_rel "README.md"
require_file_rel "index.yml"
require_dir_rel "by-surface"
require_dir_rel "by-surface/workflows"
require_dir_rel "by-surface/missions"
require_dir_rel "by-surface/automations"
require_dir_rel "by-surface/incidents"

validate_run_record() {
  local rel_file="$1"
  local run_file="$SURFACE_DIR/$rel_file"
  local run_id status started_at completed_at decision_id continuity_run_path summary
  local executor_id executor_ack heartbeat lease_expires recovery_status

  run_id="$(yq -r '.run_id // ""' "$run_file")"
  status="$(yq -r '.status // ""' "$run_file")"
  started_at="$(yq -r '.started_at // ""' "$run_file")"
  completed_at="$(yq -r '.completed_at // ""' "$run_file")"
  decision_id="$(yq -r '.decision_id // ""' "$run_file")"
  continuity_run_path="$(yq -r '.continuity_run_path // ""' "$run_file")"
  summary="$(yq -r '.summary // ""' "$run_file")"
  executor_id="$(yq -r '.executor_id // ""' "$run_file")"
  executor_ack="$(yq -r '.executor_acknowledged_at // ""' "$run_file")"
  heartbeat="$(yq -r '.last_heartbeat_at // ""' "$run_file")"
  lease_expires="$(yq -r '.lease_expires_at // ""' "$run_file")"
  recovery_status="$(yq -r '.recovery_status // ""' "$run_file")"

  [[ "$run_id" == "${rel_file%.yml}" ]] && pass "run '$run_id' file name matches run_id" || fail "run record '$rel_file' must match run_id"
  case "$status" in
    running|succeeded|failed|cancelled) pass "run '$run_id' status valid: $status" ;;
    *) fail "run '$run_id' has invalid status '$status'" ;;
  esac
  [[ "$started_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$ ]] && pass "run '$run_id' started_at is ISO-like" || fail "run '$run_id' started_at must be ISO timestamp"
  [[ -n "$decision_id" && -f "$OCTON_DIR/continuity/decisions/$decision_id/decision.json" ]] && pass "run '$run_id' decision link resolves" || fail "run '$run_id' decision link missing"
  [[ -n "$continuity_run_path" && -d "$OCTON_DIR/${continuity_run_path#.octon/}" ]] && pass "run '$run_id' continuity path resolves" || fail "run '$run_id' continuity path missing"
  [[ -n "$summary" ]] && pass "run '$run_id' summary present" || fail "run '$run_id' summary missing"

  if [[ "$status" == "running" ]]; then
    [[ -n "$executor_id" ]] && pass "run '$run_id' executor owner present" || fail "run '$run_id' running state requires executor_id"
    [[ "$executor_ack" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$ ]] && pass "run '$run_id' executor acknowledgement present" || fail "run '$run_id' running state requires executor_acknowledged_at"
    [[ "$heartbeat" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$ ]] && pass "run '$run_id' heartbeat present" || fail "run '$run_id' running state requires last_heartbeat_at"
    [[ "$lease_expires" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$ ]] && pass "run '$run_id' lease expiry present" || fail "run '$run_id' running state requires lease_expires_at"
    case "$recovery_status" in
      healthy|suspect|recovery_pending|recovered|abandoned) pass "run '$run_id' recovery_status valid: $recovery_status" ;;
      *) fail "run '$run_id' running state requires valid recovery_status" ;;
    esac
  else
    [[ "$completed_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$ ]] && pass "run '$run_id' terminal completed_at present" || fail "run '$run_id' terminal state requires completed_at"
  fi
}

while IFS= read -r run_file; do
  validate_run_record "${run_file#$SURFACE_DIR/}"
done < <(find "$SURFACE_DIR" -maxdepth 1 -type f -name '*.yml' ! -name 'index.yml' | sort)

finish_surface_validation "runs"
