# Proposal Reading And Precedence Map

## Purpose

This file defines the proposal-local reading order, authority boundaries, and
evidence model for this temporary architecture proposal. It does not make the
proposal a canonical repository authority.

## External Authorities

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-wide constitutional authority | `.octon/framework/constitution/**`, `.octon/octon.yml`, `.octon/instance/bootstrap/START.md` | Durable constitutional and runtime inputs outrank this proposal. |
| Runtime authority and execution behavior | `.octon/framework/engine/runtime/**`, `.octon/state/control/execution/**`, `.octon/state/evidence/**` | Live control and retained evidence outrank proposal intent for current-state claims. |
| Proposal workspace lifecycle and subtype contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | These govern package shape and lifecycle, not the target architecture itself. |
| Archived predecessor intent | `.octon/inputs/exploratory/proposals/.archive/architecture/fully-unified-execution-constitution-for-governed-autonomous-work/` | Historical design intent only; never runtime authority. |
| Proposal registry projection contract | `.octon/generated/proposals/registry.yml` | Discovery-only projection. |

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
| `proposal.yml` | Identity, lifecycle, scope, and promotion target contract | Highest proposal-local |
| `architecture-proposal.yml` | Architecture subtype classification | Secondary proposal-local |
| `architecture/target-architecture.md` | Desired closeout state and architectural deltas | Primary working design surface |
| `architecture/acceptance-criteria.md` | Completion proof contract for the closeout | Primary working verification surface |
| `architecture/implementation-plan.md` | Atomic cutover contract and landing choreography | Primary working delivery surface |
| `navigation/source-of-truth-map.md` | Proposal-local precedence and evidence rules | Explanatory support |
| `navigation/artifact-catalog.md` | Visible package inventory | Low-authority generated inventory |
| `/.octon/generated/proposals/registry.yml` | Discovery projection rebuilt from manifests | Projection only |
| `README.md` | Human entry point and reading guidance | Explanatory only |

## Derived Or Projection-Only Surfaces

| Surface | Status | Rule |
| --- | --- | --- |
| `/.octon/generated/proposals/registry.yml` | Committed projection | Must be regenerated from manifests; never authoritative over manifests |
| `navigation/artifact-catalog.md` | Generated inventory | Reflects visible package shape only |
| Workflow bundles under `state/evidence/runs/workflows/**` | Retained evidence | Evidence of proposal operations, not lifecycle truth |

## Conflict Resolution

1. Repository-wide constitutional, runtime, control, and evidence authorities
2. `proposal.yml`
3. `architecture-proposal.yml`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. `navigation/source-of-truth-map.md`
8. `navigation/artifact-catalog.md`
9. `/.octon/generated/proposals/registry.yml`
10. `README.md`

## Boundary Rules

- This proposal remains temporary and non-canonical at every lifecycle stage.
- Durable runtime, documentation, policy, and contract outputs must be promoted
  outside `/.octon/inputs/exploratory/proposals/`.
- The archived unified-execution proposal is intent lineage only; it must not be
  used as live implementation proof.
- Proposal completion requires durable evidence from the canonical runtime,
  control, validation, and disclosure roots rather than proposal-local claims.
