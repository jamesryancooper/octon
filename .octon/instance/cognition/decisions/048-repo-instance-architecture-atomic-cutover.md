# ADR 048: Repo-Instance Architecture Atomic Cutover

- Date: 2026-03-18
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/inputs/exploratory/proposals/architecture/repo-instance-architecture/`
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-18-repo-instance-architecture-cutover/plan.md`
  - `/.octon/framework/cognition/_meta/architecture/specification.md`

## Context

Packet 4 formalizes `instance/**` as Octon's repo-specific durable authority
layer, but the live repository still had a partial cutover:

1. core instance controls existed, but some packet-4 structure was still
   implied rather than materialized,
2. active docs and workflow surfaces still used mixed repo-instance path
   vocabulary,
3. the harness gate did not yet fail closed on packet-4 boundary drift.

## Decision

Promote Packet 4 as one atomic clean-break cutover.

Rules:

1. Packet 4 lands as a single promotion event.
2. After cutover, active contract and operator surfaces MUST treat
   `/.octon/instance/**` as the only canonical repo-owned durable authority
   layer.
3. No compatibility shims, fallback roots, or dual old/new authority paths are
   allowed after promotion.
4. Rollback is full-revert-only for the cutover change set.
5. If packet-4 validation cannot converge to one canonical authority model,
   promotion is blocked and the harness fails closed.

## Consequences

### Benefits

- Deterministic repo-owned authority placement.
- Canonical ingress, bootstrap, locality, mission, and repo-native capability
  routing.
- Fail-closed enforcement for wrong-class placement and active mixed-path
  drift.

### Costs

- Large one-shot doc, validator, and template sweep.
- Reduced flexibility for partial rollback or staged migration tactics.

### Follow-on Work

1. Packet 5 will define detailed overlay merge semantics on top of the now
   materialized overlay-capable instance roots.
2. Packet 10 and Packet 11 will rehome generated cognition summaries out of
   `instance/**`.
