# Bound Source Context

This packet was created by the proposal-lifecycle `create-packet` route as the
phase-1 child of the **Architecture Review Method Suite Program**.

- Run: `20260709-arms-program-clean-delivery-04-architecture-review-method-taxonomy-and-routing`
- Program run: `20260709-arms-program-clean-delivery-04`
- Child id: `architecture-review-method-taxonomy-and-routing`
- Bound `source`:
  `.octon/inputs/exploratory/proposals/architecture/architecture-review-method-suite-program/`
- Bound `target`:
  `.octon/inputs/exploratory/proposals/architecture/architecture-review-method-taxonomy-and-routing`

All bound source material is **non-authoritative lineage only**. Every claim is
re-grounded against the live repository at HEAD. Where a program design doc
disagrees with the live mechanism, the live mechanism wins and this child
triggers a parent registry/design revision rather than implementing a stale
claim (child-packet-contract obligation 3). One such divergence is recorded here
and in `architecture/slug-reconciliation-decision.md`.

## Source Lineage Chain

1. Non-authoritative intake unit (raw conversation-derived direction):
   `.octon/inputs/additive/.incoming/architecture-review-method-suite/`
2. Parent program design (direction for this child, not authority):
   - `architecture/method-taxonomy.md` — per-method contracts (the source for
     the six methods this child enumerates)
   - `architecture/target-architecture.md` — naming v2 / routing v2 intent
   - `architecture/child-packet-contract.md` — per-child charter and obligations
   - `resources/child-packet-index.yml` — registry: phase, dependencies, write scopes
3. Live mechanism (epistemic precedence over all of the above):
   `.octon/framework/cognition/practices/methodology/architectural-review/`
   (naming.yml, review-routing.yml, README.md,
   balanced-architecture-review-method.md, and the phase-0 lens-bank.yml)

## Per-Child Charter (verbatim from parent `child-packet-contract.md`)

> `architecture-review-method-taxonomy-and-routing`: refactor `naming.yml`
> to `architectural-review-naming-v2` (methods list, Balanced default; no
> slug renames, no alias retirements), extend `review-routing.yml` to
> `architectural-review-routing-v2` (method_selection block, per-route
> allowed methods, escalation map, fail-closed `unknown_method` and
> `missing_method_record`), extend the mechanism README canonical-names
> table, add minimal cross-references to the Balanced doc, and update
> naming/routing validators with negative controls. Existing routes,
> evidence roots, and the pre-integration gate are untouched.

## Registry Facts (verbatim from parent `resources/child-packet-index.yml`)

- `child_id: architecture-review-method-taxonomy-and-routing`
- `path: .octon/inputs/exploratory/proposals/architecture/architecture-review-method-taxonomy-and-routing`
- `required: true`, `deferred: false`
- `dependencies: [architecture-lens-bank-foundation]`
- `dependency_gate: verification`
- `phase_id: phase-1`, `group_id: suite-foundation`
- `rollback_posture: manual`
- `write_scopes:`
  - `.octon/framework/cognition/practices/methodology/architectural-review/`
  - `.octon/framework/assurance/runtime/_ops/scripts/`
- `dependency_input_note:` Method lens profiles reference lens ids defined by
  `architecture-lens-bank-foundation`; the naming v2 methods list and routing v2
  `method_selection` block must cite the verified lens bank before this child's
  implementation planning.

The immediate upstream is `architecture-lens-bank-foundation` (phase-0), which
seeded `lens-bank.yml` with `suite_methods` slugs (Balanced canonical; five
companions provisional). The immediate downstream consumers are the phase-2
children (`greenfield-reference-architecture-review-method`,
`companion-architecture-review-methods`,
`architectural-review-schema-extensions`).

## Method Taxonomy (verbatim from parent `architecture/method-taxonomy.md`)

The following is preserved verbatim as the primary source direction this child
implements as naming/routing data. It is retained here so the packet is
archive-ready without the parent packet on disk. **Note the slug divergence**
called out in the re-grounding section below: these prose slugs are non-suffixed,
while this child adopts the `-method`-suffixed canonical slugs that already exist
in the live `lens-bank.yml`.

```markdown
# Final Method Taxonomy

The Architecture Review Method Suite is the method layer of the Architectural
Review Mechanism. Routed modes in `review-routing.yml` are review
*occasions*; methods are *how* a review is conducted. Every review run
selects exactly one method; Balanced Architecture Review is the default when
no selection is made. Methods own the question, scope, routing, and output
contract; lenses come from the shared bank (`lens-bank-design.md`).

Common rules for every method:

- Output is retained evidence or proposal input. No method output gains
  lifecycle gate authority; the pre-integration support receipt remains the
  only gating review artifact.
- Every method report records the method slug and the lens profile actually
  applied (schema extension child).
- Constitutional conflicts route to Constitutional Challenge regardless of
  method (existing kernel gate).
- Unknown method selection is fail-closed (`unknown_method`).

## 1. Balanced Architecture Review Method
- Slug: `balanced-architecture-review-method` (unchanged; existing doctrine
  preserved). Default for any architecture change evaluation.
- Escalation: >=2 viable target designs -> Tradeoff; runtime/governance
  failure behavior in doubt -> Failure-Mode; long-lived mechanism health in
  doubt -> Evolution/Fitness; authority location in doubt -> Boundary/Authority;
  target does not exist yet -> Greenfield.

## 2. Greenfield Reference Architecture Review
- Prose slug (source): `greenfield-reference-architecture-review`.
- Question: If this system did not exist, what should we build first?
- Output is reference architecture only; never implementation authority.

## 3. Architecture Tradeoff Review
- Prose slug (source): `architecture-tradeoff-review`.
- Question: Given the candidate designs, which tradeoffs are we accepting, and
  which option should we recommend?

## 4. Failure-Mode Architecture Review
- Prose slug (source): `failure-mode-architecture-review`.
- Question: How does this architecture fail, drift, get bypassed, partially
  execute, lose evidence, confuse operators, or fail to recover?

## 5. Evolution/Fitness Architecture Review
- Prose slug (source): `evolution-fitness-architecture-review`.
- Question: Will this architecture remain healthy as the system changes, and
  how will we know?

## 6. Boundary/Authority Architecture Review
- Prose slug (source): `boundary-authority-architecture-review`.
- Question: Where does authority actually live for this surface, and what must
  never become authority? Octon-specific in v1 (generic mode deferred).

## Composition With Adjacent Doctrine (No Duplication)
- Architecture Readiness Evaluation owns readiness verdicts; the suite never
  issues readiness verdicts.
- Surface Architecture Audit owns single-unit authority-model classification;
  Boundary/Authority Review escalates single-unit follow-ups to it.
- Domain/readiness audit routes are unchanged review occasions; a suite method
  may be selected within them where doctrine permits, recorded in evidence.
```

## Naming v2 / Routing v2 Intent (verbatim from parent `architecture/target-architecture.md`)

> `architecture-review-method-taxonomy-and-routing` → naming v2 (methods
> list, Balanced default) and routing v2 (method-selection semantics,
> fail-closed on unknown method) with validator coverage.

Program-level invariants that constrain this child: Balanced Architecture Review
remains the default method; review outputs remain evidence or proposal input;
the pre-integration support receipt remains the only lifecycle-gating review
artifact; no new mechanism, routed workflow mode, or gate; readiness and
surface-audit doctrine untouched; generated outputs derived-only; children stay
in declared write scopes; parent evidence never substitutes for child evidence.

## Live Re-Grounding Notes (verified at HEAD)

Verified against
`.octon/framework/cognition/practices/methodology/architectural-review/`:

- `naming.yml` is at `schema_version: architectural-review-naming-v1` with a
  single `method` block (Balanced) and eight `canonical_modes`, active
  invocation aliases (`audit-domain-architecture`, `audit-surface-architecture`),
  command facades, and one retired `legacy_aliases` entry
  (`audit-architecture-readiness`). This child adds a `methods` list and bumps
  the schema to v2 **without** renaming any slug or retiring any alias.
- `review-routing.yml` is at `schema_version: architectural-review-routing-v1`
  with `default_route: pre-integration-architecture-review`, nine routes, and a
  `fail_closed_conditions` list. This child adds a `method_selection` block and
  two new fail-closed conditions (`unknown_method`, `missing_method_record`)
  **without** changing any existing route or condition.
- `README.md` canonical-names table lists the mechanism, the Balanced method,
  and eight modes. This child appends method rows and a short method-selection
  note; existing rows are unchanged.
- `balanced-architecture-review-method.md` defines Balanced's Required Sequence,
  Octon Fit Gates, and Output Contract. This child adds only **navigation
  cross-references** (to the method taxonomy and lens bank); no doctrine text is
  changed.
- **Slug divergence (recorded).** The live `lens-bank.yml` (phase-0) already
  declares `suite_methods` with `-method`-suffixed provisional slugs:
  `greenfield-reference-architecture-review-method`, `tradeoff-review-method`,
  `failure-mode-review-method`, `evolution-fitness-review-method`,
  `boundary-authority-review-method`. The parent `method-taxonomy.md` prose used
  non-suffixed slugs (`greenfield-reference-architecture-review`, etc.). Because
  the live lens bank outranks a stale parent design claim, this child adopts the
  `-method`-suffixed slugs as canonical (matching Balanced's own
  `balanced-architecture-review-method` convention), which also lets the phase-0
  lens bank bind with zero change. This divergence is recorded as a program
  design-revision note in `architecture/slug-reconciliation-decision.md`.
