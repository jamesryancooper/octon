#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r "$dir"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local name="$1"
  shift
  if "$@"; then pass "$name"; else fail "$name"; fi
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-operation-workflows.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/orchestration/runtime/workflows/meta"
  cp "$REPO_ROOT/.octon/framework/orchestration/runtime/workflows/manifest.yml" \
    "$fixture_root/.octon/framework/orchestration/runtime/workflows/manifest.yml"
  cp "$REPO_ROOT/.octon/framework/orchestration/runtime/workflows/registry.yml" \
    "$fixture_root/.octon/framework/orchestration/runtime/workflows/registry.yml"
  cp "$REPO_ROOT/.octon/framework/orchestration/runtime/workflows/README.md" \
    "$fixture_root/.octon/framework/orchestration/runtime/workflows/README.md"
  cp -R "$REPO_ROOT/.octon/framework/orchestration/runtime/workflows/meta/validate-proposal" \
    "$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/"
  cp -R "$REPO_ROOT/.octon/framework/orchestration/runtime/workflows/meta/promote-proposal" \
    "$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/"
  cp -R "$REPO_ROOT/.octon/framework/orchestration/runtime/workflows/meta/archive-proposal" \
    "$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-validate-proposal-workflow.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-validate-proposal-workflow.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-promote-proposal-workflow.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-promote-proposal-workflow.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-archive-proposal-workflow.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-archive-proposal-workflow.sh"
  printf '%s\n' "$fixture_root"
}

run_validator() {
  local fixture_root="$1"
  local script="$2"
  (
    cd "$fixture_root"
    bash "$script"
  )
}

case_validate_workflow_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_validator "$fixture_root" ".octon/framework/assurance/runtime/_ops/scripts/validate-validate-proposal-workflow.sh"
}

case_promote_workflow_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_validator "$fixture_root" ".octon/framework/assurance/runtime/_ops/scripts/validate-promote-proposal-workflow.sh"
}

case_archive_workflow_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_validator "$fixture_root" ".octon/framework/assurance/runtime/_ops/scripts/validate-archive-proposal-workflow.sh"
}

main() {
  assert_success "validate-proposal workflow validator accepts the baseline workflow" case_validate_workflow_passes
  assert_success "promote-proposal workflow validator accepts the baseline workflow" case_promote_workflow_passes
  assert_success "archive-proposal workflow validator accepts the baseline workflow" case_archive_workflow_passes

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
