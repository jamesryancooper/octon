#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARMONY_DIR/.." && pwd)"
RUNNER="$HARMONY_DIR/engine/runtime/run"
TMP_ROOT="$HARMONY_DIR/output/.tmp"

pass_count=0
fail_count=0
declare -a CLEANUP_PATHS=()

cleanup() {
  local path
  for path in "${CLEANUP_PATHS[@]}"; do
    [[ -e "$path" ]] && rm -r "$path"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }
assert_file_exists() { [[ -f "$1" ]]; }
assert_dir_exists() { [[ -d "$1" ]]; }

new_fixture_repo() {
  mkdir -p "$TMP_ROOT"
  local fixture_root
  fixture_root="$(mktemp -d "$TMP_ROOT/create-policy-proposal.XXXXXX")"
  CLEANUP_PATHS+=("$fixture_root")

  mkdir -p "$fixture_root/.harmony/scaffolding/runtime" "$fixture_root/.harmony/assurance/runtime/_ops"
  cp -R "$REPO_ROOT/.harmony/scaffolding/runtime/templates" "$fixture_root/.harmony/scaffolding/runtime/"
  cp -R "$REPO_ROOT/.harmony/assurance/runtime/_ops/scripts" "$fixture_root/.harmony/assurance/runtime/_ops/"
  printf '%s\n' "$fixture_root"
}

run_create_workflow() {
  local fixture_root="$1"
  local proposal_id="$2"
  local proposal_title="$3"
  local promotion_scope="$4"
  local promotion_targets="$5"
  (
    cd "$fixture_root"
    "$RUNNER" workflow run create-policy-proposal \
      --set "proposal_id=$proposal_id" \
      --set "proposal_title=$proposal_title" \
      --set "promotion_scope=$promotion_scope" \
      --set "promotion_targets=$promotion_targets"
  )
}

case_scaffold_passes() {
  local fixture_root output bundle_root proposal_root
  fixture_root="$(new_fixture_repo)"
  output="$(run_create_workflow "$fixture_root" runtime-package "Runtime Policy Proposal" harmony-internal ".harmony/orchestration/runtime/example.md")"
  bundle_root="$(printf '%s\n' "$output" | sed -n 's/^bundle_root: //p' | tail -n 1)"
  proposal_root="$fixture_root/.proposals/policy/runtime-package"

  [[ "$bundle_root" == *"/.harmony/output/reports/workflows/"* ]] || return 1
  assert_dir_exists "$proposal_root" || return 1
  assert_file_exists "$proposal_root/proposal.yml" || return 1
  assert_file_exists "$proposal_root/policy-proposal.yml" || return 1
  assert_file_exists "$fixture_root/.proposals/registry.yml" || return 1
  assert_file_exists "$bundle_root/bundle.yml" || return 1
  assert_file_exists "$bundle_root/summary.md" || return 1
  assert_file_exists "$bundle_root/commands.md" || return 1
  assert_file_exists "$bundle_root/validation.md" || return 1
  assert_file_exists "$bundle_root/inventory.md" || return 1
  assert_file_exists "$bundle_root/standard-validator.log" || return 1
  grep -Fq 'runtime-package' "$fixture_root/.proposals/registry.yml" || return 1
}

case_repo_local_scaffold_passes() {
  local fixture_root output proposal_root
  fixture_root="$(new_fixture_repo)"
  output="$(run_create_workflow "$fixture_root" repo-local-proposal "Repo Local Policy Proposal" repo-local "CHANGELOG.md")"
  proposal_root="$fixture_root/.proposals/policy/repo-local-proposal"

  assert_dir_exists "$proposal_root" || return 1
  assert_file_exists "$proposal_root/proposal.yml" || return 1
  assert_file_exists "$proposal_root/policy-proposal.yml" || return 1
  grep -Fq 'repo-local-proposal' "$fixture_root/.proposals/registry.yml" || return 1
}

case_duplicate_id_fails() {
  local fixture_root output
  fixture_root="$(new_fixture_repo)"
  output="$(run_create_workflow "$fixture_root" duplicate-proposal "Duplicate Proposal" harmony-internal ".harmony/orchestration/runtime/example.md")"
  [[ -n "$output" ]] || return 1
  if run_create_workflow "$fixture_root" duplicate-proposal "Duplicate Proposal" harmony-internal ".harmony/orchestration/runtime/example.md" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

main() {
  case_scaffold_passes && pass "create-policy-proposal scaffolds a policy proposal with workflow bundle receipts" || fail "create-policy-proposal scaffolds a policy proposal with workflow bundle receipts"
  case_repo_local_scaffold_passes && pass "create-policy-proposal scaffolds a repo-local proposal" || fail "create-policy-proposal scaffolds a repo-local proposal"
  case_duplicate_id_fails && pass "create-policy-proposal duplicate proposal failure writes receipts" || fail "create-policy-proposal duplicate proposal failure writes receipts"
  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
