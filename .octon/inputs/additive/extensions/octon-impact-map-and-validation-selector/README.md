# Octon Impact Map And Validation Selector Extension Pack

This bundled additive pack turns:

- touched repo paths
- proposal packets
- refactor targets
- mixed input sets

into one deterministic answer:

- an impact map
- the minimum credible validation set
- the rationale trace for that set
- the next canonical route to take

## Buckets

- `skills/` - dispatcher and leaf skill contracts
- `commands/` - thin operator-facing command wrappers
- `prompts/` - one prompt bundle per route plus shared output and routing rules
- `context/` - pack-local overview, routing guidance, examples, and reuse rules
- `validation/` - compatibility profile, scenario docs, and extension-local tests

## Stable Entry Point

- skill: `octon-impact-map-and-validation-selector`
- command: `/octon-impact-map-and-validation-selector`

Default route:

- `touched-paths`

## Prompt Contract SSOT

- each `prompts/<bundle>/manifest.yml` is the source of truth for that route's
  prompt inventory and required repo anchors
- `prompts/shared/*.md` holds the pack-wide output and routing rules
- `/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh`
  is the behavioral source of truth for prompt-bundle freshness

## Boundary

This pack is additive only.

It must not become a direct runtime or policy authority surface.
Runtime-facing consumption must flow through generated effective extension and
capability outputs, not through raw pack paths.
