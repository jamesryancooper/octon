#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-lifecycle"

pass_count=0
fail_count=0

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

main() {
  local field missing_field status unexpected_statuses

  if rg -n 'do not become Octon authority|do not become authority|must not claim authority|never become Octon authority' "$PACK_ROOT" >/dev/null; then
    pass "non-authority boundary language is present"
  else
    fail "non-authority boundary language is missing"
  fi

  if rg -n 'support/correction-prompts|support/program-correction-prompts|support/custom-closeout-prompt|resources/source-context' "$PACK_ROOT/prompts" "$PACK_ROOT/context" >/dev/null; then
    pass "packet support artifact placement is documented"
  else
    fail "packet support artifact placement is missing"
  fi

  if rg -n 'GitHub.*do not become|comments.*do not become|labels.*do not become|CI.*do not become' "$PACK_ROOT" >/dev/null; then
    pass "GitHub and CI boundary is documented"
  else
    fail "GitHub and CI boundary is missing"
  fi

  if rg -n '\.octon/inputs/exploratory/proposals/<kind>/<program-proposal-id>/children' "$PACK_ROOT"; then
    pass "invalid nested child path is explicitly documented"
  else
    fail "invalid nested child path is not documented"
  fi

  if rg -n 'child manifests' "$PACK_ROOT/prompts/review-program" "$PACK_ROOT/prompts/revise-program" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null \
    && rg -n 'child receipts' "$PACK_ROOT/prompts/review-program" "$PACK_ROOT/prompts/revise-program" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null \
    && rg -n 'child promotion targets' "$PACK_ROOT/prompts/review-program" "$PACK_ROOT/prompts/revise-program" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null \
    && rg -n 'child validation verdicts' "$PACK_ROOT/prompts/review-program" "$PACK_ROOT/prompts/revise-program" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null \
    && rg -n 'child archive metadata' "$PACK_ROOT/prompts/review-program" "$PACK_ROOT/prompts/revise-program" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null; then
    pass "program review and revision preserve child authority boundaries"
  else
    fail "program review and revision child authority boundaries are missing"
  fi

  if rg -n 'Parent (review|revision|program )?receipts? (may summarize child outcomes but )?never satisf(y|ies) child receipts|Parent `support/proposal-review.md` never satisfies child receipts|parent support receipts as child receipts' "$PACK_ROOT" >/dev/null; then
    pass "parent receipts do not satisfy child receipts"
  else
    fail "parent receipt versus child receipt boundary is missing"
  fi

  if rg -n 'support/program-creation\.md' "$PACK_ROOT/prompts/create-program" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null \
    && rg -n 'never satisf(y|ies) child receipts|never satisfies child receipts' "$PACK_ROOT/prompts/create-program" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null; then
    pass "program creation receipt is parent-local only"
  else
    fail "program creation receipt boundary is missing"
  fi

  if rg -n 'support/program-implementation-conformance-review\.md' "$PACK_ROOT/prompts" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null \
    && rg -n 'support/program-post-implementation-drift-churn-review\.md' "$PACK_ROOT/prompts" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null \
    && rg -n 'never (replace|satisf(y|ies)) child receipts|never satisfies child receipts' "$PACK_ROOT/prompts" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null \
    && rg -n 'child promotion targets' "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" "$PACK_ROOT/prompts/closeout-program" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null \
    && rg -n 'child validation verdicts' "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" "$PACK_ROOT/prompts/closeout-program" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null \
    && rg -n 'child archive metadata' "$PACK_ROOT/prompts/run-program-verification-and-correction-loop" "$PACK_ROOT/prompts/closeout-program" "$PACK_ROOT/context/patterns/proposal-program.md" >/dev/null; then
    pass "program aggregate receipts preserve child authority"
  else
    fail "program aggregate receipt authority boundary is missing"
  fi

  if ! rg -n 'cleanup-local-run-artifacts|Bash\(git (add|commit|push|merge|checkout -b)' \
    "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md" \
    "$PACK_ROOT/skills/octon-proposal-lifecycle-closeout-program/SKILL.md" >/dev/null; then
    pass "closeout skills do not carry broad cleanup or git mutation authority"
  else
    fail "closeout skills carry cleanup or broad git mutation authority"
  fi

  if rg -n 'cleanup-local-run-artifacts|Bash\(git (add|commit|push|merge|checkout -b)' \
    "$PACK_ROOT/skills/octon-proposal-lifecycle-cleanup-lifecycle-residue/SKILL.md" >/dev/null; then
    pass "dedicated cleanup skill carries cleanup route authority"
  else
    fail "dedicated cleanup skill is missing cleanup route authority"
  fi

  if rg -n 'cleanup-local-run-artifacts\.sh' "$PACK_ROOT/prompts/cleanup-lifecycle-residue" "$PACK_ROOT/skills/octon-proposal-lifecycle-cleanup-lifecycle-residue/SKILL.md" >/dev/null \
    && rg -n 'helper-classified cleanup candidates' "$PACK_ROOT/prompts/cleanup-lifecycle-residue" "$PACK_ROOT/skills/octon-proposal-lifecycle-cleanup-lifecycle-residue/SKILL.md" >/dev/null \
    && rg -n 'protected, referenced, ambiguous, manual-review, user-owned' "$PACK_ROOT/prompts/cleanup-lifecycle-residue" "$PACK_ROOT/skills/octon-proposal-lifecycle-cleanup-lifecycle-residue/SKILL.md" >/dev/null \
    && rg -n 'active implementation artifacts|active implementation work' "$PACK_ROOT/prompts/cleanup-lifecycle-residue" "$PACK_ROOT/skills/octon-proposal-lifecycle-cleanup-lifecycle-residue/SKILL.md" >/dev/null \
    && rg -n 'push-safe disposition receipt' "$PACK_ROOT/prompts/cleanup-lifecycle-residue" "$PACK_ROOT/skills/octon-proposal-lifecycle-cleanup-lifecycle-residue/SKILL.md" >/dev/null \
    && rg -n 'classify-proposal-worktree-hygiene\.sh' "$PACK_ROOT/prompts/cleanup-lifecycle-residue" "$PACK_ROOT/skills/octon-proposal-lifecycle-cleanup-lifecycle-residue/SKILL.md" >/dev/null; then
    pass "cleanup route behavior contract preserves residue boundaries"
  else
    fail "cleanup route behavior contract is incomplete"
  fi

  missing_field=0
  for field in verdict cleaned_at cleanup_candidates manual_review_count worktree_hygiene_verdict remaining_blocker_class residue_fingerprint; do
    if ! yq -e ".receipts[]? | select(.receipt_id == \"lifecycle-residue-cleanup\" and .path == \"support/lifecycle-residue-cleanup.md\") | .required_fields[]? | select(. == \"$field\")" "$PACK_ROOT/context/lifecycles/proposal-program.contract.yml" >/dev/null; then
      missing_field=1
    fi
  done
  if [[ "$missing_field" -eq 0 ]]; then
    pass "cleanup route receipt declares required residue fields"
  else
    fail "cleanup route receipt is missing required residue fields"
  fi

  unexpected_statuses="$(
    {
      yq -r '.target.allowed_statuses[]?' "$PACK_ROOT/context/lifecycle.contract.yml"
      yq -r '.target.allowed_statuses[]?' "$PACK_ROOT/context/lifecycles/proposal-program.contract.yml"
    } | while IFS= read -r status; do
      case "$status" in
        draft|in-review|accepted|rejected|implemented|archived) ;;
        *) printf '%s\n' "$status" ;;
      esac
    done | sort -u
  )"
  if [[ -z "$unexpected_statuses" ]]; then
    pass "lifecycle contracts introduce no new manifest statuses"
  else
    fail "unexpected manifest statuses declared: $unexpected_statuses"
  fi

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
