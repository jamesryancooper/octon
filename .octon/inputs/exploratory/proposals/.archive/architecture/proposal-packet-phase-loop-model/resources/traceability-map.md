# Traceability Map

| Source Requirement | Packet Coverage | Later Implementation Action | Validation Or Closure Proof |
| --- | --- | --- | --- |
| Current-state summary of proposal lifecycle and Lifecycle Autopilot | `README.md`, `resources/repository-grounding-summary.md`, `architecture/current-state-gap-map.md` | None for proposal creation; later docs align if accepted. | Proposal review verifies current-state claims against source files. |
| Target Proposal Packet phase-loop model | `architecture/target-architecture.md` | Add phase-loop declarations and runtime interpretation. | Contract, runner, replay, and acceptance tests pass. |
| Placement decision | `architecture-proposal.yml`, `README.md`, `architecture/target-architecture.md` | Implement layered/both model. | Review confirms substrate and extension boundaries. |
| Generic substrate responsibilities | `architecture/target-architecture.md`, `architecture/implementation-plan.md` | Update schema, runner, checkpoints, events, validators. | Lifecycle runner and contract tests pass. |
| Proposal-extension responsibilities | `architecture/target-architecture.md`, `architecture/implementation-plan.md` | Update extension contract, docs, skills, prompts, validation scenarios. | Extension route-resolution and proposal lifecycle tests pass. |
| Runner/executor boundary | `architecture/target-architecture.md`, `resources/repository-grounding-summary.md` | Preserve runner planning and executor invocation split. | Executor adapter tests prove no self-authorization. |
| Contract, schema, receipt, gate, checkpoint, event-log, validator impact | `architecture/implementation-plan.md`, `architecture/file-change-map.md` | Update source targets in one accepted change set. | Schema, contract, runner, and validator receipts. |
| File-by-file impact map | `architecture/file-change-map.md` | Use impact map as implementation scope. | Implementation conformance receipt covers each target. |
| Tests and acceptance scenarios | `architecture/validation-plan.md` | Add positive and negative tests. | Acceptance tests pass with retained evidence. |
| Migration or clean-break cutover | `architecture/cutover-checklist.md` | Execute atomic clean-break cutover after review acceptance. | Publication and generated freshness receipts retained. |
| Explicit non-changes | `resources/non-changes.md`, `proposal.yml` | Preserve constraints in implementation. | Boundary scans and review gate deny violations. |
| Risks and fail-closed behavior | `resources/risk-register.md` | Implement blocker classes and denial behavior. | Negative-control tests pass. |
| Later implementation sequencing | `architecture/implementation-plan.md` | Generate implementation prompt only after acceptance. | Strict proposal review gate passes before prompt generation. |
| Implementation-grade acceptance criteria | `architecture/acceptance-criteria.md`, `support/implementation-grade-completeness-review.md` | Review this packet against criteria before acceptance. | Implementation-grade completeness receipt remains pass. |
| `PPPLM-REV-001` phase set incomplete | `architecture/target-architecture.md` | Implement full phase set as contract/checkpoint/event phases. | Later review verifies all architecture-review phases are represented without new statuses. |
| `PPPLM-REV-002` v2 `phase_loop` missing | `architecture/target-architecture.md`, `architecture/implementation-plan.md` | Add `octon-extension-lifecycle-contract-v2` and `phase_loop.model_version: phase-loop-v1`. | Contract validator and schema tests pass. |
| `PPPLM-REV-003` checkpoint/event fields missing | `architecture/target-architecture.md`, `architecture/implementation-plan.md`, `architecture/acceptance-criteria.md` | Add checkpoint phase fields and phase-scoped event fields/types. | Runner, event schema, replay, and resume tests pass. |
| `PPPLM-REV-004` validator matrix incomplete | `architecture/validation-plan.md` | Add positive and negative phase-loop fixtures. | Validator tests cover dangling refs, finite bounds, terminal phase dispatch denial, status expansion denial, generated authority denial, and cancellation/resume phase preservation. |
| `PPPLM-REV-005` completeness receipt stale | `support/implementation-grade-completeness-review.md` | Update readiness receipt after revision. | Next review can compare revised packet without stale readiness mismatch. |
| `PPPLM-REV-006` optional executor schemas and host projections missing | `proposal.yml`, `architecture-proposal.yml`, `architecture/file-change-map.md` | Add request/result schemas as optional context targets and host projection handling as derived refresh. | Later implementation conformance checks target coverage and host projection refresh boundary. |
