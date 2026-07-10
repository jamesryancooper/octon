# Rollback Plan

Rollback posture: **manual** (per `resources/child-packet-index.yml`, greenfield
child entry — no explicit `rollback_posture` override; the program default is
manual for every child).

## Why Rollback Is Low-Risk

This child is additive. It adds one new doc and makes two additive navigation
edits (a `doc:` reference on the existing `naming.yml` greenfield entry and a
README references link). No existing route, gate, alias, evidence root, schema,
lens profile, or Balanced/companion doctrine is changed. Reverting returns the
mechanism to its exact prior state, where the greenfield method is named and
routable (phase-1) but has no output contract.

## Rollback Procedure

1. Delete `greenfield-reference-architecture-review-method.md`.
2. Revert the additive `doc:` reference on the `naming.yml` greenfield catalog
   entry (restore the entry to its phase-1 state with only `lens_profile_ref`).
3. Revert the README References link.
4. Confirm no downstream child references the doc yet. The phase-3
   `architectural-review-suite-integration` child binds to landed method docs only
   at its `verification` gate; a rollback performed before phase-3 implementation
   has no downstream references to repair. If phase-3 has already bound to this
   doc, rollback must be coordinated at the parent program (registry revision),
   not performed silently.
5. Re-run the full `validate-architectural-review-*.sh` suite (including the
   phase-0 lens-reference validator) to confirm the mechanism is back to its prior
   passing state.
6. Retain a rollback receipt under the child promotion evidence root recording
   what was reverted and why.

## Trigger Conditions

- Verification finds the doc's lens citations or slug inconsistent with the
  verified `lens-bank.yml` / `naming.yml` in a way that cannot be corrected in
  place.
- The canonical greenfield slug or lens profile changes upstream (phase-0 or
  phase-1 re-issue), requiring the doc to be re-authored against the new binding
  before this child closes.
- The reference-architecture-only output boundary cannot be stated in a way that
  is genuinely fail-closed (e.g., the doc would otherwise imply implementation
  authority for Greenfield output).

Any rollback that would strand a downstream child triggers parent-level
coordination rather than a silent local revert.
