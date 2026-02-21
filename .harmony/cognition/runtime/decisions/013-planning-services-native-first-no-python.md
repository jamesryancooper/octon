---
title: "ADR-013: Planning+Execution Services Native-First, No-Python Core Runtime"
description: Establish native harness execution as mandatory for core Planning and Execution services and treat external runtimes as optional adapters.
status: accepted
date: 2026-02-16
---

# ADR-013: Planning+Execution Services Native-First, No-Python Core Runtime

## Context

Planning and execution services are currently documented with strong coupling to a Python-based runtime path.
That coupling weakens Harmony's portability goals across host stacks and operating systems.

Harmony requires a planning/execution stack that:

1. Runs inside harness constraints with no required external runtime process.
2. Preserves provider/runtime interoperability without locking core behavior to one stack.
3. Keeps governance fail-closed and deterministic.

## Decision

Adopt a native-first architecture for Planning and Execution services with these rules:

1. Core Planning and Execution services (`spec`, `plan`, `playbook`, `agent`, `flow`) must run without Python.
2. `flow` must provide a native harness execution path as the default.
3. External runtime integrations (including LangGraph) are optional adapters only.
4. Core contracts remain provider/runtime-agnostic.
5. Provider/runtime-specific terms are restricted to adapter paths.

## Rationale

- Preserves stack and OS portability.
- Reduces operational coupling and setup burden.
- Improves long-term reversibility by isolating external integrations.
- Keeps Harmony as the source of truth for planning and execution semantics.

## Consequences

### Positive

- Execution flows can execute in constrained environments.
- External runtime integrations remain possible without dominating core contracts.
- Adapter boundaries become explicit and testable.

### Costs

- Additional adapter contracts and validation logic.
- Migration effort to remove Python-default assumptions from flow configs/docs.

## Alternatives Considered

1. Keep Python/LangGraph as default runtime.
   - Rejected: conflicts with portability and no-external-runtime baseline.
2. Remove external runtimes entirely.
   - Rejected: unnecessary loss of interoperability and ecosystem integration.
3. Keep mixed default behavior by environment.
   - Rejected: increases ambiguity and operational drift.

## Implementation Notes

- Add runtime HTTP capability with deny-by-default policy gating.
- Convert `execution/flow` to Rust/WASM service shape for native execution.
- Introduce optional runtime adapter registry under `execution/flow/adapters/`.
- Remove Python-required defaults from `packages/workflows/*/config.flow.json`.
