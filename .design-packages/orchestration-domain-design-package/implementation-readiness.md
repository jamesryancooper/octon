# Implementation Readiness

## Verdict

The mature orchestration model is now implementation-ready at the proposal,
contract, and validation-artifact level.

That means:

- each surface has a purpose and boundary specification
- the example shapes are defined
- the missing cross-surface contracts are codified
- the model can now move from architecture proposal to concrete implementation
  planning without needing additional core architecture discovery

It does not mean runtime code has been shipped.

## What Changed To Reach Implementation Readiness

- codified watcher event envelope rules
- codified material decision evidence with canonical `decision_id` linkage
- codified queue item and lease semantics
- codified automation concurrency and idempotency behavior
- codified run linkage between orchestration projections and continuity evidence
- codified incident object lifecycle and closure rules
- codified campaign object state and lifecycle
- codified canonical cross-surface identifiers and references
- added machine-readable schemas and fixtures for the highest-risk object
  contracts
- aligned decision evidence to a live continuity authority surface
- aligned incident governance to a live generic policy surface instead of a
  product-specific runbook

## Readiness Matrix

| Surface | Status | Basis |
|---|---|---|
| `workflows` | implementation-ready | existing Harmony workflow contracts plus cross-surface reference, run linkage, and workflow execution-control addenda |
| `missions` | implementation-ready | existing Harmony mission contracts plus cross-surface reference, mission binding, decision record, and run linkage contracts |
| `campaigns` | implementation-ready | campaign object contract plus surface specification |
| `automations` | implementation-ready | automation execution contract plus surface specification |
| `watchers` | implementation-ready | watcher event contract plus surface specification |
| `queue` | implementation-ready | queue item and lease contract plus surface specification |
| `runs` | implementation-ready | run linkage contract plus continuity evidence split |
| `incidents` | implementation-ready | incident object contract plus governance/runtime split |

## Required Contract Set

- `contracts/versioning-and-compatibility-policy.md` — `live-authority-backed`
- `contracts/cross-surface-reference-contract.md` — `live-authority-backed`
- `contracts/decision-record-contract.md` — `schema-backed` via `contracts/schemas/decision-record.schema.json`
- `contracts/campaign-object-contract.md` — `live-authority-backed`
- `contracts/automation-execution-contract.md` — `schema-backed` via `contracts/schemas/automation-execution.schema.json`
- `contracts/watcher-event-contract.md` — `schema-backed` via `contracts/schemas/watcher-event.schema.json`
- `contracts/queue-item-and-lease-contract.md` — `schema-backed` via `contracts/schemas/queue-item-and-lease.schema.json`
- `contracts/run-linkage-contract.md` — `schema-backed` via `contracts/schemas/run-linkage.schema.json`
- `contracts/incident-object-contract.md` — `schema-backed` via `contracts/schemas/incident-object.schema.json`
- `contracts/discovery-and-authority-layer-contract.md` — `live-authority-backed`
- `contracts/mission-workflow-binding-contract.md` — `live-authority-backed`
- `contracts/campaign-mission-coordination-contract.md` — `live-authority-backed`

## Required Control Documents

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

This proposal package is now implementation-ready at the design, contract, and
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
- [ ] Every watcher emits the canonical event envelope.
- [ ] Every queue item conforms to the canonical queue item schema and lease
      behavior.
- [ ] Every claimed queue item carries `claimed_at`, `claim_deadline`, and
      `claim_token`, and stale ack attempts are rejected.
- [ ] Queue ingress remains automation-only; missions are created only
      downstream when bounded follow-up work is needed.
- [ ] Every automation defines explicit concurrency, idempotency, and retry
      policy.
- [ ] Automation `replace` is allowed only for workflows that explicitly declare
      `execution_controls.cancel_safe: true`.
- [ ] Every event-triggered automation defines trigger selection in `trigger.yml`
      rather than in bindings or policy.
- [ ] Every incident object satisfies lifecycle and closure evidence rules.
- [ ] Every schema-backed contract has a valid JSON Schema plus one valid and
      one invalid fixture.
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
- file format choices where multiple acceptable encodings exist
- operational default values such as lease timeout duration or retry backoff
- UI or operator tooling around these surfaces
