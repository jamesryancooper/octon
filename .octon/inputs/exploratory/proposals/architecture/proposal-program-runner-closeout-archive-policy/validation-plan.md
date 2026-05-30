# Validation Plan

## Required Checks

- Tests cover current policy enforcement for archived/rejected child outcomes and receipt-level requirements.
- Tests cover child archive before parent terminal closeout when required by policy and no forced child archival when a future policy explicitly accepts implemented children.
- Tests cover blocked closeout receipts containing verdict, archive_authorized, selected git route, blocker class, counts, hygiene fingerprint, cleanup summary, and next route condition.

## Evidence Quality

Validation must prove behavior, boundary, runtime authorization, generated
freshness, or disclosure claims directly. Generated snapshots, proposal-local
text, host state, or chat history are not sufficient authority.

## Post-Implementation Receipts Required

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Closeout and archive claims must be refused until both receipts pass after
implementation.
