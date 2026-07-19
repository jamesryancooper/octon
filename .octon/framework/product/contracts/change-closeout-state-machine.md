---
title: Change Closeout State Machine
description: SI-00 preservation and effect-denial state machine for one Change.
status: active
---

# Change Closeout State Machine

This state machine operationalizes the active `branch-no-pr`, `branch-pr`, and
`stage-only-escalate` routes from `default-work-unit.yml`. It does not add
route, Git, provider, landing, or cleanup authority.

## SI-00 Behavior

Closeout binds governing constraints, inventories state read-only, classifies
candidate and unrelated work, selects one active route, runs non-mutating
validation, records any effect denial, and reports a preserved or blocked
outcome.

Direct-main is not active. Branch-no-PR remains a candidate classification but
cannot land. Cleanup cannot delete/prune refs, remove worktrees, or sync main.
The stable stop reasons are:

- `RP00_CONTAINMENT_PUBLICATION_DISABLED`
- `RP00_CONTAINMENT_CLEANUP_DISABLED`

## Outcomes

A generic closeout target is `preserved`. Branch-local or PR coordination
states remain continued outcomes. If a landing was independently established,
closeout may observe `landed` only with exact ref evidence and cleanup
deferred; it does not perform the effect. No current path claims `cleaned`,
`synced`, or autonomous publication success.

## Evidence

Stateful evidence records the initial inventory, candidate boundary,
preservation decisions, selected active route, validation, denial reason,
rollback/discard posture, final read-only verification, and next owner.
Historical receipts may be interpreted as evidence but cannot authorize a
current transition.

## Recovery

Any missing, stale, ambiguous, denied, or uncertain gate preserves exact work
and blocks. Recovery repairs forward to the contained state and never restores
direct-main, no-PR landing, or cleanup.
