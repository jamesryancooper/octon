#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
OCTON_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
VALIDATE_SCRIPT=".octon/assurance/runtime/_ops/scripts/validate-create-design-proposal-workflow.sh"

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

assert_failure_contains() {
  local name="$1" needle="$2"
  shift 2
  local output="" rc=0
  output="$("$@" 2>&1)" || rc=$?
  if (( rc != 0 )) && grep -Fq "$needle" <<<"$output"; then
    pass "$name"
    return 0
  fi
  fail "$name"
  echo "  expected failure containing: $needle" >&2
  echo "$output" >&2
  return 1
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/create-design-proposal-workflow.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p \
    "$fixture_root/.octon/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/orchestration/runtime/workflows/meta"
  cp "$REPO_ROOT/.octon/assurance/runtime/_ops/scripts/validate-create-design-proposal-workflow.sh" \
    "$fixture_root/.octon/assurance/runtime/_ops/scripts/validate-create-design-proposal-workflow.sh"
  cp "$REPO_ROOT/.octon/orchestration/runtime/workflows/manifest.yml" \
    "$fixture_root/.octon/orchestration/runtime/workflows/manifest.yml"
  cp "$REPO_ROOT/.octon/orchestration/runtime/workflows/registry.yml" \
    "$fixture_root/.octon/orchestration/runtime/workflows/registry.yml"
  cp "$REPO_ROOT/.octon/orchestration/runtime/workflows/README.md" \
    "$fixture_root/.octon/orchestration/runtime/workflows/README.md"
  cp -R "$REPO_ROOT/.octon/orchestration/runtime/workflows/meta/create-design-proposal" \
    "$fixture_root/.octon/orchestration/runtime/workflows/meta/"
  printf '%s\n' "$fixture_root"
}

run_validator_in_fixture() {
  local fixture_root="$1"
  (cd "$fixture_root" && bash "$VALIDATE_SCRIPT")
}

case_valid_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_validator_in_fixture "$fixture_root"
}

case_missing_stage_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  rm "$fixture_root/.octon/orchestration/runtime/workflows/meta/create-design-proposal/stages/04-validate-package.md"
  run_validator_in_fixture "$fixture_root"
}

case_missing_registry_reference_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  python3 - "$fixture_root/.octon/orchestration/runtime/workflows/meta/create-design-proposal/stages/03-scaffold-package.md" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
path.write_text(path.read_text().replace(".proposals/registry.yml", "registry-omitted"))
PY
  run_validator_in_fixture "$fixture_root"
}

case_missing_design_validator_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  python3 - "$fixture_root/.octon/orchestration/runtime/workflows/meta/create-design-proposal/stages/04-validate-package.md" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
lines = [line for line in path.read_text().splitlines() if "validate-design-proposal.sh" not in line]
path.write_text("\n".join(lines) + "\n")
PY
  run_validator_in_fixture "$fixture_root"
}

main() {
  assert_success \
    "create-design-proposal workflow validator accepts the baseline workflow" \
    case_valid_passes

  assert_failure_contains \
    "create-design-proposal workflow validator rejects missing stage files" \
    "missing file: .octon/orchestration/runtime/workflows/meta/create-design-proposal/stages/04-validate-package.md" \
    case_missing_stage_fails

  assert_failure_contains \
    "create-design-proposal workflow validator rejects missing registry reference" \
    "scaffold stage updates proposal registry" \
    case_missing_registry_reference_fails

  assert_failure_contains \
    "create-design-proposal workflow validator rejects missing design validator rule" \
    "validate stage runs design proposal validator" \
    case_missing_design_validator_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
