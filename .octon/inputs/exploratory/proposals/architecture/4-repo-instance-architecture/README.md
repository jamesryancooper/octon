# Repo-Instance Authoritative Layer

This is a temporary, implementation-scoped architecture proposal for
`repo-instance-architecture`.
It translates the ratified Packet 4 design packet and the ratified super-root
blueprint into the repository's proposal format.
The proposal has been implemented in the repository and remains here as a
temporary non-canonical planning artifact until archival.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Formalize `/.octon/instance/**` as the repo-specific durable
  authoritative layer, ratify `instance/manifest.yml`,
  `instance/ingress/AGENTS.md`, and `instance/extensions.yml` as canonical
  instance control surfaces, and define the boundary, validation, update, and
  portability rules that keep repo-owned authority separate from framework,
  raw inputs, mutable state, and generated outputs.

## Promotion Targets

- `.octon/README.md`
- `.octon/octon.yml`
- `.octon/instance/manifest.yml`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/instance/bootstrap/`
- `.octon/instance/locality/`
- `.octon/instance/cognition/`
- `.octon/instance/capabilities/runtime/`
- `.octon/instance/orchestration/`
- `.octon/instance/extensions.yml`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/shared-foundation.md`
- `.octon/framework/assurance/runtime/`
- `.octon/framework/orchestration/runtime/workflows/`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/octon_packet_4_repo_instance_architecture.md`
4. `resources/octon_ratified_architectural_blueprint.md`
5. `navigation/source-of-truth-map.md`
6. `architecture/target-architecture.md`
7. `architecture/acceptance-criteria.md`
8. `architecture/implementation-plan.md`

## Supporting Resources

- `resources/octon_packet_4_repo_instance_architecture.md` captures the
  ratified Packet 4 design packet used to draft this proposal.
- `resources/octon_ratified_architectural_blueprint.md` bundles the ratified
  blueprint sections that constrain the repo-instance boundary, canonical
  ingress placement, overlay-capable surfaces, and portability/update rules.

## Exit Path

Promote the repo-instance boundary, companion-manifest requirements, canonical
ingress placement, desired extension configuration rules, and fail-closed
validation/update semantics into durable `.octon/` architecture,
documentation, assurance, and workflow surfaces, then archive this proposal
once canonical repo-owned authority no longer depends on transitional mixed
placement assumptions.
