# ADR 038: Engine and Capabilities Authority Boundary

- Date: 2026-02-24
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: Implicit/overlapping policy ownership language between
  `/.octon/engine/` and `/.octon/capabilities/`
- Related:
  - `/.octon/engine/governance/runtime-capability-authority-boundary.md`
  - `/.octon/engine/governance/README.md`
  - `/.octon/capabilities/governance/README.md`

## Context

Octon already defined bounded surfaces for `engine/` and `capabilities/`,
but policy ownership language around runtime safety and "safe execution"
remained partially overlapping.

This created avoidable ambiguity in four areas:

1. Competing policy sources (unclear canonical owner for some rules).
2. Drift risk (runtime semantics duplicated into capability policy contracts).
3. Coupling creep (capability-side scripts reaching engine implementation
   internals).
4. Change-safety ambiguity (single behavior changes requiring edits in multiple
   authorities).

## Decision

Adopt a strict two-layer governance model with deterministic dependency and
tie-breaker rules.

### 1) Ownership split (non-overlapping)

- `engine/` owns runtime execution semantics:
  - execution model and lifecycle,
  - enforcement points and evaluation mechanics,
  - runtime defaults/fail-closed behavior,
  - runtime receipt/log semantics,
  - launch/runtime constraints and protocol/schema behavior.
- `capabilities/` owns capability declaration semantics:
  - capability taxonomy and discovery contracts,
  - capability schemas/registration rules,
  - authoring/declaration conventions,
  - capability-specific requirements and constraints declarations.

### 2) Dependency direction

- Allowed:
  - `engine/` may read capability declarations/contracts as enforcement inputs.
  - `capabilities/` may depend only on stable engine contract boundaries.
- Prohibited:
  - `capabilities/**` must not depend on engine implementation internals.
  - `capabilities/governance/**` must not redefine engine runtime semantics.

### 3) Conflict tie-breaker

- If a rule changes how execution works, it belongs to `engine/`.
- If a rule changes what a capability is or requires, it belongs to
  `capabilities/`.
- Unresolved conflicts fail closed and require ADR-backed contract updates.

## Consequences

### Benefits

- Deterministic policy ownership with a single authority per rule class.
- Reduced drift risk between declaration and enforcement layers.
- Lower cross-domain coupling and safer migrations.
- Clearer review and change-routing for policy updates.

### Costs

- Requires migration of existing capability-side call paths that currently
  reach engine internals.
- Adds boundary validation responsibilities to CI/contracts.

### Follow-on Work

1. Expose a stable engine-owned policy interface and route capabilities through
   it.
2. Keep capability policy focused on declaration semantics only.
3. Add CI boundary validation to prevent regression into prohibited dependency
   edges.
