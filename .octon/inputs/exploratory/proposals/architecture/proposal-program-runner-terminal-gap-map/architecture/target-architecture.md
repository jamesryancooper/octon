# Target Architecture

Downstream implementation packets start from a reviewed current-state map of
terminal-routing gaps, existing coverage, ownership boundaries, and required
validation. The parent program may coordinate sequence and aggregate evidence,
but it must not replace child-owned packet receipts or workflow-owned mutation
routes.

## End State

- Workflow retry dispatches cannot collide with an earlier canonical workflow
  run id for the same program child and route.
- Any resume of an existing workflow run is blocked unless the runner proves
  same input, same authority, same target, and replay-safe continuity.
- Closeout and worktree handoff checkpoints are non-authorizing lifecycle
  interactions. They may request route-owned closeout evidence but may not
  mutate Git, cleanup residue, or decide archival from the runner.
- Aggregate terminal blocker evidence is retained by the parent controller
  while every child packet keeps its own receipt, validation, promotion, and
  terminal lifecycle truth.
- Promotion dispatch is bound to the selected child identity, child receipt
  digests, authority-zone decision, write-scope digest, and route delegation
  basis before workflow-owned `promote-proposal` execution.
- Generated/effective freshness drift is classified before or at the earliest
  child-route boundary where stale projections would otherwise fail, and
  recovery stays with canonical publication scripts or declared recovery
  actions.
- Parent review freshness ignores volatile run-control and route-created
  evidence outside the reviewed parent artifact surface.
- Archive observation checks the archived proposal target after active-path
  moves and fails closed when archive completion cannot be observed.
- Regression tests prove duplicate workflow ids, replay boundaries, closeout
  handoff, aggregate blockers, promotion binding, publication freshness, review
  churn, archive observation, and fail-closed boundaries.

## Current Packet Output

This packet provides the reviewed current-state gap map and downstream
ownership map. It does not itself implement the runtime changes above. Later
child packets may mutate durable targets only after their own accepted reviews
and route-owned implementation authorization.
