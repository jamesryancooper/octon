# Phase 0 Backlog: Orchestration Domain Authority Lock

- Date: `2026-03-10`
- Parent plan: `.harmony/output/plans/2026-03-10-orchestration-domain-end-to-end-build-plan.md`
- Package path: `.design-packages/orchestration-domain-design-package`
- Scope: translate the design package into a locked, authority-cited implementation backlog before runtime build work begins

## Baseline Receipt

- `package_validator`: passed on `2026-03-10`
- `validation_command`: `bash .harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-package.sh`
- `validation_result`: `errors=0 warnings=0`
- `package_status`: `implementation-ready as a package-local architectural specification`
- `authority_order`:
  1. repository ingress and governance authorities
  2. continuity ownership for durable decision and run evidence
  3. the orchestration design package for target orchestration-domain behavior
- `phase_0_exit_criteria`:
  - package validator passes before implementation starts
  - each backlog item cites at least one package authority document
  - engineers agree which surfaces are implementation targets now and which remain optional

## Backlog Usage Rules

1. Every implementation PR must cite the corresponding backlog ID and its listed authority documents.
2. If live `.harmony/orchestration/` artifacts disagree with a backlog item, the package authority wins until that surface is formally promoted.
3. Contract artifacts, control docs, and conformance docs outrank registry projections, README summaries, and mutable state.
4. `campaigns` stay deferred unless explicit coordination pressure justifies promotion.

## Intake Summary

| Track | Count | Notes |
| --- | --- | --- |
| authority and validation gates | 4 | locks package SSOT and CI proof layer |
| required contracts | 16 | one tracked item per required contract in implementation readiness |
| required control docs | 24 | one tracked item per required control doc in implementation readiness |
| promotion targets | 8 | workflows, missions, and staged surface promotion targets |
| total | 52 | complete Phase 0 intake inventory |

## Authority And Validation Gates

| ID | Backlog item | Primary authority | Phase target | Depends on | Done when |
| --- | --- | --- | --- | --- | --- |
| `AUTH-001` | Lock package SSOT and conflict order into the team working agreement and PR template. | `navigation/source-of-truth-map.md` | `0` | none | All implementation PRs use the package authority order and escalation rule. |
| `AUTH-002` | Lock external continuity boundaries for `continuity/decisions/` and `continuity/runs/`. | `navigation/source-of-truth-map.md` | `0` | `AUTH-001` | No backlog item or design note reassigns durable decision or run evidence to orchestration runtime surfaces. |
| `GATE-001` | Wire the package validator into local and CI execution. | `normative/assurance/implementation-readiness.md`, `conformance/README.md` | `1` | `AUTH-001` | The package validator runs by default and blocks merge on failure. |
| `GATE-002` | Preserve semantic conformance execution for routing, scheduling, and recovery suites. | `conformance/README.md`, `normative/assurance/assurance-and-acceptance-matrix.md` | `1` | `GATE-001` | Conformance scenarios run in CI and report failures by suite. |

## Required Contract Backlog

| ID | Backlog item | Primary authority | Phase target | Depends on | Done when |
| --- | --- | --- | --- | --- | --- |
| `CTR-001` | Enforce contract evolution and compatibility policy across orchestration artifacts. | `contracts/versioning-and-compatibility-policy.md` | `1` | `AUTH-001` | Contract changes carry explicit versioning treatment and validator checks. |
| `CTR-002` | Implement canonical cross-surface identifiers and reference resolution rules. | `contracts/cross-surface-reference-contract.md` | `1-5` | `AUTH-001` | All runtime artifacts use canonical IDs and all cross-surface references resolve deterministically. |
| `CTR-003` | Implement canonical decision evidence with one `decision_id` per material action. | `contracts/decision-record-contract.md` | `3-7` | `CTR-002`, `GATE-001` | Decision artifacts validate and every allow, block, or escalate outcome writes exactly one decision record. |
| `CTR-004` | Implement schema-backed campaign object behavior, but keep promotion optional. | `contracts/campaign-object-contract.md` | `9` | `CTR-002`, `CTL-011` | Campaigns are either deferred explicitly or implemented without violating optionality rules. |
| `CTR-005` | Implement schema-backed workflow definition authority at `workflow.yml`. | `contracts/workflow-execution-contract.md` | `2-4` | `CTR-002`, `CTL-001` | Workflows launch from validated `workflow.yml` definitions and subordinate stage assets stay non-authoritative. |
| `CTR-006` | Implement schema-backed mission identity, lifecycle, and linkage authority at `mission.yml`. | `contracts/mission-object-contract.md` | `2` | `CTR-002`, `CTL-001` | Missions validate at `mission.yml` and registry or prose artifacts remain subordinate. |
| `CTR-007` | Implement split automation authority across `automation.yml`, `trigger.yml`, `bindings.yml`, and `policy.yml`. | `contracts/automation-execution-contract.md` | `5` | `CTR-002`, `CTL-003`, `CTL-004`, `CTL-007` | Automations launch only from split definition artifacts and all concurrency/idempotency behavior is enforced from `policy.yml`. |
| `CTR-008` | Implement canonical coordination lock artifact, lease, and CAS acquisition behavior. | `contracts/coordination-lock-contract.md` | `3-7` | `CTR-002`, `CTL-005` | Side-effectful executions acquire, renew, release, and transfer locks according to the contract. |
| `CTR-009` | Implement watcher definition authority across `watcher.yml`, `sources.yml`, `rules.yml`, and `emits.yml`. | `contracts/watcher-definition-contract.md` | `4-6` | `CTR-002`, `CTL-004`, `CTL-014` | Watchers validate against the full definition family and mutable state remains subordinate. |
| `CTR-010` | Implement the canonical watcher event envelope and linkage rules. | `contracts/watcher-event-contract.md` | `4-6` | `CTR-002`, `CTR-009`, `CTL-014` | Every emitted watcher event validates and routes using the canonical envelope. |
| `CTR-011` | Implement queue item shape, lane model, claim-token semantics, retry, and dead-letter rules. | `contracts/queue-item-and-lease-contract.md` | `3-6` | `CTR-002`, `CTL-005`, `CTL-013` | Queue items validate and all claim, ack, retry, and dead-letter transitions obey the contract. |
| `CTR-012` | Implement canonical run record authority and linkage to continuity evidence. | `contracts/run-linkage-contract.md` | `3-7` | `CTR-002`, `CTR-003`, `CTL-008` | Runs validate, projections resolve back to canonical run records, and continuity evidence linkage is intact. |
| `CTR-013` | Implement schema-backed incident object state and subordinate action or closure evidence. | `contracts/incident-object-contract.md` | `7-8` | `CTR-002`, `CTL-012` | Incidents validate at `incident.yml`, and `actions.yml` validates when present. |
| `CTR-014` | Implement discovery and authority layering across all orchestration surfaces. | `contracts/discovery-and-authority-layer-contract.md` | `1-8` | `AUTH-001` | Promoted surfaces follow the required manifest, registry, canonical object, state, and evidence order. |
| `CTR-015` | Implement mission-to-workflow linkage and invocation semantics without recurrence leakage. | `contracts/mission-workflow-binding-contract.md` | `2-4` | `CTR-005`, `CTR-006`, `CTL-011` | Mission-linked workflow execution is explicit, bounded, and traceable through runs and decisions. |
| `CTR-016` | Implement campaign-to-mission coordination semantics only if campaign adoption is justified. | `contracts/campaign-mission-coordination-contract.md` | `9` | `CTR-004`, `CTR-006` | Campaign rollups never replace mission lifecycle or run evidence authority. |

## Required Control-Document Backlog

| ID | Backlog item | Primary authority | Phase target | Depends on | Done when |
| --- | --- | --- | --- | --- | --- |
| `CTL-001` | Implement the package domain vocabulary, ownership rules, and surface non-goals. | `normative/architecture/domain-model.md` | `2-9` | `AUTH-001` | Runtime surfaces, docs, and validators use the package vocabulary without introducing conflicting terms. |
| `CTL-002` | Implement the logical control-plane component model and write-ownership rules. | `normative/architecture/runtime-architecture.md` | `3-7` | `CTL-001` | Components and ownership boundaries match the package's runtime architecture. |
| `CTL-003` | Implement orchestration entry modes, schedule semantics, concurrency posture, and execution ordering. | `normative/execution/orchestration-execution-model.md` | `4-6` | `CTL-001`, `CTR-005`, `CTR-007` | Launching behavior, scheduling, and overlap semantics match the execution model. |
| `CTL-004` | Implement deterministic dependency and trigger resolution. | `normative/execution/dependency-resolution.md` | `4-6` | `CTR-002`, `CTR-007`, `CTR-009` | Reference resolution, trigger matching, binding validation, and admission decisions follow the declared algorithm. |
| `CTL-005` | Implement target-global coordination behavior and contention handling. | `normative/execution/concurrency-control-model.md` | `3-7` | `CTR-008` | Lock class derivation, contention outcomes, and side-effect gating follow the concurrency model. |
| `CTL-006` | Implement approval, waiver, and override artifact behavior for privileged actions. | `normative/governance/approval-and-override-contract.md` | `7` | `CTR-002`, `CTR-013` | Privileged actions reference valid approval or override artifacts with matching scope and expiry. |
| `CTL-007` | Implement event-to-parameter binding semantics and validation. | `normative/execution/automation-bindings-contract.md` | `4-5` | `CTR-007`, `CTR-010` | Bindings validate before admission and do not carry trigger or policy authority. |
| `CTL-008` | Implement executor ownership, acknowledgement, heartbeat, and recovery rules. | `normative/execution/run-liveness-and-recovery-spec.md` | `4-7` | `CTR-012`, `CTR-008` | Active runs have valid liveness state and recovery is deterministic. |
| `CTL-009` | Implement approver authority registry checks and scope validation. | `normative/governance/approver-authority-model.md` | `7` | `CTL-006` | Approval is accepted only when the approver registry confirms scope and non-revoked authority. |
| `CTL-010` | Implement required schema coverage for surface-local artifacts. | `normative/assurance/surface-artifact-schemas.md` | `1-8` | `GATE-001` | All required surface-local artifacts validate against declared schemas. |
| `CTL-011` | Implement lifecycle phases and cross-surface lifecycle relationships. | `normative/execution/orchestration-lifecycle.md` | `2-9` | `CTL-001` | Surface states and lifecycle transitions obey the package lifecycle model. |
| `CTL-012` | Implement orchestration governance policy stack and enforcement points. | `normative/governance/governance-and-policy.md` | `7-8` | `CTL-001`, `CTL-006`, `CTL-009` | Policy routing, privileged action classes, and governance checks fail closed. |
| `CTL-013` | Implement the failure taxonomy, retry posture, and recovery semantics. | `normative/assurance/failure-model.md` | `3-7` | `CTL-002`, `CTR-011`, `CTR-012` | Failure classes drive retry, block, escalate, and recovery behavior without ad hoc exceptions. |
| `CTL-014` | Implement the observability model, correlation fields, and operator lookup paths. | `normative/assurance/observability.md` | `4-8` | `CTR-003`, `CTR-010`, `CTR-012`, `CTR-013` | Operators can trace orchestration activity, health, and evidence through the required lookup paths. |
| `CTL-015` | Use the package source-of-truth map as the implementation conflict-resolution table. | `navigation/source-of-truth-map.md` | `0-9` | `AUTH-001` | Every ambiguity resolution cites the source-of-truth map and follows its precedence order. |
| `CTL-016` | Implement exact per-surface state transitions and invariants. | `normative/execution/lifecycle-and-state-machine-spec.md` | `3-7` | `CTL-011` | Runs, locks, queue items, approvals, and incidents transition only through valid states. |
| `CTL-017` | Implement allow, block, and escalate routing rules for material actions. | `normative/governance/routing-authority-and-execution-control.md` | `4-7` | `CTR-003`, `CTL-012` | Every material action resolves to one routing outcome and writes the corresponding evidence. |
| `CTL-018` | Implement evidence ownership, lookup, retention, and continuity split rules. | `normative/governance/evidence-observability-and-retention-spec.md` | `3-8` | `AUTH-002`, `CTR-003`, `CTR-012` | Runtime and continuity evidence remain separated according to the package's evidence contract. |
| `CTL-019` | Use the assurance and acceptance matrix as the promotion gate definition. | `normative/assurance/assurance-and-acceptance-matrix.md` | `1-8` | `GATE-001`, `GATE-002` | `G0-G7` gates are implemented as explicit validation and rollout checks. |
| `CTL-020` | Implement safe authoring and operator guidance for promoted surfaces. | `normative/assurance/operator-and-authoring-runbook.md` | `2-8` | `CTL-019` | Practices and runbooks reflect the package's authoring and operating constraints. |
| `CTL-021` | Maintain the conformance module as the behavioral proof layer. | `conformance/README.md` | `1-8` | `GATE-002` | Conformance scenarios stay authoritative for routing, scheduling, and recovery semantics. |
| `CTL-022` | Keep worked examples aligned with the implemented runtime and contract shapes. | `reference/reference-examples.md` | `4-8` | `CTR-005`, `CTR-007`, `CTR-012`, `CTR-013` | Reference examples match implemented behavior and do not introduce unsupported patterns. |
| `CTL-023` | Use the safety-analysis reference to harden detection and mitigation coverage. | `reference/failure-modes-and-safety-analysis.md` | `3-7` | `CTL-013`, `CTL-014` | Failure-path testing and operator detection cover the major failure classes documented by the package. |
| `CTL-024` | Preserve ADR-backed rationale for material orchestration design choices. | `history/adr/README.md` | `0-9` | `AUTH-001` | Material deviations or extensions are recorded through ADR discipline instead of silent drift. |

## Promotion-Target Backlog

| ID | Backlog item | Primary authority | Phase target | Depends on | Done when |
| --- | --- | --- | --- | --- | --- |
| `PRM-001` | Strengthen live `workflows` authority so `workflow.yml` becomes the canonical execution contract and validators enforce drift checks. | `navigation/canonicalization-target-map.md` | `2` | `CTR-005`, `CTL-015`, `CTL-019` | Live workflow surfaces follow the package authority model and validators enforce it. |
| `PRM-002` | Strengthen live `missions` authority so `mission.yml` becomes canonical and mission linkage remains subordinate to runs and decisions. | `navigation/canonicalization-target-map.md` | `2` | `CTR-006`, `CTR-015`, `CTL-019` | Live mission surfaces follow the package authority model and validators enforce it. |
| `PRM-003` | Promote `runs` into live `.harmony/orchestration/runtime/runs/` with continuity-owned durable evidence preserved. | `navigation/canonicalization-target-map.md` | `8` | `CTR-012`, `CTL-018`, `CTL-019` | `runtime/runs/` exists with canonical run records, projections, validator, and operator guidance. |
| `PRM-004` | Promote `automations` into live runtime, practices, governance, and validator surfaces. | `navigation/canonicalization-target-map.md` | `8` | `CTR-007`, `CTL-019`, `PRM-003` | `automations` are live canonical with split definition authority and validator coverage. |
| `PRM-005` | Promote `incidents` runtime state if needed, keeping governance authority human-led. | `navigation/canonicalization-target-map.md` | `8` | `CTR-013`, `CTL-012`, `CTL-019` | `incidents` runtime artifacts, practices, governance extensions, and validator exist without overriding governance authority. |
| `PRM-006` | Promote `queue` as a live singular surface with lane directories, receipts, governance policy, and validator. | `navigation/canonicalization-target-map.md` | `8` | `CTR-011`, `CTL-019`, `PRM-004` | `queue` exists as one shared substrate and all authority and validation rules match the package. |
| `PRM-007` | Promote `watchers` as a live schema-backed surface with state and evidence separation. | `navigation/canonicalization-target-map.md` | `8` | `CTR-009`, `CTR-010`, `CTL-019`, `PRM-006` | `watchers` exist with full definition-family authority, practices, governance, and validator coverage. |
| `PRM-008` | Evaluate and optionally promote `campaigns` only if mission coordination load justifies the surface. | `navigation/canonicalization-target-map.md`, `history/adoption-roadmap.md` | `9` | `CTR-004`, `CTR-016`, `CTL-019` | A documented go or no-go decision exists; if go, `campaigns` promote without becoming execution containers. |

## Immediate Next Actions

1. Import this backlog into the team tracking system without changing item scope or authority citations.
2. Start `Phase 1` with `AUTH-001`, `AUTH-002`, `GATE-001`, and `GATE-002`.
3. Do not begin runtime implementation until the authority and validation gates are assigned and tracked.
