# Proposal Reading And Precedence Map

## Purpose

This file defines the proposal-local reading order, authority boundaries, and
evidence model for this temporary design proposal. It does not make the
proposal a canonical repository authority.

## External Authorities

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-wide authority and non-canonical rules | `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | These durable surfaces outrank this proposal. |
| Proposal workspace layout and lifecycle contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/design-proposal-standard.md` | These durable proposal rules define placement, lifecycle, and packet expectations. |
| Design subtype contract | `.octon/framework/scaffolding/runtime/templates/design-proposal.schema.json`, `.octon/framework/assurance/runtime/_ops/scripts/validate-design-proposal.sh` | The subtype manifest, module rules, and validator behavior must remain aligned. |
| Proposal registry projection contract | `.octon/generated/proposals/registry.yml`, `.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json` | The registry is projection-only and never outranks the manifests. |
| Workflow evidence location | `.octon/state/evidence/runs/workflows/`, `.octon/state/evidence/validation/` | Proposal operation receipts belong under retained evidence, not inside the proposal packet. |

## Primary Proposal Inputs

### Core

- `proposal.yml`
- `design-proposal.yml`
- `implementation/README.md`
- `implementation/minimal-implementation-blueprint.md`
- `implementation/first-implementation-plan.md`

### Class-Specific Normative Docs

{{CLASS_PRIMARY_DOCS}}

### Optional Modules

{{OPTIONAL_MODULE_DOCS}}

### Discovery Projection

- `/.octon/generated/proposals/registry.yml`

## Proposal-Local Authority Roles

| Artifact | Role | Authority level |
| --- | --- | --- |
| `proposal.yml` | Base identity, scope, targets, lifecycle, and exit contract | Highest proposal-local |
| `design-proposal.yml` | Design subtype class, module, and validation contract | Secondary proposal-local |
| Class-specific normative docs | The design-spec authority that implementation and review rely on | Primary working design surface |
| `implementation/*.md` | Implementation framing and first-slice guidance | Supporting implementation guidance |
| Optional module docs | Supporting reference, history, contracts, conformance, and canonicalization material | Supporting, not authoritative over manifests |
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
3. `design-proposal.yml`
4. Class-specific normative docs
5. `implementation/README.md`
6. `implementation/minimal-implementation-blueprint.md`
7. `implementation/first-implementation-plan.md`
8. Optional module docs
9. `navigation/source-of-truth-map.md`
10. `navigation/artifact-catalog.md`
11. `/.octon/generated/proposals/registry.yml`
12. `README.md`

## Boundary Rules

- This proposal remains temporary and non-canonical even when its content is implementation-ready.
- Durable runtime, documentation, policy, and contract outputs must be promoted outside `/.octon/inputs/exploratory/proposals/`.
- Proposal discovery is allowed through the committed registry projection, but lifecycle truth stays in `proposal.yml` and `design-proposal.yml`.
- Proposal operation evidence belongs under `state/evidence/**`, not inside the proposal packet or under `generated/**`.
