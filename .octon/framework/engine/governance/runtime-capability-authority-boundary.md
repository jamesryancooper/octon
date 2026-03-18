# Runtime and Capability Authority Boundary

## Purpose

Define non-overlapping authority between `engine/` and `capabilities/` so
policy ownership, dependency direction, and conflict resolution are
deterministic.

## Layer Ownership

### Engine Authority (execution semantics)

`engine/` owns runtime semantics and enforcement behavior:

- execution model and lifecycle,
- enforcement points and decision mechanics,
- launch/runtime constraints and default fail behavior,
- evaluation/receipt/log semantics,
- protocol/schema contracts required for runtime interoperability.

These invariants apply regardless of which capability is running.

### Capabilities Authority (declaration semantics)

`capabilities/` owns capability declaration contracts:

- capability taxonomy and discovery metadata,
- capability schemas and registration rules,
- authoring conventions and required declaration fields,
- capability-level requirements and constraints that must be declared before
  runtime.

This layer defines what a capability is and what it requires, not how runtime
enforcement executes internally.

## Dependency Direction

Allowed:

- `engine/` MAY read and enforce against capability declarations in
  `capabilities/runtime/**` and capability governance contracts in
  `capabilities/governance/**`.
- `capabilities/` MAY depend only on stable engine contract boundaries in
  `engine/runtime/spec/**` and engine launch interfaces.

Prohibited:

- `capabilities/**` MUST NOT depend on engine implementation internals (for
  example `engine/runtime/crates/**`, launcher internals, or engine-private
  policy logic).
- `capabilities/governance/**` MUST NOT redefine runtime execution semantics
  already owned by `engine/`.

## Tie-Breaker

If ownership is ambiguous:

- If a rule changes how execution works, it belongs to `engine/`.
- If a rule changes what a capability is or requires, it belongs to
  `capabilities/`.

When conflicts remain unresolved, fail closed and escalate through ADR-backed
contract updates before promotion.
