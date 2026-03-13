#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd -- "$OPS_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$ORCHESTRATION_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$OCTON_DIR/.." && pwd)"

LOOKUP_SCRIPT=".octon/orchestration/runtime/_ops/scripts/lookup-orchestration-lineage.sh"
RUN_HEALTH_SCRIPT=".octon/orchestration/runtime/_ops/scripts/inspect-run-health.sh"
WATCHER_SUMMARY_SCRIPT=".octon/orchestration/runtime/_ops/scripts/summarize-watcher-health.sh"
QUEUE_SUMMARY_SCRIPT=".octon/orchestration/runtime/_ops/scripts/summarize-queue-health.sh"
AUTOMATION_SUMMARY_SCRIPT=".octon/orchestration/runtime/_ops/scripts/summarize-automation-health.sh"
MISSION_SUMMARY_SCRIPT=".octon/orchestration/runtime/_ops/scripts/summarize-mission-health.sh"
INCIDENT_SUMMARY_SCRIPT=".octon/orchestration/runtime/_ops/scripts/summarize-incident-health.sh"
CLOSURE_SCRIPT=".octon/orchestration/runtime/_ops/scripts/check-incident-closure-readiness.sh"
SNAPSHOT_SCRIPT=".octon/orchestration/runtime/_ops/scripts/generate-ops-snapshot.sh"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    [[ -n "$path" ]] && rm -rf "$path"
  done
  rm -f /tmp/octon-orch-ops-event.json
}
trap cleanup EXIT

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

snapshot_runtime_tree() {
  local fixture_root="$1"
  (
    cd "$fixture_root"
    find .octon/orchestration .octon/continuity -type f -print | sort | while IFS= read -r file; do
      shasum "$file"
    done
  )
}

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/orchestration-operator.XXXXXX")"
  cleanup_paths+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/orchestration/runtime/runs/by-surface/workflows" \
    "$fixture_root/.octon/orchestration/runtime/runs/by-surface/missions" \
    "$fixture_root/.octon/orchestration/runtime/runs/by-surface/automations" \
    "$fixture_root/.octon/orchestration/runtime/runs/by-surface/incidents" \
    "$fixture_root/.octon/orchestration/runtime/queue/pending" \
    "$fixture_root/.octon/orchestration/runtime/queue/claimed" \
    "$fixture_root/.octon/orchestration/runtime/queue/retry" \
    "$fixture_root/.octon/orchestration/runtime/queue/dead-letter" \
    "$fixture_root/.octon/orchestration/runtime/queue/receipts" \
    "$fixture_root/.octon/orchestration/runtime/watchers/example/state" \
    "$fixture_root/.octon/orchestration/runtime/automations/example/state" \
    "$fixture_root/.octon/orchestration/runtime/missions/example/context" \
    "$fixture_root/.octon/orchestration/runtime/incidents/inc-001" \
    "$fixture_root/.octon/orchestration/runtime/workflows/example/sample" \
    "$fixture_root/.octon/continuity/decisions/dec-001" \
    "$fixture_root/.octon/continuity/runs/run-001" \
    "$fixture_root/.octon/orchestration/governance" \
    "$fixture_root/.octon/output/reports"

  cat > "$fixture_root/.octon/orchestration/runtime/queue/registry.yml" <<'EOF'
schema_version: "orchestration-queue-registry-v1"
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/runs/index.yml" <<'EOF'
schema_version: "orchestration-runs-index-v1"
runs: []
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/incidents/index.yml" <<'EOF'
schema_version: "orchestration-incidents-index-v1"
incidents: []
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/missions/registry.yml" <<'EOF'
schema_version: "1.0"
active: []
archived: []
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/watchers/example/watcher.yml" <<'EOF'
watcher_id: "example"
title: "Example Watcher"
owner: "@architect"
status: "active"
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/watchers/example/state/health.json" <<'EOF'
{
  "status": "healthy",
  "checked_at": "2026-03-11T10:00:00Z"
}
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/watchers/example/state/suppressions.json" <<'EOF'
{
  "suppressed": ["evt-old"]
}
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/automations/example/automation.yml" <<'EOF'
automation_id: "example"
title: "Example Automation"
workflow_ref:
  workflow_group: "example"
  workflow_id: "sample"
owner: "@architect"
status: "active"
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/automations/example/state/counters.json" <<'EOF'
{
  "blocked": 2
}
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/automations/example/state/status.json" <<'EOF'
{
  "status": "active"
}
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/missions/example/mission.yml" <<'EOF'
schema_version: "mission-object-v1"
mission_id: "example"
title: "Example Mission"
summary: "Example mission."
status: "active"
owner: "@architect"
created_at: "2026-03-10T00:00:00Z"
active_run_ids:
  - "run-001"
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/missions/example/tasks.json" <<'EOF'
{
  "tasks": [
    {"id": "t1", "status": "blocked"},
    {"id": "t2", "status": "open"},
    {"id": "t3", "status": "done"}
  ]
}
EOF
  cat > "$fixture_root/.octon/continuity/decisions/dec-001/decision.json" <<'EOF'
{
  "decision_id": "dec-001",
  "outcome": "allow",
  "surface": "automations",
  "action": "launch",
  "actor": "example",
  "summary": "Allowed.",
  "run_id": "run-001",
  "automation_id": "example",
  "event_id": "evt-001",
  "queue_item_id": "q-001",
  "workflow_ref": {
    "workflow_group": "example",
    "workflow_id": "sample"
  }
}
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/runs/run-001.yml" <<'EOF'
run_id: "run-001"
status: "running"
started_at: "2026-03-11T10:10:00Z"
decision_id: "dec-001"
continuity_run_path: ".octon/continuity/runs/run-001/"
summary: "Example run"
executor_id: "exec-1"
executor_acknowledged_at: "2026-03-11T10:10:01Z"
last_heartbeat_at: "2026-03-11T10:15:00Z"
lease_expires_at: "2099-03-11T10:20:00Z"
recovery_status: "healthy"
workflow_ref:
  workflow_group: "example"
  workflow_id: "sample"
automation_id: "example"
mission_id: "example"
incident_id: "inc-001"
queue_item_id: "q-001"
event_id: "evt-001"
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/queue/pending/q-001.json" <<'EOF'
{
  "queue_item_id": "q-001",
  "target_automation_id": "example",
  "status": "pending",
  "summary": "Queued.",
  "event_id": "evt-001",
  "watcher_id": "example",
  "payload_ref": "/tmp/octon-orch-ops-event.json",
  "enqueued_at": "2026-03-11T10:05:00Z",
  "available_at": "2026-03-11T10:05:00Z"
}
EOF
  cat > /tmp/octon-orch-ops-event.json <<'EOF'
{
  "event_id": "evt-001",
  "emitted_at": "2026-03-11T10:04:00Z"
}
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/queue/receipts/q-001-ack-20260311T101600Z.json" <<'EOF'
{
  "queue_item_id": "q-001",
  "handled_at": "2026-03-11T10:16:00Z"
}
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/incidents/inc-001/incident.yml" <<'EOF'
incident_id: "inc-001"
title: "Example Incident"
severity: "sev2"
status: "closed"
owner: "@architect"
summary: "Incident summary"
run_ids:
  - "run-001"
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/incidents/inc-001/timeline.md" <<'EOF'
# Incident Timeline: inc-001

- 2026-03-11T10:20:00Z: incident updated
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/incidents/inc-001/closure.md" <<'EOF'
# Incident Closure: inc-001

- Closed At: `2026-03-11T10:30:00Z`
- Closed By: `@architect`
- Approval: `appr-001`

Closed with evidence.

## Remediation Evidence

- Remediation Ref: `run:run-001`
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/workflows/example/sample/workflow.yml" <<'EOF'
schema_version: "workflow-contract-v1"
name: "sample"
description: "Example workflow."
version: "1.0.0"
entry_mode: "human"
execution_profile: "core"
stages: []
done_gate:
  checks: []
EOF

  printf '%s\n' "$fixture_root"
}

case_lookup_and_summary_commands() {
  local fixture_root envs run_lookup event_lookup queue_summary watcher_summary automation_summary mission_summary incident_summary
  fixture_root="$(create_fixture)"
  envs=("OCTON_DIR_OVERRIDE=$fixture_root/.octon" "OCTON_ROOT_DIR=$fixture_root" "OCTON_RUNTIME_PREFER_SOURCE=1")

  run_lookup="$(env "${envs[@]}" bash "$REPO_ROOT/$LOOKUP_SCRIPT" --run-id run-001)"
  jq -e '.artifacts | any(.kind == "decision" and .id == "dec-001") and any(.kind == "queue_item" and .id == "q-001")' <<<"$run_lookup" >/dev/null

  event_lookup="$(env "${envs[@]}" bash "$REPO_ROOT/$LOOKUP_SCRIPT" --event-id evt-001)"
  jq -e '.artifacts | any(.kind == "run" and .id == "run-001") and any(.kind == "queue_item" and .id == "q-001")' <<<"$event_lookup" >/dev/null

  queue_summary="$(env "${envs[@]}" bash "$REPO_ROOT/$QUEUE_SUMMARY_SCRIPT")"
  jq -e '.payload.pending_count == 1 and .payload.last_receipt_at == "2026-03-11T10:16:00Z"' <<<"$queue_summary" >/dev/null

  watcher_summary="$(env "${envs[@]}" bash "$REPO_ROOT/$WATCHER_SUMMARY_SCRIPT")"
  jq -e '.payload[0].watcher_id == "example" and .payload[0].suppressed_count == 1' <<<"$watcher_summary" >/dev/null

  automation_summary="$(env "${envs[@]}" bash "$REPO_ROOT/$AUTOMATION_SUMMARY_SCRIPT")"
  jq -e '.payload[0].automation_id == "example" and .payload[0].suppression_count == 2' <<<"$automation_summary" >/dev/null

  mission_summary="$(env "${envs[@]}" bash "$REPO_ROOT/$MISSION_SUMMARY_SCRIPT")"
  jq -e '.payload[0].mission_id == "example" and .payload[0].blocked_task_count == 1' <<<"$mission_summary" >/dev/null

  incident_summary="$(env "${envs[@]}" bash "$REPO_ROOT/$INCIDENT_SUMMARY_SCRIPT")"
  jq -e '.payload[0].incident_id == "inc-001" and .payload[0].closure_ready == true' <<<"$incident_summary" >/dev/null
}

case_run_health_and_closure_readiness() {
  local fixture_root envs run_health blocked_readiness ready_readiness
  fixture_root="$(create_fixture)"
  envs=("OCTON_DIR_OVERRIDE=$fixture_root/.octon" "OCTON_ROOT_DIR=$fixture_root" "OCTON_RUNTIME_PREFER_SOURCE=1")

  run_health="$(env "${envs[@]}" bash "$REPO_ROOT/$RUN_HEALTH_SCRIPT" --run-id run-001)"
  jq -e '.artifacts | any(.kind == "run" and .details.decision_link_health == "healthy" and .details.evidence_link_health == "healthy")' <<<"$run_health" >/dev/null

  cat > "$fixture_root/.octon/orchestration/runtime/incidents/inc-001/incident.yml" <<'EOF'
incident_id: "inc-001"
title: "Example Incident"
severity: "sev2"
status: "open"
owner: "@architect"
summary: "Incident summary"
EOF
  rm -f "$fixture_root/.octon/orchestration/runtime/incidents/inc-001/closure.md"
  blocked_readiness="$(env "${envs[@]}" bash "$REPO_ROOT/$CLOSURE_SCRIPT" --incident-id inc-001)"
  jq -e '.ready == false and (.blockers | index("missing linked runs")) != null and (.blockers | index("missing closure.md")) != null' <<<"$blocked_readiness" >/dev/null

  cat > "$fixture_root/.octon/orchestration/runtime/incidents/inc-001/incident.yml" <<'EOF'
incident_id: "inc-001"
title: "Example Incident"
severity: "sev2"
status: "closed"
owner: "@architect"
summary: "Incident summary"
run_ids:
  - "run-001"
EOF
  cat > "$fixture_root/.octon/orchestration/runtime/incidents/inc-001/closure.md" <<'EOF'
# Incident Closure: inc-001

- Closed At: `2026-03-11T10:30:00Z`
- Closed By: `@architect`
- Approval: `appr-001`

Closed with evidence.

## Remediation Evidence

- Remediation Ref: `run:run-001`
EOF
  ready_readiness="$(env "${envs[@]}" bash "$REPO_ROOT/$CLOSURE_SCRIPT" --incident-id inc-001)"
  jq -e '.ready == true and (.blockers | length) == 0' <<<"$ready_readiness" >/dev/null
}

case_wrappers_are_read_only_and_snapshot_writes_report() {
  local fixture_root envs before after report_path
  fixture_root="$(create_fixture)"
  envs=("OCTON_DIR_OVERRIDE=$fixture_root/.octon" "OCTON_ROOT_DIR=$fixture_root" "OCTON_RUNTIME_PREFER_SOURCE=1")

  before="$(snapshot_runtime_tree "$fixture_root")"
  env "${envs[@]}" bash "$REPO_ROOT/$LOOKUP_SCRIPT" --run-id run-001 >/dev/null
  env "${envs[@]}" bash "$REPO_ROOT/$RUN_HEALTH_SCRIPT" --run-id run-001 >/dev/null
  env "${envs[@]}" bash "$REPO_ROOT/$WATCHER_SUMMARY_SCRIPT" >/dev/null
  env "${envs[@]}" bash "$REPO_ROOT/$QUEUE_SUMMARY_SCRIPT" >/dev/null
  env "${envs[@]}" bash "$REPO_ROOT/$AUTOMATION_SUMMARY_SCRIPT" >/dev/null
  env "${envs[@]}" bash "$REPO_ROOT/$MISSION_SUMMARY_SCRIPT" >/dev/null
  env "${envs[@]}" bash "$REPO_ROOT/$INCIDENT_SUMMARY_SCRIPT" >/dev/null
  env "${envs[@]}" bash "$REPO_ROOT/$CLOSURE_SCRIPT" --incident-id inc-001 >/dev/null
  after="$(snapshot_runtime_tree "$fixture_root")"
  [[ "$before" == "$after" ]]

  report_path="$(env "${envs[@]}" bash "$REPO_ROOT/$SNAPSHOT_SCRIPT")"
  [[ -f "$report_path" ]]
  grep -q "Orchestration Summary" "$report_path"
  after="$(snapshot_runtime_tree "$fixture_root")"
  [[ "$before" == "$after" ]]
}

assert_success "operator wrappers resolve lineage and surface summaries" case_lookup_and_summary_commands
assert_success "run health and incident closure readiness wrappers report expected states" case_run_health_and_closure_readiness
assert_success "operator wrappers remain read-only while ops snapshot writes only the subordinate report" case_wrappers_are_read_only_and_snapshot_writes_report

if (( fail_count > 0 )); then
  echo "FAILURES: $fail_count" >&2
  exit 1
fi

echo "PASS: $pass_count"
