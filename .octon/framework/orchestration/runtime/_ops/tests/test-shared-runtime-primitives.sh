#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd -- "$OPS_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ORCHESTRATION_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$OCTON_DIR/.." && pwd)"

DISCOVERY_SCRIPT=".octon/framework/orchestration/runtime/_ops/scripts/load-orchestration-discovery.sh"
DECISION_SCRIPT=".octon/framework/orchestration/runtime/_ops/scripts/write-decision.sh"
RUN_SCRIPT=".octon/framework/orchestration/runtime/_ops/scripts/write-run.sh"
LOCK_SCRIPT=".octon/framework/orchestration/runtime/_ops/scripts/manage-coordination-lock.sh"
QUEUE_SCRIPT=".octon/framework/orchestration/runtime/_ops/scripts/manage-queue.sh"
RUNTIME_VALIDATE=".octon/framework/orchestration/runtime/_ops/scripts/validate-orchestration-runtime.sh"

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
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/orchestration-primitives.XXXXXX")"
  cleanup_paths+=("$fixture_root")

  mkdir -p "$fixture_root/.octon/framework/orchestration/runtime"
  mkdir -p "$fixture_root/.octon/framework/orchestration/practices"
  mkdir -p "$fixture_root/.octon/state/evidence/decisions/repo"
  mkdir -p "$fixture_root/.octon/state/evidence/runs"
  mkdir -p "$fixture_root/.octon/instance/cognition/context/shared"

  cp -R "$REPO_ROOT/.octon/framework/orchestration/runtime" "$fixture_root/.octon/framework/orchestration/"
  cp "$REPO_ROOT/.octon/framework/orchestration/practices/workflow-authoring-standards.md" \
    "$fixture_root/.octon/framework/orchestration/practices/workflow-authoring-standards.md"
  cp "$REPO_ROOT/.octon/state/evidence/decisions/repo/README.md" "$fixture_root/.octon/state/evidence/decisions/repo/README.md"
  cp "$REPO_ROOT/.octon/state/evidence/decisions/repo/retention.json" "$fixture_root/.octon/state/evidence/decisions/repo/retention.json"
  cp "$REPO_ROOT/.octon/state/evidence/runs/README.md" "$fixture_root/.octon/state/evidence/runs/README.md"
  cp "$REPO_ROOT/.octon/instance/cognition/context/shared/workflow-quality.md" \
    "$fixture_root/.octon/instance/cognition/context/shared/workflow-quality.md"
  cp "$REPO_ROOT/.octon/instance/cognition/context/shared/workflow-gaps.md" \
    "$fixture_root/.octon/instance/cognition/context/shared/workflow-gaps.md"

  printf '%s\n' "$fixture_root"
}

case_primitives_round_trip() {
  local fixture_root
  fixture_root="$(create_fixture)"

  local envs=("OCTON_DIR_OVERRIDE=$fixture_root/.octon" "OCTON_ROOT_DIR=$fixture_root")

  discovery_output="$(env "${envs[@]}" bash "$REPO_ROOT/$DISCOVERY_SCRIPT" resolve-workflow --workflow-group meta --workflow-id evaluate-harness)"
  jq -e '.workflow_ref.workflow_group == "meta" and .workflow_ref.workflow_id == "evaluate-harness"' <<<"$discovery_output" >/dev/null

  decision_path="$(env "${envs[@]}" bash "$REPO_ROOT/$DECISION_SCRIPT" \
    --decision-id dec-test-001 \
    --outcome allow \
    --surface workflows \
    --action launch-workflow \
    --actor evaluate-harness \
    --workflow-group meta \
    --workflow-id evaluate-harness \
    --reason-code target-resolved \
    --summary 'Evaluate harness workflow admitted for execution.')"
  [[ -f "$decision_path" ]]

  run_path="$(env "${envs[@]}" bash "$REPO_ROOT/$RUN_SCRIPT" create \
    --run-id run-test-001 \
    --decision-id dec-test-001 \
    --summary 'Evaluate harness run started.' \
    --workflow-group meta \
    --workflow-id evaluate-harness \
    --executor-id executor-test-01 \
    --lease-seconds 300)"
  [[ -f "$run_path" ]]

  lock_output="$(env "${envs[@]}" bash "$REPO_ROOT/$LOCK_SCRIPT" acquire \
    --coordination-key workflow:meta/evaluate-harness \
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

  env \
    ORCHESTRATION_RUNTIME_SKIP_PRIMITIVE_TEST=1 \
    ORCHESTRATION_RUNTIME_SKIP_FIRST_SLICE_TEST=1 \
    ORCHESTRATION_RUNTIME_SKIP_AUTOMATION_POLICY_TEST=1 \
    ORCHESTRATION_RUNTIME_SKIP_ROUTING_QUEUE_TEST=1 \
    ORCHESTRATION_RUNTIME_SKIP_INCIDENT_APPROVAL_TEST=1 \
    ORCHESTRATION_RUNTIME_SKIP_OPERATOR_HARDENING_TEST=1 \
    ORCHESTRATION_RUNTIME_SKIP_LIVE_INDEPENDENCE_VALIDATOR=1 \
    ORCHESTRATION_RUNTIME_SKIP_LIVE_INDEPENDENCE_TEST=1 \
    "${envs[@]}" \
    bash "$REPO_ROOT/$RUNTIME_VALIDATE" >/dev/null
}

assert_success "shared runtime primitives round-trip" case_primitives_round_trip

if (( fail_count > 0 )); then
  echo "FAILURES: $fail_count" >&2
  exit 1
fi

echo "PASS: $pass_count"
