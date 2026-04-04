#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found $1" || fail "missing $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }

validate_run_bundle() {
  local run_id="$1"
  local run_root="$OCTON_DIR/state/control/execution/runs/$run_id"
  local evidence_root="$OCTON_DIR/state/evidence/runs/$run_id"
  local run_card="$OCTON_DIR/state/evidence/disclosure/runs/$run_id/run-card.yml"

  require_file "$run_root/run-contract.yml"
  require_file "$run_root/run-manifest.yml"
  require_file "$run_root/runtime-state.yml"
  require_file "$evidence_root/measurements/summary.yml"
  require_file "$run_card"

  require_yq '.schema_version == "run-card-v2"' "$run_card" "$run_id uses RunCard v2"
  require_yq '.runtime_service_refs.replay_store == ".octon/framework/engine/runtime/crates/replay_store"' "$run_card" "$run_id cites replay_store"
  require_yq '.runtime_service_refs.telemetry_sink == ".octon/framework/engine/runtime/crates/telemetry_sink"' "$run_card" "$run_id cites telemetry_sink"
  require_yq '.runtime_service_refs.runtime_bus == ".octon/framework/engine/runtime/crates/runtime_bus"' "$run_card" "$run_id cites runtime_bus"
  require_yq '.metrics[] | select(.metric_id == "token-usage")' "$evidence_root/measurements/summary.yml" "$run_id records token usage"
  require_yq '.metrics[] | select(.metric_id == "latency-ms")' "$evidence_root/measurements/summary.yml" "$run_id records latency"
  require_yq '.metrics[] | select(.metric_id == "cost-usd")' "$evidence_root/measurements/summary.yml" "$run_id records cost"
}

main() {
  echo "== Global Runtime Richness Validation =="

  validate_run_bundle "uec-global-frontier-browser-api-studio-20260404"
  validate_run_bundle "uec-global-github-repo-consequential-20260404"
  validate_run_bundle "uec-global-ci-observe-read-20260404"
  validate_run_bundle "uec-global-repo-shell-observe-read-20260404"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
