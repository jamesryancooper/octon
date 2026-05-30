# Implementation Plan

_Status: Accepted child implementation plan_

## Workstreams

1. Update disclosure contract docs or schema references to allow publishable receipt linkage.
2. Update operator read-model prose to state that generated read models cannot satisfy evidence gates.
3. Define how RunCard and release summaries cite publishable receipts and local-only limitations.
4. Add negative examples for generated read models being incorrectly treated as evidence authority.

## Evidence Plan

- Retain validator output under the applicable `.octon/state/evidence/**` root
  when durable changes land.
- Update `support/implementation-conformance-review.md` after implementation.
- Update `support/post-implementation-drift-churn-review.md` after
  implementation.
- Do not use proposal-local files as retained evidence for runtime or closeout.

## Rollback Plan

Revert disclosure/read-model prose or schema references if they let generated outputs substitute for retained evidence.
