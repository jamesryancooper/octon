# Current-State Gap Map

Live repository state at packet creation (`2026-07-10`). Every claim below is
re-grounded against the live repository, not the parent program design docs.
Where the live tree already carries the suite dependencies, that is noted so
implementation does not re-do landed work.

## Landed Dependencies (consumed, not changed here)

| Surface | Live state | Owning child |
| --- | --- | --- |
| `methodology/architectural-review/naming.yml` | `architectural-review-naming-v2`; `methods` catalog of six methods, Balanced default | taxonomy-and-routing |
| `methodology/architectural-review/review-routing.yml` | `architectural-review-routing-v2`; `method_selection` (default method, allowed-methods-by-route, escalation map), fail-closed `unknown_method` / `missing_method_record` | taxonomy-and-routing |
| `methodology/architectural-review/lens-bank.yml` + `architecture-lens-bank.md` | present; 18 tiered lenses, per-method profiles | lens-bank-foundation |
| Five companion method docs + `greenfield-reference-architecture-review-method.md` | present | companion-methods; greenfield-method |
| `constitution/contracts/assurance/architectural-review-report-v2.schema.json` | present; adds `method`, `lenses_applied` | schema-extensions |
| `constitution/contracts/assurance/architectural-review-routing-decision-v2.schema.json` | present; adds `method`, `lenses_applied` | schema-extensions |
| `constitution/contracts/assurance/architectural-review-support-receipt-v1.schema.json` | unchanged, v1, method-free (drift guard enforced) | schema-extensions (kept unchanged) |
| `validate-architectural-review-lens-references.sh` | present | lens-bank-foundation |

These are hard, verification-gated dependencies. Implementation here begins
only after each has passed its own verification gate.

## Gaps This Child Closes

### G-01 — Review workflow contracts do not record the selected method

- **Where:** `orchestration/runtime/workflows/audit/{pre-integration,post-integration,current-state-mechanism}-architecture-review/workflow.yml`
  (schema `workflow-contract-v2`; stages configure → review → receipt) and
  `architecture-readiness-audit/workflow.yml`.
- **Current:** stages emit a support receipt (`support-receipt.yml`, v1) into
  `.../architectural-review/<mode>/`. No stage records which method the run
  used. `method_selection` in routing v2 therefore has no evidence expression.
- **Target:** the review stage emits the v2 routing-decision/report artifact
  carrying `method` + `lenses_applied` into the same existing run-evidence
  root; the support receipt stays v1 and method-free.

### G-02 — Product feature note predates the method layer

- **Where:** `product/features/architectural-review-mechanism.md`
  (Boundary / Main Surfaces / Validation).
- **Current:** describes the pre-suite mechanism; no method catalog, lens
  bank, v2 schemas, or method advisory.
- **Target:** a navigation-only method-layer section plus the per-occasion
  advisory mapping; authorizes nothing.

### G-03 — Governed cross-surface mechanism record predates the method layer

- **Where:** `cognition/_meta/architecture/governed-cross-surface-mechanisms/mechanisms/architectural-review-mechanism.md`
  and `index.yml`.
- **Current:** entry lists v1 schemas and eight validators; `index.yml` refs
  omit the v2 schemas, `lens-bank.yml`, the method catalog, and the
  lens-references validator.
- **Target:** entry and index reference the v2 schemas, the lens bank, the
  method catalog, `method_selection`, and `validate-architectural-review-lens-references.sh`,
  and document the method-selection mechanics (navigation only).

### G-04 — No per-occasion method advisory

- **Where:** feature note, mechanism entry, and workflow configure stages
  (in-scope); lifecycle prompts consult by reference.
- **Current:** operators and lifecycle prompts have no guidance on which method
  fits which occasion; Balanced-as-default is implicit in `naming.yml` only.
- **Target:** explicit advisory text — Balanced default; companion methods on
  named escalation conditions — with gates unchanged. (See the write-scope
  open item in `implementation-plan.md` regarding prompt-source edits.)

### G-05 — Workflows validator does not assert method recording

- **Where:** `assurance/runtime/_ops/scripts/validate-architectural-review-workflows.sh`.
- **Current:** checks workflow-dir presence, `workflow-contract-v2`,
  name/registry binding, and legacy-route absence; no method-recording check.
- **Target:** extended to assert each review-occasion workflow records the
  selected method id in run evidence and that the support receipt remains
  method-free, with a negative-control fixture for a missing method record.

### G-06 — Affected generated projections not refreshed against the suite

- **Where:** `.octon/generated/proposals/registry.yml`, the proposal artifact
  index, `.octon/generated/effective/capabilities/routing.effective.yml` /
  route bundle, and the product-feature-catalog drift surface.
- **Current:** no dedicated architectural-review publisher exists; the feature
  catalog (`product/features/catalog.yml`) is not auto-generated. Projections
  do not yet reflect the landed suite or this integration.
- **Target:** the affected projections are enumerated and refreshed only
  through their canonical publishers (`generate-proposal-registry.sh`,
  `generate-proposal-artifact-index.sh`, the route-bundle/effective-routing
  publisher), with retained evidence of each refresh run; the feature-catalog
  drift validator passes.

## Explicitly Not a Gap (verified unchanged)

- Support receipt schema and pre-integration gate semantics — unchanged by
  design.
- Method docs, lens bank, naming, routing, v2 schemas — landed dependencies,
  not edited here.
- Architecture-readiness and surface-architecture audit doctrine — untouched.
- Command/skill facades — conditional phase-3 sibling, out of scope.
