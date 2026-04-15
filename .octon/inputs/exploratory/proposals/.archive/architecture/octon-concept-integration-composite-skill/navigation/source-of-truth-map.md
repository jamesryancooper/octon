# Proposal Reading And Precedence Map

## Purpose

This file defines the proposal-local reading order, authority boundaries, and
evidence model for this temporary architecture proposal. It does not make the
proposal a canonical repository authority.

## External Authorities

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-wide authority and non-canonical rules | `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/framework/constitution/**` | These durable surfaces outrank this proposal. |
| Extension-pack placement, trust, and publication rules | `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/README.md`, `.octon/framework/engine/governance/extensions/README.md`, `.octon/framework/engine/governance/extensions/trust-and-compatibility.md` | The proposed pack must remain additive, non-authoritative, and publication-backed. |
| Skill and composite-skill design rules | `.octon/framework/capabilities/README.md`, `.octon/framework/capabilities/_meta/architecture/comparison.md`, `.octon/framework/capabilities/runtime/skills/composite-skills.md` | These sources determine why the reusable capability is a composite skill rather than a workflow or repo-native skill. |
| Proposal workspace layout and lifecycle contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | These durable proposal rules define placement, lifecycle, and subtype requirements. |
| Runtime-facing extension publication model | `.octon/framework/cognition/_meta/architecture/generated/effective/extensions/README.md`, `.octon/generated/effective/extensions/catalog.effective.yml`, `.octon/generated/effective/capabilities/routing.effective.yml` | Runtime-facing extension consumption must flow through generated effective state rather than raw pack paths. |
| Workflow and validation evidence location | `.octon/state/evidence/runs/workflows/`, `.octon/state/evidence/validation/` | Proposal operation receipts belong under retained evidence, not inside the proposal package. |

## Primary Proposal Inputs

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
11. `navigation/artifact-catalog.md`
12. `/.octon/generated/proposals/registry.yml`

## Proposal-Local Authority Roles

| Artifact | Role | Authority level |
| --- | --- | --- |
| `proposal.yml` | Base identity, scope, targets, lifecycle, and exit contract | Highest proposal-local |
| `architecture-proposal.yml` | Subtype-specific structured contract | Secondary proposal-local |
| `architecture/target-architecture.md` | Intended landing architecture and scope boundaries | Primary working surface |
| `architecture/current-state-gap-map.md` | Current-state constraints that justify the change | Primary supporting surface |
| `architecture/file-change-map.md` | Durable file-level promotion map | Supporting working surface |
| `architecture/validation-plan.md` | Validation and publication path for the landing | Supporting working surface |
| `architecture/acceptance-criteria.md` | Closure proof conditions for promotion | Supporting working surface |
| `architecture/implementation-plan.md` | Ordered workstreams and sequencing | Supporting working surface |
| `resources/current-state-observations.md` | Repo-grounded observations used to build the packet | Explanatory support |
| `navigation/source-of-truth-map.md` | Manual proposal-local precedence, authority, and evidence map | Explanatory support |
| `navigation/artifact-catalog.md` | Generated file inventory for the current package shape | Low-authority generated inventory |
| `/.octon/generated/proposals/registry.yml` | Discovery projection rebuilt from proposal manifests | Projection only |
| `README.md` | Human entry point and reading guidance | Explanatory only |

## Derived Or Projection-Only Surfaces

| Surface | Status | Rule |
| --- | --- | --- |
| `/.octon/generated/proposals/registry.yml` | Committed projection | Must be regenerated from manifests or fail-closed validated; never authoritative over manifests |
| `/.octon/generated/effective/extensions/**` | Rebuildable projection | Runtime-facing extension publication is derived from raw pack inputs plus repo-owned extension state |
| `/.octon/generated/effective/capabilities/**` | Rebuildable projection | Extension command and skill routing may appear here only through published `routing_exports`, never by reading raw pack paths directly |
| `navigation/artifact-catalog.md` | Generated inventory | Reflects the current package shape but does not define lifecycle truth |
| Workflow bundles under `state/evidence/runs/workflows/**` | Retained evidence | Evidence of proposal operations, not lifecycle authority |

## Conflict Resolution

1. Repository-wide governance and durable authorities
2. `proposal.yml`
3. `architecture-proposal.yml`
4. `architecture/target-architecture.md`
5. `architecture/current-state-gap-map.md`
6. `architecture/file-change-map.md`
7. `architecture/validation-plan.md`
8. `architecture/acceptance-criteria.md`
9. `architecture/implementation-plan.md`
10. `resources/current-state-observations.md`
11. `navigation/source-of-truth-map.md`
12. `navigation/artifact-catalog.md`
13. `/.octon/generated/proposals/registry.yml`

## Boundary Rules

- This proposal remains temporary and non-canonical at every lifecycle stage.
- Durable runtime, documentation, policy, and contract outputs must be
  promoted outside `/.octon/inputs/exploratory/proposals/`.
- The runtime landing must keep any root-level prompt-set copy out of the
  durable dependency chain; reusable prompt assets must live in the pack
  itself.
- Proposal discovery is allowed through the committed registry projection, but
  lifecycle truth stays in `proposal.yml` and `architecture-proposal.yml`.
- Proposal operation evidence belongs under `state/evidence/**`, not inside
  the proposal package or under `generated/**`.
