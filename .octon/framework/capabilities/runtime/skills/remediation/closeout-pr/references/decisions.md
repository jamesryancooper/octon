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

- Autonomous lane: after the autonomous draft completion preflight passes,
  mark the draft ready and request squash auto-merge or merge through the
  currently valid protected-main route once GitHub permits it.
- Manual lane: do not bypass policy; remain ready and continue observing until
  merged by an authorized human.

## Stop Conditions

- PR draft/open -> `published`, not full closeout
- PR ready but unmerged -> `ready`, not landed
- PR merged -> `landed`
- PR merged plus cleanup evidence or deferred cleanup record -> `cleaned`
- Real external blocker -> report and stop
