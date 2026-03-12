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

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_file_exists() {
  local path="$1"
  [[ -f "$path" ]]
}

assert_dir_exists() {
  local path="$1"
  [[ -d "$path" ]]
}

new_fixture_repo() {
  mkdir -p "$TMP_ROOT"
  local fixture_root
  fixture_root="$(mktemp -d "$TMP_ROOT/create-design-proposal.XXXXXX")"
  CLEANUP_PATHS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.harmony/scaffolding/runtime" \
    "$fixture_root/.harmony/assurance/runtime/_ops"

  cp -R "$REPO_ROOT/.harmony/scaffolding/runtime/templates" \
    "$fixture_root/.harmony/scaffolding/runtime/"
  cp -R "$REPO_ROOT/.harmony/assurance/runtime/_ops/scripts" \
    "$fixture_root/.harmony/assurance/runtime/_ops/"

  printf '%s\n' "$fixture_root"
}

run_create_workflow() {
  local fixture_root="$1"
  local proposal_id="$2"
  local proposal_title="$3"
  local proposal_class="$4"
  local promotion_targets="$5"
  (
    cd "$fixture_root"
    "$RUNNER" workflow run create-design-proposal \
      --set "proposal_id=$proposal_id" \
      --set "proposal_title=$proposal_title" \
      --set "proposal_class=$proposal_class" \
      --set "promotion_scope=harmony-internal" \
      --set "promotion_targets=$promotion_targets"
  )
}

latest_bundle_root() {
  local fixture_root="$1"
  find "$fixture_root/.harmony/output/reports/workflows" -maxdepth 1 -mindepth 1 -type d | sort | tail -n 1
}

case_domain_runtime_scaffold_passes() {
  local fixture_root output bundle_root package_root
  fixture_root="$(new_fixture_repo)"
  output="$(run_create_workflow "$fixture_root" runtime-package "Runtime Package" domain-runtime ".harmony/orchestration/runtime/example.md")"
  bundle_root="$(printf '%s\n' "$output" | sed -n 's/^bundle_root: //p' | tail -n 1)"
  package_root="$fixture_root/.proposals/design/runtime-package"

  [[ "$bundle_root" == *"/.harmony/output/reports/workflows/"* ]] || return 1
  assert_dir_exists "$package_root" || return 1
  assert_file_exists "$package_root/proposal.yml" || return 1
  assert_file_exists "$package_root/design-proposal.yml" || return 1
  assert_file_exists "$fixture_root/.proposals/registry.yml" || return 1
  assert_file_exists "$bundle_root/bundle.yml" || return 1
  assert_file_exists "$bundle_root/summary.md" || return 1
  assert_file_exists "$bundle_root/commands.md" || return 1
  assert_file_exists "$bundle_root/validation.md" || return 1
  assert_file_exists "$bundle_root/inventory.md" || return 1
  assert_file_exists "$bundle_root/standard-validator.log" || return 1
  assert_dir_exists "$bundle_root/reports" || return 1
  assert_dir_exists "$bundle_root/stage-inputs" || return 1
  assert_dir_exists "$bundle_root/stage-logs" || return 1
  grep -Fq 'runtime-package' "$fixture_root/.proposals/registry.yml" || return 1
}

case_experience_product_scaffold_passes() {
  local fixture_root output bundle_root package_root
  fixture_root="$(new_fixture_repo)"
  output="$(run_create_workflow "$fixture_root" experience-package "Experience Package" experience-product ".harmony/scaffolding/runtime/example.md")"
  bundle_root="$(printf '%s\n' "$output" | sed -n 's/^bundle_root: //p' | tail -n 1)"
  package_root="$fixture_root/.proposals/design/experience-package"

  assert_dir_exists "$package_root" || return 1
  assert_file_exists "$package_root/design-proposal.yml" || return 1
  assert_file_exists "$bundle_root/standard-validator.log" || return 1
  assert_file_exists "$bundle_root/bundle.yml" || return 1
  grep -Fq 'experience-package' "$fixture_root/.proposals/registry.yml" || return 1
}

case_duplicate_package_failure_writes_receipts() {
  local fixture_root first_output bundle_root output=""
  fixture_root="$(new_fixture_repo)"
  first_output="$(run_create_workflow "$fixture_root" duplicate-package "Duplicate Package" domain-runtime ".harmony/orchestration/runtime/example.md")"
  [[ -n "$first_output" ]] || return 1

  if output="$(run_create_workflow "$fixture_root" duplicate-package "Duplicate Package" domain-runtime ".harmony/orchestration/runtime/example.md" 2>&1)"; then
    return 1
  fi

  bundle_root="$(latest_bundle_root "$fixture_root")"
  assert_file_exists "$bundle_root/bundle.yml" || return 1
  assert_file_exists "$bundle_root/summary.md" || return 1
  assert_file_exists "$bundle_root/validation.md" || return 1
  assert_file_exists "$bundle_root/commands.md" || return 1
  grep -Fq 'failure_class: request-validation-failure' "$bundle_root/bundle.yml" || return 1
  grep -Fq 'failed_stage: validate-request' "$bundle_root/bundle.yml" || return 1
  grep -Fq 'request-validation-failure' "$bundle_root/summary.md" || return 1
  grep -Fq 'validate-request' "$bundle_root/validation.md" || return 1
}

main() {
  if case_domain_runtime_scaffold_passes; then
    pass "create-design-proposal scaffolds a domain-runtime proposal with workflow bundle receipts"
  else
    fail "create-design-proposal scaffolds a domain-runtime proposal with workflow bundle receipts"
  fi

  if case_experience_product_scaffold_passes; then
    pass "create-design-proposal scaffolds an experience-product proposal with workflow bundle receipts"
  else
    fail "create-design-proposal scaffolds an experience-product proposal with workflow bundle receipts"
  fi

  if case_duplicate_package_failure_writes_receipts; then
    pass "create-design-proposal duplicate proposal failure writes classified bundle receipts"
  else
    fail "create-design-proposal duplicate proposal failure writes classified bundle receipts"
  fi

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"

  if [[ "$fail_count" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
