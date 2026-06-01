# Cutover Checklist

## Before Review Acceptance

- [ ] Packet status remains `in-review`.
- [ ] Latest `support/proposal-review.md` is superseded only by a fresh
  `review-packet` route.
- [ ] Architecture floor artifacts are present and listed in
  `navigation/artifact-catalog.md`.
- [ ] `architecture/current-state-gap-map.md` maps every parent postmortem
  requirement to live evidence and downstream owner.
- [ ] `support/implementation-grade-completeness-review.md` records packet
  readiness without authorizing implementation.

## Before Downstream Child Dispatch

- [ ] Parent program review remains accepted and fresh.
- [ ] This child has a fresh accepted review and implementation prompt
  authorization if the lifecycle requires it.
- [ ] `validate-proposal-program-child-readiness.sh` passes for the parent
  before orchestration prompt generation.
- [ ] No downstream child treats this packet as durable authority or as a
  substitute for its own receipts.

## During Downstream Execution

- [ ] Each child confirms its current gap classification against live repo
  state before editing durable targets.
- [ ] Workflow-owned promote/archive routes remain workflow-owned.
- [ ] Closeout and cleanup handoffs remain non-authorizing.
- [ ] Generated/effective drift is classified before using derived outputs as
  routing evidence.
- [ ] Parent aggregate evidence records summaries only and preserves child
  receipt ownership.

## Closeout Gate

- [ ] Each child retains implementation, conformance, drift, closeout, and
  archive evidence required by its own lifecycle.
- [ ] Parent closeout cites child-owned terminal outcomes rather than
  synthesizing them.
- [ ] Archive observation proves the final archived target or records a blocked
  archive receipt.
