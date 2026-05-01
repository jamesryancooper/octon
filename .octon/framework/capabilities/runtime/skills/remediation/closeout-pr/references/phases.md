---
title: Behavior Phases
description: Phase-by-phase execution for the closeout-pr skill.
---

# Behavior Phases

## Phase 1: Review Worktree Scope

1. Confirm the current worktree is on a real branch and not `main`.
2. Inspect tracked, unstaged, and untracked files with `git status` and
   `git diff`.
3. Define the intended task-scoped file set.
4. If unrelated changes are present and cannot be separated credibly, stop and
   report the blocker.

## Phase 2: Commit Intended Changes

1. Stage only the intended files.
2. Create a conventional commit.
3. Push the branch.

## Phase 3: Create Or Update Draft PR

1. Reuse the existing branch PR if one already exists.
2. Otherwise create a draft PR from the current branch worktree.
3. Ensure the PR body satisfies the repository PR quality template.

## Phase 4: Monitor Checks And Conversations

1. Poll check state and unresolved review-thread state.
2. If checks are still running, wait and poll again.
3. If unresolved conversations remain, keep the PR blocked and continue the
   remediation loop.

## Phase 5: Remediate Check Failures

1. Inspect the failing run.
2. Identify the smallest credible fix.
3. Apply the fix locally.
4. Run the most relevant local verification available.
5. Commit and push the remediation.
6. Return to monitoring.

## Phase 6: Remediate Review Feedback

1. Address reviewer feedback with `fix + commit + push + reply`.
2. Leave reviewer-owned thread resolution to the reviewer or maintainer unless
   the documented solo-maintainer exception applies.
3. Continue polling until no unresolved conversations remain.

## Phase 7: Ready And Merge Gate

1. Move out of draft only when:
   - required checks are green
   - unresolved conversations are gone
   - no author action items remain
   - the PR is in the correct lane
2. If the PR is in the autonomous lane, request squash auto-merge or merge it
   once GitHub allows it.
3. If the PR is in the manual lane, leave it ready for authorized human merge
   and continue monitoring until merged.

## Phase 8: Completion

1. Exit only when the PR is merged.
2. If a real external blocker prevents progress, report it explicitly and stop.
