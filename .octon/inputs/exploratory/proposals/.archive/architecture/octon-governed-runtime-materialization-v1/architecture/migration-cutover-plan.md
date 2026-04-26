# Migration Cutover Plan

## Pre-cutover checks

- Working tree contains no unrelated generated or state drift.
- Proposal packet passes proposal-standard validation.
- Existing architecture conformance validators pass before migration.
- Current support mismatch inventory is captured as retained evidence.
- Material side-effect surface inventory is complete.
- Run-health source dependencies are identified and digestable.

## Cutover sequence

1. Promote support-envelope reconciliation spec and schema.
2. Promote support-envelope generator/validator and fixtures.
3. Update architecture conformance script to call the reconciler.
4. Promote authorized-effect-token runtime/spec updates.
5. Update material side-effect APIs to require verified effects.
6. Promote token enforcement tests and fixtures.
7. Promote run-health schema, generator, validator, and fixtures.
8. Regenerate:
   - support-envelope reconciliation output
   - route/support projections affected by reconciliation
   - run-health read models for fixture/example runs
9. Retain validation evidence for each gate.
10. Produce closure certification.

## Publication and support activation rule

No live support claim may be published or consumed for runtime routing unless the
support-envelope reconciler reports `status: reconciled`. A non-reconciled state
must route to staged, denied, or explicit unsupported posture.

## Compatibility impact

- Material API call sites must pass typed effects.
- Tests that relied on ambient permission must be rewritten.
- Generated support matrices and support cards may be withheld when
  reconciliation fails.
- Operator health artifacts are new generated read models and should not affect
  runtime authority.

## Roll-forward preference

If a post-cutover failure is limited to generated/read-model output, prefer
fixing the generator and regenerating. If the failure involves authority,
support, or token enforcement, stop promotion and rollback runtime/spec changes.
