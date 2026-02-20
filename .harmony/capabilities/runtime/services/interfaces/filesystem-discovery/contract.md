# Filesystem Discovery Contract (Service)

## Instructions

1. Treat snapshot artifacts as the required source for graph/discovery operations.
2. Block operations when required snapshot artifacts are missing, malformed, or unsupported.
3. Return typed errors for validation, policy, and integrity failures.
4. Enforce bounded query/discovery limits for bytes scanned and operation time.
5. Ensure returned entities remain resolvable to concrete filesystem paths.
6. Include provenance fields for explainability outputs.

## Operation Families

- Graph: `kg.get-node`, `kg.neighbors`, `kg.traverse`, `kg.resolve-to-file`
- Discovery: `discover.start`, `discover.expand`, `discover.explain`, `discover.resolve`

## Output

All operations must emit output conforming to:

- `schema/output.schema.json`
- `schema/node.schema.json` (where node payloads are returned)
- `schema/edge.schema.json` (where edge payloads are returned)

## Observability

- Service emits structured `filesystem_interfaces.metric` log events per op.
- Events include op name, status, duration, byte sizes, and scanned file counts.
