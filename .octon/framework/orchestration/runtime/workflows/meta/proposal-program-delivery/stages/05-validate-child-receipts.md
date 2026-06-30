# Stage 05: Validate Child Receipts

Validate child packet receipts directly.

Required checks:

- Implementation conformance receipts are fresh and passing.
- Post-implementation drift/churn receipts are fresh and passing.
- Governed mechanism integration receipts are present when applicable.
- Generated publication freshness is proven by the owning publisher or freshness validator.
- Aggregated evidence cites source receipts by path or evidence ref plus digest and does not replace them.
- Parent summaries, readiness projections, aggregate receipts, delivery evidence indexes, generated outputs, host state, chat, model memory, and tool state are rejected as substitutions for target-owned receipts.
- Stale child receipts emit `SC-005-stale-evidence`; stale generated publication evidence emits `SC-006-generated-freshness-drift`.
