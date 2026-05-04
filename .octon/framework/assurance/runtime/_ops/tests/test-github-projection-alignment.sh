#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-github-projection-alignment.sh"

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
  local label="$1"
  shift
  if "$@"; then pass "$label"; else fail "$label"; fi
}

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d)"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.github" \
    "$fixture_root/.octon/framework/execution-roles/practices" \
    "$fixture_root/.octon/framework/execution-roles/practices/standards" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts"

  cp -R "$REPO_ROOT/.github/workflows" "$fixture_root/.github/workflows"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/change-lifecycle-routing-quickstart.md" \
    "$fixture_root/.octon/framework/execution-roles/practices/change-lifecycle-routing-quickstart.md"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md" \
    "$fixture_root/.octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/github-autonomy-runbook.md" \
    "$fixture_root/.octon/framework/execution-roles/practices/github-autonomy-runbook.md"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json" \
    "$fixture_root/.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/standards/ai-gate-policy.json" \
    "$fixture_root/.octon/framework/execution-roles/practices/standards/ai-gate-policy.json"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh"
  cp "$VALIDATOR" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-github-projection-alignment.sh"

  printf '%s\n' "$fixture_root"
}

run_validator() {
  local fixture_root="$1"
  bash "$VALIDATOR" --root "$fixture_root" >/dev/null
}

case_live_repo_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_old_main_guard_file_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  cp "$fixture_root/.github/workflows/main-change-route-guard.yml" \
    "$fixture_root/.github/workflows/main-pr-first-guard.yml"
  ! run_validator "$fixture_root"
}

case_stale_pr_first_language_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  printf '\n# PR-first main updates\n' >>"$fixture_root/.github/workflows/main-change-route-guard.yml"
  ! run_validator "$fixture_root"
}

case_universal_ai_gate_target_fails() {
  local fixture_root tmp
  fixture_root="$(create_fixture)"
  tmp="$(mktemp)"
  jq '.rulesets.target_route_neutral_main.universal_required_checks += ["AI Review Gate / decision"]' \
    "$fixture_root/.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json" >"$tmp"
  mv "$tmp" "$fixture_root/.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json"
  ! run_validator "$fixture_root"
}

case_pr_autonomy_main_push_scope_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/\n    branches-ignore:\n      - main//' \
    "$fixture_root/.github/workflows/pr-autonomy-policy.yml"
  ! run_validator "$fixture_root"
}

case_exact_source_sha_projection_missing_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/exact_source_sha_validation/exact-source-sha-validation/g' \
    "$fixture_root/.github/workflows/change-route-projection.yml"
  ! run_validator "$fixture_root"
}

main() {
  assert_success "GitHub projection validator passes on live repo" case_live_repo_passes
  assert_success "GitHub projection validator fails when old main guard file returns" case_old_main_guard_file_fails
  assert_success "GitHub projection validator fails on stale PR-first language" case_stale_pr_first_language_fails
  assert_success "GitHub projection validator fails when AI gate becomes universal target check" case_universal_ai_gate_target_fails
  assert_success "GitHub projection validator fails when PR autonomy includes main push scope" case_pr_autonomy_main_push_scope_fails
  assert_success "GitHub projection validator fails when exact source SHA projection is missing" case_exact_source_sha_projection_missing_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
