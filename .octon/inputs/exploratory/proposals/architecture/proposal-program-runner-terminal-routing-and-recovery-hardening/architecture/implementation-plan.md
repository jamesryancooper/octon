# Implementation Plan

1. Audit the final postmortem evidence against the current runner, workflow,
   contract, validator, and test surfaces.
2. Implement retry-safe workflow leaf run-id handling with explicit resume
   proof requirements.
3. Add lifecycle interaction checkpoints for route-owned Change/worktree
   handoff after mutating child batches without moving closeout ownership into
   the generic runner.
4. Add parent-controller aggregate child terminal blocker evidence and route
   consumption rules.
5. Bind supplied promotion evidence to selected child identity, target path,
   receipts, and promotion target lineage.
6. Add pre-dispatch generated-state freshness classification and declared
   recovery guidance.
7. Suppress parent review churn from volatile lifecycle/run-control evidence
   while preserving strict review gates where required.
8. Harden archive observation and blocked archive receipts for workflow moves,
   duplicate run ids, stale workflow state, and non-converged terminal routes.
9. Add integration fixtures and negative controls covering the complete
   terminal routing failure pattern.

Each step is owned by a child proposal packet. The parent coordinates
sequencing only.
