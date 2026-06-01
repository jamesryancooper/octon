# File Change Map

This map explains the manifest target envelope. It does not authorize durable
edits during this revision route.

| Manifest Target | Exact Surfaces Reviewed | Current Packet Action | Downstream Mutation Owner |
| --- | --- | --- | --- |
| `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs` | Program planning, child state aggregation, recovery route selection, authority decisions, delegated promotion receipt writing, child job construction, recovery validation, closeout hygiene preflight, aggregate closeout evidence. | Read and cite current-state evidence only. | All downstream behavior children may touch this file only within their accepted child scope. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/` | `workflow_leaf.rs`, `observer.rs`, `adapter.rs`, `authorization.rs`, `request.rs`, `result.rs`. | Read and cite current-state evidence; no revision-route mutation. | `workflow-retry-ids` owns `workflow_leaf.rs`; `archive-observation-recovery` owns `observer.rs`; authority or request shape changes must stay with the owning child. |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/` | `lifecycle.contract.yml`, `lifecycles/proposal-program.contract.yml`, `lifecycle-model.md`, `routing-guide.md`, `output-boundaries.md`, `patterns/proposal-program.md`. | Read and cite contract evidence; no revision-route mutation. | `change-handoff-checkpoints`, `aggregate-terminal-blockers`, `promotion-evidence-binding`, `publication-freshness-preflight`, and `parent-review-churn` may update only the contract portions they own. |

## No-Op Boundaries

- This gap-map packet does not edit durable targets.
- This gap-map packet does not edit parent or sibling child packets.
- This gap-map packet does not regenerate generated/effective runtime outputs.
- This gap-map packet does not edit workflow definitions.
- This gap-map packet does not create child receipts or terminal outcomes.

## Review Boundary

A fresh review may approve this packet only as the current-state map and
handoff evidence. Durable implementation remains child-owned and route-gated.
