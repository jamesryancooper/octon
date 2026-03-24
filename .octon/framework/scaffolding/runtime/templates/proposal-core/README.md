# {{PROPOSAL_TITLE}}

This is a temporary, implementation-scoped proposal for `{{PROPOSAL_ID}}`.
It is a build or decision aid. It is not a canonical runtime, documentation,
policy, or contract authority.

## Purpose

- proposal kind: `{{PROPOSAL_KIND}}`
- promotion scope: `{{PROMOTION_SCOPE}}`
- summary: {{PROPOSAL_SUMMARY}}

## Promotion Targets

{{PROMOTION_TARGETS_BULLETS}}

## Reading Order

1. `proposal.yml`
2. subtype manifest
3. `navigation/source-of-truth-map.md`
4. subtype-specific documents
5. `navigation/artifact-catalog.md`
6. `/.octon/generated/proposals/registry.yml`

## Exit Path

{{EXIT_EXPECTATION}}

## Registry

Proposal operations regenerate `/.octon/generated/proposals/registry.yml` from
proposal manifests when this proposal is created, promoted, archived,
rejected, or materially reclassified. The registry is a committed discovery
projection only; it does not outrank `proposal.yml` or the subtype manifest.
