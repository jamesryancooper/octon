#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-authoritative-doc-triggers.sh"

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

case_live_repo_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_blanket_markdown_ignore_fails() {
  local fixture_root workflow_file
  fixture_root="$(mktemp -d)"
  CLEANUP_DIRS+=("$fixture_root")
  workflow_file="$fixture_root/main-push-safety.yml"
  cat >"$workflow_file" <<'EOF'
name: Main Push Safety
on:
  push:
    branches:
      - main
    paths-ignore:
      - "**/*.md"
      - ".octon/generated/**"
jobs:
  classify:
    runs-on: ubuntu-latest
    steps:
      - run: .octon/framework/assurance/runtime/_ops/scripts/classify-authoritative-doc-change.sh
  harness-checks:
    if: needs.classify.outputs.should_run == 'true'
    runs-on: ubuntu-latest
EOF

  MAIN_PUSH_SAFETY_WORKFLOW_FILE="$workflow_file" bash "$VALIDATOR" >/dev/null 2>&1 && return 1 || return 0
}

case_wrong_trigger_class_fails() {
  local fixture_root registry_file
  fixture_root="$(mktemp -d)"
  CLEANUP_DIRS+=("$fixture_root")
  registry_file="$fixture_root/contract-registry.yml"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/contract-registry.yml" "$registry_file"
  perl -0pi -e 's/safety_trigger_classes:\n    - "authoritative-doc"/safety_trigger_classes:\n    - "operational-guide"/' "$registry_file"

  DOC_CLASSIFICATION_REGISTRY_FILE="$registry_file" bash "$VALIDATOR" >/dev/null 2>&1 && return 1 || return 0
}

case_diff_swallow_fails() {
  local fixture_root workflow_file
  fixture_root="$(mktemp -d)"
  CLEANUP_DIRS+=("$fixture_root")
  workflow_file="$fixture_root/main-push-safety.yml"
  cat >"$workflow_file" <<'EOF'
name: Main Push Safety
jobs:
  classify:
    runs-on: ubuntu-latest
    steps:
      - run: |
          before="${{ github.event.before }}"
          git fetch --no-tags --depth=1 origin "${before}"
          git cat-file -e "${before}^{commit}" >/dev/null 2>&1
          mapfile -t changed_files < <(git diff --name-only "$before" "${{ github.sha }}" || true)
          .octon/framework/assurance/runtime/_ops/scripts/classify-authoritative-doc-change.sh
  harness-checks:
    if: needs.classify.outputs.should_run == 'true'
    runs-on: ubuntu-latest
EOF

  MAIN_PUSH_SAFETY_WORKFLOW_FILE="$workflow_file" bash "$VALIDATOR" >/dev/null 2>&1 && return 1 || return 0
}

main() {
  assert_success "authoritative-doc trigger validator passes on live repo" case_live_repo_passes
  assert_success "authoritative-doc trigger validator fails on blanket Markdown ignore" case_blanket_markdown_ignore_fails
  assert_success "authoritative-doc trigger validator fails on wrong safety trigger class" case_wrong_trigger_class_fails
  assert_success "authoritative-doc trigger validator fails when diff failures are swallowed" case_diff_swallow_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
