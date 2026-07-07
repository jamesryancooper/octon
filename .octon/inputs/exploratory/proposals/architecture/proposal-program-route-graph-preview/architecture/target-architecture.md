# Target Architecture

The lifecycle runner emits a route graph view during proposal-program planning.

The graph should include:

- Parent route selected or blocked.
- Child routes selected by child id and batch.
- Loop state for review and revision.
- Gate state for implementation orchestration and promotion.
- Architecture-review receipt status when applicable.
- Delivery handoff posture when `target_outcome=cleaned` is requested.
- Blocked alternatives and owning next routes.
- Resume command and run id.

The graph is a read model over current planning evidence. It is not a receipt, grant, cleanup authorization, archive authorization, or delivery claim.
