# Source Lineage

## Authoritative Source

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-lifecycle-improvement.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-traceability-matrix.md`

The source is the user-provided `<lifecycle_improvement>` text read on
2026-05-30. This child packet maps the source to the `planning, handoff, route selection, and replan loop` ownership
slice.

## Mapped Requirements

- R001: Drive full proposal-program lifecycle end to end under --execute-routes while preserving route ownership, handoff, delegation, workflow, recovery, cancellation, replay, checkpoint, lock, phase-loop, disclosure-tier, and authority boundaries.
- R004: Runner remains an orchestrator that plans from live state, selects parent route or child batch, emits handoff evidence, delegates through adapter, validates receipts/gates, checkpoints, and replans.
- R005: Default lifecycle run remains handoff-only and stops after planned program-route-handoff.
- R010: Program lifecycle is an orchestrated replan loop; packet lifecycle remains phase-loop.
- R016: Scheduler route inventory comes from authored lifecycle contracts and generated effective projections, not skills or prompt bundles.
- R018: Do not introduce new proposal manifest statuses; runtime states remain runtime/result states or receipts.
- R032: Program and child creation use create-program/create-packet or governed intake/admission with valid bindings; missing or unsupported inputs fail closed.
- R033: Review and revision run through existing routes, revise only blocking findings, repeat within budgets, and fail closed on exhaustion.
- R034: Prompt generation delegates child implementation prompts and parent orchestration prompt only when contract-eligible and gates pass.

## Out Of Scope

- Durable implementation in this task.
- `--execute-routes` dispatch in this task.
- Generated effective state hand edits.
- Any parent evidence satisfying child receipts.
