# Validation Plan

## Required Checks

- Tests cover sequential, parallel-independent, gated-parallel, approval-gated, and unsupported mode configurations.
- Recovery-budget tests cover stale receipt, missing evidence, validation failed, executor failed, executor timed out, publication drift, lifecycle residue cleanup, and exhausted budgets.
- Tests prove write-scope conflicts serialize and independent child continuation remains allowed.

## Evidence Quality

Validation must prove behavior, boundary, runtime authorization, generated
freshness, or disclosure claims directly. Generated snapshots, proposal-local
text, host state, or chat history are not sufficient authority.

## Post-Implementation Receipts Required

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Closeout and archive claims must be refused until both receipts pass after
implementation.
