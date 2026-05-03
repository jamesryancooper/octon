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
4. Record lifecycle outcome `published`; do not claim full closeout.

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
   - the PR is open and still draft
   - the PR belongs to the autonomous `branch-pr` lane, or manual ready is
     explicitly selected without auto-merge
   - high-impact PRs have explicit self-review of diff, policy impact,
     required evidence, and rollback path
   - required GitHub checks are green
   - `AI Review Gate / decision` is green when required
   - `PR Quality Standards`, `Validate branch naming`,
     `PR Clean State Enforcer`, and `Validate autonomy policy` are green
   - unresolved author-action review threads are gone
   - no blocking labels, requested changes, merge conflicts, or stale head
     state remain
   - Change receipt or PR closeout evidence is present
   - the current live GitHub ruleset allows the merge path
2. If the PR is in the autonomous lane, request squash auto-merge or merge it
   only through the currently valid protected-main route once GitHub allows it.
   High-impact stays in this lane when evidence and blockers are resolved.
3. If the PR is in the manual lane, leave it ready for authorized human merge
   and continue monitoring until merged. Manual lane requires a concrete
   blocker; high-impact classification alone is not enough.
4. Record lifecycle outcome `ready`; do not claim landed until merge evidence
   exists.

## Phase 8: Merge Watch And Final Evidence

1. Watch the PR until GitHub merges it or until a precise external blocker is
   reached.
2. Fetch `origin main` after merge.
3. Verify `origin/main` contains the merged result.
4. Record merged ref, validation evidence, rollback handle, and cleanup
   disposition.
5. Escalate only when required evidence, mergeability, rollback safety, or
   post-merge `origin/main` state cannot be proven.

## Phase 9: Completion And Cleanup

1. Exit successfully only when the PR is merged or a precise external blocker is
   recorded.
2. Record lifecycle outcome `landed` after merge evidence exists.
3. Record lifecycle outcome `cleaned` only after local branch, remote branch,
   and worktree cleanup evidence exists or deferred-cleanup evidence is written.
4. If a real external blocker prevents progress, report it explicitly and stop.
