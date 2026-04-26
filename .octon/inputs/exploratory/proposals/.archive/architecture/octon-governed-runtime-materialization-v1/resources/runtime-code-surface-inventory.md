# Runtime Code Surface Inventory

This inventory identifies code areas likely affected by the migration. It is a
proposal inventory and must be verified against the live working tree during
implementation.

## Runtime crates observed

- `.octon/framework/engine/runtime/crates/authority_engine`
- `.octon/framework/engine/runtime/crates/authorized_effects`
- `.octon/framework/engine/runtime/crates/kernel`
- `.octon/framework/engine/runtime/crates/policy_engine`
- `.octon/framework/engine/runtime/crates/runtime_resolver`
- `.octon/framework/engine/runtime/crates/telemetry_sink`
- `.octon/framework/engine/runtime/crates/replay_store`

## Authorization surfaces

| Surface | Expected role in migration |
| --- | --- |
| `authority_engine/src/implementation/execution.rs` | Issue grants/tokens only after route/support/policy checks |
| `authority_engine/src/implementation/effects.rs` | Central token verifier/consumer helper if present or created |
| `authorized_effects/src/lib.rs` | Token types, effect classes, verified effect type, receipt type |
| `kernel/src/commands/mod.rs` | CLI material operations must use verified effects |
| `kernel/src/pipeline.rs` | Pipeline material transitions must use verified effects |
| `kernel/src/stdio.rs` | Host-facing material command path must not bypass tokens |
| `kernel/src/workflow.rs` | Workflow stage/material effects must use verified effects |

## Required implementation inventory

For each material API, record:

- path
- effect class
- caller
- consumer
- verifier
- token record path
- receipt path
- lifecycle event type
- positive test
- negative tests
- evidence receipt

## Do not assume coverage

The existence of a spec, test name, or validator name is not sufficient. Each
runtime path must be proven with positive and negative execution evidence.
