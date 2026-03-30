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
  require_file "$OCTON_DIR/framework/constitution/contracts/authority/README.md"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/execution-request-v1.schema.json"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/execution-grant-v1.schema.json"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/execution-receipt-v1.schema.json"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/executor-profile-v1.schema.json"
  require_file "$OCTON_DIR/instance/governance/support-targets.yml"
  require_file "$OCTON_DIR/framework/engine/_ops/scripts/write-authority-control-receipt.sh"
  require_file "$OCTON_DIR/framework/engine/_ops/scripts/materialize-authority-approval.sh"
  require_file "$OCTON_DIR/framework/engine/_ops/scripts/project-github-control-approval.sh"
  require_file "$OCTON_DIR/framework/engine/_ops/scripts/record-authority-exception-lease.sh"
  require_file "$OCTON_DIR/framework/engine/_ops/scripts/record-authority-revocation.sh"
  require_file "$OCTON_DIR/framework/assurance/runtime/_ops/tests/test-authority-control-tooling.sh"
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

  if has_pattern_in_files 'materialize-pr-authority\.sh' "$ROOT_DIR/.github/workflows/pr-autonomy-policy.yml" "$ROOT_DIR/.github/workflows/ai-review-gate.yml"; then
    fail "protected GitHub workflows must not materialize authority from host projections"
  else
    pass "protected GitHub workflows do not materialize authority from host projections"
  fi

  if has_pattern_in_files 'project-github-control-approval\.sh' "$ROOT_DIR/.github/workflows/ai-review-gate.yml" "$ROOT_DIR/.github/workflows/pr-auto-merge.yml"; then
    pass "GitHub control-plane workflows dual-write into canonical approval artifacts"
  else
    fail "GitHub control-plane workflows must dual-write into canonical approval artifacts"
  fi

  if has_pattern_in_files 'accept:human|ai-gate:waive|waived-by-authority' "$ROOT_DIR/.github/workflows/pr-autonomy-policy.yml" "$ROOT_DIR/.github/workflows/ai-review-gate.yml"; then
    fail "protected GitHub workflows must not depend on label-based approval or waiver paths"
  else
    pass "protected GitHub workflows do not depend on label-based approval or waiver paths"
  fi

  if has_pattern_in_files 'projection-label|gh pr edit .*ai-gate:|gh pr edit .*autonomy:' "$ROOT_DIR/.github/workflows/ai-review-gate.yml" "$ROOT_DIR/.github/workflows/pr-auto-merge.yml"; then
    fail "critical GitHub workflows must not project or sync autonomy/ai-gate labels"
  else
    pass "critical GitHub workflows do not project or sync autonomy/ai-gate labels"
  fi

  if has_pattern_in_files 'has_label "${payload}" "autonomy:auto-merge"|has_label "${payload}" "autonomy:no-automerge"|autonomy:auto-merge label missing|autonomy:no-automerge label present' "$ROOT_DIR/.github/workflows/pr-auto-merge.yml"; then
    fail "pr-auto-merge must not use autonomy labels as merge authority"
  else
    pass "pr-auto-merge does not use autonomy labels as merge authority"
  fi

  if find "$OCTON_DIR/state/control/execution/approvals/requests" -type f -name '*.yml' | grep -q .; then
    pass "canonical approval request artifacts are populated"
  else
    fail "canonical approval request artifacts must be populated"
  fi

  if find "$OCTON_DIR/state/control/execution/approvals/grants" -type f -name '*.yml' | grep -q .; then
    pass "canonical approval grant artifacts are populated"
  else
    fail "canonical approval grant artifacts must be populated"
  fi

  if has_pattern_in_files 'schema_version:[[:space:]]*authority-exception-lease-v1' "$OCTON_DIR/state/control/execution/exceptions/leases.yml"; then
    pass "canonical exception lease artifacts are populated"
  else
    fail "canonical exception lease artifacts must be populated"
  fi

  if has_pattern_in_files 'schema_version:[[:space:]]*authority-revocation-v1' "$OCTON_DIR/state/control/execution/revocations/grants.yml"; then
    pass "canonical revocation artifacts are populated"
  else
    fail "canonical revocation artifacts must be populated"
  fi

  if has_pattern_in_files 'OCTON_EFFECTIVE_POLICY_MODE="hard-enforce"' "$ROOT_DIR/.github/workflows/ai-review-gate.yml" "$ROOT_DIR/.github/workflows/pr-autonomy-policy.yml" "$ROOT_DIR/.github/workflows/deny-by-default-gates.yml" "$ROOT_DIR/.github/workflows/release-please.yml"; then
    fail "protected GitHub workflows must not hardcode OCTON_EFFECTIVE_POLICY_MODE"
  else
    pass "protected GitHub workflows derive effective policy mode instead of hardcoding it"
  fi

  run_test \
    "kernel generic workflow test verifies emitted execution artifacts" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel pipeline::tests::mock_generic_workflow_writes_execution_artifacts -- --exact
  run_test \
    "kernel create-design workflow test verifies emitted execution artifacts" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel workflow::tests::create_design_package_writes_execution_artifacts -- --exact
  run_test \
    "kernel static proposal helper tests verify emitted execution artifacts" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel workflow::tests::create_static_and_audit_proposal_write_execution_artifacts -- --exact
  run_test \
    "kernel static proposal create failure writes execution artifacts" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel workflow::tests::create_static_proposal_failure_writes_execution_artifacts -- --exact
  run_test \
    "kernel static proposal audit failure writes execution artifacts" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel workflow::tests::audit_static_missing_target_writes_execution_artifacts -- --exact
  run_test \
    "kernel undeclared host adapter denies execution" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel authorization::tests::undeclared_host_adapter_denies_execution -- --exact
  run_test \
    "kernel unadmitted api pack denies execution" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel authorization::tests::unadmitted_api_pack_denies_execution -- --exact
  run_test \
    "kernel invalid model adapter manifest denies execution" \
    cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel authorization::tests::invalid_model_adapter_manifest_denies_execution -- --exact
  run_test \
    "authority control tooling writes canonical artifacts" \
    bash "$OCTON_DIR/framework/assurance/runtime/_ops/tests/test-authority-control-tooling.sh"

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
