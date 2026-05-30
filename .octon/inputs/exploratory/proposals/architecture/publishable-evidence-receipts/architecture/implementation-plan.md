# Implementation Plan

_Status: Accepted child implementation plan_

## Workstreams

1. Add `publishable-evidence-receipt-v1.schema.json` with required claim, validation, redaction, limitation, outcome, local reference, and rollback fields.
2. Update the tier contract with the receipt tier id and local reference requirements.
3. Add product-contract references where closeout and repo-hygiene receipts become publishable claim evidence.
4. Define example receipt placement under `.octon/state/evidence/runs/skills/<skill>/<run-id>/publishable-receipt.json`.

## Evidence Plan

- Retain validator output under the applicable `.octon/state/evidence/**` root
  when durable changes land.
- Update `support/implementation-conformance-review.md` after implementation.
- Update `support/post-implementation-drift-churn-review.md` after
  implementation.
- Do not use proposal-local files as retained evidence for runtime or closeout.

## Rollback Plan

Revert the schema and closeout references if receipts cannot prove claims without requiring raw evidence publication.
