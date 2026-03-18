#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools yq jq

ensure_dir "$RUNTIME_DIR/incidents"
[[ -f "$RUNTIME_DIR/incidents/index.yml" ]] || cat > "$RUNTIME_DIR/incidents/index.yml" <<'EOF'
schema_version: "orchestration-incidents-index-v1"
incidents: []
EOF

usage() {
  cat <<'EOF'
Usage:
  manage-incident.sh open --incident-id <id> --title <text> --severity <sev0|sev1|sev2|sev3> --owner <id> --summary <text> [options]
  manage-incident.sh update --incident-id <id> [--status <status>] [--severity <severity>] [--owner <id>] [--summary <text>] [--run-id <id>] [--mission-id <id>] [--decision-id <id>]
  manage-incident.sh close --incident-id <id> --closed-by <id> --approval-id <id> --closure-summary <text> [--remediation-ref <ref>] [--waiver-ref <ref>] [--run-note <text>]
EOF
}

incident_index_upsert() {
  local incident_id="$1"
  local status="$2"
  local severity="$3"
  local owner="$4"
  yq -o=json '.' "$RUNTIME_DIR/incidents/index.yml" | jq \
    --arg incident_id "$incident_id" \
    --arg status "$status" \
    --arg severity "$severity" \
    --arg owner "$owner" '
    .incidents = (.incidents // []) |
    .incidents |= map(select(.incident_id != $incident_id)) |
    .incidents += [{incident_id:$incident_id,status:$status,severity:$severity,owner:$owner,path:($incident_id + "/incident.yml")}]
  ' | yq -P -p=json '.' > "$RUNTIME_DIR/incidents/index.yml"
}

cmd="${1:-}"
shift || true

case "$cmd" in
  open)
    incident_id=""
    title=""
    severity=""
    owner=""
    summary=""
    run_id=""
    mission_id=""
    decision_id=""
    event_id=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --incident-id) incident_id="$2"; shift 2 ;;
        --title) title="$2"; shift 2 ;;
        --severity) severity="$2"; shift 2 ;;
        --owner) owner="$2"; shift 2 ;;
        --summary) summary="$2"; shift 2 ;;
        --run-id) run_id="$2"; shift 2 ;;
        --mission-id) mission_id="$2"; shift 2 ;;
        --decision-id) decision_id="$2"; shift 2 ;;
        --event-id) event_id="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$incident_id" && -n "$title" && -n "$severity" && -n "$owner" && -n "$summary" ]] || { usage; exit 1; }
    incident_dir="$RUNTIME_DIR/incidents/$incident_id"
    [[ ! -e "$incident_dir" ]] || { echo "incident already exists: $incident_id" >&2; exit 1; }
    ensure_dir "$incident_dir"
    created_at="$(now_utc)"
    jq -n \
      --arg incident_id "$incident_id" \
      --arg title "$title" \
      --arg severity "$severity" \
      --arg owner "$owner" \
      --arg created_at "$created_at" \
      --arg summary "$summary" \
      --arg run_id "$run_id" \
      --arg mission_id "$mission_id" \
      --arg decision_id "$decision_id" \
      --arg event_id "$event_id" '
      {
        incident_id:$incident_id,
        title:$title,
        severity:$severity,
        status:"open",
        owner:$owner,
        created_at:$created_at,
        summary:$summary
      }
      + (if $run_id != "" then {run_ids:[$run_id]} else {} end)
      + (if $mission_id != "" then {mission_ids:[$mission_id]} else {} end)
      + (if $decision_id != "" then {decision_ids:[$decision_id]} else {} end)
      + (if $event_id != "" then {event_ids:[$event_id]} else {} end)
    ' | yq -P -p=json '.' > "$incident_dir/incident.yml"
    cat > "$incident_dir/timeline.md" <<EOF
# Incident Timeline: ${incident_id}

- ${created_at}: incident opened with severity \`${severity}\` by \`${owner}\`
EOF
    incident_index_upsert "$incident_id" "open" "$severity" "$owner"
    echo "$incident_dir/incident.yml"
    ;;
  update)
    incident_id=""
    status=""
    severity=""
    owner=""
    summary=""
    run_id=""
    mission_id=""
    decision_id=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --incident-id) incident_id="$2"; shift 2 ;;
        --status) status="$2"; shift 2 ;;
        --severity) severity="$2"; shift 2 ;;
        --owner) owner="$2"; shift 2 ;;
        --summary) summary="$2"; shift 2 ;;
        --run-id) run_id="$2"; shift 2 ;;
        --mission-id) mission_id="$2"; shift 2 ;;
        --decision-id) decision_id="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$incident_id" ]] || { usage; exit 1; }
    incident_dir="$RUNTIME_DIR/incidents/$incident_id"
    incident_file="$incident_dir/incident.yml"
    [[ -f "$incident_file" ]] || { echo "incident not found: $incident_id" >&2; exit 1; }
    incident_json="$(yq -o=json '.' "$incident_file")"
    now="$(now_utc)"
    incident_json="$(jq \
      --arg status "$status" \
      --arg severity "$severity" \
      --arg owner "$owner" \
      --arg summary "$summary" \
      --arg run_id "$run_id" \
      --arg mission_id "$mission_id" \
      --arg decision_id "$decision_id" '
      (if $status != "" then .status = $status else . end)
      | (if $severity != "" then .severity = $severity else . end)
      | (if $owner != "" then .owner = $owner else . end)
      | (if $summary != "" then .summary = $summary else . end)
      | (if $run_id != "" then .run_ids = ((.run_ids // []) + [$run_id] | unique) else . end)
      | (if $mission_id != "" then .mission_ids = ((.mission_ids // []) + [$mission_id] | unique) else . end)
      | (if $decision_id != "" then .decision_ids = ((.decision_ids // []) + [$decision_id] | unique) else . end)
    ' <<<"$incident_json")"
    printf '%s\n' "$incident_json" | yq -P -p=json '.' > "$incident_file"
    {
      echo
      echo "- ${now}: incident updated"
    } >> "$incident_dir/timeline.md"
    incident_index_upsert "$incident_id" "$(yq -r '.status' "$incident_file")" "$(yq -r '.severity' "$incident_file")" "$(yq -r '.owner' "$incident_file")"
    echo "$incident_file"
    ;;
  close)
    incident_id=""
    closed_by=""
    approval_id=""
    closure_summary=""
    remediation_ref=""
    waiver_ref=""
    run_note=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --incident-id) incident_id="$2"; shift 2 ;;
        --closed-by) closed_by="$2"; shift 2 ;;
        --approval-id) approval_id="$2"; shift 2 ;;
        --closure-summary) closure_summary="$2"; shift 2 ;;
        --remediation-ref) remediation_ref="$2"; shift 2 ;;
        --waiver-ref) waiver_ref="$2"; shift 2 ;;
        --run-note) run_note="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$incident_id" && -n "$closed_by" && -n "$approval_id" && -n "$closure_summary" ]] || { usage; exit 1; }
    [[ -n "$remediation_ref" || -n "$waiver_ref" ]] || { echo "closure requires remediation-ref or waiver-ref" >&2; exit 1; }
    incident_dir="$RUNTIME_DIR/incidents/$incident_id"
    incident_file="$incident_dir/incident.yml"
    [[ -f "$incident_file" ]] || { echo "incident not found: $incident_id" >&2; exit 1; }
    bash "$SCRIPT_DIR/verify-approval-artifact.sh" --approval-id "$approval_id" --action-class "close-incident" --surface "incidents" >/dev/null
    closed_at="$(now_utc)"
    incident_json="$(yq -o=json '.' "$incident_file" | jq \
      --arg closed_at "$closed_at" \
      --arg closed_by "$closed_by" '
      .status = "closed"
      | .closed_at = $closed_at
      | .closed_by = $closed_by
    ')"
    printf '%s\n' "$incident_json" | yq -P -p=json '.' > "$incident_file"
    cat > "$incident_dir/closure.md" <<EOF
# Incident Closure: ${incident_id}

- Closed At: \`${closed_at}\`
- Closed By: \`${closed_by}\`
- Approval: \`${approval_id}\`

${closure_summary}

## Remediation Evidence

${remediation_ref:+- Remediation Ref: \`${remediation_ref}\`}
${waiver_ref:+- Waiver Ref: \`${waiver_ref}\`}
${run_note:+- Run Note: ${run_note}}
EOF
    {
      echo
      echo "- ${closed_at}: incident closed by \`${closed_by}\`"
    } >> "$incident_dir/timeline.md"
    incident_index_upsert "$incident_id" "closed" "$(yq -r '.severity' "$incident_file")" "$(yq -r '.owner' "$incident_file")"
    echo "$incident_file"
    ;;
  *)
    usage
    exit 1
    ;;
esac
