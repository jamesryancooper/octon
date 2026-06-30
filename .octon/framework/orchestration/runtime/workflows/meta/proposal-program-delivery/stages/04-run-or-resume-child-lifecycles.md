# Stage 04: Run Or Resume Child Lifecycles

Run each child packet through its owning lifecycle and replan after material repository mutations.

Required checks:

- Child implementation runs write target-local receipts.
- Child implementation does not widen accepted promotion targets.
- The retained delivery-readiness preflight receipt is consumed rather than rediscovering authority blockers independently.
- Parent program summaries do not satisfy child receipt requirements.
- Stale, missing, or ambiguous child evidence blocks downstream claims.
- Missing target-owned child evidence emits `SC-001-authority-gap`; parent-summary substitution emits `SC-009-parent-summary-substitution`.
