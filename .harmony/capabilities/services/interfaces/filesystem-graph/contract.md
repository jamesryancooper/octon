# Filesystem Graph Contract (Service)

## Instructions

1. Treat files as source-of-truth.
2. Build graph state from snapshot artifacts.
3. Use deterministic snapshot IDs from canonical input fingerprints.
4. Return typed errors for validation and policy failures.
5. Block operations on invalid or missing required snapshot artifacts.

## Operation Families

- Filesystem: `fs.list`, `fs.read`, `fs.stat`, `fs.search`
- Snapshot: `snapshot.build`, `snapshot.diff`, `snapshot.get-current`
- Graph: `kg.get-node`, `kg.neighbors`, `kg.traverse`, `kg.resolve-to-file`
- Discovery: `discover.start`, `discover.expand`, `discover.explain`, `discover.resolve`

## Output

All operations must emit output conforming to:

- `schema/output.schema.json`
- `schema/node.schema.json` (where node payloads are returned)
- `schema/edge.schema.json` (where edge payloads are returned)

## Observability

- Service emits structured `filesystem_graph.metric` log events per op.
- Events include op name, status, duration, byte sizes, and SLO status.
- CI validates SLO budgets in `contracts/slo-budgets.tsv`.
