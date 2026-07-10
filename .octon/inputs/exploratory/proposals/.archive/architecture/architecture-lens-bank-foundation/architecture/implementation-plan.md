# Implementation Plan

Atomic implementation. All authored artifacts and their validator land together;
there is no intermediate live state where a half-populated bank is referenceable.

## Preconditions

- This child has advanced through review to an implementation-authorized state
  (accepted status + accepted proposal-review receipt authorizing the executable
  implementation prompt + strict Pre-Integration Architecture Review receipt).
  At draft creation these receipts do not yet exist; they are produced by the
  later lifecycle routes.
- Write scope is limited to the registry-declared scopes:
  `.octon/framework/cognition/practices/methodology/architectural-review/` and
  `.octon/framework/assurance/runtime/_ops/scripts/` (plus the assurance test
  fixture tree for fixtures).

## Steps

1. **Author `lens-bank.yml`.** Create the machine-readable registry with all 18
   lens ids and their tiers, and `method_profiles` for all six methods,
   transcribed from `resources/lens-bank-authoring-spec.md`. Use provisional
   companion method slugs and record that phase-1 owns canonical slugs.
2. **Author `architecture-lens-bank.md`.** Create the lens doctrine doc: purpose
   and scope, the 18-lens catalog (question / evidence / when-to-apply per lens),
   the human-view profile table mirroring the YAML, the clean-sheet vs Greenfield
   complementarity statement, the Balanced sequence→lens-id appendix, and the
   four sprawl controls.
3. **Author the validator.** Create
   `validate-architectural-review-lens-references.sh` following existing
   `validate-architectural-review-*.sh` conventions, implementing both
   fail-closed rules (undefined lens id; method missing profile) and a positive
   control on the shipped bank.
4. **Author fixtures.** Add a passing fixture and two negative-control fixtures
   (undefined lens id; missing method profile) under the assurance test tree
   beside sibling architectural-review fixtures.
5. **Cross-reference, do not edit, Balanced.** Confirm the Balanced doc text is
   unchanged; the only linkage is the appendix in the lens bank doc that maps
   Balanced's existing required sequence to the 10 Balanced-required lens ids.
6. **Run validators.** Run the new lens-reference validator (positive + both
   negative controls) and re-run the existing architectural-review naming/routing
   validators to confirm no regression. Retain runs as evidence.
7. **Refresh projections only via canonical scripts.** If any generated
   projection indexes methodology files, refresh it only through the canonical
   publication script; never hand-edit generated output.

## Per-Child Validation Floor (child-packet-contract obligation 4)

- **Acceptance criteria:** `architecture/acceptance-criteria.md`.
- **Required evidence:** validator runs (positive + two negative controls),
  doc/registry consistency check, Balanced-unchanged proof.
- **Required validator depth:** this child touches an enforcement surface
  (the lens-reference validator itself), so at least one negative control per
  fail-closed rule is mandatory — satisfied by the two negative-control fixtures.
- **Rollback posture:** manual (per registry). See
  `architecture/rollback-plan.md`.

## Downstream Dependency Handoff

`architecture-review-method-taxonomy-and-routing` (phase-1) depends on this
child at the `verification` gate. Its naming v2 methods list and routing v2
`method_selection` block must cite the verified lens ids and reconcile the
canonical companion method slugs with the provisional slugs used here. That
reconciliation is a phase-1 obligation; this child ships lens-id integrity and
profile completeness that phase-1 can bind to.
