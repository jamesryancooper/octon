# Service Boundaries And Core Data Model

## Service / Process Boundaries

The package supports logical modules first. Separate deployable services are
optional as long as the same contracts and invariants hold.

| Boundary | What Crosses | Sync/Async | Governing Contract | Stable Surface |
|---|---|---|---|---|
| Discovery Loader -> Controllers | resolved refs, object metadata | sync | package-local normative docs + runtime artifacts | canonical fields only |
| Watcher Runner -> Event Router | watcher events | async | `contracts/watcher-event-contract.md` | event envelope |
| Event Router -> Queue Manager | queue item creation requests | sync or async | `contracts/queue-item-and-lease-contract.md` | queue item shape |
| Queue Manager -> Automation Controller | claimed queue item | async | queue contract + dependency resolution | claim semantics |
| Launching Component -> Coordination Manager | lock acquisition request | sync | `concurrency-control-model.md`, `contracts/coordination-lock-contract.md` | lock schema and outcomes |
| Launching Component -> Workflow Launcher | workflow launch request | sync | `contracts/workflow-execution-contract.md` | launch request/response |
| Workflow Launcher -> Executor Supervisor | executor launch, ack, heartbeat, terminalization | async | workflow execution contract + liveness spec | execution state signals |
| Controllers -> Decision Writer | decision payload | sync | `contracts/decision-record-contract.md` | decision fields |
| Controllers -> Run Writer | run lifecycle update | sync | `contracts/run-linkage-contract.md` | run fields |
| Incident Manager -> Approval Resolver | approval + authority lookup | sync | `approval-and-override-contract.md`, `approver-authority-model.md` | approval and authority fields |

Implementation-private details:

- transport choice
- caching
- worker topology
- storage engine internals

Stable details:

- canonical identifiers
- schema-backed artifacts
- decision/run/lock/approval semantics

## Authoritative Data Model

### WorkflowMetadata

Purpose:
- executable workflow contract consumed by orchestration

Required fields:
- `workflow_group`
- `workflow_id`
- `version`
- `entrypoint_ref`
- `side_effect_class`
- `execution_controls.cancel_safe`
- `coordination_key_strategy`
- `required_inputs[]`
- `produced_outputs[]`
- `executor_interface_version`

Relationships:
- referenced by automations, missions, incidents

Validation:
- schema-backed
- side-effectful workflows cannot use `coordination_key_strategy.kind=none`

### TriggerDefinition

Purpose:
- define schedule or event-based launch eligibility

Required fields:
- `kind`
- schedule subtree or event subtree

Relationships:
- belongs to exactly one automation

### Automation

Purpose:
- unattended launch surface

Required fields:
- `automation_id`
- `workflow_ref`
- owner
- status
- trigger
- bindings
- policy

Relationships:
- targets exactly one workflow
- may consume queue items

### WatcherDefinition

Purpose:
- detection surface

Required fields:
- `watcher_id`
- title
- owner
- status

Relationships:
- emits watcher events

### WatcherEvent

Purpose:
- canonical event emitted by watcher logic

Required fields:
- `event_id`
- `watcher_id`
- `event_type`
- `emitted_at`
- `severity`
- `dedupe_key`
- `source_ref`
- `summary`

Relationships:
- may route to zero or more queue items

### QueueItem

Purpose:
- machine-ingest work item for one automation

Required fields:
- `queue_item_id`
- `target_automation_id`
- `status`
- `priority`
- `available_at`
- `attempt_count`
- `max_attempts`
- `summary`
- `enqueued_at`

Conditional fields:
- claim fields when `status=claimed`

### DecisionRecord

Purpose:
- authoritative route/authority evidence

Required fields:
- `decision_id`
- `outcome`
- `surface`
- `action`
- `actor`
- `decided_at`
- `reason_codes`
- `summary`

Conditional fields:
- `run_id` only for `allow`
- lock fields for side-effectful actions
- approval/override refs for privileged actions

### ExecutionRun

Purpose:
- canonical execution instance

Required fields:
- `run_id`
- `status`
- `started_at`
- `decision_id`
- `continuity_run_path`
- `summary`

Conditional fields:
- context refs
- liveness fields when `status=running`
- `completed_at` when terminal

### CoordinationLock

Purpose:
- target-global exclusivity or compatibility artifact

Required fields:
- `lock_id`
- `coordination_key`
- `lock_class`
- `owner_run_id`
- `lock_state`
- `acquired_at`
- `lease_expires_at`
- `lock_version`

Conditional fields:
- `owner_executor_id`
- `last_heartbeat_at`
- `released_at`
- `previous_lock_id`

### ApprovalArtifact

Purpose:
- privileged action authorization

Required fields:
- `approval_id`
- `artifact_type`
- `action_class`
- `scope`
- `approved_by`
- `issued_at`
- `expires_at`
- `rationale`
- `review_required`

### ApproverAuthority

Purpose:
- registry-backed proof that an approver is allowed to authorize a scope

Required fields:
- `approver_id`
- `role`
- `approved_scopes`
- `issued_at`
- `expires_at`
- `revoked`

### IncidentRecord

Purpose:
- exception / containment state

Required fields:
- `incident_id`
- title
- severity
- status
- owner
- created_at
- summary

## Derived / Projection Records

- `runtime/runs/index.yml`
- `runtime/runs/by-surface/*`
- counters and summaries in watcher and automation state

These are query aids only. They must resolve back to authoritative records.
