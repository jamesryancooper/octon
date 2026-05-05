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
- High-impact lane: remain autonomous with elevated evidence and self-review
  requirements. Do not route to manual solely because the PR is high-impact.
- Manual lane: use only for concrete unresolved blockers that require human
  judgment, credentials, authority, or policy acceptance. Do not bypass policy;
  remain ready and continue observing until merged by an authorized human.

## Stop Conditions

- PR draft/open -> `published`, not full closeout
- PR ready but unmerged -> `ready`, not landed
- PR merged -> `landed`
- PR merged plus cleanup evidence or deferred cleanup record -> `cleaned`
- Required evidence, rollback safety, mergeability, or post-merge
  `origin/main` state cannot be proven -> report exact blocker and stop
- Real external blocker -> report and stop

## Target Outcome Resolution

When `closeout-pr` is invoked directly from an existing PR context, resolve the
target lifecycle outcome before mutating PR, merge, branch, or local `main`
state:

| target | autonomous action | report as |
| ------ | ----------------- | --------- |
| `published` | Ensure the branch is pushed and a draft/open PR exists. | continued handoff, not completed closeout |
| `ready` | Move out of draft only after the ready gate passes. | ready, not landed |
| `landed` | Request or perform merge only through the currently valid protected-main route. | landed only with merge evidence |
| `cleaned` | After merge, clean safe branches or record deferred cleanup, then fetch/sync local `main`. | completed only with cleanup/sync evidence |
| `blocked`, `escalated`, `denied` | Preserve state and record the precise reason. | blocker or denial receipt |

If the target is omitted, infer it only when the operator wording or current PR
state is unambiguous. Ask before ready, merge, cleanup, or local-main sync when
the requested target is ambiguous.
