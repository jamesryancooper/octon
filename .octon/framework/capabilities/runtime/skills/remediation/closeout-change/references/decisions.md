---
title: Closeout Change Decisions
---

# Decisions

- Select `branch-pr` when the operator requests a PR, hosted review, preview
  publication, external signoff, unresolved review discussion, PR-required
  provider rules, release automation, collaboration, existing PR context, or
  high-risk hosted governance handling.
- Select `branch-no-pr` when isolation, pause/resume, multiple commits,
  uncertain scope, handoff, branch backup, or hosted no-PR landing is needed
  without PR-backed publication and no PR-required predicate applies.
- Select `direct-main` only on clean current `main` for low-risk solo Changes
  with local validation, receipt, durable history, and rollback ready.
- Select `stage-only-escalate` when route, validation, rollback, ownership,
  support, or authority is ambiguous.

After selecting a route, select lifecycle outcome:

- `preserved`: state is recoverable but not necessarily committed or landed.
- `branch-local-complete`: intended scope is committed on a branch but not
  landed.
- `published-branch`: branch is pushed for backup or handoff without a PR.
- `landed`: no-PR branch work is fast-forward integrated into hosted `main`
  only when provider rules allow route-neutral updates, exact source SHA
  required checks pass, the source branch is pushed and current with
  `origin/main`, and `origin/main` equals the recorded landed ref after push.
- `published`: PR-backed branch is pushed and a PR exists.
- `ready`: PR gates are satisfied and waiting for merge or auto-merge.
- `landed`: the Change is integrated into `main` with route-appropriate hosted
  evidence.
- `cleaned`: branch, remote branch when present, and worktree cleanup are
  complete or explicitly deferred with evidence.
- `blocked`, `escalated`, or `denied`: closeout cannot truthfully progress.
