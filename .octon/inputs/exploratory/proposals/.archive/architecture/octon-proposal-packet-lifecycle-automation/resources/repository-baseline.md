# Repository Baseline

## Existing Proposal Infrastructure

Relevant current Octon surfaces include:

- `.octon/inputs/exploratory/proposals/README.md`
- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`
- `.octon/framework/scaffolding/governance/patterns/design-proposal-standard.md`
- `.octon/framework/scaffolding/governance/patterns/migration-proposal-standard.md`
- `.octon/framework/scaffolding/governance/patterns/policy-proposal-standard.md`
- `.octon/framework/scaffolding/runtime/templates/proposal-*`
- `.octon/framework/orchestration/runtime/workflows/meta/create-*-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/validate-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`

## Existing Related Extension Packs

- `octon-concept-integration`: source-to-packet, refresh/supersession, and packet-to-implementation.
- `octon-impact-map-and-validation-selector`: impact map, validation selection, next route.
- `octon-drift-triage`: changed-path drift triage into remediation package.
- `octon-retirement-and-hygiene-packetizer`: cleanup and migration proposal drafting.
- `octon-pack-scaffolder`: additive pack and prompt bundle scaffolding.

## Baseline Conclusion

Octon does not need a new proposal authority model. It needs a first-party
lifecycle automation pack that composes the existing proposal and extension
systems into a complete reusable operator flow.
