# Proposal Reading And Precedence Map

## Purpose

This file defines the proposal-local reading order, authority boundaries, and
evidence model for this temporary architecture proposal. It does not make the
proposal a canonical repository authority.

## External Authorities

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-wide authority and non-canonical rules | `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | These durable surfaces outrank this proposal. |
| Proposal workspace layout and lifecycle contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | These durable proposal rules define placement, lifecycle, and subtype requirements. |
| Proposal registry projection contract | `.octon/generated/proposals/registry.yml`, `.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json` | The registry is projection-only and never outranks the manifests. |
| Workflow evidence location | `.octon/state/evidence/runs/workflows/`, `.octon/state/evidence/validation/` | Proposal operation receipts belong under retained evidence, not inside the proposal packet. |

## Primary Proposal Inputs

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. `navigation/artifact-catalog.md`
8. `/.octon/generated/proposals/registry.yml`

## Proposal-Local Authority Roles

| Artifact | Role | Authority level |
| --- | --- | --- |
| `proposal.yml` | Base identity, scope, targets, lifecycle, and exit contract | Highest proposal-local |
| `architecture-proposal.yml` | Subtype-specific structured contract | Secondary proposal-local |
| Primary subtype docs | The proposal's working design/architecture/policy surface | Primary working surface |
| `navigation/source-of-truth-map.md` | Manual proposal-local precedence, authority, and evidence map | Explanatory support |
| `navigation/artifact-catalog.md` | Generated file inventory for the current packet shape | Low-authority generated inventory |
| `/.octon/generated/proposals/registry.yml` | Discovery projection rebuilt from proposal manifests | Projection only |
| `README.md` | Human entry point and reading guidance | Explanatory only |

## Derived Or Projection-Only Surfaces

| Surface | Status | Rule |
| --- | --- | --- |
| `/.octon/generated/proposals/registry.yml` | Committed projection | Must be regenerated from manifests or fail-closed validated; never authoritative over manifests |
| `navigation/artifact-catalog.md` | Generated inventory | Reflects the current packet shape but does not define lifecycle truth |
| Workflow bundles under `state/evidence/runs/workflows/**` | Retained evidence | Evidence of proposal operations, not lifecycle authority |

## Conflict Resolution

1. Repository-wide governance and durable authorities
2. `proposal.yml`
3. `architecture-proposal.yml`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. `navigation/source-of-truth-map.md`
8. `navigation/artifact-catalog.md`
9. `/.octon/generated/proposals/registry.yml`

## Boundary Rules

- This proposal remains temporary and non-canonical at every lifecycle stage.
- Durable runtime, documentation, policy, and contract outputs must be
  promoted outside `/.octon/inputs/exploratory/proposals/`.
- Proposal discovery is allowed through the committed registry projection, but
  lifecycle truth stays in `proposal.yml` and `architecture-proposal.yml`.
- Proposal operation evidence belongs under `state/evidence/**`, not inside
  the proposal packet or under `generated/**`.
