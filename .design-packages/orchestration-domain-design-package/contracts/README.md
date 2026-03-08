# Implementation Contracts

This directory contains the concrete contracts that implement the
orchestration-domain specification defined by this package.

## Reading Order

1. `versioning-and-compatibility-policy.md`
2. `cross-surface-reference-contract.md`
3. `decision-record-contract.md`
4. `workflow-execution-contract.md`
5. `campaign-object-contract.md`
6. `automation-execution-contract.md`
7. `coordination-lock-contract.md`
8. `watcher-event-contract.md`
9. `queue-item-and-lease-contract.md`
10. `run-linkage-contract.md`
11. `incident-object-contract.md`
12. `discovery-and-authority-layer-contract.md`
13. `mission-workflow-binding-contract.md`
14. `campaign-mission-coordination-contract.md`

## Contract Roles

- `versioning-and-compatibility-policy.md`
  - Normative versioning, deprecation, and compatibility rules for orchestration
    contracts
- `cross-surface-reference-contract.md`
  - Canonical identifiers and reference fields used across all surfaces
- `decision-record-contract.md`
  - Canonical decision evidence for `allow`, `block`, and `escalate` outcomes
- `workflow-execution-contract.md`
  - Workflow metadata schema, launch interface, and executor state contract
- `campaign-object-contract.md`
  - Minimum campaign schema, lifecycle, and invariants
- `automation-execution-contract.md`
  - Trigger model, policy model, concurrency, idempotency, and run rules for
    automations
- `coordination-lock-contract.md`
  - Lock artifact schema, lease semantics, and compare-and-swap acquisition
    behavior
- `watcher-event-contract.md`
  - Event envelope emitted by watchers
- `queue-item-and-lease-contract.md`
  - Queue item schema, lane semantics, claim lease behavior, retry, and
    dead-letter rules
- `run-linkage-contract.md`
  - Run record shape and linkage to continuity evidence
- `incident-object-contract.md`
  - Incident object schema, state machine, and closure evidence rules
- `discovery-and-authority-layer-contract.md`
  - Progressive-disclosure and source-of-truth rules for orchestration surfaces
- `mission-workflow-binding-contract.md`
  - Mission-to-workflow reference, invocation, and run-linkage rules
- `campaign-mission-coordination-contract.md`
  - Campaign-to-mission aggregation and lifecycle-boundary rules

## Current-Surface Note

`workflows` and `missions` remain existing Harmony runtime surfaces, but their
orchestration-domain behavior in this package is governed first by:

- `domain-model.md`
- `orchestration-execution-model.md`
- `orchestration-lifecycle.md`
- `governance-and-policy.md`
- the cross-surface reference, run linkage, decision record, and mission
  binding contracts in this directory

Live `.harmony` workflow and mission docs remain important integration and
promotion context, but they are not the primary source of target orchestration
behavior for this package.

## Proof Layer

Machine-readable proof artifacts for schema-backed object contracts live under:

- `contracts/schemas/`
- `contracts/fixtures/valid/`
- `contracts/fixtures/invalid/`

Validation is enforced by:

- `/.harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-package.sh`

### Proof Coverage

| Contract | Validation Mode | Proof Artifact |
|---|---|---|
| `versioning-and-compatibility-policy.md` | `package-normative` | package-local change-control rules plus validator coverage |
| `cross-surface-reference-contract.md` | `package-normative` | `domain-model.md`, `dependency-resolution.md`, and schema-backed object contracts |
| `decision-record-contract.md` | `schema-backed` | `contracts/schemas/decision-record.schema.json` |
| `workflow-execution-contract.md` | `schema-backed` | `contracts/schemas/workflow-execution.schema.json` |
| `campaign-object-contract.md` | `package-normative` | `domain-model.md` and `orchestration-lifecycle.md` |
| `automation-execution-contract.md` | `schema-backed` | `contracts/schemas/automation-execution.schema.json` |
| `coordination-lock-contract.md` | `schema-backed` | `contracts/schemas/coordination-lock.schema.json` |
| `watcher-event-contract.md` | `schema-backed` | `contracts/schemas/watcher-event.schema.json` |
| `queue-item-and-lease-contract.md` | `schema-backed` | `contracts/schemas/queue-item-and-lease.schema.json` |
| `run-linkage-contract.md` | `schema-backed` | `contracts/schemas/run-linkage.schema.json` |
| `incident-object-contract.md` | `schema-backed` | `contracts/schemas/incident-object.schema.json` |
| `discovery-and-authority-layer-contract.md` | `package-normative` | `runtime-architecture.md`, `orchestration-lifecycle.md`, and package-local authority rules |
| `mission-workflow-binding-contract.md` | `package-normative` | `domain-model.md`, `orchestration-execution-model.md`, and `orchestration-lifecycle.md` |
| `campaign-mission-coordination-contract.md` | `package-normative` | `domain-model.md` and `orchestration-lifecycle.md` |

### Supplementary Hardening Schemas

The following schemas back hardening guarantees introduced outside the primary
contract list:

- `contracts/schemas/approval-and-override.schema.json`
- `contracts/schemas/approver-authority-registry.schema.json`
- `contracts/schemas/automation-bindings.schema.json`
- `contracts/schemas/coordination-lock.schema.json`
- `contracts/schemas/workflow-execution.schema.json`
- `contracts/schemas/watcher-definition.schema.json`
- `contracts/schemas/watcher-rules.schema.json`
- `contracts/schemas/incident-actions.schema.json`
