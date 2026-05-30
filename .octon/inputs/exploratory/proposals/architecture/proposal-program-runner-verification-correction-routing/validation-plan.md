# Validation Plan

## Required Checks

- Tests cover verification/correction sequencing and clean packets avoiding correction reruns.
- Tests cover stale parent aggregate receipts, stale child receipts, missing prompts, isolated validator failures, bounded validator timeouts, route-resolution timeout as correction finding, and support-file correction freshness refresh.
- Negative tests prove proposal-specific domain validators are not hard-coded into the generic runner.

## Evidence Quality

Validation must prove behavior, boundary, runtime authorization, generated
freshness, or disclosure claims directly. Generated snapshots, proposal-local
text, host state, or chat history are not sufficient authority.

## Post-Implementation Receipts Required

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Closeout and archive claims must be refused until both receipts pass after
implementation.
