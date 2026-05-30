# Source Lineage

## Authoritative Source

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-lifecycle-improvement.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-traceability-matrix.md`

The source is the user-provided `<lifecycle_improvement>` text read on
2026-05-30. This child packet maps the source to the `generated state, publication, registry refresh, and non-authority boundaries` ownership
slice.

## Mapped Requirements

- R001: Drive full proposal-program lifecycle end to end under --execute-routes while preserving route ownership, handoff, delegation, workflow, recovery, cancellation, replay, checkpoint, lock, phase-loop, disclosure-tier, and authority boundaries.
- R008: Runtime lifecycle discovery uses generated effective projections; authored additive extension sources are edit source and must be republished canonically.
- R016: Scheduler route inventory comes from authored lifecycle contracts and generated effective projections, not skills or prompt bundles.
- R044: Generated state updates start from authored sources and refresh only through canonical publication or registry scripts.
- R045: Use canonical publish-extension-state, publish-capability-routing, publish-host-projections, and generate-proposal-registry scripts when relevant.
- R046: Treat generated projection drift as refreshable only when generated/non-authority and regenerable.

## Out Of Scope

- Durable implementation in this task.
- `--execute-routes` dispatch in this task.
- Generated effective state hand edits.
- Any parent evidence satisfying child receipts.
