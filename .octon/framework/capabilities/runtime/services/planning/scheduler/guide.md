# Scheduler Service

Schedules plan steps into deterministic execution stages.

Use `schedule` to:

- validate dependency graph structure,
- detect cycles,
- emit stable stage buckets subject to `maxParallel` (0 = unlimited).

Each stage runs in parallel up to the configured limit, while preserving
step ordering guarantees from dependency edges.
