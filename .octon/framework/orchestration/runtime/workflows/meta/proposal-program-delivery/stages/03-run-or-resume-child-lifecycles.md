# Stage 03: Run Or Resume Child Lifecycles

Run each child packet through its owning lifecycle and replan after material repository mutations.

Required checks:

- Child implementation runs write target-local receipts.
- Child implementation does not widen accepted promotion targets.
- Parent program summaries do not satisfy child receipt requirements.
- Stale, missing, or ambiguous child evidence blocks downstream claims.
