#!/usr/bin/env bash
# validate-planning-fixtures.sh - Fixture and determinism checks for planning services.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SPEC_IMPL="$ROOT_DIR/spec/impl/spec.sh"
PLAYBOOK_IMPL="$ROOT_DIR/playbook/impl/playbook.sh"
PLAN_IMPL="$ROOT_DIR/plan/impl/plan.sh"
CRITIC_IMPL="$ROOT_DIR/critic/impl/critic.sh"
REPLAN_IMPL="$ROOT_DIR/replan/impl/replan.sh"
SCHEDULER_IMPL="$ROOT_DIR/scheduler/impl/scheduler.sh"
CAPABILITY_BIND_IMPL="$ROOT_DIR/capability-bind/impl/capability-bind.sh"
CONTINGENCY_IMPL="$ROOT_DIR/contingency/impl/contingency.sh"

SPEC_FIXTURES="$ROOT_DIR/spec/fixtures"
PLAYBOOK_FIXTURES="$ROOT_DIR/playbook/fixtures"
PLAN_FIXTURES="$ROOT_DIR/plan/fixtures"
CRITIC_FIXTURES="$ROOT_DIR/critic/fixtures"
REPLAN_FIXTURES="$ROOT_DIR/replan/fixtures"
SCHEDULER_FIXTURES="$ROOT_DIR/scheduler/fixtures"
CAPABILITY_BIND_FIXTURES="$ROOT_DIR/capability-bind/fixtures"
CONTINGENCY_FIXTURES="$ROOT_DIR/contingency/fixtures"

errors=0

log_ok() {
  echo "✓ $1"
}

log_error() {
  echo "ERROR: $1" >&2
  errors=$((errors + 1))
}

run_success() {
  local name="$1"
  local fixture="$2"
  local impl="$3"
  local assert_filter="$4"

  if ! out="$(cat "$fixture" | "$impl")"; then
    log_error "$name fixture failed: $fixture"
    return 1
  fi

  if ! jq -e "$assert_filter" >/dev/null 2>&1 <<<"$out"; then
    log_error "$name output missing required keys"
    return 1
  fi

  echo "$out"
  return 0
}

run_expected_failure() {
  local name="$1"
  local fixture="$2"
  local impl="$3"
  local expected_exit="$4"

  set +e
  out="$(cat "$fixture" | "$impl" 2>/dev/null)"
  rc=$?
  set -e

  if [[ "$rc" -ne "$expected_exit" ]]; then
    log_error "$name expected exit $expected_exit but got $rc"
    return 1
  fi

  if ! jq -e '.status == "error"' >/dev/null 2>&1 <<<"$out"; then
    log_error "$name error output contract invalid"
    return 1
  fi

  return 0
}

check_deterministic() {
  local name="$1"
  local fixture="$2"
  local impl="$3"

  out_a="$(cat "$fixture" | "$impl" | jq -S .)"
  out_b="$(cat "$fixture" | "$impl" | jq -S .)"

  if [[ "$out_a" != "$out_b" ]]; then
    log_error "$name output is not deterministic for fixture $fixture"
    return 1
  fi

  return 0
}

main() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required" >&2
    exit 6
  fi

  # Planning Spec
  run_success "spec-positive" "$SPEC_FIXTURES/positive.json" "$SPEC_IMPL" '.status == "success" and (.command | type == "string") and (.result | type == "object")' >/dev/null || true
  run_success "spec-edge" "$SPEC_FIXTURES/edge.json" "$SPEC_IMPL" '.status == "success" and (.command == "init") and (.result.featureId | type == "string")' >/dev/null || true
  run_expected_failure "spec-negative" "$SPEC_FIXTURES/negative.json" "$SPEC_IMPL" 5 || true
  check_deterministic "spec-positive" "$SPEC_FIXTURES/positive.json" "$SPEC_IMPL" || true

  # Playbook
  run_success "playbook-positive" "$PLAYBOOK_FIXTURES/positive.json" "$PLAYBOOK_IMPL" '.status == "success" and (.playbook.path | type == "string") and (.playbook.steps | type == "array")' >/dev/null || true
  run_success "playbook-edge" "$PLAYBOOK_FIXTURES/edge.json" "$PLAYBOOK_IMPL" '.status == "success" and (.playbook.dryRun == true)' >/dev/null || true
  run_expected_failure "playbook-negative" "$PLAYBOOK_FIXTURES/negative.json" "$PLAYBOOK_IMPL" 5 || true
  check_deterministic "playbook-positive" "$PLAYBOOK_FIXTURES/positive.json" "$PLAYBOOK_IMPL" || true

  # Plan
  run_success "plan-positive" "$PLAN_FIXTURES/positive.json" "$PLAN_IMPL" '.status == "success" and (.plan.goal | type == "string") and (.plan.order | type == "array")' >/dev/null || true
  run_success "plan-edge" "$PLAN_FIXTURES/edge.json" "$PLAN_IMPL" '.status == "success" and (.plan.steps | length) >= 1' >/dev/null || true
  run_expected_failure "plan-negative" "$PLAN_FIXTURES/negative.json" "$PLAN_IMPL" 4 || true
  check_deterministic "plan-positive" "$PLAN_FIXTURES/positive.json" "$PLAN_IMPL" || true

  # Critic
  run_success "critic-positive" "$CRITIC_FIXTURES/positive.json" "$CRITIC_IMPL" '.status == "success" and .result.criticalIssueCount == 0 and .result.riskLevel == "low"' >/dev/null || true
  run_success "critic-edge" "$CRITIC_FIXTURES/edge.json" "$CRITIC_IMPL" '.status == "success" and .result.riskScore >= 0' >/dev/null || true
  run_expected_failure "critic-negative" "$CRITIC_FIXTURES/negative.json" "$CRITIC_IMPL" 5 || true
  check_deterministic "critic-positive" "$CRITIC_FIXTURES/positive.json" "$CRITIC_IMPL" || true

  # Replan
  run_success "replan-positive" "$REPLAN_FIXTURES/positive.json" "$REPLAN_IMPL" '.status == "partial" and .result.delta.removedCount >= 1' >/dev/null || true
  run_expected_failure "replan-negative" "$REPLAN_FIXTURES/negative.json" "$REPLAN_IMPL" 4 || true
  check_deterministic "replan-positive" "$REPLAN_FIXTURES/positive.json" "$REPLAN_IMPL" || true

  # Scheduler
  run_success "scheduler-positive" "$SCHEDULER_FIXTURES/positive.json" "$SCHEDULER_IMPL" '.status == "success" and .result.schedule.metrics.totalSteps == 5' >/dev/null || true
  run_success "scheduler-edge" "$SCHEDULER_FIXTURES/edge.json" "$SCHEDULER_IMPL" '.status == "success" and (.result.schedule.order | type == "array")' >/dev/null || true
  run_expected_failure "scheduler-negative" "$SCHEDULER_FIXTURES/negative.json" "$SCHEDULER_IMPL" 4 || true
  check_deterministic "scheduler-positive" "$SCHEDULER_FIXTURES/positive.json" "$SCHEDULER_IMPL" || true

  # Capability Bind
  run_success "capability-bind-positive" "$CAPABILITY_BIND_FIXTURES/positive.json" "$CAPABILITY_BIND_IMPL" '.status == "partial" and .result.bindingSummary.unsupportedCapabilitiesCount == 0' >/dev/null || true
  run_success "capability-bind-edge" "$CAPABILITY_BIND_FIXTURES/edge.json" "$CAPABILITY_BIND_IMPL" '.status == "success" and .result.bindingSummary.requestedCapabilitiesCount >= 0' >/dev/null || true
  run_expected_failure "capability-bind-negative" "$CAPABILITY_BIND_FIXTURES/negative.json" "$CAPABILITY_BIND_IMPL" 5 || true
  check_deterministic "capability-bind-positive" "$CAPABILITY_BIND_FIXTURES/positive.json" "$CAPABILITY_BIND_IMPL" || true

  # Contingency
  run_success "contingency-positive" "$CONTINGENCY_FIXTURES/positive.json" "$CONTINGENCY_IMPL" '.status == "partial" and .result.contingencySummary.requestedFailedCount == 1' >/dev/null || true
  run_success "contingency-edge" "$CONTINGENCY_FIXTURES/edge.json" "$CONTINGENCY_IMPL" '.status == "success" and .result.contingencySummary.requestedFailedCount == 0' >/dev/null || true
  run_expected_failure "contingency-negative" "$CONTINGENCY_FIXTURES/negative.json" "$CONTINGENCY_IMPL" 5 || true
  check_deterministic "contingency-positive" "$CONTINGENCY_FIXTURES/positive.json" "$CONTINGENCY_IMPL" || true

  if (( errors > 0 )); then
    echo "Planning fixture validation failed: $errors error(s)." >&2
    exit 1
  fi

  log_ok "spec fixtures"
  log_ok "playbook fixtures"
  log_ok "plan fixtures"
  log_ok "critic fixtures"
  log_ok "replan fixtures"
  log_ok "scheduler fixtures"
  log_ok "capability-bind fixtures"
  log_ok "contingency fixtures"
  echo "Planning fixture validation passed."
}

main "$@"
