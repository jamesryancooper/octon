# Proposal Reading And Precedence Map

## Purpose

This file defines the reading order, authority boundaries, and evidence model
for the temporary `octon-completion` architecture proposal. It does not make
the proposal a canonical repository authority.

## External Authorities

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-wide authority and non-canonical rules | `.octon/instance/ingress/AGENTS.md`, `.octon/framework/constitution/**`, `.octon/instance/charter/**`, `.octon/README.md` | Durable authorities outrank this proposal. |
| Proposal workspace layout and lifecycle contract | `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | These define the required package shape and lifecycle rules. |
| Proposal registry projection contract | `.octon/generated/proposals/registry.yml`, `.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json` | The registry is discovery-only and never outranks proposal manifests. |
| Workflow evidence location | `.octon/state/evidence/runs/workflows/`, `.octon/state/evidence/validation/` | Proposal operation receipts belong under retained evidence, not inside the proposal package. |

## Primary Proposal Inputs

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. `proposal/00_octon_completion_proposal_packet.md`
8. `prompts/00_revised_master_prompt.md`
9. `resources/00_authoritative_audit.md`
10. `resources/01_packet_basis_refinements.md`
11. `resources/02_prompt_delta.md`
12. `resources/03_traceability_matrix.md`
13. `navigation/artifact-catalog.md`
14. `/.octon/generated/proposals/registry.yml`

## Proposal-Local Authority Roles

| Artifact | Role | Authority level |
| --- | --- | --- |
| `proposal.yml` | Base identity, scope, promotion targets, lifecycle, and exit contract | Highest proposal-local |
| `architecture-proposal.yml` | Structured architecture subtype contract | Secondary proposal-local |
| `architecture/target-architecture.md` | Standard target-state summary for the intended durable architecture | Primary working surface |
| `architecture/acceptance-criteria.md` | Acceptance conditions that must be satisfied outside the proposal path | Primary working surface |
| `architecture/implementation-plan.md` | Workstream plan for promoting durable results | Primary working surface |
| `proposal/00_octon_completion_proposal_packet.md` | Full companion packet with the detailed A-S design program | Supporting design companion |
| `prompts/00_revised_master_prompt.md` | Regeneration/delegation prompt that preserves the packet framing | Supporting prompt |
| `resources/*.md` | Audit evidence, rationale refinements, delta notes, and traceability | Supporting evidence |
| `navigation/source-of-truth-map.md` | Manual proposal-local precedence and boundary map | Explanatory support |
| `navigation/artifact-catalog.md` | Generated file inventory for the current package shape | Low-authority generated inventory |
| `/.octon/generated/proposals/registry.yml` | Discovery projection rebuilt from manifests | Projection only |
| `README.md` | Human entry point and reading guidance | Explanatory only |

## Derived Or Projection-Only Surfaces

| Surface | Status | Rule |
| --- | --- | --- |
| `/.octon/generated/proposals/registry.yml` | Committed projection | Must be regenerated from manifests and never outranks them |
| `navigation/artifact-catalog.md` | Generated inventory | Reflects the current package shape but does not define lifecycle truth |
| Workflow bundles under `state/evidence/runs/workflows/**` | Retained evidence | Evidence of proposal operations, not lifecycle authority |

## Conflict Resolution

1. Repository-wide governance and durable authorities
2. `proposal.yml`
3. `architecture-proposal.yml`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. `proposal/00_octon_completion_proposal_packet.md`
8. `prompts/00_revised_master_prompt.md`
9. `resources/00_authoritative_audit.md`
10. `resources/01_packet_basis_refinements.md`
11. `resources/02_prompt_delta.md`
12. `resources/03_traceability_matrix.md`
13. `navigation/source-of-truth-map.md`
14. `navigation/artifact-catalog.md`
15. `/.octon/generated/proposals/registry.yml`

## Boundary Rules

- This proposal remains temporary and non-canonical at every lifecycle stage.
- Durable runtime, documentation, policy, and contract outputs must be
  promoted outside `/.octon/inputs/exploratory/proposals/`.
- This proposal may define the conditions for an honest completion claim, but
  it may not serve as the claim authority itself.
- Proposal discovery is allowed through the committed registry projection, but
  lifecycle truth stays in `proposal.yml` and `architecture-proposal.yml`.
- Proposal operation evidence belongs under `state/evidence/**`, not inside
  the proposal package or under `generated/**`.
