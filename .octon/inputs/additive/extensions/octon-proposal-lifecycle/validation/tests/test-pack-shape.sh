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
    generate-program-implementation-orchestration-prompt
    generate-program-verification-prompt
    generate-program-correction-prompt
    run-program-verification-and-correction-loop
    generate-program-closeout-prompt
    closeout-program
  )
  local route manifest_count scenario_count program_command_id program_skill_id

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
  [[ "$manifest_count" == "22" ]] && pass "22 prompt bundle manifests present" || fail "expected 22 prompt manifests, found $manifest_count"

  scenario_count="$(find "$PACK_ROOT/validation/scenarios" -name '*.md' -type f | wc -l | tr -d ' ')"
  [[ "$scenario_count" -ge 12 ]] && pass "manual and program scenario fixtures present" || fail "expected at least 12 scenarios, found $scenario_count"

  if find "$PACK_ROOT/commands" -maxdepth 1 -name 'octon-proposal-lifecycle*.md' -type f | rg . >/dev/null; then
    fail "legacy lifecycle-prefixed command files removed"
  else
    pass "legacy lifecycle-prefixed command files removed"
  fi

  program_command_id="$(yq -r '.routes[]? | select(.route_id == "generate-program-implementation-orchestration-prompt") | .command_id' "$PACK_ROOT/context/lifecycles/proposal-program.contract.yml")"
  program_skill_id="$(yq -r '.routes[]? | select(.route_id == "generate-program-implementation-orchestration-prompt") | .skill_id' "$PACK_ROOT/context/lifecycles/proposal-program.contract.yml")"
  if [[ "$program_command_id" == "octon-proposal-generate-program-orchestration-prompt" ]] \
    && [[ ${#program_command_id} -le 64 ]] \
    && [[ "$program_skill_id" == "octon-proposal-lifecycle-generate-program-orchestration-prompt" ]] \
    && [[ ${#program_skill_id} -le 64 ]] \
    && [[ -f "$PACK_ROOT/commands/$program_command_id.md" ]] \
    && [[ -f "$PACK_ROOT/skills/$program_skill_id/SKILL.md" ]]; then
    pass "program implementation orchestration host binding is host-visible"
  else
    fail "program implementation orchestration host binding is not host-visible"
  fi
  if ! yq -e '.commands[]? | select(.display_name | test("^Octon Proposal Lifecycle:?"))' "$PACK_ROOT/commands/manifest.fragment.yml" >/dev/null 2>&1 \
    && ! rg -n '^# Octon Proposal Lifecycle:?' "$PACK_ROOT/commands" >/dev/null; then
    pass "proposal lifecycle command labels omit redundant namespace"
  else
    fail "proposal lifecycle command labels still repeat redundant namespace"
  fi
  if ! rg -n 'octon-proposal-generate-program-implementation-orchestration-prompt|octon-proposal-lifecycle-generate-program-implementation-orchestration-prompt' \
    "$PACK_ROOT/commands" "$PACK_ROOT/skills" "$PACK_ROOT/commands/manifest.fragment.yml" "$PACK_ROOT/skills/manifest.fragment.yml" "$PACK_ROOT/skills/registry.fragment.yml" >/dev/null \
    && ! yq -e '.routes[]? | select(.route_id == "generate-program-implementation-orchestration-prompt") | select(.command_id == "octon-proposal-generate-program-implementation-orchestration-prompt" or .skill_id == "octon-proposal-lifecycle-generate-program-implementation-orchestration-prompt")' "$PACK_ROOT/context/lifecycles/proposal-program.contract.yml" >/dev/null 2>&1 \
    && ! yq -e '.dispatchers[]?.execution_bindings[]? | select(.route_id == "generate-program-implementation-orchestration-prompt") | select(.command_capability_id == "octon-proposal-generate-program-implementation-orchestration-prompt" or .skill_capability_id == "octon-proposal-lifecycle-generate-program-implementation-orchestration-prompt")' "$PACK_ROOT/context/routing.contract.yml" >/dev/null 2>&1; then
    pass "oversized program implementation orchestration host names are absent"
  else
    fail "oversized program implementation orchestration host names remain active"
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

  if rg -n 'stale or blocked terminal closeout evidence as an open review' "$PACK_ROOT/prompts/review-packet" >/dev/null \
    && rg -n 'support/proposal-terminal-closeout\.yml' "$PACK_ROOT/prompts/review-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-review-packet/SKILL.md" >/dev/null \
    && rg -n 'child-owned historical evidence|child-owned historical route' "$PACK_ROOT/prompts/review-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-review-packet/SKILL.md" >/dev/null \
    && rg -n 'Do not require terminal freshness validation for an `in-review` review verdict' "$PACK_ROOT/prompts/review-packet" >/dev/null; then
    pass "review packet excludes stale terminal closeout from in-review blockers"
  else
    fail "review packet can still reuse stale terminal closeout as an in-review blocker"
  fi

  if rg -n 'Accepted review completion is atomic at route level|Accepted review completion is receipt-atomic' "$PACK_ROOT/prompts/review-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-review-packet/SKILL.md" >/dev/null \
    && rg -n 'accepted-state packet digest' "$PACK_ROOT/prompts/review-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-review-packet/SKILL.md" >/dev/null \
    && rg -n 'status-only accepted mutation' "$PACK_ROOT/prompts/review-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-review-packet/SKILL.md" >/dev/null \
    && rg -n 'incomplete route (work|result)' "$PACK_ROOT/prompts/review-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-review-packet/SKILL.md" >/dev/null \
    && rg -n 'strict pre-integration architecture receipt' "$PACK_ROOT/prompts/review-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-review-packet/SKILL.md" >/dev/null; then
    pass "review packet requires accepted-state receipt-atomic completion"
  else
    fail "review packet can complete accepted status without fresh receipts"
  fi

  if rg -n 'Do not attempt to repair stale or blocked terminal closeout evidence' "$PACK_ROOT/prompts/revise-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-revise-packet/SKILL.md" >/dev/null \
    && rg -n 'nonblocking route context' "$PACK_ROOT/prompts/revise-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-revise-packet/SKILL.md" >/dev/null \
    && rg -n 'remaining review' "$PACK_ROOT/prompts/revise-packet" >/dev/null \
    && rg -n 'Use the exact field name `post_revision_digest`' "$PACK_ROOT/prompts/revise-packet" >/dev/null \
    && rg -n 'Do not emit `post_revision_packet_digest`, `pending`' "$PACK_ROOT/prompts/revise-packet" >/dev/null; then
    pass "revise packet excludes stale terminal closeout and requires fresh revision digest"
  else
    fail "revise packet can still reuse stale terminal closeout or pending revision digest"
  fi

  if rg -n 'route-required|selected implementation route uses a PR or branch lane' "$PACK_ROOT/prompts/generate-packet-closeout-prompt" "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/commands/octon-proposal-closeout-packet.md" >/dev/null \
    && ! rg -n 'final closeout is not complete until PR|the PR is unmerged' "$PACK_ROOT/prompts/generate-packet-closeout-prompt" "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/commands/octon-proposal-closeout-packet.md" >/dev/null; then
    pass "closeout wording keeps PR and branch gates route-conditional"
  else
    fail "closeout wording still makes PR or branch gates unconditional"
  fi

  if rg -n 'classifier snapshot ref churn|stable bound fingerprint|path-only classifier snapshot churn' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n 'program_child_worktree_hygiene_foreign_fingerprint' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n 'If no validated program-child closeout-worktree report has been accepted' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null; then
    pass "program-child closeout accepts validated classifier snapshot churn by stable fingerprint"
  else
    fail "program-child closeout still requires exact classifier snapshot refs"
  fi
  if rg -n 'closeout/archive-readiness' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n 'closeout receipt may record `verdict: pass`' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n '`archive_authorized: yes`' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n '`lifecycle_outcome: archive-ready`' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null; then
    pass "accepted program-child closeout-worktree report can clear archive-readiness hygiene blocker"
  else
    fail "accepted program-child closeout-worktree report still reads as archive-blocking"
  fi

  if rg -n 'after writing|after the route writes' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n 'generate-proposal-artifact-index\.sh --proposal <proposal_path> --write' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n 'targeted dependency proposal|parent program' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n 'validate-proposal-lifecycle-terminal-freshness\.sh --proposal <proposal_path> --targeted' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n 'post-write targeted freshness validation passes' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n 'reuse' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n 'blocked disposition' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null \
    && rg -n 'fresh child-owned closeout evidence and post-write freshness' "$PACK_ROOT/prompts/closeout-packet" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" >/dev/null; then
    pass "closeout packet refreshes generated artifacts after closeout receipt writes before archive-ready"
  else
    fail "closeout packet can self-stale terminal freshness after closeout receipt writes"
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

  if rg -n 'support/program-implementation-orchestration-conformance-review\.md' "$PACK_ROOT/prompts/generate-program-verification-prompt" "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" "$PACK_ROOT/prompts/generate-program-correction-prompt" >/dev/null \
    && rg -n 'support/program-post-implementation-orchestration-drift-churn-review\.md' "$PACK_ROOT/prompts/generate-program-verification-prompt" "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" "$PACK_ROOT/prompts/generate-program-correction-prompt" >/dev/null \
    && rg -n 'child_receipt_summary_count' "$PACK_ROOT/prompts/generate-program-verification-prompt" "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" >/dev/null \
    && rg -n 'child_authority_preserved' "$PACK_ROOT/prompts/generate-program-verification-prompt" "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" >/dev/null; then
    pass "program verification prompts require aggregate receipts"
  else
    fail "program verification prompts are missing aggregate receipt requirements"
  fi
  if rg -n 'resolved-by-validated-parent-closeout-worktree-return' "$PACK_ROOT/prompts/generate-program-verification-prompt" "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" "$PACK_ROOT/skills/octon-proposal-lifecycle-run-program-verification-and-correction-loop/SKILL.md" >/dev/null \
    && rg -n 'parent-closeout-worktree-return\.json' "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" "$PACK_ROOT/skills/octon-proposal-lifecycle-run-program-verification-and-correction-loop/SKILL.md" >/dev/null \
    && rg -n 'preserve-and-exclude-from-lifecycle-closeout-blocking' "$PACK_ROOT/prompts/generate-program-verification-prompt" "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" "$PACK_ROOT/skills/octon-proposal-lifecycle-run-program-verification-and-correction-loop/SKILL.md" >/dev/null; then
    pass "program verification accepts validated parent closeout-worktree handoff"
  else
    fail "program verification still loops on validated parent closeout-worktree handoff"
  fi

  if rg -n 'support/program-implementation-orchestration-conformance-review\.md' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" >/dev/null \
    && rg -n 'support/program-post-implementation-orchestration-drift-churn-review\.md' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" >/dev/null \
    && rg -n 'support/proposal-closeout\.md' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" >/dev/null \
    && rg -n 'archive_authorized' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" >/dev/null \
    && rg -n 'child_authority_preserved' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" >/dev/null; then
    pass "program closeout prompts require aggregate and closeout receipts"
  else
    fail "program closeout prompts are missing aggregate or closeout receipt requirements"
  fi
  if rg -n 'resolved-by-validated-parent-closeout-worktree-return' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-program/SKILL.md" >/dev/null \
    && rg -n 'preserve-and-exclude-from-lifecycle-closeout-blocking' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-program/SKILL.md" >/dev/null \
    && rg -n 'archive authorization|archive_authorization|archive_authorized: false' "$PACK_ROOT/prompts/generate-program-closeout-prompt" "$PACK_ROOT/prompts/closeout-program" "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-program/SKILL.md" "$PACK_ROOT/prompts/cleanup-lifecycle-residue" "$PACK_ROOT/skills/octon-proposal-lifecycle-cleanup-lifecycle-residue/SKILL.md" >/dev/null; then
    pass "program closeout keeps parent closeout-worktree handoff non-authorizing"
  else
    fail "program closeout can still treat parent closeout-worktree handoff as authority"
  fi

  assert_file "commands/octon-proposal-run-program-lifecycle.md"
  assert_file "skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md"
  if ! rg -n '(^|[^[:alnum:]_-])run-program-implementation([^[:alnum:]_-]|$)' "$PACK_ROOT/context/routing.contract.yml" "$PACK_ROOT/commands" "$PACK_ROOT/skills" "$PACK_ROOT/prompts" >/dev/null; then
    pass "direct run-program-implementation surface is absent"
  else
    fail "direct run-program-implementation surface must not exist"
  fi

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
