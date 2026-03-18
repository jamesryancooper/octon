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

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-companion-manifests.sh" >/dev/null
}

case_missing_bundled_policy_sets_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/framework/manifest.yml" <<'EOF'
schema_version: "octon-framework-manifest-v2"
framework_id: "octon-core"
release_version: "0.5.0"
supported_instance_schema_versions:
  - "octon-instance-manifest-v1"
overlay_registry: ".octon/framework/overlay-points/registry.yml"
subsystems:
  - "agency"
generators:
  - "proposal-registry"
EOF

  ! run_validator "$fixture_root"
}

main() {
  assert_success "companion validator fails when bundled_policy_sets is missing" case_missing_bundled_policy_sets_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
