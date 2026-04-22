#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"

pass_count=0
fail_count=0
cleanup_dirs=()

remove_dir_tree() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  find "$dir" -depth \( -type f -o -type l \) -exec rm -f -- {} + 2>/dev/null || true
  find "$dir" -depth -type d -exec rmdir -- {} + 2>/dev/null || true
}

cleanup() {
  local dir
  for dir in "${cleanup_dirs[@]}"; do
    remove_dir_tree "$dir"
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
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/packet10-runtime-handles.XXXXXX")"
  cleanup_dirs+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/generated/effective/runtime" \
    "$fixture_root/.octon/generated/effective/capabilities" \
    "$fixture_root/.octon/framework/engine/runtime/spec"

  cp "$ROOT_DIR/.octon/generated/effective/runtime/route-bundle.lock.yml" \
    "$fixture_root/.octon/generated/effective/runtime/route-bundle.lock.yml"
  cp "$ROOT_DIR/.octon/generated/effective/capabilities/pack-routes.lock.yml" \
    "$fixture_root/.octon/generated/effective/capabilities/pack-routes.lock.yml"
  cp "$ROOT_DIR/.octon/framework/engine/runtime/spec/runtime-effective-artifact-handle-v1.md" \
    "$fixture_root/.octon/framework/engine/runtime/spec/runtime-effective-artifact-handle-v1.md"

  printf '%s\n' "$fixture_root"
}

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-artifact-handles.sh" >/dev/null
}

case_current_lock_variants_pass() {
  local fixture_root
  fixture_root="$(create_fixture)"
  run_validator "$fixture_root"
}

case_route_lock_v3_dependency_handles_pass() {
  local fixture_root
  fixture_root="$(create_fixture)"

  yq -i '.schema_version = "octon-runtime-effective-route-bundle-lock-v3"' \
    "$fixture_root/.octon/generated/effective/runtime/route-bundle.lock.yml"
  yq -i '.dependency_handles = [{"artifact_kind":"pack_routes","output_ref":".octon/generated/effective/capabilities/pack-routes.effective.yml"}]' \
    "$fixture_root/.octon/generated/effective/runtime/route-bundle.lock.yml"

  run_validator "$fixture_root"
}

case_invalid_freshness_mode_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"

  yq -i '.freshness.mode = "legacy_only"' \
    "$fixture_root/.octon/generated/effective/runtime/route-bundle.lock.yml"

  ! run_validator "$fixture_root"
}

case_missing_invalidation_conditions_fail() {
  local fixture_root
  fixture_root="$(create_fixture)"

  yq -i 'del(.freshness.invalidation_conditions)' \
    "$fixture_root/.octon/generated/effective/runtime/route-bundle.lock.yml"

  ! run_validator "$fixture_root"
}

case_missing_allowed_consumer_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"

  yq -i 'del(.allowed_consumers)' \
    "$fixture_root/.octon/generated/effective/runtime/route-bundle.lock.yml"

  ! run_validator "$fixture_root"
}

case_invalid_classification_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"

  yq -i '.non_authority_classification = "operator-read-model"' \
    "$fixture_root/.octon/generated/effective/runtime/route-bundle.lock.yml"

  ! run_validator "$fixture_root"
}

case_v3_dependency_handle_without_output_ref_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"

  yq -i '.schema_version = "octon-runtime-effective-route-bundle-lock-v3"' \
    "$fixture_root/.octon/generated/effective/runtime/route-bundle.lock.yml"
  yq -i '.dependency_handles = [{"artifact_kind":"pack_routes"}]' \
    "$fixture_root/.octon/generated/effective/runtime/route-bundle.lock.yml"

  ! run_validator "$fixture_root"
}

main() {
  assert_success "current route and pack lock variants pass" case_current_lock_variants_pass
  assert_success "route lock v3 passes when dependency handles are declared" case_route_lock_v3_dependency_handles_pass
  assert_success "invalid freshness mode fails closed" case_invalid_freshness_mode_fails
  assert_success "missing invalidation conditions fail closed" case_missing_invalidation_conditions_fail
  assert_success "missing allowed consumer fails closed" case_missing_allowed_consumer_fails
  assert_success "invalid non-authority classification fails closed" case_invalid_classification_fails
  assert_success "v3 dependency handles require output refs" case_v3_dependency_handle_without_output_ref_fails

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
