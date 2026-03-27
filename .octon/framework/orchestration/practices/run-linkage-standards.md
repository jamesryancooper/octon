# Run Linkage Standards

Operating standards for orchestration-facing run projections under
`/.octon/framework/orchestration/runtime/runs/`.

## Scope

Applies to run creation, status updates, projection maintenance, and continuity
linkage.

## Standards

1. `state/control/execution/runs/<run-id>/run-contract.yml` is the canonical
   per-run execution contract for Wave 1.
2. `runtime/runs/<run-id>.yml` is the orchestration-facing projection derived
   from that canonical run root.
3. `index.yml` and `by-surface/` are subordinate projections.
4. Every material run projection must link to:
   - `decision_id`
   - `continuity_run_path`
   - `run_contract_path`
   - `runtime_state_path`
   - `rollback_posture_path`
5. Side-effectful active runs must record `coordination_key`.
6. Running runs must record:
   - `executor_id`
   - `executor_acknowledged_at`
   - `last_heartbeat_at`
   - `lease_expires_at`
   - `recovery_status`

## Boundary

- `runtime/runs/` owns orchestration-facing state and lookup projections.
- `state/control/execution/runs/` owns the canonical Wave 1 run contract.
- `state/evidence/runs/` owns durable receipts, digests, and evidence bundles.
