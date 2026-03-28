# Proposal Reading And Precedence Map

## Purpose

This file defines the proposal-local reading order, authority boundaries, and
evidence model for the fully unified execution constitution proposal. It does
not make the proposal itself a canonical repository authority.

## External Authorities

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-wide topology, class-root boundaries, and non-canonical proposal rules | `.octon/README.md`, `.octon/instance/bootstrap/START.md`, `.octon/framework/cognition/_meta/architecture/specification.md` | These durable surfaces outrank this proposal until promotion lands. |
| Workspace objective and current intent binding | `.octon/instance/bootstrap/OBJECTIVE.md`, `.octon/instance/cognition/context/shared/intent.contract.yml` | The proposal reworks how these surfaces participate in execution, but does not override them pre-promotion. |
| Ingress and execution governance | `.octon/instance/ingress/AGENTS.md`, `.octon/octon.yml`, `.octon/framework/engine/runtime/spec/policy-interface-v1.md` | Current runtime and governance contracts stay authoritative until the promoted constitutional kernel supersedes them. |
| Proposal package contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | These files define the proposal's own lifecycle and required artifacts. |
| Proposal discovery projection | `.octon/generated/proposals/registry.yml` | Discovery only; never lifecycle authority over manifests. |
| Promotion evidence and retained operational receipts | `.octon/state/evidence/**`, `.octon/state/continuity/**` | Promotion proof belongs under retained evidence and continuity, not under the proposal path. |

## Primary Proposal Inputs

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. `resources/proposal.md`
8. `resources/design-packet.md`
9. `resources/constitutional-harness-architecture.md`
10. `resources/harness-assessment.md`

## Proposal-Local Authority Roles

| Artifact | Role | Authority level |
| --- | --- | --- |
| `proposal.yml` | Base identity, scope, targets, lifecycle, and exit contract | Highest proposal-local |
| `architecture-proposal.yml` | Architecture scope and decision classification | Secondary proposal-local |
| `architecture/target-architecture.md` | Chosen end-state design, boundary rules, contract families, and promotion model | Primary narrative design surface |
| `architecture/acceptance-criteria.md` | Promotion proof contract | Binding within the proposal |
| `architecture/implementation-plan.md` | Workstreams, sequencing, coexistence windows, rollback posture, and phase gates | Operational planning within the proposal |
| `resources/proposal.md` | Core thesis and target-state argument | Supporting synthesis, not authoritative over the architecture docs |
| `resources/design-packet.md` | Implementation-grade source material that informed this package | Supporting synthesis, not authoritative over the manifests or architecture docs |
| `resources/constitutional-harness-architecture.md` | Abstract target-state harness model | Supporting conceptual model |
| `resources/harness-assessment.md` | Current-state baseline and gap analysis | Supporting evidence |
| `README.md` | Human entry point and reading guidance | Explanatory only |
| `navigation/artifact-catalog.md` | Required inventory of package contents | Inventory only; not semantic authority |

## Derived Or Projection-Only Surfaces

| Surface | Status | Rule |
| --- | --- | --- |
| `/.octon/generated/proposals/registry.yml` | Committed projection | Must reflect manifests but may never replace them as lifecycle authority |
| Future generated effective views and cognition projections produced by promotion | Derived runtime-facing outputs | Must stay subordinate to durable authored authority and retained evidence |
| Future run evidence, replay bundles, RunCards, and HarnessCards under `state/evidence/**` | Retained evidence | Evidence of implementation and runtime behavior, not proposal lifecycle authority |
| Future migration plans and decisions under `instance/cognition/**` | Durable promotion evidence | May supersede proposal planning after promotion, but do not retroactively change the proposal manifests |

## Conflict Resolution

1. Durable repository-wide architecture, governance, bootstrap, and runtime authorities
2. `proposal.yml`
3. `architecture-proposal.yml`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. `resources/*.md`
8. `README.md`
9. `navigation/artifact-catalog.md`

## Boundary Rules

- This proposal may define how Octon should change, but it may not act as live
  runtime, policy, governance, or documentation authority before promotion.
- The preserved `resources/*.md` files are research inputs. They ground the
  proposal but do not outrank the package manifests or architecture docs.
- Durable runtime and policy surfaces must promote into `framework/**`,
  `instance/**`, `state/**`, and `generated/**` according to existing class-
  root rules rather than back-referencing this proposal path.
- No workflow, adapter, or runtime path may treat chat transcripts, labels,
  comments, or proposal files as the steady-state source of execution
  authority.
- Promotion evidence and implementation receipts belong under retained evidence
  and continuity surfaces, not under the proposal path.
- The proposal may introduce new domains such as `framework/constitution/**`,
  `framework/lab/**`, and `framework/observability/**`, but those domains do
  not exist as canonical authority until they are promoted outside the proposal
  workspace.
