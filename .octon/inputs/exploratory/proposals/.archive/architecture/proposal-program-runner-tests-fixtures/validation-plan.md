# Validation Plan

## Required Checks

- Run relevant Rust tests for lifecycle program controller and lifecycle executor adapter changes.
- Run proposal lifecycle validation shell tests and proposal validators.
- Run canonical publication and registry checks when authored-source changes require generated refresh.

## Evidence Quality

Validation must prove behavior, boundary, runtime authorization, generated
freshness, or disclosure claims directly. Generated snapshots, proposal-local
text, host state, or chat history are not sufficient authority.

## Post-Implementation Receipts Required

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Closeout and archive claims must be refused until both receipts pass after
implementation.
