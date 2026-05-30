# Validation Plan

## Required Checks

- Add tests for handoff-only default behavior and route-ready non-completion.
- Add tests proving route inventory comes from lifecycle contracts and generated projections.
- Add tests for receipt reread and replan after parent route dispatch or child batch dispatch.

## Evidence Quality

Validation must prove behavior, boundary, runtime authorization, generated
freshness, or disclosure claims directly. Generated snapshots, proposal-local
text, host state, or chat history are not sufficient authority.

## Post-Implementation Receipts Required

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Closeout and archive claims must be refused until both receipts pass after
implementation.
