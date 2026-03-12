# Package Source Of Truth Map

## Purpose

Identify which documents are authoritative for implementing the orchestration
domain described by this package and distinguish package-local source of truth
from higher-precedence repository governance.

## Module Layout

Package modules are intentionally separated:

- `navigation/` for entry maps and planning-only rollout material
- `normative/` for active behavioral specification
- `contracts/` for interface and schema contracts
- `conformance/` for machine-checked behavioral proof
- `implementation/` for build blueprints
- `reference/` for active but non-authoritative support material
- `history/` for provenance-only artifacts

## Global Harmony Precedence

This package does not override repository-wide governance or continuity
ownership.

When conflicts exist, the higher-precedence Harmony authority wins:

1. repository ingress and agent governance authorities (`AGENTS.md`,
   `CONSTITUTION.md`, delegation/memory overlays, active objective/intent)
2. continuity ownership and retention authorities for
   `continuity/decisions/` and `continuity/runs/`
3. this package for target orchestration-domain behavior

Within the orchestration-domain design scope, this package is the package-local
source of truth for target runtime behavior, contracts, lifecycle, and safety.

## Package-Local Normative Documents

### Core Domain And Architecture

- `normative/architecture/domain-model.md`
- `normative/architecture/runtime-architecture.md`
- `normative/execution/orchestration-execution-model.md`
- `normative/execution/dependency-resolution.md`
- `normative/execution/concurrency-control-model.md`
- `normative/governance/approval-and-override-contract.md`
- `normative/execution/automation-bindings-contract.md`
- `normative/execution/run-liveness-and-recovery-spec.md`
- `normative/governance/approver-authority-model.md`
- `normative/assurance/surface-artifact-schemas.md`
- `normative/execution/orchestration-lifecycle.md`
- `normative/governance/governance-and-policy.md`
- `normative/assurance/failure-model.md`
- `normative/assurance/observability.md`

### Detailed Control Documents

- `normative/execution/lifecycle-and-state-machine-spec.md`
- `normative/governance/routing-authority-and-execution-control.md`
- `normative/governance/evidence-observability-and-retention-spec.md`
- `normative/assurance/assurance-and-acceptance-matrix.md`
- `normative/assurance/operator-and-authoring-runbook.md`

### Contracts

- all files under `contracts/`

### Conformance

- `conformance/README.md`
- all files under `conformance/scenarios/`

### Readiness And Promotion Planning

- `normative/assurance/implementation-readiness.md`
- `navigation/canonicalization-target-map.md`

## Package-Local Reference Or Historical Documents

These documents remain useful, but they are not the primary behavioral source of
truth when a more specific normative document exists:

- `history/mature-harmony-orchestration-model.md`
- `reference/layered-model.md`
- `reference/runtime-shape-and-directory-structure.md`
- `reference/canonical-surface-taxonomy.md`
- `reference/end-to-end-flow.md`
- `history/alignment-with-harmony-goal.md`
- `reference/surface-criticality-and-ranking.md`
- `history/surface-shape-architectural-review.md`
- `reference/example-orchestration-charter.md`
- `history/adoption-roadmap.md`
- `reference/reference-examples.md`
- all files under `reference/surfaces/`
- all files under `history/adr/`

Surface specs remain authoritative for surface purpose, role, and non-goals
unless a more specific contract or control document defines stricter behavior.

## Externally Inherited Harmony Authorities

The package still depends on external Harmony authorities for:

| External Authority | Why It Matters |
|---|---|
| `AGENTS.md` and governing overlays | repo-wide process, safety, and precedence rules |
| `.harmony/OBJECTIVE.md` and active intent contract | objective-bound execution and authorized scope |
| `.harmony/continuity/_meta/architecture/continuity-plane.md` | continuity ownership and evidence separation |
| `.harmony/continuity/decisions/README.md` and retention docs | decision-evidence ownership and lifecycle |
| `.harmony/continuity/runs/README.md` and retention docs | durable run-evidence ownership and lifecycle |

Current live workflow and mission docs under `.harmony/orchestration/` are
implementation integration context and promotion targets. They are not the
primary source of target orchestration behavior for this package.

Live authority reconciliation remains out of scope for this package-only
remediation.

## Source Of Truth Matrix

| Rule Category | Primary Authority In Package | Secondary / Supporting Authority | Notes |
|---|---|---|---|
| domain vocabulary and ownership | `normative/architecture/domain-model.md` | surface specs | canonical definitions and responsibilities |
| runtime component responsibilities | `normative/architecture/runtime-architecture.md` | `reference/runtime-shape-and-directory-structure.md` | logical component model and write ownership |
| execution entry modes and scheduling | `normative/execution/orchestration-execution-model.md` | `reference/reference-examples.md` | canonical launch and scheduling semantics |
| dependency and trigger resolution | `normative/execution/dependency-resolution.md` | `contracts/cross-surface-reference-contract.md` | deterministic reference and trigger matching |
| target-global coordination | `normative/execution/concurrency-control-model.md` | `normative/architecture/runtime-architecture.md` | lock derivation and contention behavior |
| approvals and overrides | `normative/governance/approval-and-override-contract.md` | `normative/governance/governance-and-policy.md` | privileged action authorization |
| automation definition and launch policy | `contracts/automation-execution-contract.md` | `normative/execution/orchestration-execution-model.md`, `normative/execution/dependency-resolution.md` | canonical split across `automation.yml`, `trigger.yml`, `bindings.yml`, and `policy.yml` |
| automation binding semantics | `normative/execution/automation-bindings-contract.md` | `contracts/automation-execution-contract.md` | event-to-parameter mapping and validation |
| run liveness and recovery | `normative/execution/run-liveness-and-recovery-spec.md` | `normative/architecture/runtime-architecture.md`, `normative/assurance/failure-model.md` | executor ownership and stale-run recovery |
| workflow definition and execution contract | `contracts/workflow-execution-contract.md` | `normative/execution/orchestration-execution-model.md` | schema-backed `workflow.yml`, subordinate stage assets, and launch interface |
| watcher definition and emitted-event interface | `contracts/watcher-definition-contract.md`, `contracts/watcher-event-contract.md` | `normative/architecture/runtime-architecture.md`, `normative/execution/dependency-resolution.md`, `normative/assurance/observability.md` | schema-backed watcher definition family plus canonical emitted event envelope |
| mission definition and lifecycle linkage | `contracts/mission-object-contract.md` | `normative/execution/lifecycle-and-state-machine-spec.md`, `reference/surfaces/missions.md` | schema-backed `mission.yml` authority plus registry/state/evidence separation |
| coordination lock artifact | `contracts/coordination-lock-contract.md` | `normative/execution/concurrency-control-model.md` | lock schema, lease, and CAS semantics |
| approver authority verification | `normative/governance/approver-authority-model.md` | `normative/governance/approval-and-override-contract.md` | approver registry and scope validation |
| surface artifact schema coverage | `normative/assurance/surface-artifact-schemas.md` | `contracts/discovery-and-authority-layer-contract.md` | required schema-backed runtime artifacts |
| lifecycle phase model | `normative/execution/orchestration-lifecycle.md` | `normative/execution/lifecycle-and-state-machine-spec.md` | phase model first, detailed tables second |
| per-surface state transitions | `normative/execution/lifecycle-and-state-machine-spec.md` | relevant surface contract | exact states and invariants |
| routing / authority | `normative/governance/routing-authority-and-execution-control.md` | `normative/governance/governance-and-policy.md` | `allow` / `block` / `escalate` rules |
| governance and approvals | `normative/governance/governance-and-policy.md` | repository governance authorities | policy stack and enforcement points |
| failure semantics and recovery | `normative/assurance/failure-model.md` | `reference/failure-modes-and-safety-analysis.md` | canonical failure classes and recovery posture |
| observability and operator lookup | `normative/assurance/observability.md` | `normative/governance/evidence-observability-and-retention-spec.md` | health, correlation, and lookup guarantees |
| decision evidence | `contracts/decision-record-contract.md` | continuity decision authorities | canonical `decision_id` and storage shape |
| run object/state, projection, and evidence linkage | `contracts/run-linkage-contract.md` | continuity run authorities | canonical `<run-id>.yml` record plus subordinate runtime projections and continuity evidence linkage |
| incident object/state and local evidence split | `contracts/incident-object-contract.md` | `normative/execution/orchestration-lifecycle.md`, `normative/governance/governance-and-policy.md`, `.harmony/orchestration/governance/incidents.md` | canonical `incident.yml` state plus subordinate local evidence and external governance authority |
| campaign object/state and mission coordination | `contracts/campaign-object-contract.md`, `contracts/campaign-mission-coordination-contract.md` | `normative/architecture/domain-model.md`, `normative/execution/orchestration-lifecycle.md` | canonical `campaign.yml` object/state record plus mission aggregation, milestone, and optionality rules |
| discovery layering and SSOT | `contracts/discovery-and-authority-layer-contract.md` | `normative/architecture/runtime-architecture.md` | package-local discovery, state ownership, and evidence-layer separation |
| behavioral proof and semantic conformance | `conformance/README.md` and scenario packs under `conformance/scenarios/` | `normative/assurance/assurance-and-acceptance-matrix.md`, validator logic | package-level proof for routing, scheduling, and recovery semantics |
| promotion criteria | `normative/assurance/implementation-readiness.md` and `normative/assurance/assurance-and-acceptance-matrix.md` | `navigation/canonicalization-target-map.md` | build-readiness vs live rollout readiness |

## What This Package Intentionally Does Not Redefine

This package does not redefine:

- repository-wide governance precedence
- active objective / intent authority
- continuity ownership of append-oriented durable decision and run evidence
- full workflow authoring syntax outside the orchestration-facing behaviors this
  package consumes
- live `.harmony/orchestration` authority alignment

## Conflict Resolution Inside The Package

When two package docs overlap, resolve in this order:

1. specific contract docs in `contracts/`
2. detailed control docs
3. core domain / architecture normative docs
4. implementation-readiness and canonicalization planning docs
5. surface specs
6. reference and historical docs
7. ADRs and examples

## Implementation Guidance

| Question | Start Here |
|---|---|
| What does this concept mean? | `normative/architecture/domain-model.md` |
| Which component owns this action? | `normative/architecture/runtime-architecture.md` |
| How does orchestration begin and schedule work? | `normative/execution/orchestration-execution-model.md` |
| How are references and triggers resolved? | `normative/execution/dependency-resolution.md` |
| What defines automation identity, triggers, bindings, and launch policy? | `contracts/automation-execution-contract.md` then `normative/execution/automation-bindings-contract.md` |
| How are conflicting executions prevented? | `normative/execution/concurrency-control-model.md` |
| What workflow definition contract must exist to launch execution? | `contracts/workflow-execution-contract.md` |
| What makes a mission valid and where do mission linkage fields live? | `contracts/mission-object-contract.md` then `contracts/mission-workflow-binding-contract.md` |
| What is the canonical lock artifact? | `contracts/coordination-lock-contract.md` |
| What approval or break-glass artifact is required? | `normative/governance/approval-and-override-contract.md` |
| How is approver authority verified? | `normative/governance/approver-authority-model.md` |
| How are event bindings validated? | `normative/execution/automation-bindings-contract.md` |
| How are stale active runs recovered? | `normative/execution/run-liveness-and-recovery-spec.md` |
| What lifecycle phase or state applies? | `normative/execution/orchestration-lifecycle.md` then `normative/execution/lifecycle-and-state-machine-spec.md` |
| Can this action proceed? | `normative/governance/routing-authority-and-execution-control.md` |
| What policy or approval gates apply? | `normative/governance/governance-and-policy.md` |
| What happens on failure or partial execution? | `normative/assurance/failure-model.md` |
| What evidence and lookup path are required? | `normative/assurance/observability.md` and `normative/governance/evidence-observability-and-retention-spec.md` |
| Which contract governs this surface? | `contracts/README.md` |
| What must pass before rollout? | `normative/assurance/implementation-readiness.md` and `normative/assurance/assurance-and-acceptance-matrix.md` |
