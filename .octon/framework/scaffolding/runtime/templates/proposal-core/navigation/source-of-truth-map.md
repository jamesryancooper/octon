# Proposal Reading And Precedence Map

## Purpose

This file defines the proposal-local reading order, authority boundaries, and
evidence model for this temporary proposal. It does not make the proposal a
canonical repository authority.

## External Authorities

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-wide authority and non-canonical rules | `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | These durable surfaces outrank this proposal. |
| Proposal workspace layout and lifecycle contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md` | These durable proposal rules define placement, lifecycle, and package expectations. |
| Proposal registry projection contract | `.octon/generated/proposals/registry.yml`, `.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json` | The registry is projection-only and never outranks the manifests. |
| Workflow evidence location | `.octon/state/evidence/runs/workflows/`, `.octon/state/evidence/validation/` | Proposal operation receipts belong under retained evidence, not inside the proposal package. |

## Primary Proposal Inputs

1. `proposal.yml`
2. subtype manifest
3. `navigation/source-of-truth-map.md`
4. subtype-specific implementation documents
5. `navigation/artifact-catalog.md`
6. `/.octon/generated/proposals/registry.yml`

## Conflict Resolution

1. Repository-wide governance and durable authorities
2. `proposal.yml`
3. subtype manifest
4. subtype-specific proposal docs
5. `navigation/source-of-truth-map.md`
6. `navigation/artifact-catalog.md`
7. `/.octon/generated/proposals/registry.yml`

## Boundary Rules

- This proposal remains temporary and non-canonical at every lifecycle stage.
- Durable runtime, documentation, policy, and contract outputs must be
  promoted outside `/.octon/inputs/exploratory/proposals/`.
- Proposal discovery is allowed through the committed registry projection, but
  lifecycle truth stays in `proposal.yml` and the subtype manifest.
- Proposal operation evidence belongs under `state/evidence/**`, not inside
  the proposal package or under `generated/**`.
