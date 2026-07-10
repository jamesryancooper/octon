# File Change Map

All paths are inside this child's registry-declared write scopes. Generated
projections are listed as **derived-only refresh via canonical publisher**, not
as direct writes. Exact stage filenames are confirmed against the live
repository at implementation time.

## Write Scope 1 — `orchestration/runtime/workflows/audit/`

| Path | Change | Note |
| --- | --- | --- |
| `pre-integration-architecture-review/workflow.yml` | extend (minimal) | Review stage emits routing-decision-v2/report-v2 with `method` + `lenses_applied` into existing run-evidence root; receipt stage unchanged |
| `pre-integration-architecture-review/stages/01-configure.md` | extend (minimal) | Record selected method (Balanced default) + per-occasion advisory |
| `pre-integration-architecture-review/stages/02-balanced-review.md` | extend (minimal) | Emit method + lens profile into v2 evidence artifact |
| `post-integration-architecture-review/workflow.yml` + `stages/*` | extend (minimal) | Same method-id recording; no new step/gate/root |
| `current-state-mechanism-architecture-review/workflow.yml` + `stages/*` | extend (minimal) | Same method-id recording |
| `architecture-readiness-audit/workflow.yml` + `stages/*` | extend (minimal) | Record selected method id in run evidence; readiness verdict semantics unchanged |

No new workflow directory, stage, gate, artifact family, or evidence root.

## Write Scope 2 — `product/features/`

| Path | Change | Note |
| --- | --- | --- |
| `architectural-review-mechanism.md` | extend | Navigation-only method-layer section + per-occasion advisory; no authority language |

## Write Scope 3 — `cognition/_meta/architecture/governed-cross-surface-mechanisms/`

| Path | Change | Note |
| --- | --- | --- |
| `mechanisms/architectural-review-mechanism.md` | extend | Reference v2 schemas, lens bank, method catalog, `method_selection`, lens-references validator; document method-selection mechanics (navigation) |
| `index.yml` | extend | Add v2 schema refs, `lens-bank.yml`, method-doc refs, and `validate-architectural-review-lens-references.sh` to the mechanism entry |

## Write Scope 4 — `assurance/runtime/_ops/scripts/`

| Path | Change | Note |
| --- | --- | --- |
| `validate-architectural-review-workflows.sh` | extend | Assert method-id recording per occasion + support-receipt method-freeness; keep existing checks |
| `.octon/framework/assurance/runtime/_ops/fixtures/architectural-review/workflow-method-recording/` | add (new fixtures) | Positive + negative (missing method record) controls, under the assurance test/fixture area permitted for proposal-path-free fixtures |

## Derived-Only Refresh (never a direct write scope)

| Generated projection | Canonical publisher | Note |
| --- | --- | --- |
| `.octon/generated/proposals/registry.yml` | `generate-proposal-registry.sh` | Reflects this packet + suite children |
| Proposal artifact index | `generate-proposal-artifact-index.sh` | Refreshed after landing |
| `.octon/generated/effective/capabilities/routing.effective.yml` / route bundle | route-bundle / effective-routing publisher | Reflects routing v2 method-selection |
| Product-feature-catalog drift surface | `validate-product-feature-catalog.sh` / `validate-feature-catalog-drift-closeout.sh` | Feature catalog is manual, not generated; drift validator confirms coherence |

## Child Evidence Root (promotion target, created at implementation)

| Path | Change | Note |
| --- | --- | --- |
| `.octon/state/evidence/validation/proposals/architectural-review-suite-integration/` | add | Retained validation and projection-refresh receipts |

## Out of Scope (verified, must not be touched here)

- `methodology/architectural-review/**` (naming, routing, lens bank, method
  docs) — owned by phase-0 through phase-2 children.
- `constitution/contracts/assurance/architectural-review-*.schema.json` —
  owned by schema-extensions; support receipt stays v1.
- Readiness and surface-architecture audit doctrine.
- `.claude/commands/**`, `.claude/skills/**` — conditional facades sibling.
- Proposal-lifecycle prompt sources under `.octon/inputs/additive/extensions/**`
  (see the open item in `implementation-plan.md`).
