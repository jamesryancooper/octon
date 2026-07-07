# Target Architecture

The target architecture keeps the existing proposal-program controller, delivery workflow, and closeout routes as authority owners while adding a clearer operator layer.

## Target Surfaces

- A first-class clean-delivery command or wrapper that expands to the existing proposal-program lifecycle runner with route execution enabled and `target_outcome=cleaned` bound as a request.
- A route-graph preview that shows parent routes, child route batches, review and revision loops, architecture-review dependencies, delivery handoff, Change closeout, sync, cleanup, and terminal proof requirements.
- A visible architecture-review status edge for architecture proposals.
- A delivery admission view that reports required profile, run id, readiness preflight, include-path classification, and source freshness evidence without fabricating those inputs.
- Naming and docs aligned to effective route ids and operator command names.
- Regression fixtures that prove the operator layer is explanatory and invocational only, not authoritative.

## Authority Boundaries

The program does not propose a flattened lifecycle authority model. The clean-delivery command requests work from the lifecycle runner. The route graph explains route selection. Delivery remains workflow-backed. Change closeout, closeout-worktree, and repo-hygiene cleanup retain their own authority.
