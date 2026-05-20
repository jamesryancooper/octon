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
}

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh" >/dev/null
}

write_leak_and_expect_failure() {
  local rel="$1"
  local body="$2"
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"

  mkdir -p "$(dirname "$fixture_root/$rel")"
  printf '%s\n' "$body" >"$fixture_root/$rel"

  ! run_validator "$fixture_root"
}

case_valid_fixture_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  run_validator "$fixture_root"
}

case_runtime_raw_input_leak_fails() {
  write_leak_and_expect_failure \
    ".octon/framework/engine/runtime/raw-input.rs" \
    'const SOURCE: &str = ".octon/inputs/exploratory/reports/bad/report.yml";'
}

case_policy_raw_input_leak_fails() {
  write_leak_and_expect_failure \
    ".octon/instance/governance/policies/raw-input.yml" \
    'runtime_source: ".octon/inputs/exploratory/plans/2026-05-20-bad-plan.md"'
}

case_generated_raw_input_leak_fails() {
  write_leak_and_expect_failure \
    ".octon/generated/effective/capabilities/routing.effective.yml" \
    'authority_source: ".octon/inputs/additive/.incoming/bad/README.md"'
}

case_state_control_raw_input_leak_fails() {
  write_leak_and_expect_failure \
    ".octon/state/control/extensions/active.yml" \
    'source: ".octon/inputs/exploratory/syntheses/bad-synthesis.md"'
}

case_publication_receipt_raw_input_leak_fails() {
  write_leak_and_expect_failure \
    ".octon/state/evidence/validation/publication/capabilities/bad.yml" \
    'authority_source: ".octon/inputs/exploratory/reports/bad/report.yml"'
}

case_command_manifest_raw_input_leak_fails() {
  write_leak_and_expect_failure \
    ".octon/framework/capabilities/runtime/commands/manifest.yml" \
    'source_path: ".octon/inputs/exploratory/reports/bad/report.yml"'
}

case_workflow_registry_raw_input_leak_fails() {
  write_leak_and_expect_failure \
    ".octon/framework/orchestration/runtime/workflows/registry.yml" \
    'path: ".octon/inputs/exploratory/plans/2026-05-20-bad-plan.md"'
}

case_host_projection_raw_input_leak_fails() {
  write_leak_and_expect_failure \
    ".codex/commands/bad.md" \
    'Read .octon/inputs/exploratory/reports/bad/report.yml as live command authority.'
}

case_allowed_skill_output_path_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  mkdir -p "$fixture_root/.octon/framework/capabilities/runtime/skills/synthesis/demo"
  cat >"$fixture_root/.octon/framework/capabilities/runtime/skills/synthesis/demo/SKILL.md" <<'EOF'
allowed-tools: Write(/.octon/inputs/exploratory/syntheses/*)
Outputs are written to `.octon/inputs/exploratory/syntheses/`.
EOF
  run_validator "$fixture_root"
}

main() {
  assert_success "input non-authority validator accepts valid fixture" case_valid_fixture_passes
  assert_success "input non-authority validator rejects runtime raw input leak" case_runtime_raw_input_leak_fails
  assert_success "input non-authority validator rejects policy raw input leak" case_policy_raw_input_leak_fails
  assert_success "input non-authority validator rejects generated raw input leak" case_generated_raw_input_leak_fails
  assert_success "input non-authority validator rejects state/control raw input leak" case_state_control_raw_input_leak_fails
  assert_success "input non-authority validator rejects publication receipt raw input leak" case_publication_receipt_raw_input_leak_fails
  assert_success "input non-authority validator rejects command manifest raw input leak" case_command_manifest_raw_input_leak_fails
  assert_success "input non-authority validator rejects workflow registry raw input leak" case_workflow_registry_raw_input_leak_fails
  assert_success "input non-authority validator rejects host projection raw input leak" case_host_projection_raw_input_leak_fails
  assert_success "input non-authority validator allows skill output path contracts" case_allowed_skill_output_path_passes

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
