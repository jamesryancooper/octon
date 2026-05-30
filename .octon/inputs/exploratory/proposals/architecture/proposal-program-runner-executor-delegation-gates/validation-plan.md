# Validation Plan

## Required Checks

- Adapter tests cover `--execute-routes` delegation for parent routes and child batches.
- Negative tests prove missing delegation proof, invalid authority zone evidence, and route-declared human-only boundaries fail closed.
- Tests cover repo-local launcher guidance when the packaged `octon` binary lacks lifecycle support.

## Evidence Quality

Validation must prove behavior, boundary, runtime authorization, generated
freshness, or disclosure claims directly. Generated snapshots, proposal-local
text, host state, or chat history are not sufficient authority.

## Post-Implementation Receipts Required

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Closeout and archive claims must be refused until both receipts pass after
implementation.
