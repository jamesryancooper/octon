# External `.extensions` Sidecar Pack System

This is a temporary, implementation-scoped architecture proposal for
`extensions-sidecar-pack-system`.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `harmony-internal`
- summary: Define the full Harmony-side implementation that lets the harness discover, validate, compile, and consume additive extension content from a repo-root `.extensions/` sidecar without creating a second authority surface.

## Promotion Targets

- `.harmony/engine/runtime/`
- `.harmony/engine/governance/`
- `.harmony/capabilities/runtime/`
- `.harmony/capabilities/_meta/architecture/`
- `.harmony/assurance/runtime/`
- `.harmony/scaffolding/`
- `.harmony/orchestration/runtime/workflows/`
- `.harmony/harmony.yml`

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

## Supporting Reference Set

This proposal also includes:

- a proposed schema for `/.extensions/catalog.yml`
- a proposed schema for `/.extensions/<pack-id>/pack.yml`
- a merge and precedence spec for Harmony effective indexes
- a concrete example pack rooted at `/.extensions/nextjs/`

## Exit Path

Promote the durable extension boundary, loader rules, validator stack,
effective-index compiler, authoring scaffolds, and operator workflows into
`/.harmony/`. Treat the repo-root `/.extensions/` surface as an implementation
outcome described by the promoted architecture, not as proposal authority.
