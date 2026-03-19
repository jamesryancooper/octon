# ADR 050: Locality And Scope Registry Atomic Cutover

- Date: 2026-03-19
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/inputs/exploratory/proposals/architecture/6-locality-and-scope-registry/`
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-19-locality-and-scope-registry-cutover/plan.md`
  - `/.octon/framework/cognition/_meta/architecture/specification.md`

## Context

Packet 6 formalizes the root-owned locality model that Packets 4 and 5 made
possible but did not yet complete:

1. the live repository already binds locality through `instance/manifest.yml`
   and ships the basic locality scaffold,
2. the live repository still lacks canonical per-scope manifests, compiled
   effective locality outputs, and mutable locality quarantine state,
3. active docs and validators still allow locality to be understood as a
   convention-only concern rather than one fail-closed scope registry.

That leaves one remaining authority gap: locality exists conceptually, but not
yet as a complete repo-owned scope system that later continuity, routing, and
validation work can trust.

## Decision

Promote Packet 6 as one atomic clean-break cutover.

Rules:

1. Packet 6 lands as a single promotion event.
2. After cutover, `instance/locality/**` is the only authored locality
   authority surface.
3. After cutover, `generated/effective/locality/**` is the only compiled
   runtime-facing locality view.
4. After cutover, `state/control/locality/quarantine.yml` is the only mutable
   locality quarantine surface.
5. No compatibility shims, nearest-registry fallback, descendant `.octon/`
   roots, or alternate locality sources are allowed after promotion.
6. Scope continuity remains gated off until Packet 7.
7. Rollback is full-revert-only for the cutover change set.
8. If locality validation cannot converge to one unambiguous root-owned scope
   registry, promotion is blocked and the harness fails closed.

## Consequences

### Benefits

- Deterministic scope identity and path binding.
- Explicit separation between authored locality inputs, compiled effective
  locality outputs, and mutable quarantine state.
- A stable locality contract for later scope continuity, capability routing,
  and fail-closed validation work.

### Costs

- Large one-shot sweep across docs, validators, generated outputs, scaffolding,
  and CI hooks.
- Reduced flexibility for partial rollback or transitional locality behavior.

### Follow-on Work

1. Packet 7 can add scope continuity only after the Packet 6 locality contract
   is live and validator-enforced.
2. Packet 12 can consume scope metadata from the authoritative locality
   manifests and compiled effective locality outputs.
3. Packet 14 can treat locality quarantine and stale effective locality views
   as first-class fail-closed rules.
