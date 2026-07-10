# Implementation Plan

Translate the target architecture into implementable workstreams. All work stays
inside the child's registry-declared write scope
`.octon/framework/cognition/practices/methodology/architectural-review/`. No
generated projection is written directly; no schema, validator, workflow, feature
note, or command facade is touched (those belong to other children).

## Preconditions

- Dependency gate: `architecture-review-method-taxonomy-and-routing` reached its
  verification terminal outcome (naming v2 + routing v2 delivered). Confirmed by
  live `naming.yml`/`review-routing.yml` grounding.
- `lens-bank.yml` `method_profiles` for the four companion slugs are complete and
  the lens-reference validator passes (grounding-confirmed).
- No competing in-flight edit to `naming.yml` or `README.md` in the same review
  directory (coordinate at the parent if another phase-2 child is mid-write; the
  contracts-and-assurance and method-docs groups write disjoint directories, so
  no overlap is expected).

## Workstream A — Author The Four Companion Method Docs

For each slug in {`tradeoff-review-method`, `failure-mode-review-method`,
`evolution-fitness-review-method`, `boundary-authority-review-method`}, author
`<slug>.md` using the shared contract shape (see `target-architecture.md`) and the
delivered `greenfield-reference-architecture-review-method.md` as the authored
template. Each doc must:

1. Open with the method question and a one-line non-authority framing that
   foreshadows the fail-closed output boundary.
2. State **Use Cases And Non-Goals**, naming the sibling method or audit that owns
   each excluded job (per method-taxonomy §§3–6).
3. State **Required Inputs**.
4. State the **Lens Profile** as a pointer to `lens-bank.yml`
   `method_profiles.<slug>`, listing the exact required and optional lens ids and
   asserting "no private lens catalog". Lists must match `lens-bank.yml` verbatim.
5. State the **Required Output Sections** — the method's output contract — with
   each output mapped to the lenses that drive it.
6. State **Escalation Rules** citing `review-routing.yml` `method_selection`.
7. State the **Output Boundary (Fail-Closed)**: evidence or proposal input only;
   pre-integration support receipt remains the only lifecycle-gating artifact.
8. Close with a navigation-only **Related** section.

Method-specific requirements:

- **`failure-mode-review-method.md`** must include the boundary statement that the
  Architecture Readiness Audit's mandatory failure-mode analysis
  (`architecture-readiness/framework.md` "## Mandatory Failure-Mode Analysis")
  owns readiness scoring; this method issues no readiness verdict and cites, not
  redefines, that vocabulary.
- **`boundary-authority-review-method.md`** must include the boundary statement
  that the Surface Architecture Audit
  (`.octon/framework/cognition/practices/methodology/audits/surface-architecture.md`,
  "## Authority Model Classification") owns single-unit
  `contract-first`/`mixed`/`markdown-first`/`human-led` classification; this method
  reviews authority placement/containment across a design and escalates
  single-unit follow-ups. It must state it ships **Octon-only** in v1 (generic
  mode deferred).

## Workstream B — Additive Discoverability Wiring

1. In `naming.yml`, add `doc: <slug>.md` to each of the four companion
   `methods.catalog` entries, mirroring the existing Greenfield entry. Change
   nothing else (no slug, role, default, or `lens_profile_ref` edits).
2. In `README.md`, add the four method-doc links to the References section. Leave
   the canonical-names table and Methods-And-Selection prose unchanged.

## Workstream C — Prove Consistency And Retain Evidence

1. Run the doc/registry consistency check (see `validation-plan.md`) proving each
   doc's slug, `lens_profile_ref`, and required/optional lens sets match
   `naming.yml` and `lens-bank.yml`, with no undefined or private lenses and no
   dangling `doc:` pointer.
2. Run the regression validators (`validate-architectural-review-naming.sh`,
   `validate-architectural-review-routing.sh`,
   `validate-architectural-review-lens-references.sh`) to prove no drift.
3. Retain validator output under
   `.octon/state/evidence/validation/proposals/companion-architecture-review-methods/`.

## Sequencing And Reversibility

- Workstream A is independent per doc and can proceed in any order; B depends on A
  (a `doc:` pointer should reference an authored file, though the naming validator
  does not enforce pointer existence). C runs last.
- The change is additive and file-scoped; rollback is deletion of the four new
  docs and reversion of the two additive edits (see `rollback-plan.md`).

## Ownership

- Durable docs and wiring: `cognition-owner` (mechanism owner) via governed
  acceptance and the pre-integration architecture review gate.
- This packet and its evidence pointers: proposal-local, non-authoritative.
