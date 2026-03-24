#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
ROOT_MANIFEST="$OCTON_DIR/octon.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

has_pattern_in_files() {
  local pattern="$1"
  shift
  if command -v rg >/dev/null 2>&1; then
    rg -n "$pattern" "$@" >/dev/null 2>&1
  else
    grep -En -- "$pattern" "$@" >/dev/null 2>&1
  fi
}

has_pattern_in_workflows() {
  local pattern="$1"
  local workflows_dir="$OCTON_DIR/framework/orchestration/runtime/workflows"

  if command -v rg >/dev/null 2>&1; then
    rg -n "$pattern" "$workflows_dir" -g 'workflow.yml' >/dev/null 2>&1
  else
    local -a workflow_files=()
    mapfile -t workflow_files < <(find "$workflows_dir" -type f -name 'workflow.yml')
    if ((${#workflow_files[@]} == 0)); then
      return 1
    fi
    grep -En -- "$pattern" "${workflow_files[@]}" >/dev/null 2>&1
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

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

main() {
  echo "== Execution Governance Validation =="

  require_file "$ROOT_MANIFEST"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/execution-authorization-v1.md"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/execution-request-v1.schema.json"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/execution-grant-v1.schema.json"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/execution-receipt-v1.schema.json"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/executor-profile-v1.schema.json"
  require_file "$SCRIPT_DIR/assert-protected-execution-posture.sh"

  if yq -e '.execution_governance.policy_mode.default == "hard-enforce"' "$ROOT_MANIFEST" >/dev/null; then
    pass "root manifest declares hard-enforce default policy mode"
  else
    fail "root manifest must declare execution_governance.policy_mode.default=hard-enforce"
  fi

  if yq -e '.execution_governance.protected_workflows | length > 0' "$ROOT_MANIFEST" >/dev/null; then
    pass "root manifest declares protected workflows"
  else
    fail "root manifest must declare execution_governance.protected_workflows"
  fi

  if has_pattern_in_workflows 'workflow-contract-v1'; then
    fail "workflow-contract-v1 references remain in live workflow.yml files"
  else
    pass "live workflow.yml files use workflow-contract-v2 only"
  fi

  if has_pattern_in_workflows 'authorization:'; then
    pass "workflow contracts declare stage authorization blocks"
  else
    fail "workflow contracts must declare stage authorization blocks"
  fi

  if has_pattern_in_files 'assert-protected-execution-posture\.sh' "$ROOT_DIR/.github/workflows/ai-review-gate.yml" "$ROOT_DIR/.github/workflows/pr-autonomy-policy.yml" "$ROOT_DIR/.github/workflows/deny-by-default-gates.yml" "$ROOT_DIR/.github/workflows/release-please.yml"; then
    pass "protected GitHub workflows call the execution posture guard"
  else
    fail "protected GitHub workflows must call assert-protected-execution-posture.sh"
  fi

  if has_pattern_in_files 'OCTON_EFFECTIVE_POLICY_MODE="hard-enforce"' "$ROOT_DIR/.github/workflows/ai-review-gate.yml" "$ROOT_DIR/.github/workflows/pr-autonomy-policy.yml" "$ROOT_DIR/.github/workflows/deny-by-default-gates.yml" "$ROOT_DIR/.github/workflows/release-please.yml"; then
    fail "protected GitHub workflows must not hardcode OCTON_EFFECTIVE_POLICY_MODE"
  else
    pass "protected GitHub workflows derive effective policy mode instead of hardcoding it"
  fi

  run_test \
    "kernel generic workflow test verifies emitted execution artifacts" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel mock_generic_workflow_writes_execution_artifacts -- --exact
  run_test \
    "kernel create-design workflow test verifies emitted execution artifacts" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel create_design_package_writes_execution_artifacts -- --exact
  run_test \
    "kernel static proposal helper tests verify emitted execution artifacts" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel create_static_and_audit_proposal_write_execution_artifacts -- --exact
  run_test \
    "kernel static proposal create failure writes execution artifacts" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel create_static_proposal_failure_writes_execution_artifacts -- --exact
  run_test \
    "kernel static proposal audit failure writes execution artifacts" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel audit_static_missing_target_writes_execution_artifacts -- --exact

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
