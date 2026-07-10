# Rollback Plan

Rollback posture: **manual** (per `resources/child-packet-index.yml`).

## Why Rollback Is Low-Risk

This child is additive. The v2 schemas are new files; the README and receipts
validator gain checks; no v1 schema field, the support-receipt schema, any
existing route, gate, or evidence root is changed. Reverting the additive diffs
and deleting the new schema files returns the contract surface to its exact prior
state, and v1 producers were never disturbed.

## Rollback Procedure

1. Delete the two new schema files:
   - `architectural-review-report-v2.schema.json`
   - `architectural-review-routing-decision-v2.schema.json`
2. Revert the additive README entries in
   `.octon/framework/constitution/contracts/assurance/README.md`.
3. Revert the receipts-validator v2 awareness (the v2 report/routing-decision
   path, the support-receipt drift guard, and NC-1/NC-2/NC-3) and delete the
   receipts-validator fixtures. The existing support-receipt assertions were never
   changed, so the validator returns to its prior behavior exactly.
4. Confirm no downstream child bound to the v2 schemas yet. Because the phase-3
   child (`architectural-review-suite-integration`) only binds to these schemas at
   its `verification` gate, a rollback performed before phase-3 implementation has
   no downstream references to repair. If phase-3 has already emitted v2 review
   evidence, rollback must be coordinated at the parent program (registry
   revision), not performed silently.
5. Re-run the full `validate-architectural-review-*.sh` suite to confirm the
   contract surface is back to its prior passing state.
6. Retain a rollback receipt under the child promotion evidence root recording
   what was reverted and why.

## Trigger Conditions

- Verification finds a v2 schema is not a clean additive superset of its v1 schema
  (a v1 field was accidentally changed or dropped) in a way that cannot be
  corrected in place.
- The `method` enum or `lenses_applied` binding must change because phase-0/phase-1
  re-issued different method slugs or lens ids, requiring a parent registry/design
  revision before this child closes.
- Any of the three negative controls cannot be made to fail closed (fail-closed
  guarantee unmet), or the support-receipt schema cannot be kept byte-for-byte
  unchanged.

Any rollback that would strand a downstream child triggers parent-level
coordination rather than a silent local revert.
