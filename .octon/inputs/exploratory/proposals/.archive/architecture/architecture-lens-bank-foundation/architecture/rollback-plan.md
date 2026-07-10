# Rollback Plan

Rollback posture: **manual** (per `resources/child-packet-index.yml`).

## Why Rollback Is Low-Risk

This child is purely additive. It creates two new methodology artifacts and one
new validator plus fixtures. It edits no existing file, changes no runtime
routing or gate, and grants no authority. Removing the new files returns the
mechanism to its exact prior state.

## Rollback Procedure

1. Delete the three durable artifacts and their fixtures:
   - `.octon/framework/cognition/practices/methodology/architectural-review/architecture-lens-bank.md`
   - `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml`
   - `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh`
   - the lens-reference validator fixtures.
2. Confirm no other file referenced them yet. Because phase-1
   (`architecture-review-method-taxonomy-and-routing`) only binds to this bank
   at its `verification` gate, a rollback performed before phase-1 implementation
   has no downstream references to repair. If phase-1 has already bound to the
   lens ids, rollback must be coordinated at the parent program (registry
   revision), not performed silently.
3. Re-run the existing architectural-review validator suite to confirm the
   mechanism is back to its prior passing state.
4. Retain a rollback receipt under the child promotion evidence root recording
   what was removed and why.

## Trigger Conditions

- Verification finds the bank inconsistent with the live mechanism in a way that
  cannot be corrected in place.
- A parent registry/design revision supersedes the lens-bank design before this
  child closes.
- The lens-reference validator cannot be made to fail closed on its negative
  controls (fail-closed guarantee unmet).

Any rollback that would strand a downstream child triggers parent-level
coordination rather than a silent local revert.
