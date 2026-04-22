#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
RECEIPT_REL=".octon/state/evidence/validation/architecture/10of10-target-transition/authorization-boundary/coverage.yml"

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

copy_repo_ref() {
  local fixture_root="$1"
  local ref="$2"

  mkdir -p "$fixture_root/$(dirname "$ref")"
  cp "$ROOT_DIR/$ref" "$fixture_root/$ref"
}

create_fixture() {
  local fixture_root ref
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/packet10-tokens.XXXXXX")"
  cleanup_dirs+=("$fixture_root")

  copy_repo_ref "$fixture_root" ".octon/framework/engine/runtime/spec/material-side-effect-inventory-v1.schema.json"
  copy_repo_ref "$fixture_root" ".octon/framework/engine/runtime/spec/material-side-effect-inventory.yml"
  copy_repo_ref "$fixture_root" "$RECEIPT_REL"

  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    copy_repo_ref "$fixture_root" "$ref"
  done < <(yq -r '.spec_ref, .coverage_map_ref, .inventory[].file, .workflow_gates[].workflow_ref' "$ROOT_DIR/$RECEIPT_REL")

  printf '%s\n' "$fixture_root"
}

enable_tokens() {
  local fixture_root="$1"
  local inventory="$fixture_root/.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml"
  local coverage_map
  local id path_id

  coverage_map="$fixture_root/$(yq -r '.coverage_map_ref' "$fixture_root/$RECEIPT_REL")"

  while IFS= read -r id; do
    [[ -n "$id" ]] || continue
    yq -i "(.classes[] | select(.id == \"$id\")).token_type = \"effect::$id\"" "$inventory"
  done < <(yq -r '.classes[] | select(.material == true) | .id' "$inventory")

  while IFS= read -r path_id; do
    [[ -n "$path_id" ]] || continue
    yq -i "(.paths[] | select(.path_id == \"$path_id\")).authorized_effect_token_type = \"effect::$path_id\"" "$coverage_map"
    yq -i "(.paths[] | select(.path_id == \"$path_id\")).negative_controls += [\"authorized-effect token bypass denial\"]" "$coverage_map"
  done < <(yq -r '.paths[].path_id' "$coverage_map")
}

run_validators() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" OCTON_ENFORCE_EFFECT_TOKENS=1 \
    bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh" >/dev/null
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" OCTON_ENFORCE_EFFECT_TOKENS=1 \
    bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh" >/dev/null
}

case_token_enforcement_fails_without_token_types() {
  local fixture_root
  fixture_root="$(create_fixture)"
  yq -i 'del(.classes[].token_type)' "$fixture_root/.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml"
  yq -i 'del(.paths[].authorized_effect_token_type)' "$fixture_root/$(yq -r '.coverage_map_ref' "$fixture_root/$RECEIPT_REL")"
  ! run_validators "$fixture_root"
}

case_token_enforcement_passes_with_declared_tokens() {
  local fixture_root
  fixture_root="$(create_fixture)"
  enable_tokens "$fixture_root"
  run_validators "$fixture_root"
}

case_missing_token_negative_control_fails() {
  local fixture_root coverage_map first_path
  fixture_root="$(create_fixture)"
  enable_tokens "$fixture_root"
  coverage_map="$fixture_root/$(yq -r '.coverage_map_ref' "$fixture_root/$RECEIPT_REL")"
  first_path="$(yq -r '.paths[0].path_id' "$coverage_map")"

  yq -i "(.paths[] | select(.path_id == \"$first_path\")).negative_controls = [\"generated-as-authority denial\"]" "$coverage_map"

  ! run_validators "$fixture_root"
}

main() {
  assert_success "token enforcement fails without token types" case_token_enforcement_fails_without_token_types
  assert_success "token enforcement passes with declared token mediation" case_token_enforcement_passes_with_declared_tokens
  assert_success "token enforcement fails without token bypass negative controls" case_missing_token_negative_control_fails

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
