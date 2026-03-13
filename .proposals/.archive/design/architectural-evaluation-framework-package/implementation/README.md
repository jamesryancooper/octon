# Implementation Guide

## Purpose

Translate this temporary package into durable Octon surfaces without turning
the package itself into a live authority.

## Integration Decision

Build a **new** architecture-readiness capability rather than mutating existing
audit surfaces to mean something different.

### Primary Durable Integration

- `audit-architecture-readiness` skill in
  `/.octon/capabilities/runtime/skills/audit/`
- `audit-architecture-readiness` workflow in
  `/.octon/orchestration/runtime/workflows/audit/`
- methodology docs in
  `/.octon/cognition/practices/methodology/architecture-readiness/`
- reusable ADR review matrix in
  `/.octon/scaffolding/governance/patterns/`

## Why New Surfaces

- `audit-domain-architecture` is intentionally external-criteria and
  domain-focused; it should stay available as a separate lens.
- `audit-cross-subsystem-coherence` verifies cross-subsystem alignment, not
  architecture-readiness scoring or failure-mode analysis.
- `audit-subsystem-health` checks internal config/schema coherence, not
  system-level architecture.
- `evaluate-harness` and `evaluate-workflow` are meta evaluators for structure
  and authoring quality, not governed architecture readiness.

## Build Order

1. Promote methodology docs so the framework has a durable explanatory home.
2. Implement the audit skill for direct whole-harness and bounded-domain runs.
3. Implement the orchestration workflow for larger-scope, multi-pass runs.
4. Promote the ADR matrix into scaffolding governance patterns.
5. Add any workflow/skill tests and validation hooks required by the new live
   surfaces.

## Scope Guard

The live framework should support only:

- whole-harness architecture audits against `/.octon/`
- bounded-surface top-level domain audits for `agency`, `capabilities`,
  `cognition`, `orchestration`, `assurance`, `scaffolding`, and `engine`

It should reject or mark not-applicable:

- `continuity`
- `ideation`
- `output`
- isolated surface-only targets such as `governance/`, `practices/`, `_meta/`,
  or `_ops/`
