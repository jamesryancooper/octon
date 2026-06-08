# Validation Plan

## Required Checks

- Tests cover cancellation during selected route dispatch and no post-cancel dispatch.
- Replay tests cover checkpoint/event divergence, duplicated events, hash-chain breaks, registry digest drift, stale locks, and missing offsets.
- Evidence-tier tests reject raw-copying local evidence into publishable retained evidence and reject hosted gates that require local-only raw evidence.

## Evidence Quality

Validation must prove behavior, boundary, runtime authorization, generated
freshness, or disclosure claims directly. Generated snapshots, proposal-local
text, host state, or chat history are not sufficient authority.

## Post-Implementation Receipts Required

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Closeout and archive claims must be refused until both receipts pass after
implementation.
