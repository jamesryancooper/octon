# Source Lineage

## Authoritative Source

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-lifecycle-improvement.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-traceability-matrix.md`

The source is the user-provided `<lifecycle_improvement>` text read on
2026-05-30. This child packet maps the source to the `evidence tiers, checkpoints, replay, cancellation, resume, and locks` ownership
slice.

## Mapped Requirements

- R001: Drive full proposal-program lifecycle end to end under --execute-routes while preserving route ownership, handoff, delegation, workflow, recovery, cancellation, replay, checkpoint, lock, phase-loop, disclosure-tier, and authority boundaries.
- R014: Parent receipts may summarize child outcomes but never satisfy child-owned receipts.
- R027: Program controller evidence explains parent run only and never rewrites child lifecycle authority.
- R028: Evidence disclosure tiers are normative: local raw, retained publishable, disclosure, generated non-authority.
- R029: Raw local evidence promotion requires redacted/summarized publishable receipt with metadata, limitations, redactions, and digest/path refs.
- R030: Typed human exception grants unblock only named route in named program run.
- R031: Cancellation, resume, replay verification, event/checkpoint convergence, and lock release preserve run lifecycle invariants.
- R057: Cancelled program run must not dispatch selected parent or child routes after cancellation observed.
- R058: Resume reconstructs from canonical run evidence, checkpoints, and live proposal state; unsafe resume conditions fail closed.
- R059: Every lock is released or explicitly recorded stale/unsafe on all exit paths.
- R061: Fail closed with receipts and route guidance for authority ambiguity, unsafe cleanup, foreign residue, unsupported modes, exhausted budgets, missing authority-zone evidence, unregenerable stale receipts, unsupported blocker classes, unknown predicates, unsafe resume, lock ambiguity, closeout/archive hygiene blockers, and local-only hosted evidence attempts.

## Out Of Scope

- Durable implementation in this task.
- `--execute-routes` dispatch in this task.
- Generated effective state hand edits.
- Any parent evidence satisfying child receipts.
