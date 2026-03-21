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
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-locality-publication-state.sh" >/dev/null
}

case_valid_fixture_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  run_validator "$fixture_root"
}

case_stale_generation_lock_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/instance/locality/scopes/octon-harness/scope.yml" <<'EOF'
schema_version: "octon-locality-scope-v2"
scope_id: "octon-harness"
display_name: "Octon Harness Updated"
root_path: ".octon"
owner: "Fixture Maintainers"
status: "active"
tech_tags:
  - "octon"
language_tags:
  - "yaml"
EOF

  ! run_validator "$fixture_root"
}

case_publish_reduces_invalid_overlap_and_records_quarantine() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p \
    "$fixture_root/.octon/instance/locality/scopes/overlap" \
    "$fixture_root/.octon/instance/cognition/context/scopes/overlap"

  cat >"$fixture_root/.octon/instance/locality/scopes/overlap/scope.yml" <<'EOF'
schema_version: "octon-locality-scope-v2"
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

  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh" >/dev/null

  [[ "$(yq -r '.publication_status // ""' "$fixture_root/.octon/generated/effective/locality/scopes.effective.yml")" == "published_with_quarantine" ]]
  [[ "$(yq -r '.active_scope_ids[0] // ""' "$fixture_root/.octon/generated/effective/locality/scopes.effective.yml")" == "octon-harness" ]]
  ! yq -e '.active_scope_ids[]? | select(. == "overlap")' "$fixture_root/.octon/generated/effective/locality/scopes.effective.yml" >/dev/null 2>&1
  yq -e '.records | length > 0' "$fixture_root/.octon/state/control/locality/quarantine.yml" >/dev/null
  run_validator "$fixture_root"
}

case_publish_reduces_scope_with_outside_root_glob() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/instance/locality/scopes/octon-harness/scope.yml" <<'EOF'
schema_version: "octon-locality-scope-v2"
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

  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh" >/dev/null

  [[ "$(yq -r '.publication_status // ""' "$fixture_root/.octon/generated/effective/locality/scopes.effective.yml")" == "published_with_quarantine" ]]
  [[ "$(yq -r '.scopes | length' "$fixture_root/.octon/generated/effective/locality/scopes.effective.yml")" == "0" ]]
  yq -e '.records[]? | select(.reason_code == "include-glob-outside-root")' \
    "$fixture_root/.octon/state/control/locality/quarantine.yml" >/dev/null
  run_validator "$fixture_root"
}

case_publish_blocks_missing_scope_id() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/instance/locality/registry.yml" <<'EOF'
schema_version: "octon-locality-registry-v1"
scopes:
  - manifest_path: ".octon/instance/locality/scopes/octon-harness/scope.yml"
EOF

  ! OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh" >/dev/null

  yq -e '.records[]? | select(.reason_code == "missing-scope-id")' \
    "$fixture_root/.octon/state/control/locality/quarantine.yml" >/dev/null
  yq -e '.records[]? | select(.publication_blocking == true)' \
    "$fixture_root/.octon/state/control/locality/quarantine.yml" >/dev/null
}

case_generation_id_stable_for_noop_republish() {
  local fixture_root first_id second_id
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  first_id="$(yq -r '.generation_id // ""' "$fixture_root/.octon/generated/effective/locality/generation.lock.yml")"
  sleep 1
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh" >/dev/null
  second_id="$(yq -r '.generation_id // ""' "$fixture_root/.octon/generated/effective/locality/generation.lock.yml")"

  [[ -n "$first_id" && "$first_id" == "$second_id" ]]
}

main() {
  assert_success "valid locality publication state passes" case_valid_fixture_passes
  assert_success "stale locality generation lock fails validation" case_stale_generation_lock_fails
  assert_success "invalid overlap republishes reduced locality set with quarantine" case_publish_reduces_invalid_overlap_and_records_quarantine
  assert_success "out-of-root glob quarantines the affected scope and republishes" case_publish_reduces_scope_with_outside_root_glob
  assert_success "repo-level locality registry failure still blocks publish" case_publish_blocks_missing_scope_id
  assert_success "generation id remains stable across noop republishes" case_generation_id_stable_for_noop_republish

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
