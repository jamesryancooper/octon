# CrewAI Mapping

## Scope

Maps canonical interop semantics to CrewAI-specific runtime contracts.

## Mapping Table

| Canonical Semantic | CrewAI Mapping | Notes |
|---|---|---|
| `scope_class` | `session.scope` | Direct enum mapping. |
| `reset_class` | `runtime.reset_mode` | Preserves `none|soft|hard`. |
| `send_class` | `dispatch.send_mode` | Preserves `append|replace|branch`. |
| Context budget warning/flush | `budget.warning_threshold`, `budget.flush_threshold` | Canonical 80/90 thresholds remain fixed. |
| `pruning_class` | `context.prune_mode` | `aggressive` may degrade to conservative behavior. |
| Flush-before-compaction | `memory.flush.required_before_compact` | Mandatory fail-closed enforcement retained. |
| Routing precedence | `router.precedence` | Canonical ordering is not reorderable by adapter. |
| Presence evidence fields | `presence.heartbeat.required_fields` | Adapter may add optional extra telemetry fields. |
