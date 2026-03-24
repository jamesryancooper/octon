# Proposal Reading And Precedence Map

## Purpose
This file defines the proposal-local reading order, authority boundaries, and evidence model for the proposal-system update. It does not make this proposal a canonical repository authority.

## External Authorities
| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-wide authority and non-canonical rules | `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | These durable surfaces outrank this proposal. |
| Proposal workspace layout, non-canonical rule, and manifest authority order | `.octon/inputs/exploratory/proposals/README.md` and `.octon/framework/scaffolding/governance/patterns/proposal-standard.md` | These are the current constraints this proposal updates but does not override before promotion. |
| Subtype file requirements and current manifest shape | `.octon/framework/scaffolding/governance/patterns/*-proposal-standard.md`, `.octon/framework/scaffolding/runtime/templates/*.schema.json`, `.octon/framework/assurance/runtime/_ops/scripts/validate-*-proposal*.sh` | Current repo evidence shows these layers drift in places; this proposal chooses the target contract to promote. |
| Proposal registry projection contract | `.octon/generated/proposals/registry.yml` and `.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json` | The registry remains projection-only and may not outrank manifests. |
| Workflow evidence location | `.octon/state/evidence/runs/workflows/` and `.octon/state/evidence/validation/` | Promotion and archive receipts belong under retained evidence, not proposal-local paths. |

## Primary Proposal Inputs
1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/proposal-system-critique.md`
4. `resources/contract-alignment-matrix.md`
5. `resources/registry-drift-report.md`
6. `resources/archive-normalization-inventory.md`
7. `architecture/target-architecture.md`
8. `architecture/acceptance-criteria.md`
9. `architecture/implementation-plan.md`

## Proposal-Local Authority Roles
| Artifact | Role | Authority level |
| --- | --- | --- |
| `proposal.yml` | Base identity, scope, targets, lifecycle, and exit contract | Highest proposal-local |
| `architecture-proposal.yml` | Architecture subtype scope and decision classification | Secondary proposal-local |
| `resources/proposal-system-critique.md` | Baseline current-state critique that frames the proposal's problem statement, preserved invariants, and target operating model | Supporting synthesis, not authoritative over manifests |
| `architecture/target-architecture.md` | Chosen next-state design and operating model | Primary narrative design surface |
| `architecture/acceptance-criteria.md` | Promotion proof contract | Binding within the proposal |
| `architecture/implementation-plan.md` | Workstream, sequencing, migration, and rollback plan | Operational planning within the proposal |
| `resources/contract-alignment-matrix.md`, `resources/registry-drift-report.md`, `resources/archive-normalization-inventory.md` | Structured evidence tables and cleanup inventories derived from the critique and used to scope promotion work | Supporting, not authoritative over manifests |
| `README.md` | Human entry point and reading guidance | Explanatory only |
| `navigation/artifact-catalog.md` | Current required inventory file | Low-authority inventory; intended to become generated in the promoted design |

## Derived Or Projection-Only Surfaces
| Surface | Status | Rule |
| --- | --- | --- |
| `/.octon/generated/proposals/registry.yml` | Committed projection | Must be regenerated from manifests or fail-closed validated; never authoritative over manifests |
| Generated artifact catalog in future state | Projection | May replace hand-authored inventory after promotion |
| Workflow bundles under `state/evidence/runs/workflows/**` | Retained evidence | Evidence of proposal operations, not lifecycle authority |

## Conflict Resolution
1. Durable repository-wide architecture, governance, and runtime/ops authorities
2. `proposal.yml`
3. `architecture-proposal.yml`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. `resources/*.md`
8. `README.md`
9. `navigation/artifact-catalog.md`

## Boundary Rules
- This proposal may define how the proposal system should change, but it may not act as durable runtime, policy, or documentation authority.
- Durable repo rules must be promoted into `framework/**`, `instance/**`, committed architecture docs, validators, templates, and workflows outside the proposal workspace.
- Archive normalization work inside `/.octon/inputs/exploratory/proposals/.archive/**` is migration-only cleanup, not durable promoted authority.
- Registry generation and validation must terminate at manifests; no workflow may treat the registry as the lifecycle source of truth.
- Promotion receipts and archive receipts belong under `state/evidence/**`, not under proposal-local paths or `generated/**`.
