#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh"

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
  fixture_root="$(mktemp -d)"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/framework/execution-roles/practices/standards" \
    "$fixture_root/.octon/framework/execution-roles/practices" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/references" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/instance/ingress" \
    "$fixture_root/.github/workflows"

  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml" \
    "$fixture_root/.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml"
  cp "$REPO_ROOT/.octon/instance/ingress/manifest.yml" \
    "$fixture_root/.octon/instance/ingress/manifest.yml"
  cp "$REPO_ROOT/.octon/instance/ingress/AGENTS.md" \
    "$fixture_root/.octon/instance/ingress/AGENTS.md"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/git-autonomy-playbook.md" \
    "$fixture_root/.octon/framework/execution-roles/practices/git-autonomy-playbook.md"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md" \
    "$fixture_root/.octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/pull-request-standards.md" \
    "$fixture_root/.octon/framework/execution-roles/practices/pull-request-standards.md"
  cp "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh"
  cp "$REPO_ROOT/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md"
  cp "$REPO_ROOT/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/references/safety.md" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/references/safety.md"
  cp "$REPO_ROOT/.github/PULL_REQUEST_TEMPLATE.md" \
    "$fixture_root/.github/PULL_REQUEST_TEMPLATE.md"
  cp "$REPO_ROOT/.github/workflows/pr-quality.yml" \
    "$fixture_root/.github/workflows/pr-quality.yml"
  cp "$REPO_ROOT/.github/workflows/pr-autonomy-policy.yml" \
    "$fixture_root/.github/workflows/pr-autonomy-policy.yml"
  cp "$REPO_ROOT/.github/workflows/pr-auto-merge.yml" \
    "$fixture_root/.github/workflows/pr-auto-merge.yml"
  cp "$VALIDATOR" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh"

  printf '%s\n' "$fixture_root"
}

run_validator() {
  local fixture_root="$1"
  (
    cd "$fixture_root"
    bash ".octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh" >/dev/null
  )
}

case_live_repo_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_manifest_missing_ready_status_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/branch_worktree_ready_pr_waiting_on_required_checks_or_auto_merge:/missing_ready_context:/g' \
    "$fixture_root/.octon/instance/ingress/manifest.yml"
  ! run_validator "$fixture_root"
}

case_stale_remediation_wording_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/Do not amend, rebase, or force-push during ordinary review remediation\./Rebase and force-push cleanup./' \
    "$fixture_root/.octon/framework/execution-roles/practices/pull-request-standards.md"
  ! run_validator "$fixture_root"
}

case_helper_missing_explicit_flags_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/--request-ready/--deprecated-ready/g; s/--request-automerge/--deprecated-automerge/g' \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh"
  ! run_validator "$fixture_root"
}

main() {
  assert_success "workflow alignment validator passes on live repo" case_live_repo_passes
  assert_success "workflow alignment validator fails when manifest loses ready-pr status handling" case_manifest_missing_ready_status_fails
  assert_success "workflow alignment validator fails on stale remediation wording" case_stale_remediation_wording_fails
  assert_success "workflow alignment validator fails when helper loses explicit request flags" case_helper_missing_explicit_flags_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
