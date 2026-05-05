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
- Provider route-neutral capability is a hosted no-PR landing precondition, not
  by itself a reason to choose `branch-no-pr` over eligible `direct-main`.
- Select `stage-only-escalate` when route, validation, rollback, ownership,
  support, or authority is ambiguous.

After selecting a route, resolve target lifecycle outcome and then actual
lifecycle outcome. Route selection answers which channel the Change uses;
target outcome answers what the operator or agent is trying to achieve; actual
outcome answers what the evidence proves.

## Hierarchical Decision Ladder

Use this order during closeout. Do not skip from route selection to a completion
claim.

| step | decision | autonomous action | ask or stop when |
| ---- | -------- | ----------------- | ---------------- |
| 1 | Select route: `direct-main`, `branch-no-pr`, `branch-pr`, or `stage-only-escalate`. | Use the fastest safe route allowed by policy, validation, rollback, and operator intent. | Route evidence, authority, or operator intent conflicts. |
| 2 | Select target lifecycle outcome. | Proceed when the target is explicit or safely inferable from the operator request. | `branch-no-pr` is route-only or the next step mutates hosted refs, deletes branches, marks ready, merges, cleans, or syncs `main`. |
| 3 | Select actual lifecycle outcome from evidence. | Record the highest route-compatible outcome that evidence proves. | Evidence is missing, stale, blocked, or proves only a lower outcome. |
| 4 | Choose closeout report posture. | Report completed closeout only for route-compatible landed or cleaned outcomes with required receipt, rollback, cleanup, and alignment evidence. | Non-terminal outcomes become continued handoff; blocked evidence becomes blocker receipt; denied authority becomes denied closeout. |

Ask a clarification question when `branch-no-pr` is selected but the target is
ambiguous:

- "Do you want `branch-no-pr` closeout to stop at pushed-branch handoff, or
  should I attempt hosted landing?"
- "If hosted landing succeeds, should I proceed through safe branch cleanup and
  local-main sync?"
- "If landing is blocked, should I record a blocker receipt, publish the branch
  for handoff, or stop for review?"

Lifecycle outcomes:

- `preserved`: state is recoverable but not necessarily committed or landed.
- `branch-local-complete`: intended scope is committed on a branch but not
  landed.
- `published-branch`: branch is pushed for backup or handoff without a PR.
  This is continued handoff, not completed closeout.
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

If target outcome is `landed` or `cleaned` but actual outcome is only
`published-branch`, record landing evaluation evidence and `not_landed_reason`.
If target outcome is `cleaned` but cleanup or local-main sync cannot be proven,
record `not_cleaned_reason`.
