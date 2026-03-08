# Normative Dependencies And Source Of Truth Map

## Purpose

Identify which documents are authoritative for implementing the orchestration
domain described by this package and distinguish package-local source of truth
from higher-precedence repository governance.

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

- `domain-model.md`
- `runtime-architecture.md`
- `orchestration-execution-model.md`
- `dependency-resolution.md`
- `concurrency-control-model.md`
- `approval-and-override-contract.md`
- `automation-bindings-contract.md`
- `run-liveness-and-recovery-spec.md`
- `approver-authority-model.md`
- `surface-artifact-schemas.md`
- `orchestration-lifecycle.md`
- `governance-and-policy.md`
- `failure-model.md`
- `observability.md`

### Detailed Control Documents

- `lifecycle-and-state-machine-spec.md`
- `routing-authority-and-execution-control.md`
- `evidence-observability-and-retention-spec.md`
- `assurance-and-acceptance-matrix.md`
- `operator-and-authoring-runbook.md`

### Contracts

- all files under `contracts/`

### Readiness And Promotion Planning

- `implementation-readiness.md`
- `canonicalization-target-map.md`

## Package-Local Reference Or Historical Documents

These documents remain useful, but they are not the primary behavioral source of
truth when a more specific normative document exists:

- `mature-harmony-orchestration-model.md`
- `layered-model.md`
- `runtime-shape-and-directory-structure.md`
- `canonical-surface-taxonomy.md`
- `end-to-end-flow.md`
- `alignment-with-harmony-goal.md`
- `surface-criticality-and-ranking.md`
- `surface-shape-architectural-review.md`
- `example-orchestration-charter.md`
- `adoption-roadmap.md`
- `reference-examples.md`
- all files under `surfaces/`
- all files under `adr/`

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

## Source Of Truth Matrix

| Rule Category | Primary Authority In Package | Secondary / Supporting Authority | Notes |
|---|---|---|---|
| domain vocabulary and ownership | `domain-model.md` | surface specs | canonical definitions and responsibilities |
| runtime component responsibilities | `runtime-architecture.md` | `runtime-shape-and-directory-structure.md` | logical component model and write ownership |
| execution entry modes and scheduling | `orchestration-execution-model.md` | `reference-examples.md` | canonical launch and scheduling semantics |
| dependency and trigger resolution | `dependency-resolution.md` | `contracts/cross-surface-reference-contract.md` | deterministic reference and trigger matching |
| target-global coordination | `concurrency-control-model.md` | `runtime-architecture.md` | lock derivation and contention behavior |
| approvals and overrides | `approval-and-override-contract.md` | `governance-and-policy.md` | privileged action authorization |
| automation binding semantics | `automation-bindings-contract.md` | `contracts/automation-execution-contract.md` | event-to-parameter mapping and validation |
| run liveness and recovery | `run-liveness-and-recovery-spec.md` | `runtime-architecture.md`, `failure-model.md` | executor ownership and stale-run recovery |
| workflow execution metadata | `contracts/workflow-execution-contract.md` | `orchestration-execution-model.md` | executable workflow metadata and launch interface |
| coordination lock artifact | `contracts/coordination-lock-contract.md` | `concurrency-control-model.md` | lock schema, lease, and CAS semantics |
| approver authority verification | `approver-authority-model.md` | `approval-and-override-contract.md` | approver registry and scope validation |
| surface artifact schema coverage | `surface-artifact-schemas.md` | `contracts/discovery-and-authority-layer-contract.md` | required schema-backed runtime artifacts |
| lifecycle phase model | `orchestration-lifecycle.md` | `lifecycle-and-state-machine-spec.md` | phase model first, detailed tables second |
| per-surface state transitions | `lifecycle-and-state-machine-spec.md` | relevant surface contract | exact states and invariants |
| routing / authority | `routing-authority-and-execution-control.md` | `governance-and-policy.md` | `allow` / `block` / `escalate` rules |
| governance and approvals | `governance-and-policy.md` | repository governance authorities | policy stack and enforcement points |
| failure semantics and recovery | `failure-model.md` | `failure-modes-and-safety-analysis.md` | canonical failure classes and recovery posture |
| observability and operator lookup | `observability.md` | `evidence-observability-and-retention-spec.md` | health, correlation, and lookup guarantees |
| decision evidence | `contracts/decision-record-contract.md` | continuity decision authorities | canonical `decision_id` and storage shape |
| run evidence and linkage | `contracts/run-linkage-contract.md` | continuity run authorities | runtime projection plus evidence linkage |
| discovery layering and SSOT | `contracts/discovery-and-authority-layer-contract.md` | `runtime-architecture.md` | package-local discovery and state ownership |
| promotion criteria | `implementation-readiness.md` and `assurance-and-acceptance-matrix.md` | `canonicalization-target-map.md` | build-readiness vs live rollout readiness |

## What This Package Intentionally Does Not Redefine

This package does not redefine:

- repository-wide governance precedence
- active objective / intent authority
- continuity ownership of append-oriented durable decision and run evidence
- full workflow authoring syntax outside the orchestration-facing behaviors this
  package consumes

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
| What does this concept mean? | `domain-model.md` |
| Which component owns this action? | `runtime-architecture.md` |
| How does orchestration begin and schedule work? | `orchestration-execution-model.md` |
| How are references and triggers resolved? | `dependency-resolution.md` |
| How are conflicting executions prevented? | `concurrency-control-model.md` |
| What workflow metadata must exist to launch execution? | `contracts/workflow-execution-contract.md` |
| What is the canonical lock artifact? | `contracts/coordination-lock-contract.md` |
| What approval or break-glass artifact is required? | `approval-and-override-contract.md` |
| How is approver authority verified? | `approver-authority-model.md` |
| How are event bindings validated? | `automation-bindings-contract.md` |
| How are stale active runs recovered? | `run-liveness-and-recovery-spec.md` |
| What lifecycle phase or state applies? | `orchestration-lifecycle.md` then `lifecycle-and-state-machine-spec.md` |
| Can this action proceed? | `routing-authority-and-execution-control.md` |
| What policy or approval gates apply? | `governance-and-policy.md` |
| What happens on failure or partial execution? | `failure-model.md` |
| What evidence and lookup path are required? | `observability.md` and `evidence-observability-and-retention-spec.md` |
| Which contract governs this surface? | `contracts/README.md` |
| What must pass before rollout? | `implementation-readiness.md` and `assurance-and-acceptance-matrix.md` |
