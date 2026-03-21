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
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-export-profile-contract.sh" >/dev/null
}

run_runtime_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh" >/dev/null
}

case_full_fidelity_include_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/octon.yml" <<'EOF'
schema_version: "octon-root-manifest-v2"
topology:
  super_root: ".octon/"
  class_roots:
    framework: "framework/"
    instance: "instance/"
    inputs: "inputs/"
    state: "state/"
    generated: "generated/"
versioning:
  harness:
    release_version: "0.5.0"
    supported_schema_versions:
      - "octon-root-manifest-v2"
      - "octon-framework-manifest-v2"
      - "octon-instance-manifest-v1"
    rejection_mode: "fail-closed"
    migration_workflow: "framework/orchestration/runtime/workflows/meta/migrate-harness/README.md"
    migration_overview: "framework/orchestration/runtime/workflows/meta/migrate-harness/00-overview.md"
    deterministic_upgrade_instructions:
      - "Upgrade."
      - "Upgrade."
      - "Upgrade."
  extensions:
    api_version: "1.0"
profiles:
  bootstrap_core:
    include:
      - "octon.yml"
      - "framework/**"
      - "instance/manifest.yml"
  repo_snapshot:
    include:
      - "octon.yml"
      - "framework/**"
      - "instance/**"
      - "inputs/additive/extensions/<enabled-and-dependent>/**"
    exclude:
      - "inputs/exploratory/**"
      - "state/**"
      - "generated/**"
  pack_bundle:
    selector: "inputs/additive/extensions/<selected>/**"
    include_dependency_closure: true
    exclude:
      - "framework/**"
      - "instance/**"
      - "inputs/exploratory/**"
      - "state/**"
      - "generated/**"
  full_fidelity:
    include:
      - "."
policies:
  raw_input_dependency: "fail-closed"
  generated_staleness: "fail-closed"
  generated_commit_defaults:
    "generated/effective/**": "commit"
    "generated/proposals/registry.yml": "commit"
    "generated/cognition/summaries/**": "commit"
    "generated/cognition/projections/definitions/**": "commit"
    "generated/cognition/graph/**": "rebuild"
    "generated/cognition/projections/materialized/**": "rebuild"
zones:
  human_led:
    - "inputs/exploratory/ideation/**"
EOF

  ! run_validator "$fixture_root"
}

case_validator_preserves_runtime_effective_coherence() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  run_validator "$fixture_root"
  run_runtime_validator "$fixture_root"
}

main() {
  assert_success "export profile validator fails when full_fidelity defines an include payload" case_full_fidelity_include_fails
  assert_success "export profile validator preserves runtime effective coherence after extension refresh" case_validator_preserves_runtime_effective_coherence

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
