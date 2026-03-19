# Repo-Instance Locality and Scope Registry

This is a temporary, implementation-scoped architecture proposal for
`locality-and-scope-registry`.
It translates the ratified Packet 6 design packet and the ratified super-root
blueprint into the repository's proposal format.
The proposal has been implemented in the repository and remains here as a
temporary non-canonical planning artifact until archival.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Formalize `/.octon/instance/locality/**` as the authoritative
  repo-owned scope registry, ratify one `root_path` per `scope_id` and zero or
  one active scope per path in v1, and define generated effective locality
  outputs plus fail-closed quarantine and downstream scope-context attachment
  rules.

## Promotion Targets

- `.octon/instance/manifest.yml`
- `.octon/instance/locality/manifest.yml`
- `.octon/instance/locality/registry.yml`
- `.octon/instance/locality/scopes/`
- `.octon/instance/cognition/context/scopes/`
- `.octon/instance/orchestration/missions/`
- `.octon/state/control/locality/`
- `.octon/generated/effective/locality/`
- `.octon/README.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/framework/cognition/governance/principles/locality.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/shared-foundation.md`
- `.octon/framework/capabilities/_meta/architecture/`
- `.octon/framework/assurance/runtime/`
- `.octon/framework/orchestration/runtime/workflows/`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/octon_packet_6_locality_and_scope_registry.md`
4. `resources/octon_ratified_architectural_blueprint.md`
5. `navigation/source-of-truth-map.md`
6. `architecture/target-architecture.md`
7. `architecture/acceptance-criteria.md`
8. `architecture/implementation-plan.md`

## Supporting Resources

- `resources/octon_packet_6_locality_and_scope_registry.md` captures the
  ratified Packet 6 design packet used to draft this proposal.
- `resources/octon_ratified_architectural_blueprint.md` bundles the ratified
  blueprint sections that constrain locality placement, scope identity,
  generated effective outputs, quarantine behavior, and migration sequencing.

## Exit Path

Promote the locality registry contract, scope-manifest schema, resolution and
quarantine rules, generated effective locality outputs, and scope-aware
placement guidance into durable `.octon/` architecture, instance, state,
generated, assurance, and workflow surfaces, then archive this proposal once
canonical locality behavior no longer depends on temporary proposal framing.
