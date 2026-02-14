# OpenCLAW Mapping

## Scope

Maps canonical interop semantics to OpenCLAW-specific fields and APIs.

## Mapping Table

| Canonical Semantic | OpenCLAW Mapping | Notes |
|---|---|---|
| `scope_class` | `session.scope` | Direct enum mapping. |
| `reset_class` | `session.reset_strategy` | `none|soft|hard` preserved. |
| `send_class` | `message.dispatch_mode` | `append|replace|branch` preserved. |
| Context budget warning/flush | `runtime.context.warning_pct`, `runtime.context.flush_pct` | Thresholds fixed by canonical policy. |
| `pruning_class` | `context.pruning.policy` | Adapter maps conservative/aggressive behavior knobs. |
| Flush-before-compaction | `memory.flush.before_compaction` | Fail-closed behavior enforced by canonical contract. |
| Routing precedence | `router.priority_chain` | Canonical precedence order is preserved. |
| Presence evidence fields | `presence.heartbeat.payload` | Adapter adds transport metadata only. |
