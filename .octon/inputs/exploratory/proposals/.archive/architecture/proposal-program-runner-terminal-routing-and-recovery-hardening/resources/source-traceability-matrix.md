# Source Traceability Matrix

| Requirement | Owner |
|---|---|
| Verify remaining postmortem gaps against current runner evidence | `proposal-program-runner-terminal-gap-map` |
| Retry archive/promote workflow routes without duplicate canonical workflow run ids | `proposal-program-runner-workflow-retry-ids` |
| Resume existing workflow run only with same-input, same-authority, same-target, replay-safe proof | `proposal-program-runner-workflow-retry-ids` |
| Declare non-authorizing Change/worktree handoff checkpoints without moving cleanup or Git authority into runner | `proposal-program-runner-change-handoff-checkpoints` |
| Keep `closeout-change` operator/route owned while allowing controller to request evidence-backed handoff | `proposal-program-runner-change-handoff-checkpoints` |
| Own aggregate child terminal blocker ledger in parent controller evidence | `proposal-program-runner-aggregate-terminal-blockers` |
| Keep child receipts, archive metadata, validation verdicts, and terminal outcomes child-owned | Parent and every child |
| Bind promotion evidence to selected child identity and receipt lineage | `proposal-program-runner-promotion-evidence-binding` |
| Classify generated-state freshness before workflow dispatch and route to canonical recovery guidance | `proposal-program-runner-publication-freshness-preflight` |
| Suppress parent review churn from volatile run-control or route-created evidence | `proposal-program-runner-parent-review-churn` |
| Observe archive terminal state after active-path moves or emit blocked archive receipt | `proposal-program-runner-archive-observation-recovery` |
| Cover duplicate workflow id, freshness drift, handoff checkpoints, aggregate blockers, promotion binding, review churn, archive observation, replay, and fail-closed boundaries with tests | `proposal-program-runner-terminal-routing-tests` |
| Preserve no-new-status, generated non-authority, workflow-owned promotion/archive, cleanup ownership, publication ownership, and parent/child authority boundaries | Parent and every child |
