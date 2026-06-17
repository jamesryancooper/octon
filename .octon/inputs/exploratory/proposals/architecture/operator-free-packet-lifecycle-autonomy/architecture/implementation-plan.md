# Implementation Plan

This parent program does not implement durable changes. Implementation happens
only after lifecycle review accepts child packets.

## Program Phases

1. Establish the outer delivery route and blocked receipt semantics.
2. Make branch-no-PR closeout an owned state machine.
3. Add generated freshness and worktree partitioning automation.
4. Add a terminal evidence sink that avoids post-landing source mutation.
5. Improve git mutation and sandbox preflight diagnostics.
6. Run aggregate delivery validation and program closeout only after child
   packets report child-owned pass receipts.

## Coordination Rules

- Child packets must be siblings under `.octon/inputs/exploratory/proposals/architecture/`.
- Parent program evidence can summarize child status but cannot satisfy child
  receipts.
- Generated outputs may be refreshed only by owning generators in the relevant
  child packet.
- Cleanup must use route-owned cleanup or hygiene helpers and must not delete
  protected evidence without authorization.

## Final Recommendation

Implement the P0 children first:

1. `blocked-delivery-receipt-semantics`
2. `packet-delivery-wrapper-orchestration-autonomy`
3. `branch-no-pr-closeout-state-machine-autonomy`

Those three remove the highest-friction operator decisions observed in the
instruction-envelope closeout and define the behavior that later freshness,
hygiene, evidence-sink, and git-preflight children should plug into.
