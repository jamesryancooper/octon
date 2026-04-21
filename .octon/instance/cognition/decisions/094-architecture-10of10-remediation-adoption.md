# ADR 094: Architecture 10/10 Remediation Adoption

- Date: 2026-04-20
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-architecture-10of10-remediation/`
  - `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
  - `/.octon/state/evidence/validation/architecture/10of10-remediation/`

## Context

The architecture remediation packet established a target-state program for
lifting Octon from a structurally strong but partially over-exposed and
insufficiently self-validating architecture to a fully registry-backed,
proof-oriented, and operator-legible architecture.

The live repository already contained much of the runtime, disclosure,
support-target, and validation machinery. What remained missing was a coherent
remediation layer that turned those partially overlapping surfaces into one
consistent target state.

This branch slice covers the docs, registry, and decision-record portion of
that broader remediation program.

## Decision

Adopt the remediation packet as an implementation-driving lineage artifact and
promote its accepted target-state content into durable framework, instance,
state, generated, and workflow surfaces outside `inputs/**`.

Rules:

1. The packet remains non-authoritative while under `inputs/**`.
2. Durable target-state authority must land in authored authority, mutable
   control truth, retained evidence, or generated non-authoritative read models
   outside the proposal tree.
3. The docs, registry, and decision-record slice may land ahead of later
   runtime and validator follow-ons as long as it preserves the existing
   constitutional model and validator compatibility.
4. Completion requires validators, retained closure evidence, and closure ADRs.

## Consequences

- The remediation becomes a durable architecture program rather than a proposal
  that can silently drift from live repo reality.
- The registry and active docs can move to steady-state roles without waiting
  for every later runtime workstream to land.
- Closure can be certified against durable evidence instead of packet prose.
- The proposal packet can be archived as lineage once promotion completes.
