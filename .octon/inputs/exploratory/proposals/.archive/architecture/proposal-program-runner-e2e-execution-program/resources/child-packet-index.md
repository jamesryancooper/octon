# Child Packet Index

All child packets are required, archived sibling proposal packets. Parent evidence coordinates only and never satisfies child receipts.

Dependent child packets use the contract-valid `verification` dependency gate:
downstream work waits for dependency implementation, conformance, and drift
verification evidence, while child closeout/archive remains owned by the child
lifecycle and parent closeout policy.

| Order | Child | Focus | Dependencies |
| --- | --- | --- | --- |
| 1 | `proposal-program-runner-current-state-gap-map` | current-state audit and gap map | none |
| 2 | `proposal-program-runner-planning-replan-loop` | planning, handoff, route selection, and replan loop | proposal-program-runner-current-state-gap-map |
| 3 | `proposal-program-runner-executor-delegation-gates` | executor adapter and delegation proof gates | proposal-program-runner-current-state-gap-map, proposal-program-runner-planning-replan-loop |
| 4 | `proposal-program-runner-evidence-run-control` | evidence tiers, checkpoints, replay, cancellation, resume, and locks | proposal-program-runner-current-state-gap-map, proposal-program-runner-planning-replan-loop |
| 5 | `proposal-program-runner-child-scheduling-recovery` | child scheduling, concurrency, blockers, and recovery | proposal-program-runner-planning-replan-loop, proposal-program-runner-executor-delegation-gates, proposal-program-runner-evidence-run-control |
| 6 | `proposal-program-runner-verification-correction-routing` | verification sweep and targeted correction routing | proposal-program-runner-planning-replan-loop, proposal-program-runner-child-scheduling-recovery |
| 7 | `proposal-program-runner-cleanup-hygiene` | cleanup, hygiene, residue classification, and predicates | proposal-program-runner-child-scheduling-recovery, proposal-program-runner-evidence-run-control |
| 8 | `proposal-program-runner-closeout-archive-policy` | closeout and archive policy enforcement | proposal-program-runner-verification-correction-routing, proposal-program-runner-cleanup-hygiene, proposal-program-runner-evidence-run-control |
| 9 | `proposal-program-runner-generated-state-publication` | generated state, publication, registry refresh, and non-authority boundaries | proposal-program-runner-current-state-gap-map, proposal-program-runner-planning-replan-loop |
| 10 | `proposal-program-runner-tests-fixtures` | tests, fixtures, negative controls, and validation coverage | proposal-program-runner-planning-replan-loop, proposal-program-runner-executor-delegation-gates, proposal-program-runner-evidence-run-control, proposal-program-runner-child-scheduling-recovery, proposal-program-runner-verification-correction-routing, proposal-program-runner-cleanup-hygiene, proposal-program-runner-closeout-archive-policy, proposal-program-runner-generated-state-publication |
