#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd -- "$OPS_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$ORCHESTRATION_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$OCTON_DIR/.." && pwd)"

SCHEDULE_SCRIPT=".octon/orchestration/runtime/_ops/scripts/evaluate-automation-schedule.py"
SCHEDULE_LAUNCH_SCRIPT=".octon/orchestration/runtime/_ops/scripts/launch-scheduled-automation-run.sh"
SCHEDULE_FIXTURES_DIR=".octon/orchestration/runtime/_ops/fixtures/scheduling"
EMIT_SCRIPT=".octon/orchestration/runtime/_ops/scripts/emit-watcher-event.sh"
ROUTE_SCRIPT=".octon/orchestration/runtime/_ops/scripts/route-watcher-event.sh"
QUEUE_SCRIPT=".octon/orchestration/runtime/_ops/scripts/manage-queue.sh"
EVENT_LAUNCH_SCRIPT=".octon/orchestration/runtime/_ops/scripts/launch-automation-run.sh"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    [[ -n "$path" && -e "$path" ]] && rm -r "$path"
  done
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

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/automation-policy.XXXXXX")"
  cleanup_paths+=("$fixture_root")

  mkdir -p "$fixture_root/.octon/orchestration/runtime"
  mkdir -p "$fixture_root/.octon/continuity/decisions"
  mkdir -p "$fixture_root/.octon/continuity/runs"

  cp -R "$REPO_ROOT/.octon/orchestration/runtime" "$fixture_root/.octon/orchestration/"
  cp "$REPO_ROOT/.octon/continuity/decisions/README.md" "$fixture_root/.octon/continuity/decisions/README.md"
  cp "$REPO_ROOT/.octon/continuity/decisions/retention.json" "$fixture_root/.octon/continuity/decisions/retention.json"
  cp "$REPO_ROOT/.octon/continuity/runs/README.md" "$fixture_root/.octon/continuity/runs/README.md"

  printf '%s\n' "$fixture_root"
}

case_schedule_dst_resolution() {
  local fixture_root spring_json fall_json spring_trigger fall_trigger
  fixture_root="$(create_fixture)"
  spring_trigger="$fixture_root/spring-trigger.yml"
  fall_trigger="$fixture_root/fall-trigger.yml"
  cat > "$spring_trigger" <<'EOF'
kind: "schedule"
schedule:
  cadence: "daily"
  at: "02:30"
  timezone: "America/Chicago"
  missed_run_policy: "next_window"
EOF
  cat > "$fall_trigger" <<'EOF'
kind: "schedule"
schedule:
  cadence: "daily"
  at: "01:30"
  timezone: "America/Chicago"
  missed_run_policy: "next_window"
EOF
  spring_json="$(python3 "$REPO_ROOT/$SCHEDULE_SCRIPT" --automation-id daily-harness-evaluation --trigger-file "$spring_trigger" --transition-file "$REPO_ROOT/$SCHEDULE_FIXTURES_DIR/dst-spring-forward.json")"
  fall_json="$(python3 "$REPO_ROOT/$SCHEDULE_SCRIPT" --automation-id daily-harness-evaluation --trigger-file "$fall_trigger" --transition-file "$REPO_ROOT/$SCHEDULE_FIXTURES_DIR/dst-fall-back.json")"
  jq -e '.resolved_local_time == "03:00" and .window_count == 1' <<<"$spring_json" >/dev/null
  jq -e '.resolved_local_time == "01:30" and .window_count == 1 and .selected_occurrence == "first"' <<<"$fall_json" >/dev/null
}

case_scheduled_launch_is_idempotent() {
  local fixture_root envs output
  fixture_root="$(create_fixture)"
  envs=("OCTON_DIR_OVERRIDE=$fixture_root/.octon" "OCTON_ROOT_DIR=$fixture_root")
  output="$(env "${envs[@]}" bash "$REPO_ROOT/$SCHEDULE_LAUNCH_SCRIPT" --automation-id daily-harness-evaluation --transition-file "$REPO_ROOT/$SCHEDULE_FIXTURES_DIR/dst-spring-forward.json" --executor-id executor-schedule)"
  jq -e '.run_id | startswith("run-daily-harness-evaluation:2026-03-08:03:00")' <<<"$output" >/dev/null
  if env "${envs[@]}" bash "$REPO_ROOT/$SCHEDULE_LAUNCH_SCRIPT" --automation-id daily-harness-evaluation --transition-file "$REPO_ROOT/$SCHEDULE_FIXTURES_DIR/dst-spring-forward.json" --executor-id executor-schedule >/dev/null 2>&1; then
    return 1
  fi
}

case_binding_failure_blocks_launch() {
  local fixture_root envs event_file claim_output claim_token
  fixture_root="$(create_fixture)"
  envs=("OCTON_DIR_OVERRIDE=$fixture_root/.octon" "OCTON_ROOT_DIR=$fixture_root")

  cat > "$fixture_root/.octon/orchestration/runtime/automations/runtime-contract-drift-remediation/bindings.yml" <<'EOF'
event_to_param_map:
  target_path:
    from: "event.payload.required_field"
    required: true
    value_type: "string"
EOF

  event_file="$fixture_root/runtime-contract-drift-event.json"
  env "${envs[@]}" bash "$REPO_ROOT/$EMIT_SCRIPT" \
    --watcher-id runtime-contract-drift-watcher \
    --rule-id workflow-contract-drift \
    --source-ref .octon/orchestration/runtime/workflows \
    --event-id evt-binding-fail-001 \
    --output-file "$event_file" >/dev/null
  env "${envs[@]}" bash "$REPO_ROOT/$ROUTE_SCRIPT" --event-file "$event_file" >/dev/null
  claim_output="$(env "${envs[@]}" bash "$REPO_ROOT/$QUEUE_SCRIPT" claim --claimed-by runtime-contract-drift-remediation --lease-seconds 300)"
  claim_token="$(jq -r '.claim_token' <<<"$claim_output")"
  if env "${envs[@]}" bash "$REPO_ROOT/$EVENT_LAUNCH_SCRIPT" --queue-item-id q-evt-binding-fail-001-runtime-contract-drift-remediation --claim-token "$claim_token" --executor-id executor-bindings >/dev/null 2>&1; then
    return 1
  fi
}

assert_success "schedule DST resolution is deterministic" case_schedule_dst_resolution
assert_success "scheduled launch is idempotent per schedule window" case_scheduled_launch_is_idempotent
assert_success "binding failure blocks event launch admission" case_binding_failure_blocks_launch

if (( fail_count > 0 )); then
  echo "FAILURES: $fail_count" >&2
  exit 1
fi

echo "PASS: $pass_count"
