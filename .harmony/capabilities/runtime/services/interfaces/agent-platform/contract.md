# Agent Platform Interop Contract (Service)

## Context

This service defines Harmony-owned interoperability semantics that remain valid
in native mode and in adapter mode.

## Instructions

1. Treat this contract as provider-agnostic source of truth.
2. Validate session policy before execution.
3. Enforce context budget thresholds (`80%` warning, `90%` flush-required).
4. Enforce flush-before-compaction policy.
5. Block compaction when mandatory flush fails unless explicit ACP waiver exists.
6. Emit deterministic evidence for degraded or fail-closed paths.

## Output

Service consumers must produce typed outputs conforming to:

- `schema/capabilities.schema.json`
- `schema/session-policy.schema.json`
- `schema/output.schema.json`
