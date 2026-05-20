#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-lifecycle"

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
    create-packet
    explain-packet
    review-packet
    revise-packet
    generate-packet-implementation-prompt
    run-packet-implementation
    generate-packet-verification-prompt
    generate-packet-correction-prompt
    run-packet-verification-and-correction-loop
    generate-packet-closeout-prompt
    closeout-packet
    create-program
    explain-program
    review-program
    revise-program
    generate-program-implementation-prompt
    generate-program-verification-prompt
    generate-program-correction-prompt
    run-program-verification-and-correction-loop
    generate-program-closeout-prompt
    closeout-program
  )
  local route manifest_count scenario_count

  assert_file "pack.yml"
  assert_file "README.md"
  assert_file "context/routing.contract.yml"
  assert_file "context/patterns.md"
  assert_file "context/patterns/proposal-program.md"
  assert_file "commands/manifest.fragment.yml"
  assert_file "commands/octon-proposal.md"
  assert_file "commands/octon-proposal-create-packet.md"
  assert_file "skills/manifest.fragment.yml"
  assert_file "skills/registry.fragment.yml"
  assert_file "validation/compatibility.yml"
  [[ -f "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh" ]] \
    && pass "program structure validator exists" \
    || fail "program structure validator is missing"

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
  [[ "$manifest_count" == "21" ]] && pass "21 prompt bundle manifests present" || fail "expected 21 prompt manifests, found $manifest_count"

  scenario_count="$(find "$PACK_ROOT/validation/scenarios" -name '*.md' -type f | wc -l | tr -d ' ')"
  [[ "$scenario_count" -ge 12 ]] && pass "manual and program scenario fixtures present" || fail "expected at least 12 scenarios, found $scenario_count"

  if find "$PACK_ROOT/commands" -maxdepth 1 -name 'octon-proposal-lifecycle*.md' -type f | rg . >/dev/null; then
    fail "legacy lifecycle-prefixed command files removed"
  else
    pass "legacy lifecycle-prefixed command files removed"
  fi

  if rg -n 'Invalid nested placement|nested child proposal packet directories|Reject nested' "$PACK_ROOT/context" "$PACK_ROOT/prompts" >/dev/null; then
    pass "program nesting rejection is documented"
  else
    fail "program nesting rejection is missing"
  fi

  if rg -n 'current-state-gap-map|file-change-map|rollback-plan|operator-disclosure|traceability map' "$PACK_ROOT/prompts/shared/lifecycle-artifact-contract.md" "$PACK_ROOT/prompts/create-packet" >/dev/null; then
    pass "creation artifact floor covers manual packet outputs"
  else
    fail "creation artifact floor is missing manual packet outputs"
  fi

  if rg -n 'two-consecutive-clean|two consecutive clean|two-consecutive-clean-pass' "$PACK_ROOT/prompts" "$PACK_ROOT/validation/scenarios" >/dev/null; then
    pass "closure certification pass depth is documented"
  else
    fail "closure certification pass depth is missing"
  fi

  if rg -n 'subagents|delegated implementation|disjoint write scopes|integration owner' "$PACK_ROOT/prompts/generate-packet-implementation-prompt" >/dev/null; then
    pass "implementation prompt delegation boundary is documented"
  else
    fail "implementation prompt delegation boundary is missing"
  fi

  if rg -n 'support/implementation-conformance-review\.md' "$PACK_ROOT/prompts/generate-packet-implementation-prompt" >/dev/null \
    && rg -n 'support/post-implementation-drift-churn-review\.md' "$PACK_ROOT/prompts/generate-packet-implementation-prompt" >/dev/null \
    && rg -n 'validate-proposal-implementation-conformance\.sh --package <proposal_path>' "$PACK_ROOT/prompts/generate-packet-implementation-prompt" >/dev/null \
    && rg -n 'validate-proposal-post-implementation-drift\.sh --package <proposal_path>' "$PACK_ROOT/prompts/generate-packet-implementation-prompt" >/dev/null \
    && rg -n 'refuse implemented, closeout, or archive-ready claims' "$PACK_ROOT/prompts/generate-packet-implementation-prompt" >/dev/null; then
    pass "implementation prompt bundle requires post-implementation gate receipts"
  else
    fail "implementation prompt bundle is missing post-implementation gate receipt requirements"
  fi

  if rg -n 'support/implementation-conformance-review\.md' "$PACK_ROOT/prompts/generate-packet-closeout-prompt" >/dev/null \
    && rg -n 'support/post-implementation-drift-churn-review\.md' "$PACK_ROOT/prompts/generate-packet-closeout-prompt" >/dev/null \
    && rg -n 'refuse implemented, closeout, or archive-ready claims' "$PACK_ROOT/prompts/generate-packet-closeout-prompt" >/dev/null; then
    pass "closeout prompt bundle requires post-implementation receipts"
  else
    fail "closeout prompt bundle is missing post-implementation receipt requirements"
  fi

  if rg -n 'route-required|selected implementation route uses a PR or branch lane' "$PACK_ROOT/prompts/generate-packet-closeout-prompt" "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/commands/octon-proposal-closeout-packet.md" >/dev/null \
    && ! rg -n 'final closeout is not complete until PR|the PR is unmerged' "$PACK_ROOT/prompts/generate-packet-closeout-prompt" "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/commands/octon-proposal-closeout-packet.md" >/dev/null; then
    pass "closeout wording keeps PR and branch gates route-conditional"
  else
    fail "closeout wording still makes PR or branch gates unconditional"
  fi

  if ! rg -n 'Fail-closed or pause states|blocked.*status|deferred.*status' "$PACK_ROOT/context" "$PACK_ROOT/prompts" >/dev/null; then
    pass "blocked and deferred are not modeled as proposal statuses"
  else
    fail "blocked or deferred wording still reads as proposal status"
  fi

  if rg -n 'support/program-creation\.md' "$PACK_ROOT/prompts/create-program" >/dev/null \
    && rg -n 'child_registry_digest' "$PACK_ROOT/prompts/create-program" >/dev/null \
    && rg -n 'child_authority_preserved' "$PACK_ROOT/prompts/create-program" >/dev/null; then
    pass "program creation prompt requires parent creation receipt"
  else
    fail "program creation prompt is missing parent creation receipt requirements"
  fi

  if rg -n 'support/program-implementation-conformance-review\.md' "$PACK_ROOT/prompts/generate-program-verification-prompt" "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" "$PACK_ROOT/prompts/generate-program-correction-prompt" >/dev/null \
    && rg -n 'support/program-post-implementation-drift-churn-review\.md' "$PACK_ROOT/prompts/generate-program-verification-prompt" "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" "$PACK_ROOT/prompts/generate-program-correction-prompt" >/dev/null \
    && rg -n 'child_receipt_summary_count' "$PACK_ROOT/prompts/generate-program-verification-prompt" "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" >/dev/null \
    && rg -n 'child_authority_preserved' "$PACK_ROOT/prompts/generate-program-verification-prompt" "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" >/dev/null; then
    pass "program verification prompts require aggregate receipts"
  else
    fail "program verification prompts are missing aggregate receipt requirements"
  fi

  if rg -n 'support/program-implementation-conformance-review\.md' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" >/dev/null \
    && rg -n 'support/program-post-implementation-drift-churn-review\.md' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" >/dev/null \
    && rg -n 'support/proposal-closeout\.md' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" >/dev/null \
    && rg -n 'archive_authorized' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" >/dev/null \
    && rg -n 'child_authority_preserved' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" >/dev/null; then
    pass "program closeout prompts require aggregate and closeout receipts"
  else
    fail "program closeout prompts are missing aggregate or closeout receipt requirements"
  fi

  assert_file "commands/octon-proposal-run-program-lifecycle.md"
  assert_file "skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md"
  if ! rg -n 'run-program-implementation' "$PACK_ROOT/context/routing.contract.yml" "$PACK_ROOT/commands" "$PACK_ROOT/skills" "$PACK_ROOT/prompts" >/dev/null; then
    pass "direct run-program-implementation surface is absent"
  else
    fail "direct run-program-implementation surface must not exist"
  fi

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
