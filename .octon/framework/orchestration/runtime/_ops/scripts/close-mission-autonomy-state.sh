#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT_WRITER="$SCRIPT_DIR/write-mission-control-receipt.sh"
ROUTE_PUBLISHER="$SCRIPT_DIR/publish-mission-effective-route.sh"

MISSION_ID=""
ISSUED_BY=""
FINAL_STATUS="completed"

usage() {
  cat <<'USAGE'
Usage:
  close-mission-autonomy-state.sh --mission-id <id> --issued-by <ref> [--final-status completed|cancelled]
USAGE
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mission-id) MISSION_ID="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      --final-status) FINAL_STATUS="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$MISSION_ID" ]] || { echo "--mission-id is required" >&2; exit 1; }
  [[ -n "$ISSUED_BY" ]] || { echo "--issued-by is required" >&2; exit 1; }

  local mission_file="$OCTON_DIR/instance/orchestration/missions/$MISSION_ID/mission.yml"
  local control_dir="$OCTON_DIR/state/control/execution/missions/$MISSION_ID"
  local continuity_dir="$OCTON_DIR/state/continuity/repo/missions/$MISSION_ID"
  [[ -f "$mission_file" ]] || { echo "missing mission charter: ${mission_file#$ROOT_DIR/}" >&2; exit 1; }
  [[ -d "$control_dir" ]] || { echo "missing mission control dir: ${control_dir#$ROOT_DIR/}" >&2; exit 1; }
  [[ -d "$continuity_dir" ]] || { echo "missing mission continuity dir: ${continuity_dir#$ROOT_DIR/}" >&2; exit 1; }

  local ts
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  cat > "$control_dir/lease.yml" <<EOF
schema_version: "mission-control-lease-v1"
mission_id: "$MISSION_ID"
lease_id: "close-$MISSION_ID"
state: "revoked"
issued_by: "$ISSUED_BY"
issued_at: "$ts"
expires_at: "$ts"
continuation_scope:
  summary: "Closed mission autonomy continuation scope"
  allowed_execution_postures:
    - "one_shot"
  max_concurrent_runs: 0
  allowed_action_classes: []
  default_safing_subset:
    - "observe_only"
revocation_reason: "mission_closed"
last_reviewed_at: "$ts"
EOF

  cat > "$control_dir/mode-state.yml" <<EOF
schema_version: "mode-state-v1"
mission_id: "$MISSION_ID"
oversight_mode: "notify"
execution_posture: "one_shot"
safety_state: "paused"
phase: "closed"
active_run_ref: null
current_slice_ref: null
next_safe_interrupt_boundary_id: null
effective_scenario_resolution_ref: null
autonomy_burn_state: "healthy"
breaker_state: "healthy"
updated_at: "$ts"
EOF

  cat > "$continuity_dir/next-actions.yml" <<EOF
schema_version: "mission-next-actions-v1"
mission_id: "$MISSION_ID"
next_actions: []
EOF

  cat > "$continuity_dir/handoff.md" <<EOF
# Mission Handoff

- mission_id: \`$MISSION_ID\`
- final_status: \`$FINAL_STATUS\`
- closed_at: \`$ts\`
- follow_up: \`none\`
EOF

  bash "$ROUTE_PUBLISHER" --mission-id "$MISSION_ID" >/dev/null

  bash "$RECEIPT_WRITER" \
    --mission-id "$MISSION_ID" \
    --receipt-type "mission-close" \
    --issued-by "$ISSUED_BY" \
    --reason "Close mission autonomy control and continuity state" \
    --new-state-ref ".octon/state/control/execution/missions/$MISSION_ID/lease.yml" \
    --reason-code "MISSION_CONTROL_CLOSED" \
    --policy-ref ".octon/instance/governance/policies/mission-autonomy.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/lease.yml" \
    --affected-path ".octon/state/control/execution/missions/$MISSION_ID/mode-state.yml" \
    --affected-path ".octon/state/continuity/repo/missions/$MISSION_ID/next-actions.yml" \
    --affected-path ".octon/state/continuity/repo/missions/$MISSION_ID/handoff.md" \
    --affected-path ".octon/generated/effective/orchestration/missions/$MISSION_ID/scenario-resolution.yml" \
    >/dev/null
}

main "$@"
