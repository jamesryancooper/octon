# Filesystem Watch Contract (Service)

## Instructions

1. Use bounded polling to detect filesystem change hints.
2. Keep watcher state in runtime state files under explicit state keys.
3. Enforce deterministic ordering for emitted change events.
4. Exclude volatile runtime and VCS paths by default.
5. Fail closed on invalid input and limit exceedance.
6. Persist bounded sampled state to avoid oversized runtime state writes.

## Operation Families

- Watch: `watch.poll`

## Output

All operations must emit output conforming to:

- `schema/output.schema.json`

## Observability

- Service emits `filesystem_watch.metric` event fields including scan duration and file counts.
