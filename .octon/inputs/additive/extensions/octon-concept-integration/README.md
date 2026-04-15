# Octon Concept Integration Extension Pack

This bundled additive pack internalizes a family of concept-integration prompt
bundles as reusable Octon capabilities.

It is designed to:

- route to one of several concept-integration bundles
- support source-driven packet generation, synthesis, refresh, execution,
  architecture revision, and constitutional challenge
- keep command, skill, and prompt bundle names grouped under the same family
  prefix

## Buckets

- `skills/` - composite skill contract and pack-local metadata
- `commands/` - thin command wrapper for stable operator invocation
- `prompts/` - shared prompt-family contracts plus one manifest-governed folder
  per prompt bundle
- `context/` - pack-local overview and usage guidance
- `validation/` - validation and publication guidance

## Prompt Contract SSOT

- each `prompts/<bundle>/manifest.yml` is the source of truth for that bundle's
  prompt inventory, repo anchors, and packet support filenames.
- `prompts/shared/*.md` holds family-wide prompt-bundle behavioral contracts.
- `/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh`
  is the behavioral source of truth for `alignment_mode`.

## Boundary

This pack is additive only.

It must not become a direct runtime or policy authority surface.
Runtime-facing consumption must flow through generated effective extension and
capability publication outputs, not through raw pack paths.
