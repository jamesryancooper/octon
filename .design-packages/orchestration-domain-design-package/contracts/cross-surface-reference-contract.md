# Cross-Surface Reference Contract

## Purpose

This contract defines the canonical identifiers and reference fields used across
the mature orchestration model.

## Canonical Identifier Fields

| Surface | Canonical Identifier |
|---|---|
| `campaigns` | `campaign_id` |
| `missions` | `mission_id` |
| `workflows` | `workflow_id` |
| `workflows` group | `workflow_group` |
| `automations` | `automation_id` |
| `watchers` | `watcher_id` |
| watcher events | `event_id` |
| `queue` items | `queue_item_id` |
| `runs` | `run_id` |
| `incidents` | `incident_id` |
| decision records | `decision_id` |

## Canonical Reference Fields

| Source Surface | Required References | Optional References |
|---|---|---|
| `campaigns` | `campaign_id` | `mission_ids[]` |
| `missions` | `mission_id` | `campaign_id`, `related_run_ids[]`, `default_workflow_refs[]` |
| `workflows` | `workflow_id`, `workflow_group` | `mission_id`, `automation_id`, `incident_id` in execution context |
| `automations` | `automation_id`, `workflow_ref` | `campaign_id`, `mission_id`, `watcher_ids[]` |
| `watchers` | `watcher_id` | `target_automation_ids[]`, `candidate_incident_id` |
| `queue` | `queue_item_id`, `target_automation_id` | `event_id`, `watcher_id`, `candidate_incident_id` |
| `runs` | `run_id`, `decision_id` | `workflow_ref`, `mission_id`, `automation_id`, `incident_id`, `event_id`, `queue_item_id`, `parent_run_id` |
| `incidents` | `incident_id` | `run_ids[]`, `mission_ids[]`, `workflow_refs[]`, `automation_ids[]`, `event_ids[]`, `decision_ids[]` |

## Canonical Workflow Reference Shape

```yaml
workflow_ref:
  workflow_group: "audit"
  workflow_id: "audit-continuous-workflow"
```

## Relationship Rules

1. A `mission` may belong to zero or one `campaign`.
2. An `automation` must reference exactly one workflow target.
3. A `watcher` event may recommend a target automation but must not directly
   invoke workflows.
4. A `queue` item is automation-ingress only and must reference exactly one
   `target_automation_id`.
5. A `run` must reference the strongest available execution context:
   - `workflow_ref` is required for workflow-backed runs
   - `automation_id` is required when launched by an automation
   - `mission_id` is required when the run belongs to mission-owned execution
   - `incident_id` is required when the run is part of incident response
6. Every material run must reference exactly one `decision_id`.
7. An `incident` should reference at least one run, workflow, mission, or
   decision record.
8. Event-trigger selection belongs to an automation-local `trigger.yml` artifact,
   not to queue items or watcher definitions.

## Invariants

- Identifiers are immutable after creation.
- Cross-surface references must use canonical identifier fields, not display
  names.
- References may be optional, but when present they must resolve to an existing
  surface object.
- `decision_id` references must resolve to a decision record under
  `continuity/decisions/`.
- Projection indexes may duplicate references for queryability, but the object
  record remains the source of truth.
