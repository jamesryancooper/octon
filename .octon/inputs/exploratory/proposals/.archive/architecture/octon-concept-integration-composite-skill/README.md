# Octon Concept Integration Extension-Pack Composite Skill

This is a temporary, implementation-scoped architecture proposal for
`octon-concept-integration-composite-skill`.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Add a first-party bundled extension pack that internalizes the
  concept-integration prompt set as a reusable composite-skill capability with
  a stable command wrapper, pack-local prompt assets, and proposal-packet-first
  outputs.

## Promotion Targets

- `.octon/inputs/additive/extensions/octon-concept-integration/`
- `.octon/instance/extensions.yml`
- `.octon/instance/bootstrap/catalog.md`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/current-state-gap-map.md`
6. `architecture/file-change-map.md`
7. `architecture/validation-plan.md`
8. `architecture/acceptance-criteria.md`
9. `architecture/implementation-plan.md`
10. `resources/current-state-observations.md`
11. `navigation/artifact-catalog.md`
12. `/.octon/generated/proposals/registry.yml`

## Exit Path

Remain active until the extension pack, command wrapper, pack-local prompt
assets, and enablement guidance land under the declared `/.octon/**`
promotion targets and the resulting capability can generate validated proposal
packets without depending on the root `.prompts/` source path at runtime.

## Registry

Proposal operations regenerate `/.octon/generated/proposals/registry.yml` from
proposal manifests when this proposal is created, promoted, archived,
rejected, or materially reclassified. The registry is a committed discovery
projection only.
