# Governed Lifecycle Terminology

This proposal packet evaluates and implements a terminology refactor for the
current governed lifecycle system.

The proposal retires "Lifecycle Autopilot" where it names the current product
capability because that name can imply autonomous authority. The replacement
capability name is "Governed Lifecycle Orchestration".

The implementation must keep these technical nouns stable:

- Product capability: `Governed Lifecycle Orchestration`
- Runtime orchestration component: `Lifecycle Runner`
- Route execution component: `Lifecycle Executor Adapter`
- Contract primitive: `Lifecycle Phase-Loop Model`
- Behavioral/state-machine concept: `Governed Lifecycle Control Loop`

The behavioral term is prose-only. It must not become a component, file name,
schema name, route name, lifecycle id, or contract primitive.

Generated projections, proposal-local receipts, chat context, CI, GitHub state,
tool state, and model memory remain non-authoritative unless converted into
durable governed evidence through the lifecycle.
