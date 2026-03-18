#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_packet2_fixture_lib.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -rf "$dir"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

assert_failure() {
  local name="$1"
  shift
  if "$@"; then
    fail "$name"
  else
    pass "$name"
  fi
}

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh" >/dev/null
}

case_valid_manifest_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"
  run_validator "$fixture_root"
}

case_old_shape_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/octon.yml" <<'EOF'
schema_version: "octon-root-manifest-v1"
class_roots:
  framework: ".octon/framework"
  instance: ".octon/instance"
  inputs: ".octon/inputs"
  state: ".octon/state"
  generated: ".octon/generated"
versioning:
  harness:
    release_version: "0.4.15"
    supported_schema_versions:
      - "octon-root-manifest-v1"
    rejection_mode: "fail-closed"
    migration_workflow: "framework/orchestration/runtime/workflows/meta/migrate-harness/README.md"
    migration_overview: "framework/orchestration/runtime/workflows/meta/migrate-harness/00-overview.md"
    deterministic_upgrade_instructions:
      - "Upgrade."
extensions:
  api_version: "v1"
human_led:
  - "inputs/exploratory/ideation/**"
EOF

  ! run_validator "$fixture_root"
}

main() {
  assert_success "version contract validator passes for v2 manifest" case_valid_manifest_passes
  assert_success "version contract validator fails for old root-manifest shape" case_old_shape_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
