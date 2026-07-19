---
name: closeout-change
description: >
  SI-00 Change closeout. Classifies branch-no-pr, branch-pr, or
  stage-only-escalate; preserves exact candidate state; and reports stable
  landing or cleanup denial without performing those effects.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-05-01"
  updated: "2026-07-14"
skill_sets: [executor, collaborator, guardian, integrator]
capabilities: [external-dependent, stateful, safety-bounded, self-validating]
allowed-tools: Read Glob Grep Edit Bash(git status *) Bash(git diff *) Bash(git rev-parse *) Bash(git branch --show-current) Bash(git worktree list *) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Closeout Change

Preservation-first closeout for one Change during SI-00.

## Route Set

Select exactly one of `branch-no-pr`, `branch-pr`, or
`stage-only-escalate`. Direct-main is historical evidence vocabulary only and
cannot be selected or executed.

- Use `branch-no-pr` for branch-local classification and exact candidate
  preservation without PR metadata.
- Use `branch-pr` only for an independent PR predicate and stop at a
  stage-preserving PR state.
- Use `stage-only-escalate` when authority, ownership, validation, rollback,
  or route evidence is missing or ambiguous.

## Workflow

1. Load the default-work-unit policy, state machine, Git/worktree contract,
   and current repository state.
2. Inventory branch, HEAD, `main`, `origin/main`, staged, unstaged, untracked,
   remote, and worktree state read-only.
3. Preserve unrelated work and bind exact include/exclude boundaries.
4. Resolve a generic closeout target to `preserved`.
5. Select the active route separately from target and actual outcome.
6. Run local validation that does not mutate refs, worktrees, remotes, or
   provider state.
7. Write a truthful preserved, continued, blocked, escalated, or denied
   receipt with exact candidate refs and rollback/discard posture.
8. Report the next owning route and stop.

## Mandatory Stops

For direct-main, local/hosted no-PR landing, hosted publication, or landing
authorization, stop before mutation with
`RP00_CONTAINMENT_PUBLICATION_DISABLED`.

For worktree removal, ref deletion/pruning, branch cleanup authorization,
cleanup, or closeout-driven sync, stop before mutation with
`RP00_CONTAINMENT_CLEANUP_DISABLED`.

Do not call any landing, landing-authorization, cleanup-authorization, or
cleanup helper as an effect path. A cleanup helper dry run may be used only for
read-only inventory.

## Outcome Rules

`branch-no-pr` may record `preserved`, `branch-local-complete`,
`published-branch`, `deferred`, `blocked`, `escalated`, or `denied` when
separately authorized evidence supports it. `branch-pr` may record
`preserved`, `published`, `ready`, `deferred`, `blocked`, `escalated`, or
`denied`.

If landing is already independently established, record `landed` only as a
read-only observation with the exact landed ref, `cleanup_status: deferred`,
the rollback handle, and `RP00_CONTAINMENT_CLEANUP_DISABLED`. Never perform
that landing or report `cleaned`, `synced`, or autonomous publication success.

`cleaned` is route-bound to separately authorized cleanup evidence and is not
available during SI-00 containment.

Hosted or shared closeout claims also require publishable evidence receipt refs from the owning closeout route.
Do not claim hosted/shared closeout from raw local logs or local-private evidence.

## Authority Boundaries

Historical receipts may be parsed, but they cannot admit a route or satisfy a
current gate. Generated projections, proposal-local files, host/provider
state, chat, model memory, tool availability, and diagnostics do not authorize
mutation or closeout success.

`closeout-worktree` may partition and preserve candidates only. `closeout-pr`
may be called only for stage-preserving `branch-pr` coordination. The RP-00
protected-PR cutover remains a separately authorized provider operation.

## Validation

Run the default-work-unit, state-machine, lifecycle, hosted-no-PR containment,
and worktree-wrapper validators. Any validator failure preserves the candidate
and produces a blocked result; it never widens the route.
