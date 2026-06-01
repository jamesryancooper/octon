# Target Architecture

The hardened proposal-program runner remains an orchestrator. It plans from
live lifecycle contracts and generated effective projections, emits retained
handoff evidence, dispatches only through the shared executor adapter, consumes
route receipts, observes workflow completion, checkpoints, and replans.

## Required End State

- Workflow retries do not collide with existing canonical workflow run ids.
- Explicit resume of an existing workflow run is allowed only with same-input,
  same-authority, same-target, replay-safe proof.
- Child implementation and promotion can produce route-owned change handoff
  checkpoints without transferring Git, cleanup, publication, promotion, or
  archive authority to the runner.
- Aggregate child terminal blockers are recorded by parent controller evidence
  while child receipts remain child-owned.
- Promotion evidence is bound to the selected child identity and receipt
  lineage before workflow-owned promotion dispatch.
- Generated-state freshness is checked before workflow dispatch where stale
  route bundles would fail anyway, and recovery guidance cites canonical
  publication scripts or declared recovery routes.
- Parent review freshness does not churn merely because volatile run-control or
  route-created evidence changed outside the reviewed parent artifact surface.
- Archive workflow routing observes terminal outcomes after active-path moves
  or fails closed with machine-readable blocked archive evidence.
- Regression tests cover the session failure pattern and the authority
  boundaries above.

## Authority Boundaries

The runner must not perform workflow-owned promotion or archive mutation,
cleanup deletion, branch cleanup, generated-state publication, registry
mutation, Change closeout, or child receipt synthesis. It may coordinate,
checkpoint, emit handoff evidence, validate gates, and replan from live state.
