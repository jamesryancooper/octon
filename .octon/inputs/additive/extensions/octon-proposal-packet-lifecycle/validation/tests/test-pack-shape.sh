#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle"

pass_count=0
fail_count=0

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

assert_file() {
  local rel="$1"
  [[ -f "$PACK_ROOT/$rel" ]] && pass "file exists: $rel" || fail "missing file: $rel"
}

assert_dir() {
  local rel="$1"
  [[ -d "$PACK_ROOT/$rel" ]] && pass "directory exists: $rel" || fail "missing directory: $rel"
}

assert_yq() {
  local rel="$1" query="$2" label="$3"
  yq -e "$query" "$PACK_ROOT/$rel" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

main() {
  local routes=(
    create-proposal-packet
    explain-proposal-packet
    generate-implementation-prompt
    generate-verification-prompt
    generate-correction-prompt
    run-verification-and-correction-loop
    generate-closeout-prompt
    closeout-proposal-packet
    create-proposal-program
    generate-program-implementation-prompt
    generate-program-verification-prompt
    generate-program-correction-prompt
    run-program-verification-and-correction-loop
    generate-program-closeout-prompt
    closeout-proposal-program
  )
  local route manifest_count scenario_count

  assert_file "pack.yml"
  assert_file "README.md"
  assert_file "context/routing.contract.yml"
  assert_file "context/patterns.md"
  assert_file "context/patterns/proposal-program.md"
  assert_file "commands/manifest.fragment.yml"
  assert_file "commands/octon-proposal-packet.md"
  assert_file "commands/octon-proposal-packet-create.md"
  assert_file "skills/manifest.fragment.yml"
  assert_file "skills/registry.fragment.yml"
  assert_file "validation/compatibility.yml"

  for route in "${routes[@]}"; do
    assert_file "prompts/$route/manifest.yml"
    assert_file "prompts/$route/README.md"
    assert_dir "prompts/$route/stages"
    assert_dir "prompts/$route/companions"
    assert_file "prompts/$route/references/bundle-contract.md"
    assert_yq "prompts/$route/manifest.yml" '.stages | length > 0' "stage declared for $route"
    assert_yq "prompts/$route/manifest.yml" '.companions | length > 0' "companion declared for $route"
    assert_yq "prompts/$route/manifest.yml" '.shared_references[]? | select(.ref_id == "proposal-authority-boundaries")' "authority shared ref declared for $route"
  done

  manifest_count="$(find "$PACK_ROOT/prompts" -mindepth 2 -maxdepth 2 -name manifest.yml -type f | wc -l | tr -d ' ')"
  [[ "$manifest_count" == "15" ]] && pass "15 prompt bundle manifests present" || fail "expected 15 prompt manifests, found $manifest_count"

  scenario_count="$(find "$PACK_ROOT/validation/scenarios" -name '*.md' -type f | wc -l | tr -d ' ')"
  [[ "$scenario_count" -ge 12 ]] && pass "manual and program scenario fixtures present" || fail "expected at least 12 scenarios, found $scenario_count"

  if find "$PACK_ROOT/commands" -maxdepth 1 -name 'octon-proposal-packet-lifecycle*.md' -type f | rg . >/dev/null; then
    fail "legacy lifecycle-prefixed command files removed"
  else
    pass "legacy lifecycle-prefixed command files removed"
  fi

  if rg -n 'Invalid nested placement|nested child proposal package directories|Reject nested' "$PACK_ROOT/context" "$PACK_ROOT/prompts" >/dev/null; then
    pass "program nesting rejection is documented"
  else
    fail "program nesting rejection is missing"
  fi

  if rg -n 'current-state-gap-map|file-change-map|rollback-plan|operator-disclosure|traceability map' "$PACK_ROOT/prompts/shared/lifecycle-artifact-contract.md" "$PACK_ROOT/prompts/create-proposal-packet" >/dev/null; then
    pass "creation artifact floor covers manual packet outputs"
  else
    fail "creation artifact floor is missing manual packet outputs"
  fi

  if rg -n 'two-consecutive-clean|two consecutive clean|two-consecutive-clean-pass' "$PACK_ROOT/prompts" "$PACK_ROOT/validation/scenarios" >/dev/null; then
    pass "closure certification pass depth is documented"
  else
    fail "closure certification pass depth is missing"
  fi

  if rg -n 'subagents|delegated implementation|disjoint write scopes|integration owner' "$PACK_ROOT/prompts/generate-implementation-prompt" >/dev/null; then
    pass "implementation prompt delegation boundary is documented"
  else
    fail "implementation prompt delegation boundary is missing"
  fi

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
