# Orchestration Domain Design Package

This is a temporary, implementation-scoped design package. It exists to
organize the orchestration design artifacts until their long-lived authority is
promoted into `.harmony/`.

This package is the implementation-ready architectural specification for the
target orchestration domain in Harmony.

Package-local normative documents define the target orchestration behavior,
contracts, lifecycle rules, runtime architecture, and safety model. Repository
governance, active objective/intent, and continuity ownership still remain
higher-precedence authorities. Promotion into live `.harmony/` runtime surfaces
is a separate canonicalization step defined in this package. This remediation is
package-only: it hardens the package contract and proof surface, but it does not
claim to reconcile live `.harmony/orchestration` authority.

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

## AI Discovery

- `navigation/artifact-catalog.md`
  - exhaustive categorized inventory of every file in this package
- package content is now organized by module
  - navigation, normative, contracts, conformance, implementation, reference,
    and history each have one clear job
- if you need substance rather than inventory, follow the reading order below

## Package Layout

```text
.design-packages/orchestration-domain-design-package/
├── README.md
├── navigation/
├── normative/
├── contracts/
├── conformance/
├── implementation/
├── reference/
└── history/
```

### Module Roles

- `navigation/`
  - package entry maps, inventory, source-of-truth, and planning-only
    canonicalization material
- `normative/`
  - active behavioral specification grouped into architecture, execution,
    governance, and assurance
- `contracts/`
  - object, interface, linkage, and compatibility contracts plus schemas and
    fixtures
- `conformance/`
  - machine-readable semantic scenarios and the scenario contract used to prove
    routing, scheduling, and recovery behavior
- `implementation/`
  - implementer-facing build blueprint derived from the normative spec
- `reference/`
  - active non-authoritative examples, surface deep dives, and safety-analysis
    support material
- `history/`
  - provenance-only material such as prior reviews, legacy framing, and ADRs

## Reading Routes

### Implementer

1. `normative/architecture/domain-model.md`
2. `normative/architecture/runtime-architecture.md`
3. `normative/execution/orchestration-execution-model.md`
4. `normative/execution/dependency-resolution.md`
5. `normative/execution/run-liveness-and-recovery-spec.md`
6. `contracts/README.md`
7. `conformance/README.md`
8. `normative/assurance/implementation-readiness.md`

### Contract Author

1. `navigation/source-of-truth-map.md`
2. `contracts/README.md`
3. `contracts/versioning-and-compatibility-policy.md`
4. `normative/execution/dependency-resolution.md`
5. `normative/governance/governance-and-policy.md`
6. `conformance/README.md`

### Auditor

1. `navigation/artifact-catalog.md`
2. `navigation/source-of-truth-map.md`
3. `normative/assurance/assurance-and-acceptance-matrix.md`
4. `normative/assurance/implementation-readiness.md`
5. `conformance/README.md`
6. `reference/reference-examples.md`

## Package Contents

### Core Normative Specification

- `normative/architecture/domain-model.md`
  - canonical vocabulary, ownership model, and surface relationships
- `normative/architecture/runtime-architecture.md`
  - logical runtime components, write ownership, and reconciliation behavior
- `normative/execution/orchestration-execution-model.md`
  - execution entry modes, schedule semantics, concurrency, and idempotency
- `normative/execution/dependency-resolution.md`
  - deterministic reference resolution and trigger matching algorithms
- `normative/execution/concurrency-control-model.md`
  - target-global coordination, locking, and contention behavior
- `normative/governance/approval-and-override-contract.md`
  - approval, waiver, and break-glass override artifact contract
- `normative/execution/automation-bindings-contract.md`
  - normative semantics for `bindings.yml` and event parameter mapping
- `normative/execution/run-liveness-and-recovery-spec.md`
  - executor ownership, heartbeat, and deterministic recovery behavior
- `normative/governance/approver-authority-model.md`
  - governance-owned approver registry and approval verification model
- `normative/assurance/surface-artifact-schemas.md`
  - schema coverage expectations for required surface-local artifacts
- `normative/execution/orchestration-lifecycle.md`
  - cross-surface lifecycle phase model
- `normative/governance/governance-and-policy.md`
  - policy stack, enforcement points, and auditability rules
- `normative/assurance/failure-model.md`
  - canonical failure classes, retry semantics, compensation posture, and
    recovery rules
- `normative/assurance/observability.md`
  - correlation model, required health signals, and operator lookup guarantees

### Detailed Control Docs

- `normative/execution/lifecycle-and-state-machine-spec.md`
  - exact state tables, transitions, and invariants for stateful surfaces
- `normative/governance/routing-authority-and-execution-control.md`
  - `allow` / `block` / `escalate` rules for material actions
- `normative/governance/evidence-observability-and-retention-spec.md`
  - evidence ownership, linkage, retention, and continuity split rules
- `normative/assurance/assurance-and-acceptance-matrix.md`
  - validation expectations and promotion gates
- `normative/assurance/implementation-readiness.md`
  - build-readiness verdict, contract inventory, and implementation checklist
- `navigation/source-of-truth-map.md`
  - package-local source-of-truth map and conflict-resolution order
- `normative/assurance/operator-and-authoring-runbook.md`
  - safe authoring and operating guidance

### Contracts

- `contracts/`
  - concrete object, interface, linkage, and compatibility contracts
- `contracts/schemas/`
  - machine-readable schemas for schema-backed contracts
- `contracts/fixtures/`
  - valid and invalid fixtures used by the design-package validator

### Conformance

- `conformance/README.md`
  - semantic scenario contract and proof-layer navigation
- `conformance/scenarios/`
  - routing, scheduling, and recovery scenario packs consumed by the validator

### Reference And Historical Context

- `implementation/`
  - implementer-oriented multi-page blueprint for the first production build
- `reference/reference-examples.md`
  - end-to-end worked examples
- `navigation/canonicalization-target-map.md`
  - live `.harmony` promotion targets and sequencing
- `reference/surfaces/`
  - per-surface purpose, non-goals, and implementation summaries
- `history/mature-harmony-orchestration-model.md`
  - legacy high-level framing retained as background context
- `history/surface-shape-architectural-review.md`
  - historical review artifact retained for provenance
- `history/profile-selection-and-compliance.md`
  - creation-time governance receipt retained for provenance
- `history/adr/`
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
- the semantic conformance scenarios required to keep routing, scheduling, and
  recovery claims honest
- the promotion targets for landing this model in live `.harmony` authority
  surfaces

This package does not itself implement the live runtime. It defines the build
specification engineers should implement.

## Explicit Non-Goals For This Remediation

- live `.harmony/orchestration` authority reconciliation
- canonicalization safety claims beyond package planning artifacts
- storage-backend or transport selection
