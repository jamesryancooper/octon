# Source Of Truth Map

## Durable Authorities After Promotion

- `.octon/framework/cognition/practices/methodology/architectural-review/`
  owns review mode doctrine, routing, naming, and authority boundaries.
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`
  owns governed mechanism documentation and cross-surface coverage.
- `.octon/framework/orchestration/runtime/workflows/**` owns canonical
  workflow execution contracts.
- `.octon/framework/capabilities/runtime/skills/**` and
  `.octon/framework/capabilities/runtime/commands/**` own invocation surfaces.
- `.octon/framework/assurance/runtime/_ops/scripts/**` owns validation gates.
- `.octon/framework/product/features/**` owns navigation-only product feature
  discoverability when a feature entry is used.

## Derived Projections

- `.octon/generated/effective/capabilities/**` is derived-only capability
  projection.
- `.octon/generated/proposals/**` is derived-only proposal projection.
- `.codex/commands/**` and `.codex/skills/**` are host-facing generated
  projections when emitted by canonical publication scripts.

## Retained Evidence

- Workflow run evidence under `.octon/state/evidence/runs/workflows/**`.
- Proposal-local review receipts under `support/**` while the packet is active.
- Validation logs and publication receipts under `.octon/state/evidence/**`.

## Proposal-Local Lifecycle Sources

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`

## Supporting Lineage

- `resources/source-prompt.md`
- `resources/source-findings.md`
- `support/proposal-creation.md`
- `support/proposal-review.md`
- `support/pre-integration-architecture-review.yml`
- `support/executable-implementation-prompt.md`
- `support/implementation-grade-completeness-review.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

## Non-Authority Boundaries

Raw inputs, proposal packets, generated outputs, host projections, dashboards,
chat, model memory, tool availability, extension packetization, product feature
navigation, and lifecycle postmortems cannot authorize review outcomes,
implementation, closeout, support widening, or generated publication.
