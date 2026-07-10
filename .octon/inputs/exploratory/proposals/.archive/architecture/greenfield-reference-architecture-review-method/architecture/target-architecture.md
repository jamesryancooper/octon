# Target Architecture

## Target State

After this child is implemented, the Architectural Review Mechanism directory
`.octon/framework/cognition/practices/methodology/architectural-review/` carries
an authored Greenfield method doc and two additive navigation edits. The
directory keeps every existing file; one file is added and two are changed
additively:

- **New:** `greenfield-reference-architecture-review-method.md` — the method
  output contract, authored per `architecture/method-doc-authoring-spec.md`. It
  contains the method question, use cases, required inputs, non-goals, the five
  required output sections, initial-build sequencing, minimum viable
  architecture, the what-not-to-build-yet list, the clean-sheet complementarity
  statement, escalation rules, the lens-profile reference bound to
  `lens-bank.yml`, and the reference-architecture-only output boundary stated
  fail-closed.
- **Additive:** `naming.yml` — the existing `methods.catalog` greenfield entry
  gains a `doc: "greenfield-reference-architecture-review-method.md"` field
  (matching Balanced's entry). No slug, no schema version, and no other entry
  changes.
- **Additive:** `README.md` — the References section gains a link to the new
  Greenfield method doc. No canonical-names table row changes (phase-1 already
  added the method rows); existing content is unchanged.

No file under `.octon/framework/assurance/runtime/_ops/scripts/` changes; this
child ships no enforcement surface. Its validation floor is a doc-consistency
check (see `architecture/validation-plan.md`).

## Invariants

1. **Reference architecture only, fail-closed.** The doc states, as a fail-closed
   output boundary, that Greenfield output is reference architecture — evidence or
   proposal input, never implementation authority, never a lifecycle gate, never a
   what-to-change verdict. The pre-integration support receipt remains the only
   lifecycle-gating review artifact.
2. **Five required sections present.** The doc contains all five required output
   sections named in method-taxonomy.md §2: domain/job model; reference
   architecture; quality/security/ops model; authority/evidence model; evolution
   plan.
3. **Build discipline present.** The doc contains initial-build sequencing, a
   minimum viable architecture, and an explicit what-not-to-build-yet list.
4. **Lens binding.** The doc cites its lenses by id from `lens-bank.yml`
   `method_profiles.greenfield-reference-architecture-review-method` (14 required
   + 3 optional) and defines no private lens catalog. The doc-consistency check
   proves the cited ids match the profile exactly.
5. **Slug consistency.** The doc's declared method slug equals the `naming.yml`
   `methods.catalog` slug and the `lens-bank.yml` `suite_methods` slug
   (`greenfield-reference-architecture-review-method`).
6. **Distinctness.** The doc states its non-goals and its clean-sheet
   complementarity with Balanced (deliverable vs comparison tool; no
   what-to-change verdict) and does not absorb any companion method's output
   contract.
7. **Additive only, no doctrine change.** Balanced doctrine text, the naming
   methods list, routing `method_selection`, the lens bank, and every validator
   are unchanged except for the additive `naming.yml` `doc:` reference and the
   README references link.
8. **No new authority.** No new mechanism, gate, routed workflow mode, evidence
   root, command facade, or schema. Greenfield outputs grant no authority.

## Boundary With Adjacent Doctrine

Architecture-readiness evaluation and surface-architecture audit doctrine are out
of scope and unchanged; the Greenfield doc references them only as composition
boundaries (Greenfield never issues readiness verdicts; it escalates option
choices to Tradeoff and runtime-critical subsystems to Failure-Mode). Balanced
remains the default method and the method for existing systems; the Greenfield
doc contrasts with Balanced but changes no Balanced doctrine. Constitutional
conflicts continue to route to Constitutional Challenge (existing kernel gate).

## What This Child Deliberately Does Not Build

- The four **companion method docs** (Tradeoff, Failure-Mode, Evolution/Fitness,
  Boundary/Authority) — owned by `companion-architecture-review-methods`
  (phase-2). This child authors only the Greenfield doc.
- The `architectural-review-report-v2` / `routing-decision-v2` **schema** fields
  that record the selected method and applied lenses — owned by
  `architectural-review-schema-extensions` (phase-2).
- Review workflow **method-id recording** in run evidence and any **generated
  projection refresh** — owned by `architectural-review-suite-integration`
  (phase-3).
- Any change to the phase-1 **naming methods list / routing `method_selection`**
  beyond the additive `doc:` reference, or to the phase-0 **lens bank**.
