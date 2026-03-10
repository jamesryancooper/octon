# Surface Artifact Schemas

## Purpose

Identify required surface-local artifacts that need machine-readable schemas to
prevent implementation drift.

This document is normative for schema coverage expectations.

## Required Schema Coverage

| Surface | Artifact | Required Schema |
|---|---|---|
| `automations` | `automation.yml` | `contracts/schemas/automation-definition.schema.json` |
| `automations` | `trigger.yml` | `contracts/schemas/automation-trigger.schema.json` |
| `automations` | `bindings.yml` | `contracts/schemas/automation-bindings.schema.json` |
| `automations` | `policy.yml` | `contracts/schemas/automation-policy.schema.json` |
| `workflows` | `workflow.yml` | `contracts/schemas/workflow-execution.schema.json` |
| `missions` | `mission.yml` | `contracts/schemas/mission-object.schema.json` |
| `watchers` | `watcher.yml` | `contracts/schemas/watcher-definition.schema.json` |
| `watchers` | `sources.yml` | `contracts/schemas/watcher-sources.schema.json` |
| `watchers` | `rules.yml` | `contracts/schemas/watcher-rules.schema.json` |
| `watchers` | `emits.yml` | `contracts/schemas/watcher-emits.schema.json` |
| `incidents` | `incident.yml` | `contracts/schemas/incident-object.schema.json` |
| `incidents` | `actions.yml` | `contracts/schemas/incident-actions.schema.json` |
| coordination manager | lock artifact | `contracts/schemas/coordination-lock.schema.json` |
| approvals / overrides | approval artifact | `contracts/schemas/approval-and-override.schema.json` |
| governance | approver authority registry | `contracts/schemas/approver-authority-registry.schema.json` |

For `automations`, the schema-backed definition layer is split across
`automation.yml`, `trigger.yml`, `bindings.yml`, and `policy.yml`. Aggregate
bundle validation may exist for contract proof, but validators must target the
real authored runtime artifacts first.

For `workflows`, the schema-backed artifact is the definition contract
(`workflow.yml`), not registry metadata or prose guidance.

For `missions`, the schema-backed artifact is `mission.yml`, not `mission.md`.
Mission Markdown, task state, and progress logs remain subordinate narrative or
mutable local state/evidence assets.

`stages/*.md` remain Markdown assets. They do not require a JSON Schema, but
they must be resolved only from a valid `workflow.yml` and remain subject to
drift checks for relative pathing and local asset ownership.

For `watchers`, the definition layer is the four-file family
`watcher.yml` + `sources.yml` + `rules.yml` + `emits.yml`.

Watcher `state/*.json` artifacts remain runner-owned mutable state in v1. They
must satisfy behavioral guarantees from the lifecycle, observability, and
retention specs, but they are not promoted as schema-backed cross-runtime
definition artifacts in this package pass.

For `incidents`, `incident.yml` is the canonical object/state artifact because
incidents are runtime-born response records rather than author-authored
definitions. `actions.yml` is subordinate machine-readable coordination data
and is required whenever the incident tracks executable response actions.
`timeline.md` and `closure.md` remain prose evidence and must not outrank
`incident.yml`.

For `queue`, v1 does not introduce a separate surface-local definition artifact
beyond runtime discovery projections. The authoritative machine-readable
definition is `contracts/schemas/queue-item-and-lease.schema.json`, referenced
by `contracts/queue-item-and-lease-contract.md`. Any surface-local `schema.yml`
remains a projection/reference artifact and must not become an independent
behavioral authority.

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

If an artifact is required by surface layout and operator behavior, but lacks a
schema, the package is not fully hardened for independent implementation.
