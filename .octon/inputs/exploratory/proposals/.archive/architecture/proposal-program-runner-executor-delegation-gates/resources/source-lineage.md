# Source Lineage

## Authoritative Source

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-lifecycle-improvement.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-traceability-matrix.md`

The source is the user-provided `<lifecycle_improvement>` text read on
2026-05-30. This child packet maps the source to the `executor adapter and delegation proof gates` ownership
slice.

## Mapped Requirements

- R001: Drive full proposal-program lifecycle end to end under --execute-routes while preserving route ownership, handoff, delegation, workflow, recovery, cancellation, replay, checkpoint, lock, phase-loop, disclosure-tier, and authority boundaries.
- R006: Full execution is allowed only with --execute-routes, valid invocation authority, retained delegation proof, route delegation_contract, and any required typed human exception grant.
- R007: Use repo-local launcher when octon is absent or stale.
- R012: Extension and workflow routes both delegate through shared executor adapter; no runner-local workflow shortcuts or route-id special cases.
- R013: Durable routes execute only after proof-gated delegation succeeds and routes satisfy their own delegation_contract.
- R021: promote-proposal and archive-proposal are workflow routes and must remain workflow-owned.
- R030: Typed human exception grants unblock only named route in named program run.
- R041: Use repo-declared or harness-supported shell/toolchain through shared command, validator, or executor boundary and fail closed if unsupported.

## Out Of Scope

- Durable implementation in this task.
- `--execute-routes` dispatch in this task.
- Generated effective state hand edits.
- Any parent evidence satisfying child receipts.
