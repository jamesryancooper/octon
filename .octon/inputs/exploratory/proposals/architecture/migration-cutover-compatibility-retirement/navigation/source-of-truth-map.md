# Source Of Truth Map

_Status: Draft child proposal navigation_

## Packet-Local Lifecycle Authority

- `proposal.yml` is the child proposal manifest.
- `architecture-proposal.yml` is the architecture subtype manifest.
- `architecture/target-architecture.md`, `architecture/implementation-plan.md`, and `architecture/acceptance-criteria.md` define the child proposal thesis, planned promotion surface, and acceptance gate.
- `support/implementation-grade-completeness-review.md` records whether this draft is implementation-ready.

## Supporting Navigation And Evidence

- `README.md` summarizes purpose, scope, dependencies, authority boundaries, and promotion targets.
- `navigation/artifact-catalog.md` is generated inventory and is not semantic authority.
- `resources/source-context.md` records non-authoritative source lineage.
- `RISK-REGISTER.md` and `validation-plan.md` are child-local planning surfaces.

## Durable Authority Boundary

If accepted and promoted, durable authority may change only in the promotion targets listed in `proposal.yml`. Until then, existing run lifecycle, execution authorization, context-pack, effect-token, evidence-store, support-target, and fail-closed contracts remain canonical.

## Non-Authority Source Lineage

- `.octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update/resources/octon-determinism-conversation-1.md`
- `.octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update/resources/octon-determinism-conversation-2.md`

These source materials, this child packet, generated projections, MCP/tool availability, Durable Object state, external workflow engines, and agent output do not become authority by reference.
