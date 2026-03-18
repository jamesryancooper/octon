#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

validators=(
  "$RUNTIME_DIR/workflows/_ops/scripts/validate-workflows.sh"
  "$RUNTIME_DIR/missions/_ops/scripts/validate-missions.sh"
  "$RUNTIME_DIR/runs/_ops/scripts/validate-runs.sh"
  "$RUNTIME_DIR/automations/_ops/scripts/validate-automations.sh"
  "$RUNTIME_DIR/incidents/_ops/scripts/validate-incidents.sh"
  "$RUNTIME_DIR/queue/_ops/scripts/validate-queue.sh"
  "$RUNTIME_DIR/watchers/_ops/scripts/validate-watchers.sh"
  "$RUNTIME_DIR/campaigns/_ops/scripts/validate-campaigns.sh"
)

for validator in "${validators[@]}"; do
  echo "== Run ${validator#$RUNTIME_DIR/} =="
  bash "$validator"
  echo
done

primitive_test="$RUNTIME_DIR/_ops/tests/test-shared-runtime-primitives.sh"
if [[ -f "$primitive_test" && "${ORCHESTRATION_RUNTIME_SKIP_PRIMITIVE_TEST:-0}" != "1" ]]; then
  echo "== Run ${primitive_test#$RUNTIME_DIR/} =="
  bash "$primitive_test"
  echo
fi

live_independence_validator="$RUNTIME_DIR/_ops/scripts/validate-orchestration-live-independence.sh"
if [[ -f "$live_independence_validator" && "${ORCHESTRATION_RUNTIME_SKIP_LIVE_INDEPENDENCE_VALIDATOR:-0}" != "1" ]]; then
  echo "== Run ${live_independence_validator#$RUNTIME_DIR/} =="
  bash "$live_independence_validator"
  echo
fi

first_slice_test="$RUNTIME_DIR/_ops/tests/test-first-end-to-end-slice.sh"
if [[ -f "$first_slice_test" && "${ORCHESTRATION_RUNTIME_SKIP_FIRST_SLICE_TEST:-0}" != "1" ]]; then
  echo "== Run ${first_slice_test#$RUNTIME_DIR/} =="
  bash "$first_slice_test"
  echo
fi

automation_policy_test="$RUNTIME_DIR/_ops/tests/test-automation-policy-and-scheduling.sh"
if [[ -f "$automation_policy_test" && "${ORCHESTRATION_RUNTIME_SKIP_AUTOMATION_POLICY_TEST:-0}" != "1" ]]; then
  echo "== Run ${automation_policy_test#$RUNTIME_DIR/} =="
  bash "$automation_policy_test"
  echo
fi

routing_queue_test="$RUNTIME_DIR/_ops/tests/test-watcher-routing-and-queue.sh"
if [[ -f "$routing_queue_test" && "${ORCHESTRATION_RUNTIME_SKIP_ROUTING_QUEUE_TEST:-0}" != "1" ]]; then
  echo "== Run ${routing_queue_test#$RUNTIME_DIR/} =="
  bash "$routing_queue_test"
  echo
fi

incident_approval_test="$RUNTIME_DIR/_ops/tests/test-incident-approval-control.sh"
if [[ -f "$incident_approval_test" && "${ORCHESTRATION_RUNTIME_SKIP_INCIDENT_APPROVAL_TEST:-0}" != "1" ]]; then
  echo "== Run ${incident_approval_test#$RUNTIME_DIR/} =="
  bash "$incident_approval_test"
  echo
fi

operator_hardening_test="$RUNTIME_DIR/_ops/tests/test-operator-hardening.sh"
if [[ -f "$operator_hardening_test" && "${ORCHESTRATION_RUNTIME_SKIP_OPERATOR_HARDENING_TEST:-0}" != "1" ]]; then
  echo "== Run ${operator_hardening_test#$RUNTIME_DIR/} =="
  bash "$operator_hardening_test"
  echo
fi

live_independence_test="$RUNTIME_DIR/_ops/tests/test-orchestration-live-independence.sh"
if [[ -f "$live_independence_test" && "${ORCHESTRATION_RUNTIME_SKIP_LIVE_INDEPENDENCE_TEST:-0}" != "1" ]]; then
  echo "== Run ${live_independence_test#$RUNTIME_DIR/} =="
  bash "$live_independence_test"
  echo
fi
