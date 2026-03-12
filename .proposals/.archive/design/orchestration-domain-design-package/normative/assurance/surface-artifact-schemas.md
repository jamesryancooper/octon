# Surface Artifact Schemas

## Purpose

Identify required machine-readable artifacts across the orchestration surface
portfolio that need explicit schemas to prevent implementation drift.

This document is normative for schema coverage expectations across:

- surface-local definition artifacts
- runtime-generated object/state artifacts
- cross-surface execution and evidence artifacts the portfolio depends on

## Required Schema Coverage

| Surface / Scope | Artifact | Required Schema |
|---|---|---|
| `workflows` | `workflow.yml` | `contracts/schemas/workflow-execution.schema.json` |
| `missions` | `mission.yml` | `contracts/schemas/mission-object.schema.json` |
| `automations` | `automation.yml` | `contracts/schemas/automation-definition.schema.json` |
| `automations` | `trigger.yml` | `contracts/schemas/automation-trigger.schema.json` |
| `automations` | `bindings.yml` | `contracts/schemas/automation-bindings.schema.json` |
| `automations` | `policy.yml` | `contracts/schemas/automation-policy.schema.json` |
| `watchers` | `watcher.yml` | `contracts/schemas/watcher-definition.schema.json` |
| `watchers` | `sources.yml` | `contracts/schemas/watcher-sources.schema.json` |
| `watchers` | `rules.yml` | `contracts/schemas/watcher-rules.schema.json` |
| `watchers` | `emits.yml` | `contracts/schemas/watcher-emits.schema.json` |
| `watchers` emitted evidence | watcher event envelope | `contracts/schemas/watcher-event.schema.json` |
| `queue` | queue item records in `pending/`, `claimed/`, `retry/`, and `dead-letter/` | `contracts/schemas/queue-item-and-lease.schema.json` |
| `runs` | canonical `<run-id>.yml` record | `contracts/schemas/run-linkage.schema.json` |
| `incidents` | `incident.yml` | `contracts/schemas/incident-object.schema.json` |
| `incidents` | `actions.yml` | `contracts/schemas/incident-actions.schema.json` |
| `campaigns` | `campaign.yml` | `contracts/schemas/campaign-object.schema.json` |
| continuity decision evidence | `continuity/decisions/<decision-id>/decision.json` | `contracts/schemas/decision-record.schema.json` |
| coordination manager | lock artifact | `contracts/schemas/coordination-lock.schema.json` |
| approvals / overrides | approval artifact | `contracts/schemas/approval-and-override.schema.json` |
| governance | approver authority registry | `contracts/schemas/approver-authority-registry.schema.json` |

For `automations`, the schema-backed definition layer is split across
`automation.yml`, `trigger.yml`, `bindings.yml`, and `policy.yml`. Aggregate
bundle validation may exist for contract proof, but validators must target the
real authored runtime artifacts first.

For `campaigns`, `campaign.yml` is the canonical object/state artifact because
campaign coordination needs machine-readable identity, lifecycle status,
mission membership, milestones, and waiver-sensitive completion metadata.
`log.md` remains subordinate prose evidence and operator guidance.

For `workflows`, the schema-backed artifact is the definition contract
(`workflow.yml`), not registry metadata or prose guidance.

For `missions`, the schema-backed artifact is `mission.yml`, not `mission.md`.
Mission Markdown, task state, and progress logs remain subordinate narrative or
mutable local state/evidence assets.

`stages/*.md` remain Markdown assets. They do not require a JSON Schema, but
they must be resolved only from a valid `workflow.yml` and remain subject to
drift checks for relative pathing and local asset ownership.

For `watchers`, both the definition family and the emitted event envelope are
machine-readable authority. `watcher.yml`, `sources.yml`, `rules.yml`, and
`emits.yml` define what a watcher may observe and emit. The watcher-event
schema defines the emitted execution-bearing evidence that downstream routing
consumes.

Watcher `state/*.json` artifacts remain runner-owned mutable state in v1. They
must satisfy behavioral guarantees from the lifecycle, observability, and
retention specs, but they are not promoted as schema-backed cross-runtime
definition artifacts in this package pass.

For `queue`, v1 does not introduce a separate authored definition artifact
beyond runtime discovery projections. The authoritative machine-readable
definition is the queue-item schema applied to the items stored in the lane
directories. Any surface-local `schema.yml` remains a projection/reference
artifact and must not become an independent behavioral authority.

For `runs`, the canonical `<run-id>.yml` record is the schema-backed
orchestration-facing object/state artifact. `index.yml` and `by-surface/`
remain projections only, while durable evidence remains continuity-owned.

For `incidents`, `incident.yml` is the canonical object/state artifact because
incidents are runtime-born response records rather than author-authored
definitions. `actions.yml` is subordinate machine-readable coordination data
and is required whenever the incident tracks executable response actions.
`timeline.md` and `closure.md` remain prose evidence and must not outrank
`incident.yml`.

Decision records are continuity-owned rather than orchestration-local, but they
remain mandatory machine-readable evidence for the portfolio because every
material orchestration action must resolve to exactly one `decision_id`.

## Validation Mode

Each required schema must have:

- a machine-readable schema
- one valid fixture
- one invalid fixture
- validator enforcement in
  `validate-orchestration-design-package.sh`

## Relationship To Discovery Layers

`contracts/discovery-and-authority-layer-contract.md` defines where artifacts
live. This document defines which of those artifacts must be schema-backed.

## Migration Rule

If an artifact is required by surface layout, execution behavior, or durable
decision/run evidence, but lacks a schema, the package is not fully hardened
for independent implementation.
