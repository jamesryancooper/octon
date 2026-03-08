# Implementation Readiness

## Verdict

The orchestration domain design package is now implementation-ready as a
package-local architectural specification.

That means:

- the system architecture can be reconstructed from package-local normative docs
- the runtime component model, execution model, dependency resolution rules,
  lifecycle model, failure semantics, governance model, and observability model
  are defined in this package
- the missing cross-surface contracts are codified
- engineers can implement the target orchestration domain without relying on
  external Harmony docs for core orchestration behavior

It does not mean live `.harmony` runtime code has already been shipped. Live
rollout remains a separate canonicalization step.

## What Changed To Reach Implementation Readiness

- codified watcher event envelope rules
- codified material decision evidence with canonical `decision_id` linkage
- codified queue item and lease semantics
- codified automation concurrency and idempotency behavior
- codified run linkage between orchestration projections and continuity evidence
- codified incident object lifecycle and closure rules
- codified campaign object state and lifecycle
- codified canonical cross-surface identifiers and references
- added package-local domain model, runtime architecture, execution model,
  lifecycle model, dependency-resolution algorithm, governance model,
  observability model, and failure model
- added package-local hardening artifacts for target-global concurrency,
  approval and override evidence, automation bindings, run liveness, and
  surface artifact schemas
- added machine-readable schemas and fixtures for the highest-risk object
  contracts
- added machine-readable schemas and fixtures for approvals, automation
  bindings, and selected surface-local artifacts
- internalized the orchestration-domain behavior previously left implicit or
  externally assumed
- aligned decision evidence and durable run evidence with their continuity-owned
  storage boundaries

## Readiness Matrix

| Surface | Status | Basis |
|---|---|---|
| `workflows` | implementation-ready | package-local domain, execution, lifecycle, governance, and run-linkage rules plus workflow-specific contracts |
| `missions` | implementation-ready | package-local domain, execution, lifecycle, and mission-binding rules plus mission/run linkage contracts |
| `campaigns` | implementation-ready | package-local domain and lifecycle rules plus campaign contracts |
| `automations` | implementation-ready | execution model, dependency resolution, failure model, and automation execution contract |
| `watchers` | implementation-ready | runtime architecture, dependency resolution, observability, and watcher event contract |
| `queue` | implementation-ready | dependency resolution, runtime architecture, failure model, and queue item / lease contract |
| `runs` | implementation-ready | runtime architecture, workflow execution, coordination lock, liveness, observability, and run linkage contract |
| `incidents` | implementation-ready | governance model, lifecycle, failure model, and incident object contract |

## Required Contract Set

- `contracts/versioning-and-compatibility-policy.md` — `package-normative`
- `contracts/cross-surface-reference-contract.md` — `package-normative`
- `contracts/decision-record-contract.md` — `schema-backed` via `contracts/schemas/decision-record.schema.json`
- `contracts/campaign-object-contract.md` — `package-normative`
- `contracts/workflow-execution-contract.md` — `schema-backed` via `contracts/schemas/workflow-execution.schema.json`
- `contracts/automation-execution-contract.md` — `schema-backed` via `contracts/schemas/automation-execution.schema.json`
- `contracts/coordination-lock-contract.md` — `schema-backed` via `contracts/schemas/coordination-lock.schema.json`
- `contracts/watcher-event-contract.md` — `schema-backed` via `contracts/schemas/watcher-event.schema.json`
- `contracts/queue-item-and-lease-contract.md` — `schema-backed` via `contracts/schemas/queue-item-and-lease.schema.json`
- `contracts/run-linkage-contract.md` — `schema-backed` via `contracts/schemas/run-linkage.schema.json`
- `contracts/incident-object-contract.md` — `schema-backed` via `contracts/schemas/incident-object.schema.json`
- `contracts/discovery-and-authority-layer-contract.md` — `package-normative`
- `contracts/mission-workflow-binding-contract.md` — `package-normative`
- `contracts/campaign-mission-coordination-contract.md` — `package-normative`

## Required Control Documents

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
- `normative-dependencies-and-source-of-truth-map.md`
- `lifecycle-and-state-machine-spec.md`
- `routing-authority-and-execution-control.md`
- `evidence-observability-and-retention-spec.md`
- `assurance-and-acceptance-matrix.md`
- `operator-and-authoring-runbook.md`
- `reference-examples.md`
- `failure-modes-and-safety-analysis.md`
- `adr/README.md`

## Canonicalization Targets

Promotion targets for live Harmony authority surfaces are defined in:

- `canonicalization-target-map.md`

Proof-layer enforcement is provided by:

- `/.harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-package.sh`

This package is now implementation-ready at the design, contract, and
validation-artifact level, and canonicalization-ready at the promotion-planning
level.

## Harmony Philosophy Alignment

This package aligns with Harmony's philosophy because it preserves:

- `agent-first` execution through bounded agent-readable orchestration surfaces
- `system-governed` control through explicit governance boundaries and incident
  escalation
- single source of truth through per-surface contracts and canonical reference
  rules
- contract-first design through explicit object, interface, and linkage
  contracts
- progressive disclosure through staged discovery artifacts and promotion
  targets
- minimal sufficient complexity through a mature core of `workflows`,
  `missions`, and `runs`, with optional scale surfaces added only when needed

## Implementation Gate Checklist

- [ ] Every runtime surface uses the canonical identifier fields from the
      cross-surface reference contract.
- [ ] Every material action attempt emits exactly one continuity decision record.
- [ ] Every material autonomous execution emits a run record linked to
      continuity evidence and `decision_id`.
- [ ] Event-to-automation routing is deterministic, including zero-match,
      target-hint, and multi-match fan-out behavior.
- [ ] `match_mode`, `dedupe_window`, and `bindings.yml` semantics are defined
      and enforced consistently.
- [ ] Schedule-window evaluation is deterministic across timezone and DST
      boundaries.
- [ ] Every side-effectful material action derives a `coordination_key` and
      acquires the required lock before external side effects begin.
- [ ] Every workflow advertises executable metadata including `version`,
      `side_effect_class`, `cancel_safe`, and `coordination_key_strategy`.
- [ ] Every watcher emits the canonical event envelope.
- [ ] Every queue item conforms to the canonical queue item schema and lease
      behavior.
- [ ] Every claimed queue item carries `claimed_at`, `claim_deadline`, and
      `claim_token`, and stale ack attempts are rejected.
- [ ] Queue ingress remains automation-only; missions are created only
      downstream when bounded follow-up work is needed.
- [ ] Every automation defines explicit concurrency, idempotency, and retry
      policy.
- [ ] Every automation retry policy uses canonical failure classes and supported
      backoff semantics.
- [ ] Every privileged action references a valid approval or override artifact
      whose scope and expiry match the action.
- [ ] Every privileged action also resolves to a non-revoked approver authority
      entry with sufficient scope.
- [ ] Automation `replace` is allowed only for workflows that explicitly declare
      `execution_controls.cancel_safe: true`.
- [ ] Every event-triggered automation defines trigger selection in `trigger.yml`
      rather than in bindings or policy.
- [ ] Orphan allow decisions, missing evidence links, and other launch-commit
      failures are detected by reconciliation and surfaced operator-visibly.
- [ ] Every active run has one executor owner, a valid liveness lease, and a
      deterministic recovery path if that lease expires.
- [ ] Every incident object satisfies lifecycle and closure evidence rules.
- [ ] Every schema-backed contract has a valid JSON Schema plus one valid and
      one invalid fixture.
- [ ] Required surface-local artifacts validate against their declared schemas.
- [ ] Workflow execution metadata, coordination lock artifacts, and approver
      authority registry artifacts validate against their schemas.
- [ ] `validate-orchestration-design-package.sh` passes.
- [ ] Every promoted surface satisfies the discovery-and-authority layering
      contract.
- [ ] Contract evolution satisfies the versioning and compatibility policy.
- [ ] Mission-to-workflow invocation and linkage satisfy the mission binding
      contract.
- [ ] Campaign aggregation and lifecycle boundaries satisfy the campaign
      coordination contract.
- [ ] `campaigns` remain optional and are introduced only if mission
      coordination load justifies them.

## Non-Blocking Follow-Ups

The following choices still need implementation decisions, but they are no
longer architectural blockers:

- backing storage technology
- operator-facing presentation or dashboard tooling
- operational default values such as lease timeout duration, schedule evaluation
  tick frequency, executor heartbeat interval, or exact backoff interval
  constants
