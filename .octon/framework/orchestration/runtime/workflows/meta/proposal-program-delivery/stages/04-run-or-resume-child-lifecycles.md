# Stage 04: Run Or Resume Child Lifecycles

Run each child packet through its owning lifecycle and replan after material repository mutations.

Required checks:

- Child implementation runs write target-local receipts.
- Child implementation does not widen accepted promotion targets.
- The retained delivery-readiness preflight receipt is consumed rather than rediscovering authority blockers independently.
- Parent program summaries do not satisfy child receipt requirements.
- Stale, missing, or ambiguous child evidence blocks downstream claims.
- Missing target-owned child evidence emits `SC-001-authority-gap`; parent-summary substitution emits `SC-009-parent-summary-substitution`.
- Repeated blocker fingerprints, repeated full workflow directory emission, file-count limits, or byte-count limits use compact blocker-remediation receipts only for recoverable retry artifact budgets.
- Compact blocker-remediation must preserve required receipts and retained full-evidence digest refs; evidence-loss risk, unclassified blockers, or unsafe route ownership blocks continuation.
- Repeated unchanged no-dispatch or max-step states update the bounded no-dispatch attempt ledger keyed by target, route, input digest, blocker class, and blocker fingerprint instead of emitting another full compact evidence bundle.
- The no-dispatch attempt ledger is evidence-only and does not replace child packet, parent delivery, archive, cleanup, Change, generated-publication, branch cleanup, terminal proof, or proposal-status receipts.
