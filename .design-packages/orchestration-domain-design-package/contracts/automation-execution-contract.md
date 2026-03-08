# Automation Execution Contract

## Purpose

This contract defines the implementation-ready object model and behavioral rules
for `automations`.

## Required Object Artifacts

```text
automations/
├── registry.yml
└── <automation-id>/
    ├── automation.yml
    ├── trigger.yml
    ├── bindings.yml
    ├── policy.yml
    └── state/
        ├── status.json
        ├── last-run.json
        └── counters.json
```

## Minimum Automation Fields

### `automation.yml`

| Field | Required | Notes |
|---|---|---|
| `automation_id` | yes | canonical stable id |
| `title` | yes | operator-readable name |
| `workflow_ref` | yes | canonical workflow reference |
| `owner` | yes | human or agent owner |
| `status` | yes | `active`, `paused`, `disabled`, `error` |

### `trigger.yml`

Required for all automations.

| Field | Required | Notes |
|---|---|---|
| `kind` | yes | `schedule` or `event` |
| `schedule` | required when `kind=schedule` | cadence/timing rules |
| `event` | required when `kind=event` | event selection rules |

#### `trigger.yml` schedule shape

| Field | Required | Notes |
|---|---|---|
| `cadence` | yes | schedule cadence |
| `at` | yes | execution time |
| `timezone` | yes | timezone |
| `missed_run_policy` | yes | `skip`, `run_immediately`, `next_window` |

#### `trigger.yml` event shape

| Field | Required | Notes |
|---|---|---|
| `watcher_ids` | yes | allowed source watchers |
| `event_types` | yes | allowed event types |
| `severity_at_or_above` | no | minimum event severity |
| `source_ref_globs` | no | optional source filters |
| `match_mode` | yes | `all` or `any` |
| `dedupe_window` | no | optional event dedupe window |

### `bindings.yml`

| Field | Required | Notes |
|---|---|---|
| `default_params` | no | workflow parameter defaults |
| `event_to_param_map` | no | only for event-triggered automations |

### `policy.yml`

| Field | Required | Notes |
|---|---|---|
| `max_concurrency` | yes | integer `>= 1` |
| `concurrency_mode` | yes | `serialize`, `drop`, `replace`, `parallel` |
| `idempotency_strategy.kind` | yes | `event-dedupe` or `schedule-window` |
| `idempotency_strategy.key_fields` | yes | canonical fields used to derive the idempotency key |
| `retry_policy` | yes | attempts, backoff, retryable error classes |
| `pause_on_error` | yes | boolean |
| `incident_policy` | no | incident escalation threshold or target |

## State Model

`active <-> paused`

`active|paused -> disabled`

`active -> error -> paused|disabled|active`

## Concurrency Semantics

### `serialize`

- Requires `max_concurrency=1`.
- If a run is already active, the new eligible launch is deferred rather than
  launched.
- Queue-backed work remains unacknowledged until admitted. Schedule-backed work
  follows `missed_run_policy`.

### `drop`

- If the launch is a duplicate or would exceed `max_concurrency`, the launch is
  suppressed.
- No run is emitted.
- A blocking decision record and suppression counter update are required.

### `parallel`

- Distinct launches may overlap up to `max_concurrency`.
- If `max_concurrency` is reached, the new eligible launch is deferred rather
  than dropped.

### `replace`

- Requires `max_concurrency=1`.
- Requires the target workflow to declare
  `execution_controls.cancel_safe: true`.
- If no run is active, the launch behaves like a normal admitted launch.
- If a run is active, the newest eligible launch wins, the active run is
  cancelled first, and the replacement launch is emitted only after the prior
  run reaches `cancelled`.
- If cancellation safety is not declared or cancellation cannot be confirmed,
  the replacement launch blocks and emits a decision record. It does not
  silently downgrade to another mode.

## Idempotency Semantics

- `event-dedupe` is required for event-triggered automations and derives the
  idempotency key from:
  - `automation_id`
  - `event_id`
  - `workflow_ref.workflow_id`
- `schedule-window` is required for scheduled automations and derives the
  idempotency key from:
  - `automation_id`
  - resolved schedule window identifier

## Workflow-Side Requirement

- Workflows that may be targeted by `replace` must expose
  `execution_controls.cancel_safe` in workflow registry metadata.
- Omitted `execution_controls.cancel_safe` is treated as `false`.

## Behavioral Rules

1. Every automation must target exactly one workflow.
2. Every admitted launch attempt must emit a run record linked to a
   `decision_id`.
3. Every blocked, dropped, or escalated launch attempt must emit a decision
   record, even when no run is created.
4. Event-triggered automations must select events only through `trigger.yml`.
5. `max_concurrency`, `concurrency_mode`, and idempotency rules must be
   enforced before workflow launch.
6. `replace` may not preempt a workflow unless
   `execution_controls.cancel_safe=true`.
7. If `pause_on_error=true`, repeated terminal failures move the automation to
   `paused`.

## Example Policy

```yaml
max_concurrency: 1
concurrency_mode: "serialize"
idempotency_strategy:
  kind: "event-dedupe"
  key_fields:
    - "automation_id"
    - "event_id"
    - "workflow_ref.workflow_id"
retry_policy:
  max_attempts: 3
  backoff: "exponential"
  retryable_classes:
    - "transient"
pause_on_error: true
incident_policy:
  open_incident_on:
    - "repeated-terminal-failure"
```
