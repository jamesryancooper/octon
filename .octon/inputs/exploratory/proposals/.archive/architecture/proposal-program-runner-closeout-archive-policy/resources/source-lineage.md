# Source Lineage

## Authoritative Source

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-lifecycle-improvement.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-traceability-matrix.md`

The source is the user-provided `<lifecycle_improvement>` text read on
2026-05-30. This child packet maps the source to the `closeout and archive policy enforcement` ownership
slice.

## Mapped Requirements

- R001: Drive full proposal-program lifecycle end to end under --execute-routes while preserving route ownership, handoff, delegation, workflow, recovery, cancellation, replay, checkpoint, lock, phase-loop, disclosure-tier, and authority boundaries.
- R014: Parent receipts may summarize child outcomes but never satisfy child-owned receipts.
- R015: Program routes coordinate child packets but do not own child manifest truth, promotion targets, validation verdicts, archive metadata, or terminal outcomes.
- R019: Child run-packet-implementation writes evidence; child promote-proposal owns implemented status transition.
- R020: Program promote-proposal owns parent implemented status transition after fresh review, orchestration prompt evidence, and passing orchestration run evidence.
- R021: promote-proposal and archive-proposal are workflow routes and must remain workflow-owned.
- R022: closeout-program and closeout-packet write closeout evidence only and do not own Git cleanup, repo hygiene deletion, branch cleanup, hosted landing, Change closeout, archive mutation, or generated-state mutation outside route boundary.
- R023: Program closeout reads active closeout policy; current authored policy requires non-deferred children archived or rejected.
- R024: Archived and rejected child terminal outcomes enforce receipt-level requirements.
- R025: Human-readable closeout prompts do not override enforceable active program.closeout_policy.
- R026: Do not hard-code child archival for policies that accept implemented children, while not loosening current policy.
- R052: After verification/correction, delegate child closeout routes and enforce active policy rather than universal archival.
- R053: If child closeout authorizes archive and active policy requires archived terminal outcomes, delegate child archive workflow before parent terminal closeout.
- R054: Parent closeout and blocked closeout receipts include required fields and route guidance.
- R055: Archive only through workflow-owned archive-proposal after policy, freshness, hygiene, generated refresh, and explicit authorization pass.
- R056: If archive is blocked, preserve evidence and emit machine-readable blocked archive or closeout receipt at route boundary.
- R061: Fail closed with receipts and route guidance for authority ambiguity, unsafe cleanup, foreign residue, unsupported modes, exhausted budgets, missing authority-zone evidence, unregenerable stale receipts, unsupported blocker classes, unknown predicates, unsafe resume, lock ambiguity, closeout/archive hygiene blockers, and local-only hosted evidence attempts.

## Out Of Scope

- Durable implementation in this task.
- `--execute-routes` dispatch in this task.
- Generated effective state hand edits.
- Any parent evidence satisfying child receipts.
