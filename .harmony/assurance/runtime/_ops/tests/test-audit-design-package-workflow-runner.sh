#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd "$HARMONY_DIR/.." && pwd)"
RUNNER="$HARMONY_DIR/engine/runtime/run"
TMP_ROOT="$HARMONY_DIR/output/.tmp"

pass_count=0
fail_count=0

declare -a CLEANUP_PATHS=()

cleanup() {
  local path
  for path in "${CLEANUP_PATHS[@]}"; do
    [[ -e "$path" ]] && rm -rf "$path"
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

parse_output_value() {
  local key="$1"
  local output="$2"
  printf '%s\n' "$output" | sed -n "s/^${key}: //p" | tail -n 1
}

assert_file_exists() {
  local path="$1"
  [[ -f "$path" ]]
}

assert_dir_exists() {
  local path="$1"
  [[ -d "$path" ]]
}

new_fixture_package() {
  mkdir -p "$TMP_ROOT"
  local fixture_dir
  fixture_dir="$(mktemp -d "$TMP_ROOT/design-package-runner.XXXXXX")"
  CLEANUP_PATHS+=("$fixture_dir")

  cat >"$fixture_dir/README.md" <<'EOF'
# Fixture Design Package

This is a minimal fixture package for design-package workflow runner tests.
EOF

  cat >"$fixture_dir/domain-model.md" <<'EOF'
# Domain Model

- entity: fixture
EOF

  printf '%s\n' "$fixture_dir"
}

run_runner() {
  local package_rel="$1"
  local mode="$2"
  local executor="$3"
  local slug="$4"
  shift 4
  "$RUNNER" workflow run audit-design-package \
    --set "package_path=$package_rel" \
    --set "mode=$mode" \
    --executor "$executor" \
    --output-slug "$slug" \
    "$@"
}

assert_bundle_contract() {
  local bundle_root="$1"
  assert_dir_exists "$bundle_root" || return 1
  assert_file_exists "$bundle_root/summary.md" || return 1
  assert_file_exists "$bundle_root/commands.md" || return 1
  assert_file_exists "$bundle_root/inventory.md" || return 1
  assert_file_exists "$bundle_root/validation.md" || return 1
  assert_file_exists "$bundle_root/package-delta.md" || return 1
  assert_file_exists "$bundle_root/bundle.yml" || return 1
  assert_dir_exists "$bundle_root/stage-inputs" || return 1
  assert_dir_exists "$bundle_root/stage-logs" || return 1
}

case_short_mock_runner_passes() {
  local fixture_dir fixture_rel output bundle_root summary_report final_verdict
  fixture_dir="$(new_fixture_package)"
  fixture_rel="${fixture_dir#$ROOT_DIR/}"
  output="$(run_runner "$fixture_rel" short mock design-package-runner-short)"

  bundle_root="$(parse_output_value "bundle_root" "$output")"
  summary_report="$(parse_output_value "summary_report" "$output")"
  final_verdict="$(parse_output_value "final_verdict" "$output")"

  CLEANUP_PATHS+=("$bundle_root" "$summary_report")

  [[ "$final_verdict" == "mock-executed" ]] || return 1
  [[ "$bundle_root" == *"/.harmony/output/reports/workflows/"* ]] || return 1
  [[ "$bundle_root" != *"/.harmony/output/reports/audits/"* ]] || return 1
  assert_file_exists "$summary_report" || return 1
  assert_bundle_contract "$bundle_root" || return 1
  assert_file_exists "$bundle_root/reports/01-design-package-audit.md" || return 1
  assert_file_exists "$bundle_root/reports/02-design-package-remediation.md" || return 1
  assert_file_exists "$bundle_root/reports/06-implementation-simulation.md" || return 1
  assert_file_exists "$bundle_root/reports/07-specification-closure.md" || return 1
  assert_file_exists "$bundle_root/reports/08-minimal-implementation-architecture-blueprint.md" || return 1
  assert_file_exists "$bundle_root/reports/09-first-implementation-plan.md" || return 1
  grep -Fq "synthetic-remediation.md" "$bundle_root/package-delta.md" || return 1
  grep -Fq "CHANGE MANIFEST" "$bundle_root/reports/02-design-package-remediation.md" || return 1
  grep -Fq "stage 02 | executor=mock" "$bundle_root/commands.md" || return 1
  assert_file_exists "$bundle_root/stage-inputs/02-02-design-package-remediation.prompt.md" || return 1
  assert_file_exists "$bundle_root/stage-logs/02-02-design-package-remediation.log" || return 1
  assert_file_exists "$fixture_dir/.harmony-mock-runner/synthetic-remediation.md" || return 1
}

case_rigorous_mock_runner_passes() {
  local fixture_dir fixture_rel output bundle_root summary_report final_verdict
  fixture_dir="$(new_fixture_package)"
  fixture_rel="${fixture_dir#$ROOT_DIR/}"
  output="$(run_runner "$fixture_rel" rigorous mock design-package-runner-rigorous)"

  bundle_root="$(parse_output_value "bundle_root" "$output")"
  summary_report="$(parse_output_value "summary_report" "$output")"
  final_verdict="$(parse_output_value "final_verdict" "$output")"

  CLEANUP_PATHS+=("$bundle_root" "$summary_report")

  [[ "$final_verdict" == "mock-executed" ]] || return 1
  [[ "$bundle_root" == *"/.harmony/output/reports/workflows/"* ]] || return 1
  assert_file_exists "$summary_report" || return 1
  assert_bundle_contract "$bundle_root" || return 1
  assert_file_exists "$bundle_root/reports/01-design-package-audit.md" || return 1
  assert_file_exists "$bundle_root/reports/03-design-red-team.md" || return 1
  assert_file_exists "$bundle_root/reports/04-design-hardening.md" || return 1
  assert_file_exists "$bundle_root/reports/05-design-integration.md" || return 1
  assert_file_exists "$bundle_root/reports/06-implementation-simulation.md" || return 1
  assert_file_exists "$bundle_root/reports/07-specification-closure.md" || return 1
  assert_file_exists "$bundle_root/reports/08-minimal-implementation-architecture-blueprint.md" || return 1
  assert_file_exists "$bundle_root/reports/09-first-implementation-plan.md" || return 1
  grep -Fq "stage 05 | executor=mock" "$bundle_root/commands.md" || return 1
  assert_file_exists "$bundle_root/stage-inputs/05-05-design-integration.prompt.md" || return 1
  assert_file_exists "$bundle_root/stage-logs/05-05-design-integration.log" || return 1
  grep -Fq "synthetic-hardening.md" "$bundle_root/package-delta.md" || return 1
}

case_live_runner_optional() {
  if [[ "${HARMONY_RUN_LIVE_EXECUTOR_SMOKE:-0}" != "1" ]]; then
    pass "live executor smoke skipped"
    return 0
  fi

  local fixture_dir fixture_rel executor output bundle_root summary_report final_verdict
  fixture_dir="$(new_fixture_package)"
  fixture_rel="${fixture_dir#$ROOT_DIR/}"
  executor="${HARMONY_LIVE_EXECUTOR:-codex}"
  output="$(run_runner "$fixture_rel" rigorous "$executor" design-package-runner-live)"

  bundle_root="$(parse_output_value "bundle_root" "$output")"
  summary_report="$(parse_output_value "summary_report" "$output")"
  final_verdict="$(parse_output_value "final_verdict" "$output")"

  CLEANUP_PATHS+=("$bundle_root" "$summary_report")

  [[ -n "$final_verdict" ]] || return 1
  [[ "$bundle_root" == *"/.harmony/output/reports/workflows/"* ]] || return 1
  assert_dir_exists "$bundle_root" || return 1
  assert_file_exists "$summary_report" || return 1

  pass "live executor smoke (${executor})"
}

main() {
  if case_short_mock_runner_passes; then
    pass "audit-design-package workflow runner short-mode mock execution"
  else
    fail "audit-design-package workflow runner short-mode mock execution"
  fi

  if case_rigorous_mock_runner_passes; then
    pass "audit-design-package workflow runner rigorous-mode mock execution"
  else
    fail "audit-design-package workflow runner rigorous-mode mock execution"
  fi

  case_live_runner_optional || fail "live executor smoke"

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"

  if [[ "$fail_count" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
