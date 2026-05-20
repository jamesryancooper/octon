#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../.." && pwd)"

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

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/incoming-intake.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts"
  mkdir -p "$fixture_root/.octon/inputs/additive/.incoming"
  mkdir -p "$fixture_root/.octon/inputs/additive/.archive"
  mkdir -p "$fixture_root/.octon/inputs/additive/extensions"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh"
  chmod +x "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh"
  printf '%s\n' "$fixture_root"
}

run_validator() {
  local fixture_root="$1"
  local intake_id="$2"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh" --intake-id "$intake_id" >/dev/null 2>&1
}

write_intake_file() {
  local fixture_root="$1"
  local intake_id="$2"
  mkdir -p "$fixture_root/.octon/inputs/additive/.incoming/$intake_id"
  printf '# Intake\n' >"$fixture_root/.octon/inputs/additive/.incoming/$intake_id/README.md"
}

case_accepts_valid_rust_intake_id() {
  local fixture_root
  fixture_root="$(create_fixture)"
  write_intake_file "$fixture_root" "octon-rust-skill-pack-rust-source-authority"
  run_validator "$fixture_root" "octon-rust-skill-pack-rust-source-authority"
}

case_rejects_bad_ids() {
  local fixture_root id
  fixture_root="$(create_fixture)"
  for id in "../escape" "UpperCase" ".hidden" "bad--id" "bad-id-" "bad_id"; do
    if run_validator "$fixture_root" "$id"; then
      return 1
    fi
  done
}

case_rejects_missing_intake() {
  local fixture_root
  fixture_root="$(create_fixture)"
  ! run_validator "$fixture_root" "missing-intake"
}

case_rejects_empty_intake() {
  local fixture_root
  fixture_root="$(create_fixture)"
  mkdir -p "$fixture_root/.octon/inputs/additive/.incoming/empty-intake"
  ! run_validator "$fixture_root" "empty-intake"
}

case_rejects_noise_only_intake() {
  local fixture_root intake
  fixture_root="$(create_fixture)"
  intake="$fixture_root/.octon/inputs/additive/.incoming/noise-only"
  mkdir -p "$intake"
  printf 'noise\n' >"$intake/.DS_Store"
  printf 'keep\n' >"$intake/.gitkeep"
  ! run_validator "$fixture_root" "noise-only"
}

case_rejects_symlink_escape_inside_intake() {
  local fixture_root intake
  fixture_root="$(create_fixture)"
  write_intake_file "$fixture_root" "symlink-escape"
  intake="$fixture_root/.octon/inputs/additive/.incoming/symlink-escape"
  printf 'outside\n' >"$fixture_root/outside.txt"
  ln -s "$fixture_root/outside.txt" "$intake/outside-link"
  ! run_validator "$fixture_root" "symlink-escape"
}

case_rejects_forbidden_resolved_targets() {
  local fixture_root target id link index
  fixture_root="$(create_fixture)"
  index=0

  for target in \
    "$fixture_root/Downloads/bad-intake" \
    "$fixture_root/.archive/bad-intake" \
    "$fixture_root/.octon/generated/bad-intake" \
    "$fixture_root/.octon/state/control/bad-intake" \
    "$fixture_root/.codex/skills/bad-intake" \
    "$fixture_root/.claude/skills/bad-intake" \
    "$fixture_root/.cursor/skills/bad-intake" \
    "$fixture_root/.octon/inputs/additive/extensions/.incoming/bad-intake"; do
    index=$((index + 1))
    id="bad-target-$index"
    link="$fixture_root/.octon/inputs/additive/.incoming/$id"
    mkdir -p "$target"
    printf '# Bad\n' >"$target/README.md"
    ln -s "$target" "$link"
    if run_validator "$fixture_root" "$id"; then
      return 1
    fi
    rm -f "$link"
  done
}

case_accepts_safe_filename_with_spaces() {
  local fixture_root intake output
  fixture_root="$(create_fixture)"
  intake="$fixture_root/.octon/inputs/additive/.incoming/safe-spaces"
  mkdir -p "$intake"
  printf '# Safe\n' >"$intake/file with spaces and punctuation-1.0.md"
  output="$(
    OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
      bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh" --intake-id "safe-spaces"
  )"
  [[ "$output" == *"file with spaces and punctuation-1.0.md"* ]]
}

case_rejects_unsafe_inventory_paths() {
  local fixture_root intake file
  fixture_root="$(create_fixture)"

  for file in \
    $'newline\npath.md' \
    $'tab\tpath.md' \
    'quote"path.md' \
    'back\slash.md' \
    $'control\001path.md'; do
    intake="$fixture_root/.octon/inputs/additive/.incoming/unsafe-paths"
    rm -r -f -- "$intake"
    mkdir -p "$intake"
    printf '# Unsafe\n' >"$intake/$file"
    if run_validator "$fixture_root" "unsafe-paths"; then
      return 1
    fi
  done
}

main() {
  assert_success "incoming intake validator accepts valid rust intake id" case_accepts_valid_rust_intake_id
  assert_success "incoming intake validator rejects bad ids" case_rejects_bad_ids
  assert_success "incoming intake validator rejects missing intake" case_rejects_missing_intake
  assert_success "incoming intake validator rejects empty intake" case_rejects_empty_intake
  assert_success "incoming intake validator rejects noise-only intake" case_rejects_noise_only_intake
  assert_success "incoming intake validator rejects symlink escape inside intake" case_rejects_symlink_escape_inside_intake
  assert_success "incoming intake validator rejects forbidden resolved targets" case_rejects_forbidden_resolved_targets
  assert_success "incoming intake validator accepts safe filenames with spaces" case_accepts_safe_filename_with_spaces
  assert_success "incoming intake validator rejects unsafe inventory paths" case_rejects_unsafe_inventory_paths

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
