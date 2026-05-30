# Implementation Plan

_Status: Accepted child implementation plan_

## Workstreams

1. Inventory current `.octon/state/evidence/runs/skills/**` cleanup and closeout evidence and classify raw versus publishable material.
2. Create a migration decision table for move-to-local, keep-publishable, replace-with-receipt, retain-with-rationale, or discard-after-archive.
3. Generate publishable replacement receipts for any hosted/shared claim that would otherwise point to local-only evidence.
4. Run validators and record aggregate parent closeout evidence without satisfying child receipts from parent evidence.

## Evidence Plan

- Retain validator output under the applicable `.octon/state/evidence/**` root
  when durable changes land.
- Update `support/implementation-conformance-review.md` after implementation.
- Update `support/post-implementation-drift-churn-review.md` after
  implementation.
- Do not use proposal-local files as retained evidence for runtime or closeout.

## Rollback Plan

Restore from local archive or retain old publishable evidence paths if migration produces weaker claim proof.
