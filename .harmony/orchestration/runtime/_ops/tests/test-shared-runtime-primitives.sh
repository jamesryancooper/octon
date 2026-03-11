#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd -- "$OPS_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="$(cd -- "$ORCHESTRATION_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$HARMONY_DIR/.." && pwd)"

DISCOVERY_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/load-orchestration-discovery.sh"
DECISION_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/write-decision.sh"
RUN_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/write-run.sh"
LOCK_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/manage-coordination-lock.sh"
QUEUE_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/manage-queue.sh"
RUNTIME_VALIDATE=".harmony/orchestration/runtime/_ops/scripts/validate-orchestration-runtime.sh"

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
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/orchestration-primitives.XXXXXX")"
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

case_primitives_round_trip() {
  local fixture_root
  fixture_root="$(create_fixture)"

  local envs=("HARMONY_DIR_OVERRIDE=$fixture_root/.harmony" "HARMONY_ROOT_DIR=$fixture_root")

  discovery_output="$(env "${envs[@]}" bash "$REPO_ROOT/$DISCOVERY_SCRIPT" resolve-workflow --workflow-group meta --workflow-id create-harness)"
  jq -e '.workflow_ref.workflow_group == "meta" and .workflow_ref.workflow_id == "create-harness"' <<<"$discovery_output" >/dev/null

  decision_path="$(env "${envs[@]}" bash "$REPO_ROOT/$DECISION_SCRIPT" \
    --decision-id dec-test-001 \
    --outcome allow \
    --surface workflows \
    --action launch-workflow \
    --actor create-harness \
    --workflow-group meta \
    --workflow-id create-harness \
    --reason-code target-resolved \
    --summary 'Create harness workflow admitted for execution.')"
  [[ -f "$decision_path" ]]

  run_path="$(env "${envs[@]}" bash "$REPO_ROOT/$RUN_SCRIPT" create \
    --run-id run-test-001 \
    --decision-id dec-test-001 \
    --summary 'Create harness run started.' \
    --workflow-group meta \
    --workflow-id create-harness \
    --executor-id executor-test-01 \
    --lease-seconds 300)"
  [[ -f "$run_path" ]]

  lock_output="$(env "${envs[@]}" bash "$REPO_ROOT/$LOCK_SCRIPT" acquire \
    --coordination-key workflow:meta/create-harness \
    --lock-class exclusive \
    --owner-run-id run-test-001 \
    --lease-seconds 300)"
  jq -e '.status == "acquired"' <<<"$lock_output" >/dev/null

  queue_path="$(env "${envs[@]}" bash "$REPO_ROOT/$QUEUE_SCRIPT" enqueue \
    --queue-item-id q-test-001 \
    --target-automation-id auto-test \
    --summary 'test enqueue')"
  [[ -f "$queue_path" ]]

  claim_output="$(env "${envs[@]}" bash "$REPO_ROOT/$QUEUE_SCRIPT" claim \
    --claimed-by auto-test \
    --lease-seconds 300)"
  claim_token="$(jq -r '.claim_token' <<<"$claim_output")"
  [[ -n "$claim_token" && "$claim_token" != "null" ]]

  receipt_path="$(env "${envs[@]}" bash "$REPO_ROOT/$QUEUE_SCRIPT" ack \
    --queue-item-id q-test-001 \
    --claim-token "$claim_token")"
  [[ -f "$receipt_path" ]]

  env ORCHESTRATION_RUNTIME_SKIP_PRIMITIVE_TEST=1 "${envs[@]}" bash "$REPO_ROOT/$RUNTIME_VALIDATE" >/dev/null
}

assert_success "shared runtime primitives round-trip" case_primitives_round_trip

if (( fail_count > 0 )); then
  echo "FAILURES: $fail_count" >&2
  exit 1
fi

echo "PASS: $pass_count"
