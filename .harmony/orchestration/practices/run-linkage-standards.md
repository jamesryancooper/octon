# Run Linkage Standards

Operating standards for orchestration-facing run state under
`/.harmony/orchestration/runtime/runs/`.

## Scope

Applies to run creation, status updates, projection maintenance, and continuity
linkage.

## Standards

1. `runtime/runs/<run-id>.yml` is the canonical orchestration-facing run
   record.
2. `index.yml` and `by-surface/` are subordinate projections.
3. Every material run must link to:
   - `decision_id`
   - `continuity_run_path`
4. Side-effectful active runs must record `coordination_key`.
5. Running runs must record:
   - `executor_id`
   - `executor_acknowledged_at`
   - `last_heartbeat_at`
   - `lease_expires_at`
   - `recovery_status`

## Boundary

- `runtime/runs/` owns orchestration-facing state and lookup projections.
- `continuity/runs/` owns durable receipts, digests, and evidence bundles.
