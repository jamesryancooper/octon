#!/usr/bin/env bash
# test-validate-orchestration-design-proposal.sh - Regression tests for design proposal validation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARMONY_DIR/.." && pwd)"
VALIDATE_SCRIPT=".harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-proposal.sh"
PACKAGE_PATH=".proposals/.archive/design/orchestration-domain-design-package"

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
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/design-package-validation.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p "$fixture_root/.harmony/assurance/runtime/_ops/scripts" "$fixture_root/.proposals/.archive/design"
  cp "$REPO_ROOT/.harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-proposal.sh" \
    "$fixture_root/.harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-proposal.sh"
  cp -R "$REPO_ROOT/.proposals/.archive/design/orchestration-domain-design-package" \
    "$fixture_root/.proposals/.archive/design/"

  printf '%s\n' "$fixture_root"
}

run_validator_in_fixture() {
  local fixture_root="$1"
  (
    cd "$fixture_root"
    bash "$VALIDATE_SCRIPT" "$PACKAGE_PATH"
  )
}

case_valid_package_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_validator_in_fixture "$fixture_root"
}

case_missing_schema_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  rm "$fixture_root/.proposals/.archive/design/orchestration-domain-design-package/contracts/schemas/decision-record.schema.json"
  run_validator_in_fixture "$fixture_root"
}

case_missing_coverage_marker_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  perl -0pi -e 's/`contracts\/decision-record-contract\.md` — `schema-backed` via `contracts\/schemas\/decision-record\.schema\.json`/`contracts\/decision-record-contract.md`/' \
    "$fixture_root/.proposals/.archive/design/orchestration-domain-design-package/normative/assurance/implementation-readiness.md"
  run_validator_in_fixture "$fixture_root"
}

case_invalid_fixture_that_passes_is_detected() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  cp \
    "$fixture_root/.proposals/.archive/design/orchestration-domain-design-package/contracts/fixtures/valid/decision-record.valid.json" \
    "$fixture_root/.proposals/.archive/design/orchestration-domain-design-package/contracts/fixtures/invalid/decision-record.invalid.json"
  run_validator_in_fixture "$fixture_root"
}

main() {
  assert_success \
    "design proposal validator accepts the baseline proof layer" \
    case_valid_package_passes

  assert_failure_contains \
    "design proposal validator rejects missing schema artifacts" \
    "missing schema for schema-backed contract" \
    case_missing_schema_fails

  assert_failure_contains \
    "design proposal validator rejects missing validation coverage markers" \
    "required contract missing validation coverage marker" \
    case_missing_coverage_marker_fails

  assert_failure_contains \
    "design proposal validator rejects invalid fixtures that unexpectedly pass" \
    "schema-backed invalid fixture unexpectedly passed" \
    case_invalid_fixture_that_passes_is_detected

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"

  if [[ "$fail_count" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
