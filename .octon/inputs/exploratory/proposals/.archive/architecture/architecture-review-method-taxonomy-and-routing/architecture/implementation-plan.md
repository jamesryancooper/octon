# Implementation Plan

Atomic implementation. The naming v2 refactor, routing v2 refactor, README and
Balanced cross-reference edits, validator updates, and fixtures land together;
there is no intermediate live state where a half-declared method layer is
routable.

## Preconditions

- This child has advanced through review to an implementation-authorized state
  (accepted status + accepted proposal-review receipt authorizing the executable
  implementation prompt + strict Pre-Integration Architecture Review receipt).
  At draft creation these receipts do not yet exist; they are produced by the
  later lifecycle routes.
- The upstream dependency `architecture-lens-bank-foundation` (phase-0) has
  passed its `verification` gate, so `lens-bank.yml` `suite_methods` and
  `method_profiles` are verified and stable.
- Write scope is limited to the registry-declared scopes:
  `.octon/framework/cognition/practices/methodology/architectural-review/` and
  `.octon/framework/assurance/runtime/_ops/scripts/` (plus the assurance test
  fixture tree for fixtures).

## Steps

1. **Confirm the slug decision against the live lens bank.** Re-read
   `lens-bank.yml` `suite_methods`; confirm the six canonical slugs in
   `architecture/slug-reconciliation-decision.md` still match. If phase-0 changed
   them, reconcile before proceeding (repository wins).
2. **Refactor `naming.yml` to v2.** Bump `schema_version` to
   `architectural-review-naming-v2` and add the `methods` block (default +
   six-entry catalog) per `resources/naming-routing-authoring-spec.md`. Preserve
   every existing key verbatim. Rename no slug; retire no alias.
3. **Refactor `review-routing.yml` to v2.** Bump `schema_version` to
   `architectural-review-routing-v2`, add the `method_selection` block
   (`default_method`, `allowed_methods_by_route`, `escalation_map`,
   `constitutional_conflict_routes_to`), and append `unknown_method` and
   `missing_method_record` to `fail_closed_conditions`. Preserve existing routes
   and conditions verbatim.
4. **Extend the mechanism README.** Append the six method rows and a short
   "Methods And Selection" note plus reference links to the canonical-names
   section. Leave existing rows unchanged.
5. **Add Balanced cross-references (only).** Add a short "See also" / "Related"
   navigation block to `balanced-architecture-review-method.md` pointing to the
   method taxonomy, the lens bank, and the escalation map. Confirm no doctrine
   text (Required Sequence, Octon Fit Gates, Output Contract) changed.
6. **Extend the naming validator.** Add checks for `schema_version` v2,
   `methods.default == balanced-architecture-review-method`, presence of all six
   catalog slugs, and NC-A (every method slug ∈ `lens-bank.yml` `suite_methods`).
   Retain all existing assertions (no-regression guard).
7. **Extend the routing validator.** Add checks for `schema_version` v2,
   `method_selection.default_method`, that every method referenced in
   `allowed_methods_by_route`/`escalation_map` is a declared naming method
   (NC-B, `unknown_method`), and that `fail_closed_conditions` contains both new
   conditions (NC-C, `missing_method_record`). Retain all existing assertions.
8. **Author fixtures.** Add a passing fixture and three negative-control fixtures
   (`fail-unknown-method`, `fail-method-without-profile`,
   `fail-missing-method-record`) under the assurance test tree beside the sibling
   architectural-review fixtures.
9. **Run validators.** Run the extended naming and routing validators (positive
   + all negative controls), re-run the phase-0 lens-reference validator to
   confirm the lens bank still passes with the now-canonical slugs, and re-run
   the remaining `validate-architectural-review-*.sh` suite to confirm no
   regression. Retain runs as evidence.
10. **Refresh projections only via canonical scripts.** If any generated
    projection indexes naming/routing, refresh it only through the canonical
    publication script; never hand-edit generated output.

## Per-Child Validation Floor (child-packet-contract obligation 4)

- **Acceptance criteria:** `architecture/acceptance-criteria.md`.
- **Required evidence:** naming + routing validator runs (positive + three
  negative controls), lens-bank binding proof, no-regression proof for existing
  routes/aliases/gate, and a `git diff` proof that the Balanced doctrine text is
  unchanged.
- **Required validator depth:** this child touches an enforcement surface
  (naming and routing validators), so at least one negative control per new
  fail-closed rule is mandatory — satisfied by NC-A (`method without profile`),
  NC-B (`unknown_method`), and NC-C (`missing_method_record`).
- **Rollback posture:** manual (per registry). See
  `architecture/rollback-plan.md`.

## Downstream Dependency Handoff

The phase-2 children
(`greenfield-reference-architecture-review-method`,
`companion-architecture-review-methods`,
`architectural-review-schema-extensions`) depend on this child at the
`verification` gate. Their method docs and schema fields must use the canonical
method slugs fixed here; the schema-extensions child completes the
`missing_method_record` enforcement at the report/routing-decision schema level.
This child ships stable canonical slugs, method-selection routing, and
fail-closed conditions those children bind to.
