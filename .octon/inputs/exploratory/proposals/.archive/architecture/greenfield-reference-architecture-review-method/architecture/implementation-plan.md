# Implementation Plan

Atomic implementation. The new method doc and the two additive wiring edits
(`naming.yml` `doc:` reference, README references link) land together; there is
no intermediate live state where the doc exists but is unreachable, or where the
catalog references a doc that does not exist.

## Preconditions

- This child has advanced through review to an implementation-authorized state
  (accepted status + accepted proposal-review receipt authorizing the executable
  implementation prompt + strict Pre-Integration Architecture Review receipt). At
  draft creation these receipts do not yet exist; they are produced by the later
  lifecycle routes.
- The upstream dependency `architecture-review-method-taxonomy-and-routing`
  (phase-1) has passed its `verification` gate, so `naming.yml` `methods.catalog`
  names the greenfield method and `review-routing.yml` `method_selection` routes
  it. Transitively, `architecture-lens-bank-foundation` (phase-0) has passed
  verification, so `lens-bank.yml`
  `method_profiles.greenfield-reference-architecture-review-method` is verified
  and stable.
- Write scope is limited to the registry-declared scope:
  `.octon/framework/cognition/practices/methodology/architectural-review/`.

## Steps

1. **Re-confirm the bindings against the live surfaces.** Re-read `naming.yml`
   `methods.catalog` (greenfield slug + `lens_profile_ref`), `review-routing.yml`
   `method_selection` (allowed methods + escalation map), and `lens-bank.yml`
   `method_profiles.greenfield-reference-architecture-review-method` (14 required
   + 3 optional lens ids). If any slug or lens id has changed since creation,
   reconcile before authoring (repository wins).
2. **Author the method doc.** Create
   `greenfield-reference-architecture-review-method.md` per
   `architecture/method-doc-authoring-spec.md`: question, use cases, non-goals,
   required inputs, lens profile (cited by id from the bank), the five required
   output sections, initial-build sequencing, minimum viable architecture, the
   what-not-to-build-yet list, clean-sheet complementarity with Balanced,
   escalation rules, the reference-architecture-only output boundary stated
   fail-closed, and the Related/navigation block.
3. **Wire the doc into `naming.yml`.** Add
   `doc: "greenfield-reference-architecture-review-method.md"` to the existing
   `methods.catalog` greenfield entry (mirrors Balanced). Change nothing else; do
   not bump `schema_version`; rename no slug; retire no alias.
4. **Add the README references link.** Append a link to the new Greenfield method
   doc in the mechanism README **References** section. Do not touch the
   canonical-names table (the Greenfield row already exists from phase-1).
5. **Run the doc-consistency check.** Confirm the doc's declared slug equals the
   `naming.yml` and `lens-bank.yml` slug, and that every lens id the doc cites
   matches the `lens-bank.yml` greenfield profile (required and optional sets)
   with no extra and no missing id and no private catalog.
6. **Run the no-regression validator sweep.** Run the naming and routing
   validators (to confirm the additive `doc:` field does not break them), the
   phase-0 lens-reference validator, and the remaining
   `validate-architectural-review-*.sh` suite. Confirm all still pass and that
   Balanced doctrine, companion docs, the lens bank, and routing semantics are
   unchanged (`git diff` scoped).
7. **Refresh projections only via canonical scripts.** If any generated
   methodology index references the mechanism directory, it is refreshed only
   through the canonical publication script (owned by the phase-3
   suite-integration child); this child never hand-edits generated output.

## Per-Child Validation Floor (child-packet-contract obligation 4)

- **Acceptance criteria:** `architecture/acceptance-criteria.md`.
- **Required evidence:** the doc-consistency check run (slug + lens-profile
  match), a structural check that all five required sections and the three
  build-discipline subsections are present, the fail-closed output-boundary
  presence check, and the no-regression validator sweep + `git diff` proof.
- **Required validator depth:** this child touches **only methodology docs**, so
  per child-packet-contract obligation 4 its floor is a **doc-consistency check
  against `naming.yml` and `lens-bank.yml`** — not a negative control. It ships no
  enforcement surface, so no new fail-closed rule or fixture is required.
- **Rollback posture:** manual (per registry). See
  `architecture/rollback-plan.md`.

## Upstream / Downstream Handoff

- **Upstream:** consumes the phase-1 naming/routing method layer and the phase-0
  lens bank as verified dependencies; binds to their slugs and lens ids and does
  not modify them beyond the additive `naming.yml` `doc:` reference.
- **Downstream:** `architectural-review-suite-integration` (phase-3) records the
  selected method id in run evidence and refreshes generated projections; it
  binds to this landed method doc (and the companion-methods doc) at its
  `verification` gate. This child ships a stable, catalog-wired output contract
  for that integration to reference.
