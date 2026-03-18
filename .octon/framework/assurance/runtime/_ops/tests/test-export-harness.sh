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

run_export() {
  local fixture_root="$1"
  shift
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh" "$@"
}

write_pack() {
  local fixture_root="$1"
  local pack_id="$2"
  local requires_block="$3"
  local conflicts_block="$4"

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/$pack_id"
  cat >"$fixture_root/.octon/inputs/additive/extensions/$pack_id/pack.yml" <<EOF
schema_version: "extension-pack-v1"
id: "$pack_id"
version: "1.0.0"
compatibility:
  octon_version: "0.5.0"
  extensions_api_version: "1.0"
dependencies:
  requires:
$requires_block
  conflicts:
$conflicts_block
EOF
}

case_repo_snapshot_empty_enabled_exports_core_only() {
  local fixture_root output_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  output_root="$fixture_root/out"
  run_export "$fixture_root" --profile repo_snapshot --output-dir "$output_root" >/dev/null || return 1

  [[ -f "$output_root/.octon/octon.yml" ]]
  [[ -d "$output_root/.octon/framework" ]]
  [[ -d "$output_root/.octon/instance" ]]
  [[ ! -e "$output_root/.octon/state" ]]
  [[ ! -e "$output_root/.octon/generated" ]]
}

case_repo_snapshot_missing_enabled_pack_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v1"
selection:
  enabled:
    - "missing-pack"
sources: {}
trust: {}
acknowledgements: []
EOF

  ! run_export "$fixture_root" --profile repo_snapshot --output-dir "$fixture_root/out" >/dev/null 2>&1
}

case_pack_bundle_includes_dependency_closure_only() {
  local fixture_root output_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_pack "$fixture_root" "b" "    []" "    []"
  write_pack "$fixture_root" "a" $'    - id: "b"\n      version_range: "1.0.0"' "    []"

  output_root="$fixture_root/out"
  run_export "$fixture_root" --profile pack_bundle --output-dir "$output_root" --pack-ids "a" >/dev/null || return 1

  [[ -d "$output_root/.octon/inputs/additive/extensions/a" ]]
  [[ -d "$output_root/.octon/inputs/additive/extensions/b" ]]
  [[ ! -e "$output_root/.octon/framework" ]]
  [[ ! -e "$output_root/.octon/instance" ]]
  [[ ! -e "$output_root/.octon/state" ]]
  [[ ! -e "$output_root/.octon/generated" ]]
}

case_full_fidelity_rejected() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  ! run_export "$fixture_root" --profile full_fidelity --output-dir "$fixture_root/out" >/dev/null 2>&1
}

case_pack_bundle_cycle_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_pack "$fixture_root" "a" $'    - id: "b"\n      version_range: "1.0.0"' "    []"
  write_pack "$fixture_root" "b" $'    - id: "a"\n      version_range: "1.0.0"' "    []"

  ! run_export "$fixture_root" --profile pack_bundle --output-dir "$fixture_root/out" --pack-ids "a" >/dev/null 2>&1
}

case_pack_bundle_conflict_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_pack "$fixture_root" "b" "    []" "    []"
  write_pack "$fixture_root" "a" "    []" $'    - id: "b"\n      version_range: "1.0.0"'

  ! run_export "$fixture_root" --profile pack_bundle --output-dir "$fixture_root/out" --pack-ids "a,b" >/dev/null 2>&1
}

case_pack_bundle_compatibility_mismatch_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/a"
  cat >"$fixture_root/.octon/inputs/additive/extensions/a/pack.yml" <<'EOF'
schema_version: "extension-pack-v1"
id: "a"
version: "1.0.0"
compatibility:
  octon_version: "^9.0.0"
  extensions_api_version: "1.0"
dependencies:
  requires: []
  conflicts: []
EOF

  ! run_export "$fixture_root" --profile pack_bundle --output-dir "$fixture_root/out" --pack-ids "a" >/dev/null 2>&1
}

main() {
  assert_success "repo_snapshot with empty enabled set exports only core payload" case_repo_snapshot_empty_enabled_exports_core_only
  assert_success "repo_snapshot fails when an enabled pack payload is missing" case_repo_snapshot_missing_enabled_pack_fails
  assert_success "pack_bundle exports selected packs plus dependency closure only" case_pack_bundle_includes_dependency_closure_only
  assert_success "full_fidelity export is rejected" case_full_fidelity_rejected
  assert_success "pack_bundle fails on dependency cycles" case_pack_bundle_cycle_fails
  assert_success "pack_bundle fails on declared conflicts" case_pack_bundle_conflict_fails
  assert_success "pack_bundle fails on compatibility mismatch" case_pack_bundle_compatibility_mismatch_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
