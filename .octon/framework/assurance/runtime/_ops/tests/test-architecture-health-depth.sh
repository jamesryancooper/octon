#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"

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

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/packet10-arch-health.XXXXXX")"
  cleanup_dirs+=("$fixture_root")
  printf '%s\n' "$fixture_root"
}

write_matrix() {
  local fixture_root="$1"
  cat >"$fixture_root/matrix.txt" <<'EOF'
runtime_effective_handles|runtime|validate-runtime-effective-route-bundle.sh|required
publication_receipts|runtime|validate-publication-freshness-gates.sh|required
authorized_effect_tokens|runtime|validate-material-side-effect-inventory.sh|optional
EOF
}

write_results() {
  local fixture_root="$1"
  local handle_depth="$2"
  cat >"$fixture_root/results.yml" <<EOF
---
schema_version: "octon-validator-result-v1"
validator_id: "validate-runtime-effective-route-bundle.sh"
dimension: "runtime_effective_handles"
claimed_depth: "runtime"
achieved_depth: "$handle_depth"
status: "pass"
---
schema_version: "octon-validator-result-v1"
validator_id: "validate-publication-freshness-gates.sh"
dimension: "publication_receipts"
claimed_depth: "runtime"
achieved_depth: "runtime"
status: "pass"
EOF
}

run_validator() {
  local fixture_root="$1"
  OCTON_ARCHITECTURE_HEALTH_MATRIX_FILE="$fixture_root/matrix.txt" \
  OCTON_ARCHITECTURE_HEALTH_RESULTS_FILE="$fixture_root/results.yml" \
    bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh" >/dev/null
}

case_meeting_required_depth_passes() {
  local fixture_root
  fixture_root="$(create_fixture)"
  write_matrix "$fixture_root"
  write_results "$fixture_root" "runtime"
  run_validator "$fixture_root"
}

case_shallow_emitted_depth_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  write_matrix "$fixture_root"
  write_results "$fixture_root" "schema"
  ! run_validator "$fixture_root"
}

main() {
  assert_success "architecture health passes when achieved depth meets requirements" case_meeting_required_depth_passes
  assert_success "architecture health fails when emitted depth is too shallow" case_shallow_emitted_depth_fails

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
