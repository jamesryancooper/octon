# Target Architecture

The completed program should leave the proposal-program lifecycle runner as a
bounded orchestrator. It plans from live state and generated effective lifecycle
projections, emits retained handoff evidence, dispatches selected parent routes
or child batches through the shared executor adapter only under
`--execute-routes`, validates route receipts and contract-declared gates,
records checkpoints and events, releases or records locks, and replans.

The runner must not duplicate route, validation, promotion, closeout, cleanup,
publication, registry, disclosure-tier, archive, or run-lifecycle behavior.
Those surfaces remain owned by their existing routes, workflows, validators,
contracts, scripts, or runtime machinery.
