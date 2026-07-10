# Architectural Review Suite Integration

_Status: Draft. Phase-3 integration child of the Architecture Review Method
Suite Program. Non-authoritative planning input; not accepted or authorized
for implementation._

## Problem

The Architecture Review Method Suite has landed as methodology and contract
surfaces — a shared lens bank (`architecture-lens-bank.md` + `lens-bank.yml`),
five companion method docs plus Greenfield, naming v2 (`architectural-review-naming-v2`),
routing v2 (`architectural-review-routing-v2`, with a `method_selection`
block and fail-closed `unknown_method` / `missing_method_record`), and the
additive report/routing-decision v2 schemas that carry `method` and
`lenses_applied`. But the **operating surfaces of the mechanism have not
caught up**:

- Existing review workflow contracts do not record which method a review run
  used, so `method_selection` in routing v2 has no evidence expression.
- The product feature note and the governed cross-surface mechanism entry and
  index describe only the pre-suite, single-method mechanism (v1 schemas, no
  lens bank, no method catalog).
- Lifecycle prompts and operators have no advisory that tells them which
  method fits which review occasion.
- Generated projections that reflect the mechanism have not been refreshed
  against the landed suite.

## Target Outcome

The existing Architectural Review Mechanism operates the method layer with no
new authority:

- Each review run records the **selected method id** (and the lens profile
  actually applied) in run evidence through the existing v2 routing-decision
  or report artifact, inside the existing architectural-review run-evidence
  root. The pre-integration **support receipt (v1) is unchanged** and never
  carries `method` — method evidence flows only through routing-decision/report
  v2.
- The product feature note and the governed cross-surface mechanism entry and
  index gain **navigation-only** method-layer descriptions (method catalog,
  lens bank, v2 schemas, method-selection mechanics) and **per-occasion method
  advisory text** (Balanced is the default; companion methods are recommended
  on named escalation conditions).
- **Affected generated projections are refreshed only through canonical
  publishers**; no generated path is a direct write target.
- The **full architectural-review validator suite** (naming, routing,
  receipts, workflows, lifecycle-gates, extension-split, skills-commands,
  lens-references) plus the **proposal and product-feature-catalog
  validators** pass as the closing sweep, with the workflows validator
  extended to assert method-id recording.

## Scope

- Record the selected method id in run evidence for the four architectural
  review occasions (pre-integration, post-integration, current-state-mechanism,
  architecture-readiness-audit) using the existing v2 routing-decision/report
  artifacts. No new stage, no new gate, no new evidence root.
- Extend the product feature note with a navigation-only method-layer section
  and the per-occasion advisory mapping.
- Extend the governed cross-surface mechanism entry (`mechanisms/architectural-review-mechanism.md`)
  and `index.yml` to reference the v2 schemas, the lens bank, the method
  catalog, the lens-references validator, and the method-selection mechanics.
- Extend `validate-architectural-review-workflows.sh` (and its fixtures) to
  assert that each review-occasion workflow records the selected method id and
  that the support receipt remains method-free.
- Enumerate the affected generated projections and refresh them only through
  the canonical publishers, retaining evidence of the refresh run.

## Non-Goals

- No new mechanism, routed workflow mode, lifecycle gate, evidence root, or
  command/skill facade (facades are the conditional phase-3 sibling).
- No change to the support receipt schema or the pre-integration gate
  semantics; the support receipt remains the only lifecycle-gating review
  artifact and remains v1.
- No authoring or editing of method docs, the lens bank, naming, routing, or
  the v2 schemas — those are owned by the phase-0 through phase-2 children and
  are consumed here as landed dependencies.
- No modification of architecture-readiness or surface-architecture audit
  doctrine; those are cited and composed with, never changed.
- No edits to proposal-lifecycle prompt sources; the advisory is authored in
  in-scope surfaces that prompts consult by reference (see the open item in
  `architecture/implementation-plan.md`).
- No direct writes to `.octon/generated/**`; projections are derived-only.

## Dependencies

Hard verification-gated dependencies (all landed in the working tree at
creation time; each must pass its own verification gate before this child's
implementation begins):

- `greenfield-reference-architecture-review-method`
- `companion-architecture-review-methods`
- `architectural-review-schema-extensions`

Parent coordination: `architecture-review-method-suite-program`
(`resources/child-packet-index.yml`, `architecture/packet-sequence.md`,
`architecture/child-packet-contract.md`).

## Authority Boundary

This packet remains non-authoritative input. Durable authority can arise only
from separately reviewed implementation in the declared promotion targets.
Parent program evidence never satisfies this child's creation, review,
implementation, verification, or closeout receipts. Generated projections, run
evidence, raw inputs, and parent-program design docs are not authority. Where a
program design doc disagrees with the live repository, the repository wins and
this child triggers a program registry/design revision rather than
implementing a stale claim.
