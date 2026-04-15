# Proposal Reading And Precedence Map

## External Authorities

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Extension-pack placement and publication rules | `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/README.md`, `.octon/framework/cognition/_meta/architecture/generated/effective/extensions/README.md` | These durable surfaces outrank this proposal. |
| Publisher and validator behavior | `.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh`, `.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh`, `.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh` | Live scripts determine current behavior. |
| Proposal workspace rules | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | Proposal-local lifecycle stays subordinate to these rules. |

## Primary Proposal Inputs

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. `support/source-artifact.md`
8. `support/concept-extraction-output.md`
9. `support/concept-verification-output.md`
10. `support/executable-implementation-prompt.md`
11. `navigation/artifact-catalog.md`

## Boundary Rules

- This proposal remains temporary and non-authoritative.
- Any effective extension skill registry surface must remain generated and
  non-authoritative.
- Runtime and policy consumers must continue to avoid direct reads from raw
  pack payloads under `inputs/**`.
