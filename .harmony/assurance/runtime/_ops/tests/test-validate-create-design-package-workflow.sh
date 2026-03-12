#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARMONY_DIR/.." && pwd)"
VALIDATE_SCRIPT=".harmony/assurance/runtime/_ops/scripts/validate-create-design-package-workflow.sh"

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

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

assert_failure_contains() {
  local name="$1"
  local needle="$2"
  shift 2

  local output=""
  local rc=0
  output="$("$@" 2>&1)" || rc=$?

  if (( rc != 0 )) && grep -Fq "$needle" <<<"$output"; then
    pass "$name"
    return 0
  fi

  fail "$name"
  echo "  expected failure containing: $needle" >&2
  echo "  exit code: $rc" >&2
  echo "  output:" >&2
  echo "$output" >&2
  return 1
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/create-design-package-workflow.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.harmony/assurance/runtime/_ops/scripts" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/meta" \
    "$fixture_root/.design-packages"

  cp "$REPO_ROOT/.harmony/assurance/runtime/_ops/scripts/validate-create-design-package-workflow.sh" \
    "$fixture_root/.harmony/assurance/runtime/_ops/scripts/validate-create-design-package-workflow.sh"
  cp "$REPO_ROOT/.harmony/orchestration/runtime/workflows/manifest.yml" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/manifest.yml"
  cp "$REPO_ROOT/.harmony/orchestration/runtime/workflows/registry.yml" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/registry.yml"
  cp "$REPO_ROOT/.harmony/orchestration/runtime/workflows/README.md" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/README.md"
  cp -R "$REPO_ROOT/.harmony/orchestration/runtime/workflows/meta/create-design-package" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/meta/"

  printf '%s\n' "$fixture_root"
}

run_validator_in_fixture() {
  local fixture_root="$1"
  (
    cd "$fixture_root"
    bash "$VALIDATE_SCRIPT"
  )
}

case_valid_workflow_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_validator_in_fixture "$fixture_root"
}

case_missing_stage_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  rm "$fixture_root/.harmony/orchestration/runtime/workflows/meta/create-design-package/stages/04-validate-package.md"
  run_validator_in_fixture "$fixture_root"
}

case_missing_registry_update_rule_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  perl -0pi -e 's#\.design-packages/registry\.yml#registry-omitted#g' \
    "$fixture_root/.harmony/orchestration/runtime/workflows/meta/create-design-package/stages/03-scaffold-package.md"
  run_validator_in_fixture "$fixture_root"
}

case_missing_standard_validator_rule_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  perl -0pi -e 's/validate-design-package-standard\.sh[^\n]*//g' \
    "$fixture_root/.harmony/orchestration/runtime/workflows/meta/create-design-package/stages/04-validate-package.md"
  run_validator_in_fixture "$fixture_root"
}

case_missing_bundle_output_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  perl -0pi -e 's#reports/workflows#reports/broken#g' \
    "$fixture_root/.harmony/orchestration/runtime/workflows/registry.yml"
  run_validator_in_fixture "$fixture_root"
}

main() {
  assert_success \
    "create-design-package workflow validator accepts the baseline workflow" \
    case_valid_workflow_passes

  assert_failure_contains \
    "create-design-package workflow validator rejects missing stage files" \
    "missing file: .harmony/orchestration/runtime/workflows/meta/create-design-package/stages/04-validate-package.md" \
    case_missing_stage_fails

  assert_failure_contains \
    "create-design-package workflow validator rejects missing registry-update guarantees" \
    "scaffold stage guarantees registry update" \
    case_missing_registry_update_rule_fails

  assert_failure_contains \
    "create-design-package workflow validator rejects missing standard validator invocation" \
    "validate stage runs the standard package validator" \
    case_missing_standard_validator_rule_fails

  assert_failure_contains \
    "create-design-package workflow validator rejects missing workflow bundle outputs" \
    "workflow contract and registry output paths agree" \
    case_missing_bundle_output_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"

  if [[ "$fail_count" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
