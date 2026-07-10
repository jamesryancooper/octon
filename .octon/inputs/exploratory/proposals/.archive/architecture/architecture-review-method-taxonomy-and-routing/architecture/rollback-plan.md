# Rollback Plan

Rollback posture: **manual** (per `resources/child-packet-index.yml`).

## Why Rollback Is Low-Risk

This child is additive. naming v1→v2 and routing v1→v2 add fields; the README and
Balanced edits add rows and navigation links; the validators add checks. No
existing route, gate, alias, evidence root, or Balanced doctrine text is changed.
Reverting the additive diffs returns the mechanism to its exact prior v1 state.

## Rollback Procedure

1. Revert the additive diffs on the four methodology files:
   - `naming.yml` — remove the `methods` block; restore `schema_version` to
     `architectural-review-naming-v1`.
   - `review-routing.yml` — remove the `method_selection` block and the two
     appended `fail_closed_conditions`; restore `schema_version` to
     `architectural-review-routing-v1`.
   - `README.md` — remove the appended method rows, selection note, and links.
   - `balanced-architecture-review-method.md` — remove the added navigation
     cross-references (doctrine text was never touched).
2. Revert the naming/routing validator extensions and delete the
   method-taxonomy/routing fixtures.
3. Confirm no downstream child bound to the method slugs yet. Because the phase-2
   children only bind to this taxonomy/routing at their `verification` gates, a
   rollback performed before phase-2 implementation has no downstream references
   to repair. If a phase-2 child has already bound to the canonical slugs,
   rollback must be coordinated at the parent program (registry revision), not
   performed silently.
4. Re-run the full `validate-architectural-review-*.sh` suite (including the
   phase-0 lens-reference validator) to confirm the mechanism is back to its
   prior passing v1 state.
5. Retain a rollback receipt under the child promotion evidence root recording
   what was reverted and why.

## Trigger Conditions

- Verification finds the naming/routing v2 models inconsistent with the live
  mechanism or the verified lens bank in a way that cannot be corrected in place.
- The canonical slug decision must change (e.g., phase-0 re-issues different
  `suite_methods` slugs), requiring a parent registry/design revision before this
  child closes.
- A naming or routing negative control cannot be made to fail closed
  (fail-closed guarantee unmet).

Any rollback that would strand a downstream child triggers parent-level
coordination rather than a silent local revert.
