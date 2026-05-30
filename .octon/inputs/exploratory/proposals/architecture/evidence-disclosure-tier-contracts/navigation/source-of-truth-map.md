# Source Of Truth Map

_Status: Accepted child navigation_

## Proposal-Local Lifecycle Sources

- `proposal.yml` is the child proposal manifest.
- `architecture-proposal.yml` is the architecture subtype manifest.
- `architecture/target-architecture.md` defines the child target.
- `architecture/implementation-plan.md` defines implementation workstreams.
- `architecture/acceptance-criteria.md` defines readiness conditions.

## Supporting Sources

- `resources/source-context.md` records source lineage and required review phrases.
- `validation-plan.md` records validation expectations.
- `support/implementation-grade-completeness-review.md` records implementation readiness.
- `support/proposal-review.md` records accepted review and implementation authorization.

## Durable Targets After Promotion

- `.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml`
- `.octon/framework/engine/runtime/spec/evidence-disclosure-tiers-v1.md`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/constitution/obligations/evidence.yml`

## Boundary Rules

This packet is non-authoritative. Durable targets must not depend on proposal
paths after implementation. Generated outputs, raw inputs, local evidence, host
state, chat history, model memory, and tool availability do not become evidence
or authority through this packet.
