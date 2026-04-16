# Octon Pack Scaffolder Extension Pack

This bundled additive pack scaffolds new additive extension packs and common
pack-local assets under `/.octon/inputs/additive/extensions/<pack-id>/`.

It is designed to:

- scaffold a new extension pack root
- scaffold pack-local prompt bundles, skills, commands, context docs, and
  validation fixtures
- keep extension authoring additive and aligned with the existing extension
  publication model

## Buckets

- `skills/` - family root plus explicit leaf scaffolding skills
- `commands/` - thin command wrappers for stable invocation
- `context/` - output shapes, examples, and usage guidance
- `validation/` - compatibility profile, scenarios, and extension-local tests

## Boundary

This pack is additive only.

It may create or update raw pack content under
`/.octon/inputs/additive/extensions/<pack-id>/`, but it must not activate,
publish, quarantine, govern, or compile that pack.
Runtime-facing extension consumption must continue to flow through generated
effective extension outputs, never directly from raw pack paths.
