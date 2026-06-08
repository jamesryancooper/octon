# Validation Plan

## Required Checks

- Tests cover cleanup-safe residue, no-op cleanup with unchanged fingerprint, changed fingerprint requiring one cleanup attempt, and foreign/manual-review residue blocked behavior.
- Tests cover `implementation_blocking`, `closeout_blocking`, and `archive_blocking` phase scoping.
- Negative tests cover unknown predicates, unsupported predicate shapes, stale cleanup fingerprints, and unsafe cleanup.

## Evidence Quality

Validation must prove behavior, boundary, runtime authorization, generated
freshness, or disclosure claims directly. Generated snapshots, proposal-local
text, host state, or chat history are not sufficient authority.

## Post-Implementation Receipts Required

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Closeout and archive claims must be refused until both receipts pass after
implementation.
