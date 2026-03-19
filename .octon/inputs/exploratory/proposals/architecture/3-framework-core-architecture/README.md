# Portable Framework/Core Architecture

This is a temporary, implementation-scoped architecture proposal for
`framework-core-architecture`.
It translates the ratified Packet 3 design packet and the ratified super-root
blueprint into the repository's proposal format.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Formalize `/.octon/framework/**` as the portable authored Octon
  core bundle, ratify `framework/manifest.yml` and
  `framework/overlay-points/registry.yml` as authoritative framework control
  surfaces, and define the class-boundary, portability, update, and validation
  rules that keep framework authority separate from repo-specific instance
  content, raw inputs, mutable state, and generated outputs.

## Promotion Targets

- `.octon/octon.yml`
- `.octon/README.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/framework/manifest.yml`
- `.octon/framework/overlay-points/registry.yml`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/shared-foundation.md`
- `.octon/framework/assurance/runtime/`
- `.octon/framework/orchestration/runtime/workflows/`
- `.octon/framework/scaffolding/runtime/templates/octon/`
- `.octon/framework/`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/octon_packet_3_framework_core_architecture.md`
4. `resources/octon_ratified_architectural_blueprint.md`
5. `navigation/source-of-truth-map.md`
6. `architecture/target-architecture.md`
7. `architecture/acceptance-criteria.md`
8. `architecture/implementation-plan.md`

## Supporting Resources

- `resources/octon_packet_3_framework_core_architecture.md` captures the
  ratified Packet 3 design packet used to draft this proposal.
- `resources/octon_ratified_architectural_blueprint.md` bundles the ratified
  blueprint sections that constrain the framework/core boundary, overlay
  registry ownership, and portability/update contract.

## Exit Path

Promote the framework bundle boundary, companion-manifest and overlay-registry
requirements, framework placement rules, and fail-closed validation/update
semantics into durable `.octon/` architecture, control-plane, assurance, and
workflow surfaces, then archive this proposal once the canonical framework
contract no longer depends on transitional boundary assumptions.
