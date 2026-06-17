#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-envelope-normalization.sh"

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
  root="$(mktemp -d "${TMPDIR:-/tmp}/capability-envelope-normalization.XXXXXX")"
  CLEANUP_DIRS+=("$root")

  mkdir -p "$root/.octon/framework/engine/runtime/spec"
  mkdir -p "$root/.octon/instance/governance/policies"
  mkdir -p "$root/.octon/framework/capabilities/packs/shell"
  mkdir -p "$root/.octon/framework/capabilities/packs/repo"
  mkdir -p "$root/.octon/instance/governance/capability-packs"
  mkdir -p "$root/.octon/instance/capabilities/runtime/packs/admissions"

  cp "$ROOT_DIR/.octon/framework/engine/runtime/spec/execution-request-v2.schema.json" \
    "$root/.octon/framework/engine/runtime/spec/execution-request-v2.schema.json"
  cp "$ROOT_DIR/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json" \
    "$root/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json"
  cp "$ROOT_DIR/.octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json" \
    "$root/.octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json"
  cp "$ROOT_DIR/.octon/instance/governance/policies/repo-shell-execution-classes.yml" \
    "$root/.octon/instance/governance/policies/repo-shell-execution-classes.yml"
  cp "$ROOT_DIR/.octon/framework/capabilities/packs/shell/manifest.yml" \
    "$root/.octon/framework/capabilities/packs/shell/manifest.yml"
  cp "$ROOT_DIR/.octon/framework/capabilities/packs/repo/manifest.yml" \
    "$root/.octon/framework/capabilities/packs/repo/manifest.yml"
  cp "$ROOT_DIR/.octon/instance/governance/capability-packs/shell.yml" \
    "$root/.octon/instance/governance/capability-packs/shell.yml"
  cp "$ROOT_DIR/.octon/instance/capabilities/runtime/packs/admissions/shell.yml" \
    "$root/.octon/instance/capabilities/runtime/packs/admissions/shell.yml"

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

case_missing_receipt_raw_payload_refs_fails() {
  local root
  root="$(new_fixture_root)"
  yq -i 'del(.properties.raw_payload_refs)' \
    "$root/.octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json"
  ! run_validator_for_root "$root"
}

case_missing_class_envelope_ref_fails() {
  local root
  root="$(new_fixture_root)"
  yq -i 'del(.classes[] | select(.class_id == "safe-read-only").output_envelope_policy_ref)' \
    "$root/.octon/instance/governance/policies/repo-shell-execution-classes.yml"
  ! run_validator_for_root "$root"
}

case_missing_shell_pack_receipt_field_fails() {
  local root
  root="$(new_fixture_root)"
  yq -i 'del(.normalized_receipt_fields[] | select(. == "execution_class_id"))' \
    "$root/.octon/framework/capabilities/packs/shell/manifest.yml"
  ! run_validator_for_root "$root"
}

case_missing_admission_validator_ref_fails() {
  local root
  root="$(new_fixture_root)"
  yq -i 'del(.validator_refs[] | select(. == ".octon/framework/assurance/runtime/_ops/scripts/validate-capability-envelope-normalization.sh"))' \
    "$root/.octon/instance/capabilities/runtime/packs/admissions/shell.yml"
  ! run_validator_for_root "$root"
}

main() {
  assert_success "current fixture passes capability envelope validation" case_current_fixture_passes
  assert_success "missing receipt raw_payload_refs fails closed" case_missing_receipt_raw_payload_refs_fails
  assert_success "missing class envelope ref fails closed" case_missing_class_envelope_ref_fails
  assert_success "missing shell pack receipt field fails closed" case_missing_shell_pack_receipt_field_fails
  assert_success "missing admission validator ref fails closed" case_missing_admission_validator_ref_fails

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
