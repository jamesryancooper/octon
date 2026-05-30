# Implementation Plan

_Status: Accepted child implementation plan_

## Workstreams

1. Add or extend assurance validators for local evidence tracking, receipt schema fields, concision thresholds, and hosted closeout checks.
2. Add fixture tests for valid publishable receipts, tracked local evidence denial, missing tier metadata, oversized evidence, and local-only closeout dependency denial.
3. Wire validators into the relevant governance or closeout validation profile without making proposal paths authoritative.
4. Document validator failure modes and remediation routes.

## Evidence Plan

- Retain validator output under the applicable `.octon/state/evidence/**` root
  when durable changes land.
- Update `support/implementation-conformance-review.md` after implementation.
- Update `support/post-implementation-drift-churn-review.md` after
  implementation.
- Do not use proposal-local files as retained evidence for runtime or closeout.

## Rollback Plan

Remove or narrow validator gates if they block existing required evidence without improving publication safety.
