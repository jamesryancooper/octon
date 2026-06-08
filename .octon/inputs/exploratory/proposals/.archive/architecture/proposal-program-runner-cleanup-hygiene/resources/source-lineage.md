# Source Lineage

## Authoritative Source

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-lifecycle-improvement.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-traceability-matrix.md`

The source is the user-provided `<lifecycle_improvement>` text read on
2026-05-30. This child packet maps the source to the `cleanup, hygiene, residue classification, and predicates` ownership
slice.

## Mapped Requirements

- R001: Drive full proposal-program lifecycle end to end under --execute-routes while preserving route ownership, handoff, delegation, workflow, recovery, cancellation, replay, checkpoint, lock, phase-loop, disclosure-tier, and authority boundaries.
- R022: closeout-program and closeout-packet write closeout evidence only and do not own Git cleanup, repo hygiene deletion, branch cleanup, hosted landing, Change closeout, archive mutation, or generated-state mutation outside route boundary.
- R047: Distinguish implementation hygiene from publication/archive hygiene.
- R048: Cleanup-safe current-run residue routes through repo-hygiene cleanup or canonical helper after dry-run, summary, authorization, and active-work proof.
- R049: Foreign, ambiguous, manual-review, or user-authored residue must not be deleted automatically.
- R050: No-op or blocked-retained cleanup with implementation_blocking false must not block child implementation; closeout/archive blockers are terminal-phase scoped.
- R051: Scheduler evaluates cleanup predicates from explicit route-evaluation context and fails closed on unknown or stale cleanup context.
- R061: Fail closed with receipts and route guidance for authority ambiguity, unsafe cleanup, foreign residue, unsupported modes, exhausted budgets, missing authority-zone evidence, unregenerable stale receipts, unsupported blocker classes, unknown predicates, unsafe resume, lock ambiguity, closeout/archive hygiene blockers, and local-only hosted evidence attempts.

## Out Of Scope

- Durable implementation in this task.
- `--execute-routes` dispatch in this task.
- Generated effective state hand edits.
- Any parent evidence satisfying child receipts.
