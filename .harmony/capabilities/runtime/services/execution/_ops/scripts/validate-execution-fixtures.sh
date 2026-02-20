#!/usr/bin/env bash
# validate-execution-fixtures.sh - Fixture and adapter checks for execution services.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AGENT_IMPL="$ROOT_DIR/agent/impl/agent.sh"
AGENT_FIXTURES="$ROOT_DIR/agent/fixtures"
FLOW_DIR="$ROOT_DIR/flow"
FLOW_MANIFEST="$FLOW_DIR/service.json"

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

  if ! out="$(cat "$fixture" | bash "$impl")"; then
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
  out="$(cat "$fixture" | bash "$impl" 2>/dev/null)"
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

  out_a="$(cat "$fixture" | bash "$impl" | jq -S .)"
  out_b="$(cat "$fixture" | bash "$impl" | jq -S .)"

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

  # Agent fixtures and deterministic behavior.
  run_success "agent-positive" "$AGENT_FIXTURES/positive.json" "$AGENT_IMPL" '.status == "success" and (.runId | type == "string") and (.result.mode == "execute")' >/dev/null || true
  run_success "agent-edge" "$AGENT_FIXTURES/edge.json" "$AGENT_IMPL" '.status == "partial" and (.checkpoint.state == "checkpointed")' >/dev/null || true
  run_expected_failure "agent-negative" "$AGENT_FIXTURES/negative.json" "$AGENT_IMPL" 5 || true

  resume_payload='{"planPath":"plan.json","runId":"run-123","resume":true}'
  if ! resume_out="$(printf '%s' "$resume_payload" | bash "$AGENT_IMPL")"; then
    log_error "agent-resume gate failed"
  elif ! jq -e '.status == "success" and .checkpoint.state == "resumed"' >/dev/null 2>&1 <<<"$resume_out"; then
    log_error "agent-resume output did not reach resumed state"
  else
    log_ok "agent resume gate"
  fi

  check_deterministic "agent-positive" "$AGENT_FIXTURES/positive.json" "$AGENT_IMPL" || true

  # Flow adapter structure and manifest assertions.
  if ! bash "$FLOW_DIR/impl/validate-adapters.sh" >/dev/null; then
    log_error "flow adapter validation failed"
  else
    log_ok "flow adapters"
  fi

  if [[ ! -f "$FLOW_MANIFEST" ]]; then
    log_error "flow service manifest missing: $FLOW_MANIFEST"
  elif ! jq -e '.category == "execution"' "$FLOW_MANIFEST" >/dev/null 2>&1; then
    log_error "flow service manifest category must be execution"
  else
    log_ok "flow manifest category"
  fi

  if (( errors > 0 )); then
    echo "Execution fixture validation failed: $errors error(s)." >&2
    exit 1
  fi

  log_ok "agent fixtures"
  echo "Execution fixture validation passed."
}

main "$@"
