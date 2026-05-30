# Implementation Plan

_Status: Accepted child implementation plan_

## Workstreams

1. Create `.octon/state/evidence/local/README.md` with allowed contents, forbidden consumers, and promotion route.
2. Create `.octon/state/evidence/.gitignore` with `local/**` and narrow exceptions only if durable marker files must be tracked.
3. Update repo-hygiene policy so local evidence is protected from generic cleanup and excluded from hosted closeout evidence gates.
4. Define the operator rule for local archive retention versus explicit discard.

## Evidence Plan

- Retain validator output under the applicable `.octon/state/evidence/**` root
  when durable changes land.
- Update `support/implementation-conformance-review.md` after implementation.
- Update `support/post-implementation-drift-churn-review.md` after
  implementation.
- Do not use proposal-local files as retained evidence for runtime or closeout.

## Rollback Plan

Remove the local README, scoped ignore rule, and repo-hygiene references if the local root creates ambiguity or blocks required evidence retention.
