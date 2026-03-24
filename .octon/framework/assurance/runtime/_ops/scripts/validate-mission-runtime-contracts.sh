#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
SPEC_DIR="$OCTON_DIR/framework/engine/runtime/spec"
CONFIG_FILE="$OCTON_DIR/framework/engine/runtime/config/policy-interface.yml"
CARGO_MANIFEST="$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml"

errors=0

fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
has_pattern() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q -- "$pattern" "$file"
  else
    grep -Eq -- "$pattern" "$file"
  fi
}
run_test() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  echo "== Mission Runtime Contracts Validation =="

  for file in \
    mission-charter-v2.schema.json \
    mission-autonomy-policy-v1.schema.json \
    ownership-registry-v1.schema.json \
    mission-control-lease-v1.schema.json \
    action-slice-v1.schema.json \
    intent-register-v1.schema.json \
    mode-state-v1.schema.json \
    control-directive-v1.schema.json \
    schedule-control-v1.schema.json \
    autonomy-budget-v1.schema.json \
    circuit-breaker-v1.schema.json \
    subscriptions-v1.schema.json \
    execution-request-v2.schema.json \
    execution-receipt-v2.schema.json \
    policy-receipt-v2.schema.json \
    policy-digest-v2.md \
    control-receipt-v1.schema.json \
    scenario-resolution-v1.schema.json
  do
    [[ -f "$SPEC_DIR/$file" ]] && pass "found spec $file" || fail "missing spec $file"
  done

  has_pattern 'mission_autonomy_policy' "$CONFIG_FILE" && pass "policy interface exposes mission autonomy policy" || fail "policy interface missing mission_autonomy_policy path"
  has_pattern 'mission_control_root' "$CONFIG_FILE" && pass "policy interface exposes mission control root" || fail "policy interface missing mission_control_root path"
  has_pattern 'control_receipt_root' "$CONFIG_FILE" && pass "policy interface exposes control receipt root" || fail "policy interface missing control_receipt_root path"
  has_pattern 'mission_effective_route_root' "$CONFIG_FILE" && pass "policy interface exposes mission effective route root" || fail "policy interface missing mission_effective_route_root path"
  has_pattern 'policy-receipt-v2' "$OCTON_DIR/framework/capabilities/_ops/scripts/policy-receipt-write.sh" && pass "shared policy receipt writer emits v2 schema" || fail "shared policy receipt writer still emits v1 schema"
  has_pattern 'policy-digest-v2' "$OCTON_DIR/framework/capabilities/_ops/scripts/policy-receipt-write.sh" && pass "shared policy receipt writer emits v2 digest format" || fail "shared policy receipt writer still emits v1 digest format"
  has_pattern 'autonomy_context' "$OCTON_DIR/framework/engine/runtime/crates/kernel/src/authorization.rs" && pass "kernel authorization uses autonomy_context" || fail "kernel authorization missing autonomy_context"
  has_pattern 'workflow_mode' "$OCTON_DIR/framework/engine/runtime/crates/kernel/src/pipeline.rs" && pass "pipeline emits workflow_mode" || fail "pipeline missing workflow_mode"

  run_test \
    "authorization denies autonomous execution without mission context" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel autonomous_request_requires_mission_context
  run_test \
    "authorization accepts seeded autonomous mission context" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel autonomous_request_allows_seeded_mission_context
  run_test \
    "approval-required autonomous execution returns stage-only without approval" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel approval_required_autonomous_request_returns_stage_only_without_human_approval
  run_test \
    "proceed-on-silence blocks when autonomy budget is not healthy" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel proceed_on_silence_blocks_when_autonomy_budget_not_healthy
  run_test \
    "authorization stage-onlys when mission scenario resolution is missing" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel missing_scenario_resolution_returns_stage_only
  run_test \
    "authorization stage-onlys when mission scenario resolution is stale" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel stale_scenario_resolution_returns_stage_only

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
