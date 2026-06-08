# Validation Plan

## Required Checks

- Run targeted grep and semantic read-through over lifecycle contracts, runtime controller, executor adapter, prompts, validators, publication scripts, registry scripts, and workflow routes.
- Validate that proposed downstream child work maps only to authored sources, existing runtime/controller surfaces, executor integration, validators, prompts, tests, or canonical generated publication routes.
- Record source coverage against the lifecycle improvement text before implementation prompts are used.

## Evidence Quality

Validation must prove behavior, boundary, runtime authorization, generated
freshness, or disclosure claims directly. Generated snapshots, proposal-local
text, host state, or chat history are not sufficient authority.

## Post-Implementation Receipts Required

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Closeout and archive claims must be refused until both receipts pass after
implementation.
