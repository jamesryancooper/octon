---
title: Decision Logic
description: Decision boundaries for the closeout-pr skill.
---

# Decision Logic

## File Scope

- Prefer the current branch worktree diff as the intended task scope.
- If the worktree contains unrelated changes, do not silently sweep them into
  the closeout commit.

## Check Failures

- If a failing check is code-related and within branch scope, remediate it.
- If a failing check is infrastructure-only, report the blocker rather than
  forcing a speculative code change.

## Review Threads

- Unresolved conversations are a merge blocker.
- The author path is `fix + commit + push + reply`, not thread resolution.

## Merge Lane

- Autonomous lane: request squash auto-merge or merge once GitHub permits it.
- Manual lane: do not bypass policy; remain ready and continue observing until
  merged by an authorized human.

## Stop Conditions

- PR merged -> success
- Real external blocker -> report and stop
