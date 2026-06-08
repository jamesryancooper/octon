# Acceptance Criteria

- Runnable children are scheduled by dependency order and declared execution mode, with `--max-child-concurrency` limiting child executors inside one batch.
- Non-fatal parent maintenance routes do not starve runnable child routes.
- Child route failures, timeouts, stale receipts, missing evidence, and validation failures are classified and routed through configured recovery where safe.
- Independent children continue when recovery policy allows; dependent children pause until predecessor blockers resolve.

## Negative Criteria

- Do not invent recovery behavior outside the contract-declared recovery policy.
- Do not continue dependent children past unresolved predecessor blockers.
- Do not treat no-op cleanup receipts with `implementation_blocking: false` as child implementation blockers.

## Terminal Criteria

- Child implementation evidence exists only after a later
  `run-packet-implementation` route.
- Child promotion is workflow-owned by `promote-proposal` and cannot be claimed
  by parent program evidence.
- Child closeout and archive remain child-owned and route-gated.
