# Target Architecture

## Target State

After this child is implemented, the Architectural Review Mechanism directory
`.octon/framework/cognition/practices/methodology/architectural-review/` holds
six files: the existing `README.md`, `balanced-architecture-review-method.md`,
`naming.yml`, `review-routing.yml`, plus two new authored artifacts:

- `architecture-lens-bank.md` — lens doctrine: the 18-lens catalog in two tiers
  (12 core, 6 extended), a human-readable per-method profile table, the
  clean-sheet vs Greenfield complementarity statement, the Balanced
  sequence→lens-id appendix, and the four sprawl controls.
- `lens-bank.yml` — the machine-readable contract: `lenses[]` with `id` + `tier`
  for all 18 lenses, and `method_profiles.<method>` with `required`/`optional`
  lens sets for all six suite methods.

`.octon/framework/assurance/runtime/_ops/scripts/` gains one new validator,
`validate-architectural-review-lens-references.sh`, with fixtures under the
assurance test tree.

## Invariants

1. **One bank, no private catalogs.** `lens-bank.yml` is the only lens catalog
   for the suite. Method docs may reference lens ids but may not define their
   own lens lists.
2. **Methods own questions; lenses are tools.** The bank encodes only lens ids,
   tiers, and per-method required/optional profiles. Questions, scope, routing,
   and output contracts stay in method docs.
3. **Balanced doctrine is unchanged.** Balanced's required lens set equals its
   existing 11-step required sequence expressed as lens ids. The Balanced doc
   text is not edited; a cross-reference appendix in the lens bank doc records
   the mapping.
4. **Fail-closed cross-reference.** The lens-reference validator exits non-zero
   when a method reference cites an undefined lens id or a bank-known method
   lacks a profile. Two negative-control fixtures prove both failure modes.
5. **Additive only.** No new mechanism, lifecycle gate, routed workflow mode,
   evidence root, or command facade. `naming.yml`, `review-routing.yml`, the
   contract schemas, and the review workflows are untouched by this child.
6. **No authority granted to review outputs.** The lens bank is analysis
   tooling. Review outputs remain evidence or proposal input; the
   pre-integration support receipt remains the only lifecycle-gating review
   artifact.
7. **Doc/registry agreement.** `architecture-lens-bank.md` and `lens-bank.yml`
   agree on all 18 lens ids, both tiers, and all six method profiles.

## Boundary With Adjacent Doctrine

Architecture-readiness evaluation and surface-architecture audit doctrine are
out of scope and unchanged. This child composes with them by lens-id reference
only; it neither modifies nor duplicates them. Method-specific concerns
(FMEA mode catalogs, option matrices, fitness-function definitions, etc.) belong
to the later method-doc children, not to this bank.

## What This Child Deliberately Does Not Build

- The `naming.yml` v2 methods-list refactor and canonical companion method slugs
  (owned by `architecture-review-method-taxonomy-and-routing`, phase-1).
- The `review-routing.yml` `method_selection` semantics (phase-1).
- The Greenfield and companion method docs (phase-2).
- The `architectural-review-report-v2` / `routing-decision-v2` schemas (phase-2).
- Review workflow contract method-recording and any generated projection
  refresh (phase-3 integration child).
