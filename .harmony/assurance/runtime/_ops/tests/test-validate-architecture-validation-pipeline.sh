#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARMONY_DIR/.." && pwd)"
VALIDATE_SCRIPT=".harmony/assurance/runtime/_ops/scripts/validate-architecture-validation-pipeline.sh"

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
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/architecture-validation-pipeline.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.harmony/assurance/runtime/_ops/scripts" \
    "$fixture_root/.harmony/orchestration/runtime/pipelines/audit" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/audit" \
    "$fixture_root/.harmony/orchestration/governance" \
    "$fixture_root/.design-packages"

  cp "$REPO_ROOT/.harmony/assurance/runtime/_ops/scripts/validate-architecture-validation-pipeline.sh" \
    "$fixture_root/.harmony/assurance/runtime/_ops/scripts/validate-architecture-validation-pipeline.sh"
  cp "$REPO_ROOT/.harmony/orchestration/runtime/pipelines/manifest.yml" \
    "$fixture_root/.harmony/orchestration/runtime/pipelines/manifest.yml"
  cp "$REPO_ROOT/.harmony/orchestration/runtime/pipelines/registry.yml" \
    "$fixture_root/.harmony/orchestration/runtime/pipelines/registry.yml"
  cp "$REPO_ROOT/.harmony/orchestration/runtime/pipelines/README.md" \
    "$fixture_root/.harmony/orchestration/runtime/pipelines/README.md"
  cp "$REPO_ROOT/.harmony/orchestration/runtime/workflows/manifest.yml" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/manifest.yml"
  cp "$REPO_ROOT/.harmony/orchestration/runtime/workflows/registry.yml" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/registry.yml"
  cp "$REPO_ROOT/.harmony/orchestration/runtime/workflows/README.md" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/README.md"
  cp "$REPO_ROOT/.harmony/orchestration/governance/capability-map-v1.yml" \
    "$fixture_root/.harmony/orchestration/governance/capability-map-v1.yml"
  cp "$REPO_ROOT/.design-packages/README.md" \
    "$fixture_root/.design-packages/README.md"
  cp -R "$REPO_ROOT/.harmony/orchestration/runtime/pipelines/audit/audit-design-package-workflow" \
    "$fixture_root/.harmony/orchestration/runtime/pipelines/audit/"
  cp -R "$REPO_ROOT/.harmony/orchestration/runtime/workflows/audit/audit-design-package-workflow" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/audit/"

  printf '%s\n' "$fixture_root"
}

run_validator_in_fixture() {
  local fixture_root="$1"
  (
    cd "$fixture_root"
    bash "$VALIDATE_SCRIPT"
  )
}

case_valid_pipeline_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_validator_in_fixture "$fixture_root"
}

case_missing_stage_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  rm "$fixture_root/.harmony/orchestration/runtime/pipelines/audit/audit-design-package-workflow/stages/05-specification-closure.md"
  run_validator_in_fixture "$fixture_root"
}

case_missing_change_manifest_rule_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  perl -0pi -e 's/CHANGE MANIFEST/change receipt/' \
    "$fixture_root/.harmony/orchestration/runtime/pipelines/audit/audit-design-package-workflow/stages/03-remediation-track.md"
  run_validator_in_fixture "$fixture_root"
}

case_missing_capability_map_registration_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  perl -0pi -e 's/\n  - workflow_id: "audit-design-package-workflow"\n    classification: "agent-augmented"\n    autonomous_allowed: false\n    required_contracts:\n      - "delegation-boundaries-v1"\n//' \
    "$fixture_root/.harmony/orchestration/governance/capability-map-v1.yml"
  run_validator_in_fixture "$fixture_root"
}

case_temporary_dependency_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  printf '\n- legacy: .design-packages/architecture-validation-pipeline-package\n' >> \
    "$fixture_root/.harmony/orchestration/runtime/pipelines/audit/audit-design-package-workflow/stages/02-design-audit.md"
  run_validator_in_fixture "$fixture_root"
}

main() {
  assert_success \
    "architecture validation pipeline validator accepts the baseline pipeline" \
    case_valid_pipeline_passes

  assert_failure_contains \
    "architecture validation pipeline validator rejects missing stage files" \
    "missing file: .harmony/orchestration/runtime/pipelines/audit/audit-design-package-workflow/stages/05-specification-closure.md" \
    case_missing_stage_fails

  assert_failure_contains \
    "architecture validation pipeline validator rejects remediation stages without change manifest guidance" \
    "remediation track requires change manifest" \
    case_missing_change_manifest_rule_fails

  assert_failure_contains \
    "architecture validation pipeline validator rejects missing workflow capability-map registration" \
    "capability map classifies workflow" \
    case_missing_capability_map_registration_fails

  assert_failure_contains \
    "architecture validation pipeline validator rejects temporary design-package dependencies" \
    "design audit stage avoids temporary package path references" \
    case_temporary_dependency_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"

  if [[ "$fail_count" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
