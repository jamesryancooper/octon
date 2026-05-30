# Implementation Plan

_Status: Accepted child implementation plan_

## Workstreams

1. Add `evidence-disclosure-tiers-v1.yml` with tier ids, allowed roots, Git posture, authority roles, promotion rule, and forbidden consumers.
2. Add `evidence-disclosure-tiers-v1.md` explaining the operator-facing model and path semantics.
3. Revise `evidence-store-v1.md` so retained evidence no longer implies publishable raw transcript completeness.
4. Update `evidence.yml` obligations so consequential evidence records carry tier classification where publication or closeout claims depend on them.

## Evidence Plan

- Retain validator output under the applicable `.octon/state/evidence/**` root
  when durable changes land.
- Update `support/implementation-conformance-review.md` after implementation.
- Update `support/post-implementation-drift-churn-review.md` after
  implementation.
- Do not use proposal-local files as retained evidence for runtime or closeout.

## Rollback Plan

Revert the new tier contract, runtime prose updates, and obligation deltas if they weaken current evidence-store completeness or make generated views authoritative.
