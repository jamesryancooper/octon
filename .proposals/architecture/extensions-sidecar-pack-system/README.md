# External `.extensions` Sidecar Pack System

This is a temporary, implementation-scoped architecture proposal for
`extensions-sidecar-pack-system`.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Define the full Octon-side implementation that lets the harness discover, validate, compile, and consume additive extension content from a repo-root `.extensions/` sidecar without creating a second authority surface.

## Promotion Targets

- `.octon/engine/runtime/`
- `.octon/engine/governance/`
- `.octon/capabilities/runtime/`
- `.octon/capabilities/_meta/architecture/`
- `.octon/assurance/runtime/`
- `.octon/scaffolding/`
- `.octon/orchestration/runtime/workflows/`
- `.octon/octon.yml`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `architecture/target-architecture.md`
4. `architecture/acceptance-criteria.md`
5. `architecture/implementation-plan.md`
6. `reference/effective-index-merge-and-precedence.md`
7. `reference/catalog.schema.json`
8. `reference/pack.schema.json`
9. `examples/.extensions/nextjs/`
10. `examples/.extensions/docs/`
11. `examples/.extensions/node-ts/`

## Supporting Reference Set

This proposal also includes:

- a proposed schema for `/.extensions/catalog.yml`
- a proposed schema for `/.extensions/<pack-id>/pack.yml`
- a merge and precedence spec for Octon effective indexes
- concrete example packs rooted at:
  - `/.extensions/nextjs/`
  - `/.extensions/docs/`
  - `/.extensions/node-ts/`

## Exit Path

Promote the durable extension boundary, loader rules, validator stack,
effective-index compiler, authoring scaffolds, and operator workflows into
`/.octon/`. Treat the repo-root `/.extensions/` surface as an implementation
outcome described by the promoted architecture, not as proposal authority.
