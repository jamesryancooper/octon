# Proposal Reading And Precedence Map

## Purpose

This file defines the proposal-local reading order, authority boundaries, and
evidence model for this temporary architecture proposal. It does not make the
proposal a canonical repository authority.

## External Authorities

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-wide authority and non-canonical rules | `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/framework/constitution/**` | These durable surfaces outrank this proposal. |
| Extension-pack placement and publication rules | `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/README.md`, `.octon/framework/cognition/_meta/architecture/generated/effective/extensions/README.md`, `.octon/framework/engine/governance/extensions/README.md` | The prompt publication model must remain additive, generated, and non-authoritative. |
| Prompt compilation and fail-closed prompt service behavior | `.octon/framework/capabilities/runtime/services/modeling/prompt/guide.md` and companion contract artifacts | The follow-on should reuse the native prompt modeling lane rather than inventing a second prompt compiler. |
| Current concept-integration pack intent | `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-concept-integration-composite-skill/**` | This follow-on packet hardens that live extension-pack landing. |
| Proposal workspace layout and lifecycle contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | These durable proposal rules define placement, lifecycle, and subtype requirements. |
| Workflow and validation evidence location | `.octon/state/evidence/runs/workflows/`, `.octon/state/evidence/validation/`, `.octon/state/evidence/runs/skills/` | Publication receipts and run provenance belong under retained evidence, not inside the proposal package. |

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
11. `resources/source-artifact.md`
12. `navigation/artifact-catalog.md`
13. `/.octon/generated/proposals/registry.yml`

## Proposal-Local Authority Roles

| Artifact | Role | Authority level |
| --- | --- | --- |
| `proposal.yml` | Base identity, scope, targets, lifecycle, and exit contract | Highest proposal-local |
| `architecture-proposal.yml` | Subtype-specific structured contract | Secondary proposal-local |
| `architecture/target-architecture.md` | Intended end-state publication, gating, and provenance model | Primary working surface |
| `architecture/current-state-gap-map.md` | Current-state constraints that justify the hardening work | Primary supporting surface |
| `architecture/file-change-map.md` | Durable file-level promotion map | Supporting working surface |
| `architecture/validation-plan.md` | Publication, freshness, and proof burden for the landing | Supporting working surface |
| `architecture/acceptance-criteria.md` | Closure proof conditions for promotion | Supporting working surface |
| `architecture/implementation-plan.md` | Ordered workstreams and sequencing | Supporting working surface |
| `resources/current-state-observations.md` | Repo-grounded observations used to build the packet | Explanatory support |
| `resources/source-artifact.md` | Captured design intent for the follow-on hardening | Explanatory support |
| `navigation/source-of-truth-map.md` | Manual proposal-local precedence, authority, and evidence map | Explanatory support |
| `navigation/artifact-catalog.md` | Generated file inventory for the current package shape | Low-authority generated inventory |
| `/.octon/generated/proposals/registry.yml` | Discovery projection rebuilt from proposal manifests | Projection only |
| `README.md` | Human entry point and reading guidance | Explanatory only |

## Derived Or Projection-Only Surfaces

| Surface | Status | Rule |
| --- | --- | --- |
| `/.octon/generated/proposals/registry.yml` | Committed projection | Must be regenerated from manifests or fail-closed validated; never authoritative over manifests |
| `/.octon/generated/effective/extensions/**` | Rebuildable projection | Runtime-facing extension prompt consumption must flow through generated effective state rather than raw pack files |
| prompt bundle publication receipts under `state/evidence/validation/**` | Retained evidence | Evidence of prompt publication and freshness, not authority |
| run-level prompt provenance under `state/evidence/runs/skills/**` | Retained evidence | Records which prompt bundle and alignment receipt a run used |
| `navigation/artifact-catalog.md` | Generated inventory | Reflects the current package shape but does not define lifecycle truth |

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
11. `resources/source-artifact.md`
12. `navigation/source-of-truth-map.md`
13. `navigation/artifact-catalog.md`
14. `/.octon/generated/proposals/registry.yml`

## Boundary Rules

- This proposal remains temporary and non-canonical at every lifecycle stage.
- Durable runtime, documentation, policy, and contract outputs must be
  promoted outside `/.octon/inputs/exploratory/proposals/`.
- The follow-on must not make raw prompt files under `inputs/**` authoritative;
  it may only make them published runtime-facing inputs when backed by
  generated effective state, retained receipts, and fail-closed freshness
  checks.
- Prompt publication and alignment receipts belong under retained evidence, not
  under generated outputs.
- Proposal discovery is allowed through the committed registry projection, but
  lifecycle truth stays in `proposal.yml` and `architecture-proposal.yml`.
