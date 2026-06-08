# Source Lineage

## Authoritative Source

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-lifecycle-improvement.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-traceability-matrix.md`

The source is the user-provided `<lifecycle_improvement>` text read on
2026-05-30. This child packet maps the source to the `tests, fixtures, negative controls, and validation coverage` ownership
slice.

## Mapped Requirements

- R001: Drive full proposal-program lifecycle end to end under --execute-routes while preserving route ownership, handoff, delegation, workflow, recovery, cancellation, replay, checkpoint, lock, phase-loop, disclosure-tier, and authority boundaries.
- R003: Preserve existing owned behavior and add tests instead of reimplementing behavior already owned elsewhere.
- R005: Default lifecycle run remains handoff-only and stops after planned program-route-handoff.
- R007: Use repo-local launcher when octon is absent or stale.
- R009: Preserve authored packet and program lifecycle contract paths and treat packet phase ids as lifecycle context only.
- R016: Scheduler route inventory comes from authored lifecycle contracts and generated effective projections, not skills or prompt bundles.
- R018: Do not introduce new proposal manifest statuses; runtime states remain runtime/result states or receipts.
- R019: Child run-packet-implementation writes evidence; child promote-proposal owns implemented status transition.
- R024: Archived and rejected child terminal outcomes enforce receipt-level requirements.
- R033: Review and revision run through existing routes, revise only blocking findings, repeat within budgets, and fail closed on exhaustion.
- R060: Edge cases for recoverable blockers, stale receipts, missing prompts, validator failures/timeouts, generated drift, cleanup fingerprints, local evidence refs, raw log publication attempts, implemented-state review mismatch, route-resolution timeout, cancellation, resume, stale locks, replay divergence, active closeout policy variations, and no forced child archival are covered safely.
- R061: Fail closed with receipts and route guidance for authority ambiguity, unsafe cleanup, foreign residue, unsupported modes, exhausted budgets, missing authority-zone evidence, unregenerable stale receipts, unsupported blocker classes, unknown predicates, unsafe resume, lock ambiguity, closeout/archive hygiene blockers, and local-only hosted evidence attempts.
- R062: Acceptance criteria test coverage is mandatory for handoff default, execute delegation, route inventory, phase non-authority, promotion ownership, recovery budgets, verification/correction, hygiene, evidence tiers, generated refresh, timeout, implemented-state gate behavior, cancellation, resume/replay, locks, no-new-status, closeout/archive policy, and blocked receipts.

## Out Of Scope

- Durable implementation in this task.
- `--execute-routes` dispatch in this task.
- Generated effective state hand edits.
- Any parent evidence satisfying child receipts.
