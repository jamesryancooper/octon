# Implementation Plan

Atomic implementation. The two v2 schemas, the contracts/assurance README
extension, the receipts-validator v2 awareness, and the negative-control fixtures
land together; there is no intermediate live state where a v2 schema exists
without validator coverage.

## Preconditions

- This child has advanced through review to an implementation-authorized state
  (accepted status + accepted proposal-review receipt authorizing the executable
  implementation prompt + strict Pre-Integration Architecture Review receipt).
  At draft creation these receipts do not yet exist; they are produced by the
  later lifecycle routes.
- The upstream dependencies have passed their `verification` gates:
  `architecture-review-method-taxonomy-and-routing` (phase-1) so `naming.yml`
  `methods` catalog slugs are verified and stable, and
  `architecture-lens-bank-foundation` (phase-0) so `lens-bank.yml` lens ids are
  verified and stable.
- Write scope is limited to the registry-declared scopes:
  `.octon/framework/constitution/contracts/assurance/` and
  `.octon/framework/assurance/runtime/_ops/scripts/` (plus the assurance test
  fixture tree for fixtures).

## Steps

1. **Confirm the binding surfaces against the live repo.** Re-read the six
   `naming.yml` `methods` catalog slugs and the `lens-bank.yml` lens ids; confirm
   `resources/schema-extension-authoring-spec.md` still matches. If phase-0/1
   changed them, reconcile before proceeding (repository wins).
2. **Author `architectural-review-report-v2.schema.json`.** Copy
   `architectural-review-report-v1` verbatim, change `$id` and `title` and the
   `schema_version` const to the v2 names, and add `method` (enum of the six
   canonical slugs) and `lenses_applied` (array of strings, `minItems: 1`,
   `uniqueItems: true`, `items.minLength: 1`) to `properties` and to `required`.
   Keep `additionalProperties: false`.
3. **Author `architectural-review-routing-decision-v2.schema.json`.** Same
   treatment applied to `architectural-review-routing-decision-v1`: v2 `$id`,
   `title`, `schema_version` const, and the two additive required fields. Preserve
   the v1 `selected_mode` enum and all other v1 fields and constraints verbatim.
4. **Leave the support receipt and the v1 schemas untouched.** Make no edit to
   `architectural-review-support-receipt-v1.schema.json`,
   `architectural-review-report-v1.schema.json`, or
   `architectural-review-routing-decision-v1.schema.json`.
5. **Extend the contracts/assurance README.** Add the two v2 schema entries to the
   architectural-review schema list beside their v1 counterparts. Leave existing
   entries unchanged.
6. **Extend the receipts validator with v2 awareness.** Add: a `receipt_schema_drift`
   guard on the support-receipt path (any non-v1 schema_version or an unexpected
   `method`/`lenses_applied` field fails closed); a v2 report/routing-decision
   path that, when `schema_version` ends in `-v2`, asserts `method` ∈ the live
   `naming.yml` `methods` catalog (NC — `unknown_method`) and every
   `lenses_applied` id ∈ `lens-bank.yml` (NC — `undefined_lens`); and a v1 path
   that validates the v1 artifacts without requiring the new fields. Retain all
   existing support-receipt assertions (no-regression guard).
7. **Author fixtures.** Add a passing fixture (a valid v2 report and a valid v2
   routing-decision using a real method slug and real lens ids) and three
   negative-control fixtures: `fail-unknown-method` (v2 artifact with a `method`
   not in the naming catalog), `fail-undefined-lens` (v2 artifact with a
   `lenses_applied` id not in the lens bank), and `fail-receipt-schema-drift` (a
   support receipt whose `schema_version` is not v1 / that carries a `method`
   field), under the assurance test tree beside the sibling architectural-review
   fixtures.
8. **Run validators.** Run the extended receipts validator (positive + all three
   negative controls). Validate both v2 schemas as well-formed JSON Schema and
   confirm the additive-superset property (diff v2 against v1: only `$id`,
   `title`, `schema_version` const, and the two additive fields differ). Re-run
   the phase-1 naming validator and phase-0 lens-reference validator to confirm
   the binding surfaces still pass, and re-run the remaining
   `validate-architectural-review-*.sh` suite to confirm no regression. Retain
   runs as evidence.
9. **Refresh projections only via canonical scripts.** If any generated projection
   indexes the assurance contract schemas, refresh it only through the canonical
   publication script; never hand-edit generated output.

## Per-Child Validation Floor (child-packet-contract obligation 4)

- **Acceptance criteria:** `architecture/acceptance-criteria.md`.
- **Required evidence:** v2 schema well-formedness + additive-superset proof,
  receipts-validator runs (positive + three negative controls), method-enum ↔
  naming-catalog binding proof, `lenses_applied` ↔ lens-bank binding proof, v1
  coexistence proof, support-receipt-unchanged proof, and the remaining-suite
  no-regression proof.
- **Required validator depth:** this child touches an enforcement surface (the
  receipts validator with new fail-closed rules), so at least one negative control
  per new fail-closed rule is mandatory — satisfied by `unknown_method`,
  `undefined_lens`, and `receipt_schema_drift`.
- **Rollback posture:** manual (per registry). See `architecture/rollback-plan.md`.

## Downstream Dependency Handoff

The phase-3 child `architectural-review-suite-integration` depends on this child
at the `verification` gate: when it records the selected method id in review
workflow run evidence, that evidence conforms to `architectural-review-report-v2`
/ `architectural-review-routing-decision-v2`. This child ships stable v2 schemas
and the receipts-validator v2 awareness that phase-3 binds to; it does not itself
wire the schemas into workflow contracts.
