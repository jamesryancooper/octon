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
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-exploratory-input-surfaces.sh" >/dev/null
}

case_valid_fixture_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  run_validator "$fixture_root"
}

case_rejects_retired_drafts_and_packages() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  mkdir -p "$fixture_root/.octon/inputs/exploratory/drafts"
  mkdir -p "$fixture_root/.octon/inputs/exploratory/packages"
  ! run_validator "$fixture_root"
}

case_plans_accept_allowed_names() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  printf '# Plan\n' >"$fixture_root/.octon/inputs/exploratory/plans/2026-05-20-demo-implementation-plan.md"
  printf '# Checklist\n' >"$fixture_root/.octon/inputs/exploratory/plans/2026-05-20-demo-checklist.md"
  printf '# Backlog\n' >"$fixture_root/.octon/inputs/exploratory/plans/2026-05-20-demo-backlog.md"
  printf '# Assessment\n' >"$fixture_root/.octon/inputs/exploratory/plans/2026-05-20-demo-assessment.md"
  run_validator "$fixture_root"
}

case_plans_reject_receipts() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  printf '# Receipt\n' >"$fixture_root/.octon/inputs/exploratory/plans/2026-05-20-demo-completion-receipt.md"
  ! run_validator "$fixture_root"
}

case_reports_require_manifest() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  mkdir -p "$fixture_root/.octon/inputs/exploratory/reports/missing-manifest"
  ! run_validator "$fixture_root"
}

case_reports_validate_manifest() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  mkdir -p "$fixture_root/.octon/inputs/exploratory/reports/demo-report"
  cat >"$fixture_root/.octon/inputs/exploratory/reports/demo-report/report.yml" <<'EOF'
schema_version: "octon-exploratory-report-v1"
report_id: "demo-report"
authority_mode: "non_authoritative"
EOF
  run_validator "$fixture_root"
}

case_syntheses_accept_only_synthesis_docs() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  printf '# Synthesis\n' >"$fixture_root/.octon/inputs/exploratory/syntheses/demo-synthesis.md"
  run_validator "$fixture_root"
}

case_syntheses_reject_generic_drafts() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  prepare_fixture "$fixture_root"
  printf '# Draft\n' >"$fixture_root/.octon/inputs/exploratory/syntheses/generic-draft.md"
  ! run_validator "$fixture_root"
}

main() {
  assert_success "exploratory input validator accepts valid fixture" case_valid_fixture_passes
  assert_success "exploratory input validator rejects retired drafts and packages" case_rejects_retired_drafts_and_packages
  assert_success "exploratory input validator accepts allowed plan names" case_plans_accept_allowed_names
  assert_success "exploratory input validator rejects receipt-like plans" case_plans_reject_receipts
  assert_success "exploratory input validator requires report manifest" case_reports_require_manifest
  assert_success "exploratory input validator accepts valid report manifest" case_reports_validate_manifest
  assert_success "exploratory input validator accepts synthesis docs" case_syntheses_accept_only_synthesis_docs
  assert_success "exploratory input validator rejects generic draft staging" case_syntheses_reject_generic_drafts

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
