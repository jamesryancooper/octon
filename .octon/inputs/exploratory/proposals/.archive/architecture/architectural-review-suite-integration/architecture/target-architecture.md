# Target Architecture

## Boundary

This child owns the **integration seam** between the landed Architecture
Review Method Suite (methodology docs, lens bank, naming v2, routing v2, v2
schemas) and the **operating surfaces** of the existing Architectural Review
Mechanism: the review workflow contracts, the product feature note, the
governed cross-surface mechanism entry and index, one assurance validator, and
the derived-only generated projections.

It does **not** own the method docs, lens bank, naming, routing, or schemas
(phase-0 through phase-2 children own those), the pre-integration support
receipt (schema-extensions child kept it v1 by design), readiness or
surface-audit doctrine (unchanged), or command/skill facades (conditional
sibling).

## Target State

When this child closes through its own governed lifecycle:

1. **Method-id run evidence.** Each of the four architectural review occasions
   — `pre-integration-architecture-review`, `post-integration-architecture-review`,
   `current-state-mechanism-architecture-review`, and
   `architecture-readiness-audit` — records the selected review method id (and
   the lens profile actually applied) in run evidence through the existing
   `architectural-review-routing-decision-v2` or `architectural-review-report-v2`
   artifact, written inside the existing run-evidence root
   `.octon/state/evidence/runs/workflows/{run_id}/architectural-review/<mode>/`.
   No new stage, gate, evidence root, or artifact family is introduced; the
   support receipt remains v1 and method-free.
2. **Navigation-only feature description.** The product feature note
   `product/features/architectural-review-mechanism.md` describes the method
   layer: the method catalog, the shared lens bank, the v2 report/routing-decision
   schemas, and the per-occasion method advisory. It authorizes nothing.
3. **Governed mechanism record.** The mechanism entry
   `governed-cross-surface-mechanisms/mechanisms/architectural-review-mechanism.md`
   and `index.yml` reference the v2 schemas, `lens-bank.yml`, the method
   catalog in `naming.yml`, the `method_selection` semantics in
   `review-routing.yml`, and the `validate-architectural-review-lens-references.sh`
   validator, so the governed cross-surface record is coherent with the landed
   suite.
4. **Per-occasion method advisory.** Balanced Architecture Review is stated as
   the default for every occasion; companion methods are recommended on the
   named escalation conditions (target does not exist yet → Greenfield; ≥2
   viable designs → Tradeoff; failure behavior in doubt → Failure-Mode;
   long-lived fitness in doubt → Evolution/Fitness; authority placement in
   doubt → Boundary/Authority). The advisory is authored in in-scope surfaces
   (feature note, mechanism entry, workflow configure stages) that lifecycle
   prompts consult by reference. Gates are unchanged.
5. **Derived-only projection refresh.** The generated projections affected by
   the suite (proposal registry, proposal artifact index, effective routing
   bundle, and the product feature catalog drift surface) are refreshed only
   through their canonical publishers, with retained evidence of the refresh
   run.
6. **Green closing validator sweep.** The full architectural-review validator
   suite plus the proposal-standard, architecture-subtype, and
   product-feature-catalog validators pass, with
   `validate-architectural-review-workflows.sh` extended to assert method-id
   recording and receipt method-freeness.

## Invariants (inherited from the program)

- Balanced Architecture Review remains the default method.
- Review outputs remain evidence or proposal input; the pre-integration
  support receipt remains the only lifecycle-gating review artifact and remains
  v1.
- No new mechanism, routed workflow mode, lifecycle gate, evidence root, or
  review-output authority.
- Generated outputs are derived-only and refreshed only through canonical
  publishers.
- The change stays inside this child's registry-declared write scopes;
  touching another child's scope requires a parent registry revision, not
  silent expansion.
- Readiness and surface-architecture audit doctrine are untouched.

## Method-Evidence Data Flow (target)

```text
review occasion (workflow.yml)
  configure stage        -> selects method (default: balanced-architecture-review-method)
  review stage           -> emits architectural-review-report-v2 / routing-decision-v2
                            with method + lenses_applied
                            (bound to naming.yml catalog + lens-bank.yml ids; fail-closed)
  receipt stage          -> emits architectural-review-support-receipt-v1
                            (UNCHANGED; no method field; drift guard NC still fires if present)
run-evidence root        -> existing .../architectural-review/<mode>/ (no new root)
validator                -> validate-architectural-review-workflows.sh asserts method recorded
                            + support receipt method-free
```

## Negative Controls (target behavior to prove)

- A review-occasion workflow that omits the method-id recording fails
  `validate-architectural-review-workflows.sh`.
- A support receipt that carries a `method` or `lenses_applied` field fails the
  existing receipt drift guard (`receipt_schema_drift`) — the integration does
  not weaken it.
- A recorded method id outside `naming.yml`'s method catalog is fail-closed
  (`unknown_method`), and a missing method record is fail-closed
  (`missing_method_record`), per routing v2 — this child does not add or relax
  those conditions.
- No write lands in `.octon/generated/**`; projection changes appear only as
  the output of a canonical publisher run.
- The feature note and mechanism entry additions contain no authority-granting
  language (no new gate, mode, or review-output authority).
