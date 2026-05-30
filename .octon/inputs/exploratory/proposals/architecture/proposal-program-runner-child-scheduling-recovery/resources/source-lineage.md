# Source Lineage

## Authoritative Source

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-lifecycle-improvement.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-traceability-matrix.md`

The source is the user-provided `<lifecycle_improvement>` text read on
2026-05-30. This child packet maps the source to the `child scheduling, concurrency, blockers, and recovery` ownership
slice.

## Mapped Requirements

- R001: Drive full proposal-program lifecycle end to end under --execute-routes while preserving route ownership, handoff, delegation, workflow, recovery, cancellation, replay, checkpoint, lock, phase-loop, disclosure-tier, and authority boundaries.
- R011: --max-steps and --max-child-concurrency semantics must be preserved.
- R035: Schedule runnable children by dependency order and mode; parent maintenance routes must not starve runnable child routes.
- R036: Classify child failures/timeouts/stale or missing evidence, use configured recovery safely, and continue independent children where allowed.

## Out Of Scope

- Durable implementation in this task.
- `--execute-routes` dispatch in this task.
- Generated effective state hand edits.
- Any parent evidence satisfying child receipts.
