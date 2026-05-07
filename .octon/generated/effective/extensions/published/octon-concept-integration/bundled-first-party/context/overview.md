# Octon Concept Integration Overview

This pack now exposes a family of concept-integration bundles rather than one
single prompt lane.

## Stable Entry Point

- skill: `octon-concept-integration`
- command: `/octon-concept-integration`

Default route:

- `source-to-architecture-packet`

## Bundle Families

- source-driven packet generation:
  `source-to-architecture-packet`,
  `source-to-policy-packet`,
  `source-to-migration-packet`
- architecture and governance challenge:
  `architecture-revision-packet`,
  `constitutional-challenge-packet`
- synthesis and scoping:
  `multi-source-synthesis-packet`,
  `subsystem-targeted-integration`,
  `repo-internal-concept-mining`
- packet lifecycle:
  `packet-refresh-and-supersession`,
  `packet-to-implementation`

## Important Boundary

Pack-local prompts are runtime inputs for this extension family, but they
remain non-authoritative additive content. Runtime-facing consumption must flow
through generated effective extension publication outputs.
