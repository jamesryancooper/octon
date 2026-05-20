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
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-input-archive-retention.sh" >/dev/null
}

case_empty_archive_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  run_validator "$fixture_root"
}

case_archive_payload_without_receipt_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  mkdir -p "$fixture_root/.octon/inputs/additive/.archive/demo-intake"
  printf '# Demo\n' >"$fixture_root/.octon/inputs/additive/.archive/demo-intake/README.md"
  ! run_validator "$fixture_root"
}

case_archive_payload_with_receipt_passes() {
  local fixture_root receipt_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  mkdir -p "$fixture_root/.octon/inputs/additive/.archive/demo-intake"
  printf '# Demo\n' >"$fixture_root/.octon/inputs/additive/.archive/demo-intake/README.md"
  receipt_root="$fixture_root/.octon/state/evidence/validation/inputs/archive-retention"
  mkdir -p "$receipt_root"
  cat >"$receipt_root/demo-intake.yml" <<'EOF'
schema_version: "octon-input-archive-retention-v1"
archive_id: "demo-intake"
authority_mode: "non_authoritative"
retention_justification: "Safe review fixture retained for validator coverage."
EOF
  run_validator "$fixture_root"
}

main() {
  assert_success "archive retention validator accepts empty additive archive" case_empty_archive_passes
  assert_success "archive retention validator rejects payload without receipt" case_archive_payload_without_receipt_fails
  assert_success "archive retention validator accepts payload with receipt" case_archive_payload_with_receipt_passes

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
