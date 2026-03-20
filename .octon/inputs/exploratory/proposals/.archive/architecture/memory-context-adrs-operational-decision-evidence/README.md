# Memory Routing and Decision Surfaces

This is a temporary, implementation-scoped architecture proposal for
`memory-context-adrs-operational-decision-evidence`.
It translates the ratified Packet 11 design packet and the ratified super-root
blueprint into the repository's proposal format.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Ratify one canonical home for durable context, ADR authority,
  active continuity, retained decision and run evidence, and derived
  cognition summaries so `instance/**`, `state/**`, and `generated/**` stop
  competing as overlapping memory surfaces.

## Promotion Targets

- `.octon/README.md`
- `.octon/octon.yml`
- `.octon/instance/bootstrap/START.md`
- `.octon/framework/agency/governance/MEMORY.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `.octon/framework/cognition/_meta/architecture/state/continuity/`
- `.octon/instance/cognition/context/index.yml`
- `.octon/instance/cognition/context/shared/`
- `.octon/instance/cognition/decisions/`
- `.octon/state/continuity/`
- `.octon/state/evidence/`
- `.octon/generated/cognition/`
- `.octon/framework/assurance/runtime/`
- `.octon/framework/orchestration/runtime/workflows/`
- `.octon/framework/scaffolding/runtime/templates/octon/`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/octon_packet_11_memory_context_adrs_operational_decision_evidence.md`
4. `resources/octon_ratified_architectural_blueprint.md`
5. `navigation/source-of-truth-map.md`
6. `architecture/target-architecture.md`
7. `architecture/acceptance-criteria.md`
8. `architecture/implementation-plan.md`

## Supporting Resources

- `resources/octon_packet_11_memory_context_adrs_operational_decision_evidence.md`
  captures the ratified Packet 11 design packet used to draft this proposal.
- `resources/octon_ratified_architectural_blueprint.md` bundles the ratified
  blueprint sections that constrain memory routing, durable context,
  continuity, retained evidence, generated cognition views, and migration
  sequencing.

## Exit Path

Promote the final memory-routing contract, ADR-versus-operational-evidence
boundary, one-primary-home continuity rule, generated-cognition non-authority
rule, duplicate-summary cleanup, and class-correct reset and retention
guidance into durable `.octon/` architecture, governance, validation,
workflow, and scaffolding surfaces, then archive this proposal once live
memory behavior no longer depends on proposal-local framing.
