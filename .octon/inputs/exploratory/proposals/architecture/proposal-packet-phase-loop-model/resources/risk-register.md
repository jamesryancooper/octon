# Risk Register

| Risk ID | Risk | Failure Mode | Required Fail-Closed Behavior | Mitigation |
| --- | --- | --- | --- | --- |
| `RISK-001` | Phase ids are mistaken for proposal statuses. | Operators or code add status values outside the proposal manifest contract. | Deny validation and preserve existing status set. | Schema and tests prohibit status widening. |
| `RISK-002` | Generic substrate absorbs proposal semantics. | Runner decides review verdicts or archive meaning. | Block route execution on authority-boundary ambiguity. | Keep route semantics in extension contract. |
| `RISK-003` | Self-operating becomes self-authorizing. | Executor dispatches durable mutation without accepted review or approval evidence. | Authorization proof fails before dispatch. | Strict review gate and delegation proof tests. |
| `RISK-004` | Generated projection becomes authority. | Runtime or docs rely on generated effective files as source truth. | Deny generated authority path and require source plus publication receipt. | Generated authority negative controls. |
| `RISK-005` | Proposal-local receipts overclaim authority. | Packet support receipt is used to prove durable implementation or closeout. | Deny promotion, closeout, or archive route. | Receipt class checks and operator disclosure. |
| `RISK-006` | Loop bounds are ambiguous. | Review or correction loops run indefinitely or consume no budget incorrectly. | Stop as blocked max iterations or blocked max steps. | Explicit loop counters in checkpoint and events. |
| `RISK-007` | Resume corrupts state. | Checkpoint, event log, target, or receipt digest disagree. | Stop as blocked unsafe or blocked recoverable with preserved evidence. | Replay and checkpoint convergence validation. |
| `RISK-008` | Clean-break cutover leaves dual semantics. | Old route progression and new phase-loop semantics both appear live. | Acceptance fails until old semantics are removed or explicitly retained with owner and retirement trigger. | Atomic cutover and post-implementation drift review. |
| `RISK-009` | Change closeout semantics are duplicated or weakened. | Proposal phase-loop becomes a competing closeout workflow. | Deny conflicting route authority. | Align vocabulary while preserving default work-unit ownership. |
| `RISK-010` | Tests only mirror implementation. | Validators pass text shape without proving behavior. | Treat evidence as insufficient and block implementation-grade closeout. | Require behavior, boundary, replay, and negative-control tests. |
