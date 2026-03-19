#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

CAPABILITIES_DIR="$OCTON_DIR/capabilities"
COGNITION_OPS_DIR="$OCTON_DIR/cognition/_ops"
SHIM_PATH="$CAPABILITIES_DIR/_ops/scripts/run-octon-policy.sh"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

check_no_internal_engine_dependencies() {
  local pattern
  local hits

  pattern='engine/runtime/crates/|generated/\\.tmp/engine/build/runtime-crates-target|runtime/crates/policy_engine'
  hits="$(rg -n --no-heading -e "$pattern" \
    "$CAPABILITIES_DIR" \
    --glob '*.sh' \
    --glob '*.yml' \
    --glob '*.yaml' \
    --glob '*.json' \
    --glob '*.toml' \
    --glob '*.cmd' || true)"

  if [[ -n "$hits" ]]; then
    fail "capabilities references engine implementation internals"
    printf '%s\n' "$hits"
  else
    pass "no capabilities references to engine implementation internals"
  fi
}

check_policy_runner_cutover() {
  local refs
  local violations

  refs="$(rg -n --no-heading "run-octon-policy\\.sh" \
    "$CAPABILITIES_DIR" \
    "$COGNITION_OPS_DIR" \
    --glob '!**/*.md' || true)"

  if [[ -z "$refs" ]]; then
    pass "no legacy runner references remain"
    return
  fi

  violations="$(printf '%s\n' "$refs" | awk -F: -v shim="$SHIM_PATH" '$1 != shim')"

  if [[ -n "$violations" ]]; then
    fail "legacy capabilities runner referenced outside compatibility shim"
    printf '%s\n' "$violations"
  else
    pass "legacy runner only appears in compatibility shim"
  fi
}

main() {
  check_no_internal_engine_dependencies
  check_policy_runner_cutover

  if [[ "$errors" -gt 0 ]]; then
    echo "[FAIL] engine/capabilities boundary validation failed with $errors error(s)"
    exit 1
  fi

  echo "[PASS] engine/capabilities boundary validation passed"
}

main "$@"
