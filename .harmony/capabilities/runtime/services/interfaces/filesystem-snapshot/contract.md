# Filesystem Snapshot Contract (Service)

## Instructions

1. Treat files as source-of-truth.
2. Build deterministic snapshot artifacts from canonical filesystem inputs.
3. Publish snapshots atomically and reject incomplete/corrupt artifacts.
4. Enforce typed policy and validation failures with fail-closed behavior.
5. Enforce bounded limits for files scanned, bytes processed, and operation time.
6. Preserve retention constraints without deleting the active snapshot pointer.

## Operation Families

- Filesystem: `fs.list`, `fs.read`, `fs.stat`, `fs.search`
- Snapshot: `snapshot.build`, `snapshot.diff`, `snapshot.get-current`

## Output

All operations must emit output conforming to:

- `schema/output.schema.json`
- `schema/snapshot-manifest.schema.json` (where snapshot manifest payloads are returned)

## Observability

- Service emits structured `filesystem_interfaces.metric` log events per op.
- Events include op name, status, duration, byte sizes, and scanned file counts.
