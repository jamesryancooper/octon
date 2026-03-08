# Implementation Contracts

This directory contains the concrete contracts that make the mature
orchestration model
proposal implementation-ready.

## Reading Order

1. `versioning-and-compatibility-policy.md`
2. `cross-surface-reference-contract.md`
3. `decision-record-contract.md`
4. `campaign-object-contract.md`
5. `automation-execution-contract.md`
6. `watcher-event-contract.md`
7. `queue-item-and-lease-contract.md`
8. `run-linkage-contract.md`
9. `incident-object-contract.md`
10. `discovery-and-authority-layer-contract.md`
11. `mission-workflow-binding-contract.md`
12. `campaign-mission-coordination-contract.md`

## Contract Roles

- `versioning-and-compatibility-policy.md`
  - Normative versioning, deprecation, and compatibility rules for orchestration
    contracts
- `cross-surface-reference-contract.md`
  - Canonical identifiers and reference fields used across all surfaces
- `decision-record-contract.md`
  - Canonical decision evidence for `allow`, `block`, and `escalate` outcomes
- `campaign-object-contract.md`
  - Minimum campaign schema, lifecycle, and invariants
- `automation-execution-contract.md`
  - Trigger model, policy model, concurrency, idempotency, and run rules for
    automations
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
  - Progressive-disclosure and source-of-truth rules for promoted surfaces
- `mission-workflow-binding-contract.md`
  - Mission-to-workflow reference, invocation, and run-linkage rules
- `campaign-mission-coordination-contract.md`
  - Campaign-to-mission aggregation and lifecycle-boundary rules

## Current-Surface Note

`workflows` and `missions` already have strong current Harmony contracts. Their
implementation readiness depends on:

- existing Harmony runtime docs
- the cross-surface reference contract in this directory
- the run linkage contract in this directory
- the decision record contract in this directory
- the mission workflow binding contract in this directory

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
| `versioning-and-compatibility-policy.md` | `live-authority-backed` | live Harmony governance and release authority |
| `cross-surface-reference-contract.md` | `live-authority-backed` | live workflow and mission authority plus schema-backed object contracts |
| `decision-record-contract.md` | `schema-backed` | `contracts/schemas/decision-record.schema.json` |
| `campaign-object-contract.md` | `live-authority-backed` | optional surface; promotion remains gated by live authority work |
| `automation-execution-contract.md` | `schema-backed` | `contracts/schemas/automation-execution.schema.json` |
| `watcher-event-contract.md` | `schema-backed` | `contracts/schemas/watcher-event.schema.json` |
| `queue-item-and-lease-contract.md` | `schema-backed` | `contracts/schemas/queue-item-and-lease.schema.json` |
| `run-linkage-contract.md` | `schema-backed` | `contracts/schemas/run-linkage.schema.json` |
| `incident-object-contract.md` | `schema-backed` | `contracts/schemas/incident-object.schema.json` |
| `discovery-and-authority-layer-contract.md` | `live-authority-backed` | live workflow progressive disclosure and authority layering |
| `mission-workflow-binding-contract.md` | `live-authority-backed` | live mission and workflow runtime/practices addenda |
| `campaign-mission-coordination-contract.md` | `live-authority-backed` | optional surface; promotion remains gated by live authority work |
