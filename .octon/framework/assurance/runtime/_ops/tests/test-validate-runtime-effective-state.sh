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
    [[ -n "$dir" ]] && rm -r -f -- "$dir"
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

prepare_fixture() {
  local fixture_root="$1"
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh" >/dev/null
}

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh" >/dev/null
}

case_valid_fixture_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  run_validator "$fixture_root"
}

case_raw_input_dependency_violation_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"

  mkdir -p "$fixture_root/.octon/framework/engine/runtime"
  cat >"$fixture_root/.octon/framework/engine/runtime/raw-input-leak.md" <<'EOF'
# invalid

Reads from .octon/inputs/additive/extensions/demo/pack.yml at runtime.
EOF

  ! run_validator "$fixture_root"
}

case_stale_required_effective_output_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"

  printf '# drift\n' >>"$fixture_root/.octon/generated/effective/extensions/catalog.effective.yml"

  ! run_validator "$fixture_root"
}

case_missing_generation_lock_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"

  rm "$fixture_root/.octon/generated/effective/capabilities/generation.lock.yml"

  ! run_validator "$fixture_root"
}

case_cross_family_generation_mismatch_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"

  perl -0pi -e 's/locality-[a-z0-9]+/locality-bad/' \
    "$fixture_root/.octon/generated/effective/capabilities/routing.effective.yml"
  perl -0pi -e 's/locality-[a-z0-9]+/locality-bad/' \
    "$fixture_root/.octon/generated/effective/capabilities/generation.lock.yml"

  ! run_validator "$fixture_root"
}

case_invalid_class_root_binding_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"

  perl -0pi -e 's#framework: "framework/"#framework: "framework-bad/"#' \
    "$fixture_root/.octon/octon.yml"

  ! run_validator "$fixture_root"
}

main() {
  assert_success "runtime effective validator passes for coherent fixture" case_valid_fixture_passes
  assert_success "runtime effective validator fails on raw input dependency leakage" case_raw_input_dependency_violation_fails
  assert_success "runtime effective validator fails on stale required effective outputs" case_stale_required_effective_output_fails
  assert_success "runtime effective validator fails on missing generation lock" case_missing_generation_lock_fails
  assert_success "runtime effective validator fails on cross-family generation mismatch" case_cross_family_generation_mismatch_fails
  assert_success "runtime effective validator fails on invalid class-root binding" case_invalid_class_root_binding_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
