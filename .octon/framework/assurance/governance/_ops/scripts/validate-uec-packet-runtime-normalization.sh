#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found $1" || fail "missing $1"; }

role_run_id() { yq -r ".run_roles.${1}.run_id" "$CONFIG_FILE"; }

validate_event_ledger() {
  local run_id="$1"
  local ledger="$OCTON_DIR/state/control/execution/runs/$run_id/events.ndjson"
  require_file "$ledger"
  jq -Rcs 'split("\n") | map(select(length > 0) | fromjson) | length > 0' "$ledger" >/dev/null 2>&1 && pass "$run_id event ledger parses" || fail "$run_id event ledger parses"
}

main() {
  echo "== Global Runtime Normalization Validation =="

  require_file "$CONFIG_FILE"
  require_file "$OCTON_DIR/framework/engine/runtime/crates/replay_store/Cargo.toml"
  require_file "$OCTON_DIR/framework/engine/runtime/crates/telemetry_sink/Cargo.toml"
  require_file "$OCTON_DIR/framework/engine/runtime/crates/runtime_bus/Cargo.toml"
  require_file "$OCTON_DIR/framework/constitution/contracts/runtime/compensation-record-v1.schema.json"

  cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_replay_store >/dev/null 2>&1 && pass "replay_store tests pass" || fail "replay_store tests pass"
  cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_telemetry_sink >/dev/null 2>&1 && pass "telemetry_sink tests pass" || fail "telemetry_sink tests pass"
  cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_runtime_bus >/dev/null 2>&1 && pass "runtime_bus tests pass" || fail "runtime_bus tests pass"

  validate_event_ledger "$(role_run_id supported_run_only)"
  validate_event_ledger "$(role_run_id authority_exercise)"
  validate_event_ledger "$(role_run_id intervention_control)"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
