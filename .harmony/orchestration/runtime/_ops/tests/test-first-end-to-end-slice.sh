#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd -- "$OPS_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="$(cd -- "$ORCHESTRATION_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$HARMONY_DIR/.." && pwd)"

EMIT_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/emit-watcher-event.sh"
ROUTE_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/route-watcher-event.sh"
QUEUE_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/manage-queue.sh"
LAUNCH_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/launch-automation-run.sh"
RECONCILE_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/reconcile-orchestration-runtime.sh"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    [[ -n "$path" ]] && rm -rf "$path"
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
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/orchestration-first-slice.XXXXXX")"
  cleanup_paths+=("$fixture_root")

  mkdir -p "$fixture_root/.harmony/orchestration/runtime"
  mkdir -p "$fixture_root/.harmony/continuity/decisions"
  mkdir -p "$fixture_root/.harmony/continuity/runs"

  cp -R "$REPO_ROOT/.harmony/orchestration/runtime" "$fixture_root/.harmony/orchestration/"
  cp "$REPO_ROOT/.harmony/continuity/decisions/README.md" "$fixture_root/.harmony/continuity/decisions/README.md"
  cp "$REPO_ROOT/.harmony/continuity/decisions/retention.json" "$fixture_root/.harmony/continuity/decisions/retention.json"
  cp "$REPO_ROOT/.harmony/continuity/runs/README.md" "$fixture_root/.harmony/continuity/runs/README.md"

  printf '%s\n' "$fixture_root"
}

case_first_slice_round_trip() {
  local fixture_root event_file route_output claim_output launch_output reconcile_output claim_token run_file
  fixture_root="$(create_fixture)"
  local envs=("HARMONY_DIR_OVERRIDE=$fixture_root/.harmony" "HARMONY_ROOT_DIR=$fixture_root")

  event_file="$fixture_root/runtime-contract-drift-event.json"
  env "${envs[@]}" bash "$REPO_ROOT/$EMIT_SCRIPT" \
    --watcher-id runtime-contract-drift-watcher \
    --rule-id workflow-contract-drift \
    --source-ref .harmony/orchestration/runtime/workflows \
    --event-id evt-first-slice-001 \
    --output-file "$event_file" >/dev/null
  [[ -f "$event_file" ]]

  route_output="$(env "${envs[@]}" bash "$REPO_ROOT/$ROUTE_SCRIPT" --event-file "$event_file")"
  jq -e 'length == 1 and .[0].automation_id == "runtime-contract-drift-remediation"' <<<"$route_output" >/dev/null

  claim_output="$(env "${envs[@]}" bash "$REPO_ROOT/$QUEUE_SCRIPT" claim --claimed-by runtime-contract-drift-remediation --lease-seconds 300)"
  claim_token="$(jq -r '.claim_token' <<<"$claim_output")"
  [[ -n "$claim_token" && "$claim_token" != "null" ]]

  launch_output="$(env "${envs[@]}" bash "$REPO_ROOT/$LAUNCH_SCRIPT" \
    --queue-item-id q-evt-first-slice-001-runtime-contract-drift-remediation \
    --claim-token "$claim_token" \
    --executor-id executor-first-slice \
    --lease-seconds 300)"
  jq -e '.run_id == "run-runtime-contract-drift-remediation-evt-first-slice-001" and .decision_id == "dec-runtime-contract-drift-remediation-evt-first-slice-001-allow"' <<<"$launch_output" >/dev/null

  run_file="$fixture_root/.harmony/orchestration/runtime/runs/run-runtime-contract-drift-remediation-evt-first-slice-001.yml"
  [[ -f "$run_file" ]]
  yq -o=json '.' "$run_file" | jq -e '.status == "running" and .executor_acknowledged_at != null and .recovery_status == "healthy"' >/dev/null

  # Simulate heartbeat expiry to prove deterministic reconciliation.
  yq -o=json '.' "$run_file" | jq '.lease_expires_at = "2000-01-01T00:00:00Z"' | yq -P -p=json '.' > "$run_file.tmp"
  mv "$run_file.tmp" "$run_file"

  reconcile_output="$(env "${envs[@]}" bash "$REPO_ROOT/$RECONCILE_SCRIPT" --now "2000-01-02T00:00:00Z")"
  jq -e 'length == 1 and .[0].reason == "heartbeat-expired"' <<<"$reconcile_output" >/dev/null
  yq -o=json '.' "$run_file" | jq -e '.recovery_status == "recovery_pending" and .recovery_reason == "heartbeat-expired"' >/dev/null
}

assert_success "first end-to-end slice round-trip" case_first_slice_round_trip

if (( fail_count > 0 )); then
  echo "FAILURES: $fail_count" >&2
  exit 1
fi

echo "PASS: $pass_count"
