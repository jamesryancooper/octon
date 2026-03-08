# Orchestration Domain Design Package

This package is the implementation-ready architectural specification for the
target orchestration domain in Harmony.

Package-local normative documents define the target orchestration behavior,
contracts, lifecycle rules, runtime architecture, and safety model. Repository
governance, active objective/intent, and continuity ownership still remain
higher-precedence authorities. Promotion into live `.harmony/` runtime surfaces
is a separate canonicalization step defined in this package.

## Core Conclusions

- Harmony should optimize for `AI-native, system-governed autonomy`, not
  human-free autonomy.
- `workflows` remain the bounded procedural core of orchestration.
- `missions` remain the bounded multi-session initiative surface.
- `runs` are the first-class execution-instance surface, while durable evidence
  remains aligned with `continuity/runs/`.
- material decision evidence is first-class continuity evidence under
  `continuity/decisions/`.
- `automations` own recurrence and event-triggered launch decisions rather than
  turning workflows into schedulers.
- `watchers` and `queue` are scale surfaces for event-driven autonomy, not
  mandatory foundations.
- `incidents` remain a safety and escalation surface with human-governed
  authority.
- `campaigns` remain optional portfolio coordination above missions.

## Reading Order

1. `domain-model.md`
2. `runtime-architecture.md`
3. `orchestration-execution-model.md`
4. `dependency-resolution.md`
5. `concurrency-control-model.md`
6. `approval-and-override-contract.md`
7. `automation-bindings-contract.md`
8. `run-liveness-and-recovery-spec.md`
9. `approver-authority-model.md`
10. `surface-artifact-schemas.md`
11. `orchestration-lifecycle.md`
12. `governance-and-policy.md`
13. `failure-model.md`
14. `observability.md`
15. `lifecycle-and-state-machine-spec.md`
16. `routing-authority-and-execution-control.md`
17. `evidence-observability-and-retention-spec.md`
18. `assurance-and-acceptance-matrix.md`
19. `implementation-readiness.md`
20. `normative-dependencies-and-source-of-truth-map.md`
21. `contracts/README.md`
22. `reference-examples.md`
23. `operator-and-authoring-runbook.md`
24. `canonicalization-target-map.md`
25. `surfaces/`
26. Historical and supporting context:
    - `profile-selection-and-compliance.md`
    - `surface-shape-architectural-review.md`
    - `mature-harmony-orchestration-model.md`
    - `layered-model.md`
    - `runtime-shape-and-directory-structure.md`
    - `adoption-roadmap.md`
    - `adr/README.md`

## Package Contents

### Core Normative Specification

- `domain-model.md`
  - canonical vocabulary, ownership model, and surface relationships
- `runtime-architecture.md`
  - logical runtime components, write ownership, and reconciliation behavior
- `orchestration-execution-model.md`
  - execution entry modes, schedule semantics, concurrency, and idempotency
- `dependency-resolution.md`
  - deterministic reference resolution and trigger matching algorithms
- `concurrency-control-model.md`
  - target-global coordination, locking, and contention behavior
- `approval-and-override-contract.md`
  - approval, waiver, and break-glass override artifact contract
- `automation-bindings-contract.md`
  - normative semantics for `bindings.yml` and event parameter mapping
- `run-liveness-and-recovery-spec.md`
  - executor ownership, heartbeat, and deterministic recovery behavior
- `approver-authority-model.md`
  - governance-owned approver registry and approval verification model
- `surface-artifact-schemas.md`
  - schema coverage expectations for required surface-local artifacts
- `orchestration-lifecycle.md`
  - cross-surface lifecycle phase model
- `governance-and-policy.md`
  - policy stack, enforcement points, and auditability rules
- `failure-model.md`
  - canonical failure classes, retry semantics, compensation posture, and
    recovery rules
- `observability.md`
  - correlation model, required health signals, and operator lookup guarantees

### Detailed Control Docs

- `lifecycle-and-state-machine-spec.md`
  - exact state tables, transitions, and invariants for stateful surfaces
- `routing-authority-and-execution-control.md`
  - `allow` / `block` / `escalate` rules for material actions
- `evidence-observability-and-retention-spec.md`
  - evidence ownership, linkage, retention, and continuity split rules
- `assurance-and-acceptance-matrix.md`
  - validation expectations and promotion gates
- `implementation-readiness.md`
  - build-readiness verdict, contract inventory, and implementation checklist
- `normative-dependencies-and-source-of-truth-map.md`
  - package-local source-of-truth map and conflict-resolution order
- `operator-and-authoring-runbook.md`
  - safe authoring and operating guidance

### Contracts

- `contracts/`
  - concrete object, interface, linkage, and compatibility contracts
- `contracts/schemas/`
  - machine-readable schemas for schema-backed contracts
- `contracts/fixtures/`
  - valid and invalid fixtures used by the design-package validator

### Reference And Historical Context

- `implementation-blueprint/`
  - implementer-oriented multi-page blueprint for the first production build
- `reference-examples.md`
  - end-to-end worked examples
- `canonicalization-target-map.md`
  - live `.harmony` promotion targets and sequencing
- `surfaces/`
  - per-surface purpose, non-goals, and implementation summaries
- `mature-harmony-orchestration-model.md`
  - legacy high-level framing retained as background context
- `surface-shape-architectural-review.md`
  - historical review artifact retained for provenance
- `profile-selection-and-compliance.md`
  - creation-time governance receipt retained for provenance
- `adr/`
  - architectural decision records explaining material design choices

## Specification Scope

This package defines:

- the target orchestration-domain model
- the runtime responsibilities and interaction boundaries of the orchestration
  components
- the contracts and algorithms required to implement orchestration safely
- the coordination, approval, and run-liveness guarantees required to avoid
  unsafe or divergent implementations
- the workflow execution, lock artifact, and approver-authority contracts
  required to make the package spec-closed for implementation
- the evidence, observability, and governance rules required for trustworthy
  operation
- the promotion targets for landing this model in live `.harmony` authority
  surfaces

This package does not itself implement the live runtime. It defines the build
specification engineers should implement.
