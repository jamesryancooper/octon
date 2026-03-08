# Run Linkage Contract

## Purpose

This contract defines the canonical orchestration-facing run record and its
linkage to continuity evidence.

## Required Artifacts

```text
orchestration/runtime/runs/
├── index.yml
├── by-surface/
│   ├── workflows/
│   ├── missions/
│   ├── automations/
│   └── incidents/
└── <run-id>.yml
```

Durable evidence remains under:

```text
continuity/runs/<run-id>/
```

## Run Record Fields

| Field | Required | Notes |
|---|---|---|
| `run_id` | yes | canonical stable id |
| `status` | yes | `running`, `succeeded`, `failed`, `cancelled` |
| `started_at` | yes | ISO timestamp |
| `completed_at` | no | required once terminal |
| `workflow_ref` | yes for workflow-backed runs | canonical workflow reference |
| `mission_id` | no | required when mission-owned |
| `automation_id` | no | required when launched by automation |
| `incident_id` | no | required when part of incident response |
| `event_id` | no | source watcher event |
| `queue_item_id` | no | source queue item |
| `parent_run_id` | no | lineage support |
| `decision_id` | yes | routing and authority decision record |
| `continuity_run_path` | yes | evidence bundle path |
| `summary` | yes | short outcome summary |

## Projection Rules

- `index.yml` is the global run index.
- `by-surface/` projections are query aids, not independent sources of truth.
- A run record is authoritative for orchestration status.
- Continuity evidence is authoritative for durable receipts, digests, and
  evidence bundles.

## Invariants

- `run_id` must match the continuity evidence directory name.
- `decision_id` must resolve to a continuity decision record.
- `continuity_run_path` is required for every material run.
- Terminal runs require `completed_at`.
- A `failed` run must include a non-empty `summary`.
- Projection entries must resolve back to a canonical `<run-id>.yml` file.

## Workflow And Mission Integration Rules

1. A workflow-backed execution context must always carry `workflow_ref`.
2. A mission-owned run must carry `mission_id`.
3. Workflows remain definition surfaces; they do not persist run history inside
   workflow artifacts.
4. Missions may project run linkage through fields such as:
   - `default_workflow_refs[]`
   - `active_run_ids[]`
   - `recent_run_ids[]`
5. `run_id` is the stable bridge across:
   - workflow execution context
   - mission execution context
   - automation launch state
   - decision evidence
   - continuity evidence storage

## Example

```yaml
run_id: "run-20260307-audit-continuous-01"
status: "succeeded"
started_at: "2026-03-07T18:05:00Z"
completed_at: "2026-03-07T18:08:00Z"
workflow_ref:
  workflow_group: "audit"
  workflow_id: "audit-continuous-workflow"
automation_id: "weekly-freshness-audit"
event_id: "evt-20260307-governance-drift-01"
queue_item_id: "q-20260307-001"
decision_id: "dec-20260307-weekly-freshness-audit-allow-01"
continuity_run_path: ".harmony/continuity/runs/run-20260307-audit-continuous-01/"
summary: "Continuous audit completed with warning-level findings."
```
