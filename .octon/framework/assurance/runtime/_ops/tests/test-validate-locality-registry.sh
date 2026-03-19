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

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-locality-registry.sh" >/dev/null
}

case_valid_fixture_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  run_validator "$fixture_root"
}

case_duplicate_scope_id_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/instance/locality/registry.yml" <<'EOF'
schema_version: "octon-locality-registry-v1"
scopes:
  - scope_id: "octon-harness"
    manifest_path: ".octon/instance/locality/scopes/octon-harness/scope.yml"
  - scope_id: "octon-harness"
    manifest_path: ".octon/instance/locality/scopes/octon-harness/scope.yml"
EOF

  ! run_validator "$fixture_root"
}

case_missing_scope_manifest_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  rm -f "$fixture_root/.octon/instance/locality/scopes/octon-harness/scope.yml"
  ! run_validator "$fixture_root"
}

case_overlapping_active_scopes_fail() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p \
    "$fixture_root/.octon/instance/locality/scopes/overlap" \
    "$fixture_root/.octon/instance/cognition/context/scopes/overlap"

  cat >"$fixture_root/.octon/instance/locality/scopes/overlap/scope.yml" <<'EOF'
schema_version: "octon-locality-scope-v1"
scope_id: "overlap"
display_name: "Overlap"
root_path: ".octon/framework"
owner: "Fixture Maintainers"
status: "active"
tech_tags:
  - "octon"
language_tags:
  - "yaml"
EOF

  cat >"$fixture_root/.octon/instance/cognition/context/scopes/overlap/README.md" <<'EOF'
# Overlap
EOF

  cat >"$fixture_root/.octon/instance/locality/registry.yml" <<'EOF'
schema_version: "octon-locality-registry-v1"
scopes:
  - scope_id: "octon-harness"
    manifest_path: ".octon/instance/locality/scopes/octon-harness/scope.yml"
  - scope_id: "overlap"
    manifest_path: ".octon/instance/locality/scopes/overlap/scope.yml"
EOF

  ! run_validator "$fixture_root"
}

case_escaped_include_glob_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/instance/locality/scopes/octon-harness/scope.yml" <<'EOF'
schema_version: "octon-locality-scope-v1"
scope_id: "octon-harness"
display_name: "Octon Harness"
root_path: ".octon"
include_globs:
  - "../outside/**"
owner: "Fixture Maintainers"
status: "active"
tech_tags:
  - "octon"
language_tags:
  - "yaml"
EOF

  ! run_validator "$fixture_root"
}

case_safe_but_outside_root_glob_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/instance/locality/scopes/octon-harness/scope.yml" <<'EOF'
schema_version: "octon-locality-scope-v1"
scope_id: "octon-harness"
display_name: "Octon Harness"
root_path: ".octon/framework"
include_globs:
  - ".octon/instance/**"
owner: "Fixture Maintainers"
status: "active"
tech_tags:
  - "octon"
language_tags:
  - "yaml"
EOF

  ! run_validator "$fixture_root"
}

main() {
  assert_success "valid locality registry fixture passes" case_valid_fixture_passes
  assert_success "duplicate scope ids fail locality validation" case_duplicate_scope_id_fails
  assert_success "missing scope manifest fails locality validation" case_missing_scope_manifest_fails
  assert_success "overlapping active scopes fail locality validation" case_overlapping_active_scopes_fail
  assert_success "escaped include glob fails locality validation" case_escaped_include_glob_fails
  assert_success "safe but out-of-root glob fails locality validation" case_safe_but_outside_root_glob_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
