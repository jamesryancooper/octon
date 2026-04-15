# Extension Skill Registry Effective Surface

This is a temporary, implementation-scoped architecture proposal for
`octon-extension-skill-registry-effective-surface`.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Add a generated effective surface for extension skill registry
  metadata so extension-contributed composite skills are introspectable without
  rereading raw pack payloads.

## Promotion Targets

- `.octon/framework/cognition/_meta/architecture/generated/effective/extensions/`
- `.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh`
- `.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. `support/concept-verification-output.md`
8. `navigation/artifact-catalog.md`
9. `/.octon/generated/proposals/registry.yml`

## Exit Path

Remain active until the proposed effective extension skill registry surface,
publisher updates, and validation coverage land outside the proposal workspace.
