#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
ARCH_WORKFLOW="$ROOT_DIR/.github/workflows/architecture-conformance.yml"
PHASE5_PLAN="$OCTON_DIR/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase5-adapter-support-target-hardening/plan.md"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

require_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if command -v rg >/dev/null 2>&1; then
    if rg -Fq "$needle" "$file"; then
      pass "$label"
    else
      fail "$label"
    fi
  elif grep -Fq -- "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
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
  echo "== Unified Execution Constitution Phase 5 Validation =="

  require_file "$PHASE5_PLAN"
  require_file "$ARCH_WORKFLOW"

  bash "$SCRIPT_DIR/validate-wave5-agency-adapter-hardening.sh"

  require_text "validate-phase5-adapter-support-target-hardening.sh" "$ARCH_WORKFLOW" "architecture conformance workflow enforces Phase 5 validator"
  require_text ".octon/framework/capabilities/packs/**" "$ARCH_WORKFLOW" "architecture workflow triggers on framework capability pack changes"
  require_text ".octon/instance/capabilities/runtime/packs/**" "$ARCH_WORKFLOW" "architecture workflow triggers on runtime capability pack admission changes"

  run_test \
    "kernel unadmitted api pack denies execution" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel authorization::tests::unadmitted_api_pack_denies_execution -- --exact
  run_test \
    "kernel invalid model adapter manifest denies execution" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel authorization::tests::invalid_model_adapter_manifest_denies_execution -- --exact
  run_test \
    "kernel undeclared host adapter still denies execution" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel authorization::tests::undeclared_host_adapter_denies_execution -- --exact
  run_test \
    "kernel generic workflow fixture still writes execution artifacts" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel pipeline::tests::mock_generic_workflow_writes_execution_artifacts -- --exact

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
