# Automation Execution Contract

## Purpose

This contract defines the implementation-ready object model and behavioral rules
for `automations`.

`automations` are a split-definition collection surface. Their authoritative
behavior lives in machine-readable files that separate:

- automation identity and workflow target
- trigger selection
- input binding/defaulting
- overlap, idempotency, retry, and incident policy

Markdown may explain the surface, but it must not become the canonical launch
contract.

## Required Object Artifacts

```text
automations/
├── manifest.yml
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

`bindings.yml` is required even when it contains only `{}`. Keeping it present
prevents trigger selection, workflow defaults, and binding semantics from
drifting into `trigger.yml`, `policy.yml`, or prose guidance.

## Automation Authority Model

- `manifest.yml`
  - discovery identity, summary, and canonical path projection
- `registry.yml`
  - routing metadata, dependency projections, operational summaries, and state
    pointers; never the canonical trigger or policy contract
- `automation.yml`
  - canonical automation identity, workflow target, owner, and lifecycle
    control state
- `trigger.yml`
  - canonical schedule or event selection contract
- `bindings.yml`
  - canonical workflow parameter defaults and event-to-parameter binding rules
- `policy.yml`
  - canonical overlap, idempotency, retry, and incident-escalation rules
- `state/status.json`, `state/last-run.json`, `state/counters.json`
  - mutable operational projections for controller state, recent launch
    activity, and counters
- decision and run evidence outside the automation tree
  - `continuity/decisions/`, `runtime/runs/`, and `continuity/runs/`

Authority rules:

1. `automation.yml` is the single source of truth for `automation_id`,
   `workflow_ref`, `owner`, and automation lifecycle control state.
2. `trigger.yml` is the single source of truth for schedule cadence,
   event-selection criteria, and dedupe-window configuration.
3. `bindings.yml` is the single source of truth for input defaults and event
   parameter extraction. It must not introduce trigger selection or retry
   policy.
4. `policy.yml` is the single source of truth for overlap, idempotency, retry,
   and automation-local incident escalation policy.
5. `registry.yml` may project selected fields for discovery or operator UX, but
   it must not outrank the per-automation definition files.
6. `state/*.json` files may project current status, last-run summaries, and
   counters, but they must not redefine workflow target, trigger selection, or
   execution policy.
7. Decisions and runs are the authority for what execution actually happened.
   Automation-local state must not replace that evidence.

## Required Schema Coverage

| Artifact | Schema |
|---|---|
| `automation.yml` | `contracts/schemas/automation-definition.schema.json` |
| `trigger.yml` | `contracts/schemas/automation-trigger.schema.json` |
| `bindings.yml` | `contracts/schemas/automation-bindings.schema.json` |
| `policy.yml` | `contracts/schemas/automation-policy.schema.json` |
| aggregate contract bundle | `contracts/schemas/automation-execution.schema.json` |

The aggregate bundle schema is supporting proof for the contract as a whole.
Validators must treat the file-level schemas above as the primary authority
checks for authored runtime artifacts.

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
| `cadence` | yes | schedule cadence using the grammar in `../orchestration-execution-model.md` |
| `at` | yes | local execution time in `HH:MM` 24-hour form |
| `timezone` | yes | IANA timezone |
| `missed_run_policy` | yes | `skip`, `run_immediately`, `next_window` |

#### `trigger.yml` event shape

| Field | Required | Notes |
|---|---|---|
| `watcher_ids` | yes | allowed source watchers |
| `event_types` | yes | allowed event types |
| `severity_at_or_above` | no | minimum event severity |
| `source_ref_globs` | no | optional source filters |
| `match_mode` | yes | `all` requires every declared selector group to match; `any` requires at least one declared selector group to match |
| `dedupe_window` | no | optional suppression window for semantically identical events after idempotency-key derivation |

### `bindings.yml`

| Field | Required | Notes |
|---|---|---|
| `default_params` | no | workflow parameter defaults |
| `event_to_param_map` | no | only for event-triggered automations; governed by `../automation-bindings-contract.md` |

Rules:

- `bindings.yml` may be `{}` for automations that need neither defaults nor
  event-derived parameters.
- `event_to_param_map` is allowed only when `trigger.kind=event`.
- `bindings.yml` must never select events or redefine retry/concurrency policy.

### `policy.yml`

| Field | Required | Notes |
|---|---|---|
| `max_concurrency` | yes | integer `>= 1` |
| `concurrency_mode` | yes | `serialize`, `drop`, `replace`, `parallel` |
| `idempotency_strategy.kind` | yes | `event-dedupe` or `schedule-window` |
| `idempotency_strategy.key_fields` | yes | canonical fields used to derive the idempotency key |
| `retry_policy` | yes | attempts, supported backoff mode (`fixed`, `linear`, `exponential`), and canonical retryable error classes from `../failure-model.md` |
| `pause_on_error` | yes | boolean |
| `incident_policy.open_incident_on[]` | no | automation-local incident escalation thresholds listed below |

#### Supported `incident_policy.open_incident_on[]` values

- `repeated-terminal-failure`
- `retry-exhausted`
- `launch-commit-failure`
- `evidence-write-failure`

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
  `execution_controls.cancel_safe` in the schema-backed `workflow.yml`
  definition artifact.
- Omitted `execution_controls.cancel_safe` is treated as `false`.

## Behavioral Rules

1. Every automation must target exactly one workflow.
2. Every automation must contain valid `automation.yml`, `trigger.yml`,
   `bindings.yml`, and `policy.yml` artifacts.
3. Every admitted launch attempt must emit a run record linked to a
   `decision_id`.
4. Every blocked, dropped, or escalated launch attempt must emit a decision
   record, even when no run is created.
5. Event-triggered automations must select events only through `trigger.yml`.
6. Event-triggered launches must validate bindings according to
   `../automation-bindings-contract.md` before `allow` is possible.
7. Side-effectful launches must satisfy
   `../concurrency-control-model.md` in addition to automation-local overlap
   policy.
8. `max_concurrency`, `concurrency_mode`, and idempotency rules must be
   enforced before workflow launch.
9. `replace` may not preempt a workflow unless
   `execution_controls.cancel_safe=true`.
10. If `pause_on_error=true`, repeated terminal failures move the automation to
    `paused`.
11. One event may route to multiple automations, but each queue item and each
    admitted launch remains automation-specific.

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
    - "transient_runtime_failure"
pause_on_error: true
incident_policy:
  open_incident_on:
    - "repeated-terminal-failure"
    - "retry-exhausted"
```
