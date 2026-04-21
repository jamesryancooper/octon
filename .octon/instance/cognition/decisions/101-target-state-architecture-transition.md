# ADR 101: Target-State Architecture Transition

- Date: 2026-04-20
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/inputs/exploratory/proposals/architecture/octon-target-state-architecture-transition/`
  - `/.octon/state/evidence/validation/architecture-target-state-transition/`
  - `/.octon/state/evidence/validation/support-targets/`

## Context

The target-state architecture packet requires one durable closure record that
binds the runtime boundary refactor, support proof-bundle hardening, generated
navigation maps, compatibility-retirement wiring, and the packet-named
validation evidence under durable non-proposal paths.

The packet proposed ADR id `099`, but the live decisions index already uses
that id for promotion semantics hardening. This ADR uses `101` to preserve
append-only ADR uniqueness while keeping the packet’s architectural intent
durable.

## Decision

Treat the target-state architecture transition as implemented only when:

1. the runtime boundary is represented through packet-named schemas, inventory,
   coverage maps, and phase-result artifacts;
2. live support tuples bind current proof bundles and derived SupportCards;
3. generated navigation maps exist only as non-authoritative projections;
4. compatibility-retirement governance is bridged into the structural
   registry; and
5. retained evidence under
   `state/evidence/validation/architecture-target-state-transition/**`
   supports closure without proposal-path runtime or policy dependency.

## Consequences

- The packet’s target-state contract is promoted into durable repo surfaces.
- Proposal lineage remains informative only.
- Future closure and architecture audits can traverse one retained evidence
  root plus one durable ADR instead of depending on packet-local narration.
