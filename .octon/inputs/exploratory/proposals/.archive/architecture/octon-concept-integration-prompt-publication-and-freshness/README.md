# Octon Concept Integration Prompt Publication And Freshness

This is a temporary, implementation-scoped architecture proposal for
`octon-concept-integration-prompt-publication-and-freshness`.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Add an authored prompt-set contract, generated effective prompt
  bundle publication, fail-closed freshness and alignment gating, and
  run-level prompt provenance for the `octon-concept-integration` extension
  pack.

## Promotion Targets

- `.octon/inputs/additive/extensions/octon-concept-integration/prompts/octon-concept-integration-pipeline/`
- `.octon/inputs/additive/extensions/octon-concept-integration/skills/octon-concept-integration/SKILL.md`
- `.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml`
- `.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh`
- `.octon/framework/cognition/_meta/architecture/generated/effective/extensions/`
- `.octon/framework/capabilities/runtime/services/modeling/prompt/`
- `.octon/state/evidence/runs/skills/octon-concept-integration/`

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
11. `resources/source-artifact.md`
12. `navigation/artifact-catalog.md`
13. `/.octon/generated/proposals/registry.yml`

## Exit Path

Remain active until prompt publication, freshness validation, fail-closed
skill gating, and run-level prompt provenance land in durable surfaces and the
concept-integration pack can no longer run on stale prompt assumptions without
explicitly failing closed or re-aligning first.

## Registry

Proposal operations regenerate `/.octon/generated/proposals/registry.yml` from
proposal manifests when this proposal is created, promoted, archived,
rejected, or materially reclassified. The registry is a committed discovery
projection only.
