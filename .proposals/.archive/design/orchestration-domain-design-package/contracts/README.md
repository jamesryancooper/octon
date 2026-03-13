# Implementation Contracts

This directory contains the concrete contracts that implement the
orchestration-domain specification defined by this package.

## Reading Order

1. `versioning-and-compatibility-policy.md`
2. `cross-surface-reference-contract.md`
3. `decision-record-contract.md`
4. `workflow-execution-contract.md`
5. `mission-object-contract.md`
6. `campaign-object-contract.md`
7. `automation-execution-contract.md`
8. `coordination-lock-contract.md`
9. `watcher-definition-contract.md`
10. `watcher-event-contract.md`
11. `queue-item-and-lease-contract.md`
12. `run-linkage-contract.md`
13. `incident-object-contract.md`
14. `discovery-and-authority-layer-contract.md`
15. `mission-workflow-binding-contract.md`
16. `campaign-mission-coordination-contract.md`

## Contract Roles

- `versioning-and-compatibility-policy.md`
  - Normative versioning, deprecation, and compatibility rules for orchestration
    contracts
- `cross-surface-reference-contract.md`
  - Canonical identifiers and reference fields used across all surfaces
- `decision-record-contract.md`
  - Canonical decision evidence for `allow`, `block`, and `escalate` outcomes
- `workflow-execution-contract.md`
  - Workflow definition artifact, launch interface, and executor state contract
- `mission-object-contract.md`
  - Schema-backed mission definition, lifecycle, ownership, and linkage object
- `campaign-object-contract.md`
  - Schema-backed campaign object/state authority, lifecycle, and invariants
- `automation-execution-contract.md`
  - Split automation definition artifacts, trigger model, policy model,
    concurrency, idempotency, and run rules for automations
- `coordination-lock-contract.md`
  - Lock artifact schema, lease semantics, and compare-and-swap acquisition
    behavior
- `watcher-definition-contract.md`
  - Watcher definition-layer artifacts, authority split, and watcher-local
    state/evidence separation
- `watcher-event-contract.md`
  - Event envelope emitted by watchers
- `queue-item-and-lease-contract.md`
  - Queue item schema, lane semantics, claim lease behavior, retry, and
    dead-letter rules for `queue`
- `run-linkage-contract.md`
  - Run record shape, projection-layer rules, and linkage to continuity
    evidence
- `incident-object-contract.md`
  - Incident object schema, state machine, and closure evidence rules
- `discovery-and-authority-layer-contract.md`
  - Progressive-disclosure and source-of-truth rules for orchestration surfaces
- `mission-workflow-binding-contract.md`
  - Mission-to-workflow reference, invocation, and run-linkage rules
- `campaign-mission-coordination-contract.md`
  - Campaign-to-mission aggregation and lifecycle-boundary rules

## Current-Surface Note

`workflows` and `missions` remain existing Octon runtime surfaces, but their
orchestration-domain behavior in this package is governed first by:

- `normative/architecture/domain-model.md`
- `normative/execution/orchestration-execution-model.md`
- `normative/execution/orchestration-lifecycle.md`
- `normative/governance/governance-and-policy.md`
- the cross-surface reference, run linkage, decision record, and mission
  object and mission binding contracts in this directory

Live `.octon` workflow and mission docs remain important integration and
promotion context, but they are not the primary source of target orchestration
behavior for this package.

## Proof Layer

Machine-readable proof artifacts for schema-backed object contracts live under:

- `contracts/schemas/`
- `contracts/fixtures/valid/`
- `contracts/fixtures/invalid/`

Validation is enforced by:

- `/.octon/assurance/runtime/_ops/scripts/validate-orchestration-design-package.sh`
- `conformance/validate_scenarios.py` for package semantic conformance

### Proof Coverage

| Contract | Validation Mode | Proof Artifact |
|---|---|---|
| `versioning-and-compatibility-policy.md` | `package-normative` | package-local change-control rules plus validator coverage |
| `cross-surface-reference-contract.md` | `package-normative` | `normative/architecture/domain-model.md`, `normative/execution/dependency-resolution.md`, and schema-backed object contracts |
| `decision-record-contract.md` | `schema-backed` | `contracts/schemas/decision-record.schema.json` |
| `workflow-execution-contract.md` | `schema-backed` | `contracts/schemas/workflow-execution.schema.json` validating `workflow.yml` |
| `mission-object-contract.md` | `schema-backed` | `contracts/schemas/mission-object.schema.json` validating `mission.yml` |
| `campaign-object-contract.md` | `schema-backed` | `contracts/schemas/campaign-object.schema.json` validating `campaign.yml` |
| `automation-execution-contract.md` | `schema-backed` | aggregate `contracts/schemas/automation-execution.schema.json` plus file-level schemas for `automation.yml`, `trigger.yml`, `bindings.yml`, and `policy.yml` |
| `coordination-lock-contract.md` | `schema-backed` | `contracts/schemas/coordination-lock.schema.json` |
| `watcher-definition-contract.md` | `package-normative` | `contracts/schemas/watcher-definition.schema.json`, `contracts/schemas/watcher-sources.schema.json`, `contracts/schemas/watcher-rules.schema.json`, and `contracts/schemas/watcher-emits.schema.json` |
| `watcher-event-contract.md` | `schema-backed` | `contracts/schemas/watcher-event.schema.json` |
| `queue-item-and-lease-contract.md` | `schema-backed` | `contracts/schemas/queue-item-and-lease.schema.json` |
| `run-linkage-contract.md` | `schema-backed` | `contracts/schemas/run-linkage.schema.json` |
| `incident-object-contract.md` | `schema-backed` | `contracts/schemas/incident-object.schema.json` |
| `discovery-and-authority-layer-contract.md` | `package-normative` | `normative/architecture/runtime-architecture.md`, `normative/execution/orchestration-lifecycle.md`, and package-local authority rules |
| `mission-workflow-binding-contract.md` | `package-normative` | `normative/architecture/domain-model.md`, `normative/execution/orchestration-execution-model.md`, and `normative/execution/orchestration-lifecycle.md` |
| `campaign-mission-coordination-contract.md` | `package-normative` | `normative/architecture/domain-model.md` and `normative/execution/orchestration-lifecycle.md` |

### Supplementary Hardening Schemas

The following schemas back hardening guarantees introduced outside the primary
contract list:

- `contracts/schemas/approval-and-override.schema.json`
- `contracts/schemas/approver-authority-registry.schema.json`
- `contracts/schemas/automation-definition.schema.json`
- `contracts/schemas/automation-bindings.schema.json`
- `contracts/schemas/automation-trigger.schema.json`
- `contracts/schemas/automation-policy.schema.json`
- `contracts/schemas/coordination-lock.schema.json`
- `contracts/schemas/workflow-execution.schema.json`
- `contracts/schemas/watcher-definition.schema.json`
- `contracts/schemas/watcher-sources.schema.json`
- `contracts/schemas/watcher-rules.schema.json`
- `contracts/schemas/watcher-emits.schema.json`
- `contracts/schemas/incident-actions.schema.json`
