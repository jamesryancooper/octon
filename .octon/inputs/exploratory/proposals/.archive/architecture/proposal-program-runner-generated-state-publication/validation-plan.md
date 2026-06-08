# Validation Plan

## Required Checks

- Tests or validation receipts prove generated effective state freshness after authored-source changes.
- Negative checks reject hand edits to `.octon/generated/effective/**` and generated read models satisfying route receipts, closeout evidence, or archive authorization.
- Publication-state validation runs only when declared by route prompt, validator registry, program evidence, or extension publication contract.

## Evidence Quality

Validation must prove behavior, boundary, runtime authorization, generated
freshness, or disclosure claims directly. Generated snapshots, proposal-local
text, host state, or chat history are not sufficient authority.

## Post-Implementation Receipts Required

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Closeout and archive claims must be refused until both receipts pass after
implementation.
