#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-instruction-layer-manifest-depth.sh"

declare -a CLEANUP_DIRS=()
pass_count=0
fail_count=0

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -rf "$dir"
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

new_fixture_root() {
  local root
  root="$(mktemp -d "${TMPDIR:-/tmp}/instruction-layer-manifest-depth.XXXXXX")"
  CLEANUP_DIRS+=("$root")

  mkdir -p "$root/.octon/framework/constitution/contracts/runtime"
  mkdir -p "$root/.octon/instance/execution-roles/runtime"
  cp \
    "$ROOT_DIR/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json" \
    "$root/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json"
  cp \
    "$ROOT_DIR/.octon/instance/execution-roles/runtime/tool-output-budgets.yml" \
    "$root/.octon/instance/execution-roles/runtime/tool-output-budgets.yml"

  printf '%s\n' "$root"
}

run_validator_for_root() {
  local root="$1"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$VALIDATOR" >/dev/null
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

case_current_fixture_passes() {
  local root
  root="$(new_fixture_root)"
  run_validator_for_root "$root"
}

case_missing_capability_pack_refs_fails() {
  local root
  root="$(new_fixture_root)"
  yq -i 'del(.properties.capability_pack_refs)' \
    "$root/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json"
  ! run_validator_for_root "$root"
}

case_missing_context_layer_disclosure_fails() {
  local root
  root="$(new_fixture_root)"
  yq -i 'del(."$defs".context_layer.properties.disclosure_mode.enum)' \
    "$root/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json"
  ! run_validator_for_root "$root"
}

case_missing_shell_budget_policy_fails() {
  local root
  root="$(new_fixture_root)"
  yq -i 'del(.capability_packs.shell.output_envelope_policy_ref)' \
    "$root/.octon/instance/execution-roles/runtime/tool-output-budgets.yml"
  ! run_validator_for_root "$root"
}

case_missing_execution_class_budget_ref_fails() {
  local root
  root="$(new_fixture_root)"
  yq -i 'del(.execution_classes."safe-read-only".output_envelope_policy_ref)' \
    "$root/.octon/instance/execution-roles/runtime/tool-output-budgets.yml"
  ! run_validator_for_root "$root"
}

main() {
  assert_success "current fixture passes manifest depth validation" case_current_fixture_passes
  assert_success "missing capability_pack_refs fails closed" case_missing_capability_pack_refs_fails
  assert_success "missing context-layer disclosure enum fails closed" case_missing_context_layer_disclosure_fails
  assert_success "missing shell budget policy ref fails closed" case_missing_shell_budget_policy_fails
  assert_success "missing execution-class budget ref fails closed" case_missing_execution_class_budget_ref_fails

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
