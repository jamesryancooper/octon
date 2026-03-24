# Proposal Reading And Precedence Map

## Purpose

This file defines the proposal-local reading order, authority boundaries, and
evidence model for this temporary design proposal. It does not make the
proposal a canonical repository authority.

## External Authorities

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-wide authority and non-canonical rules | `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | These durable surfaces outrank this proposal. |
| Proposal workspace layout and lifecycle contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/design-proposal-standard.md` | These durable proposal rules define placement, lifecycle, and package expectations. |
| Design subtype contract | `.octon/framework/scaffolding/runtime/templates/design-proposal.schema.json`, `.octon/framework/assurance/runtime/_ops/scripts/validate-design-proposal.sh` | The subtype manifest, module rules, and validator behavior must remain aligned. |
| Proposal registry projection contract | `.octon/generated/proposals/registry.yml`, `.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json` | The registry is projection-only and never outranks the manifests. |
| Workflow evidence location | `.octon/state/evidence/runs/workflows/`, `.octon/state/evidence/validation/` | Proposal operation receipts belong under retained evidence, not inside the proposal package. |

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

## Conflict Resolution

1. Repository-wide governance and durable authorities
2. `proposal.yml`
3. `design-proposal.yml`
4. class-specific normative docs
5. `implementation/README.md`
6. `implementation/minimal-implementation-blueprint.md`
7. `implementation/first-implementation-plan.md`
8. optional module docs
9. `/.octon/generated/proposals/registry.yml`

## Boundary Rules

- This proposal remains temporary and non-canonical at every lifecycle stage.
- Durable runtime, documentation, policy, and contract outputs must be
  promoted outside `/.octon/inputs/exploratory/proposals/`.
- Proposal discovery is allowed through the committed registry projection, but
  lifecycle truth stays in `proposal.yml` and `design-proposal.yml`.
- Proposal operation evidence belongs under `state/evidence/**`, not inside
  the proposal package or under `generated/**`.
