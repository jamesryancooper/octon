#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-retired-terminology-guardrails.sh"

pass_count=0
fail_count=0

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

case_current_repo_passes() {
  if "$VALIDATOR" >/tmp/octon-retired-terminology-current.out 2>&1; then
    pass "current repo retired terminology guardrails pass"
  else
    cat /tmp/octon-retired-terminology-current.out >&2
    fail "current repo retired terminology guardrails pass"
  fi
}

case_disallowed_active_source_fails() {
  local root
  root="$(mktemp -d "${TMPDIR:-/tmp}/octon-retired-term.XXXXXX")"
  trap 'rm -rf "$root"' RETURN
  mkdir -p "$root/.octon/framework/product/features"
  printf '# Legacy Compatibility Note: Lifecycle Autopilot\n' >"$root/.octon/framework/product/features/lifecycle-autopilot.md"
  printf 'Lifecycle Autopilot should not be current feature text.\n' >"$root/.octon/framework/product/features/current.md"

  if "$VALIDATOR" --root "$root" >/tmp/octon-retired-terminology-negative.out 2>&1; then
    fail "disallowed active source retired term fails"
  else
    pass "disallowed active source retired term fails"
  fi
}

case_compatibility_context_passes() {
  local root
  root="$(mktemp -d "${TMPDIR:-/tmp}/octon-retired-term.XXXXXX")"
  trap 'rm -rf "$root"' RETURN
  mkdir -p "$root/.octon/framework/product/features"
  printf '# Legacy Compatibility Note: Lifecycle Autopilot\n' >"$root/.octon/framework/product/features/lifecycle-autopilot.md"

  if "$VALIDATOR" --root "$root" >/tmp/octon-retired-terminology-compat.out 2>&1; then
    pass "compatibility context retired term passes"
  else
    cat /tmp/octon-retired-terminology-compat.out >&2
    fail "compatibility context retired term passes"
  fi
}

case_current_repo_passes
case_disallowed_active_source_fails
case_compatibility_context_passes

printf 'Summary: %d passed, %d failed\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]
