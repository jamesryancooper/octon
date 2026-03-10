# Reference Examples

## Purpose

Provide concrete worked examples that show the orchestration model in motion and
remove ambiguity from the abstract model.

These examples are illustrative. Contracts and control documents remain
authoritative if an example and a contract ever diverge.

## Example 1: Manual Mission-Driven Execution

### Involved Surfaces

- `missions`
- `workflows`
- `runs`
- `continuity`

### Important Contracts

- `contracts/mission-workflow-binding-contract.md`
- `contracts/run-linkage-contract.md`
- `contracts/cross-surface-reference-contract.md`

### Pseudo Objects

```yaml
mission_id: "release-readiness-capabilities"
default_workflow_refs:
  - workflow_group: "audit"
    workflow_id: "audit-release-readiness-workflow"
```

```yaml
run_id: "run-20260308-release-readiness-01"
workflow_ref:
  workflow_group: "audit"
  workflow_id: "audit-release-readiness-workflow"
mission_id: "release-readiness-capabilities"
decision_id: "dec-20260308-release-readiness-allow-01"
continuity_run_path: ".harmony/continuity/runs/run-20260308-release-readiness-01/"
```

### Step-By-Step Flow

1. A mission is created in `runtime/missions/release-readiness-capabilities/`.
2. The mission references `audit-release-readiness-workflow` via
   `default_workflow_refs[]`.
3. A human or delegated actor invokes the workflow in mission context.
4. A decision record is written for the admitted workflow launch.
5. The workflow executes as a bounded procedure.
6. A run record is emitted with `mission_id`, `workflow_ref`, and
   `decision_id`.
7. Durable evidence is written under `continuity/runs/<run_id>/`.
8. Mission-local state is updated:
   - `log.md`
   - `tasks.json`
   - optional recent run linkage

### State Transitions

- mission: `created -> active`
- run: `running -> succeeded|failed|cancelled`

### Evidence Expectations

- run record exists
- decision record exists
- continuity evidence path resolves
- mission links to the resulting run where useful

### Failure / Containment Notes

- if the workflow fails, the run becomes `failed`
- the mission remains `active` unless explicitly cancelled
- blocked follow-up work is represented through mission tasks and evidence, not
  by mutating workflow definition

### What Must NOT Happen

- the mission must not embed workflow step content
- the workflow must not become mission-specific without a new workflow identity
- the run evidence must not live only inside mission files

## Example 2: Event-Driven Execution

### Involved Surfaces

- `watchers`
- `queue`
- `automations`
- `workflows`
- `runs`
- `continuity`

### Important Contracts

- `contracts/watcher-event-contract.md`
- `contracts/queue-item-and-lease-contract.md`
- `contracts/automation-execution-contract.md`
- `contracts/run-linkage-contract.md`

### Pseudo Objects

```yaml
event_id: "evt-20260308-governance-drift-01"
watcher_id: "governance-drift-watcher"
event_type: "freshness-drift"
severity: "warning"
source_ref: ".harmony/orchestration/runtime/workflows"
target_automation_id: "weekly-freshness-audit"
```

```yaml
queue_item_id: "q-20260308-001"
event_id: "evt-20260308-governance-drift-01"
watcher_id: "governance-drift-watcher"
target_automation_id: "weekly-freshness-audit"
status: "claimed"
claimed_by: "weekly-freshness-audit"
claimed_at: "2026-03-08T18:00:05Z"
claim_deadline: "2026-03-08T18:10:05Z"
claim_token: "claim-weekly-freshness-audit-0001"
```

```yaml
automation_id: "weekly-freshness-audit"
workflow_ref:
  workflow_group: "audit"
  workflow_id: "audit-continuous-workflow"
trigger:
  kind: "event"
  event:
    watcher_ids: ["governance-drift-watcher"]
    event_types: ["freshness-drift"]
    severity_at_or_above: "warning"
    source_ref_globs:
      - ".harmony/orchestration/runtime/**"
    match_mode: "all"
```

### Step-By-Step Flow

1. `governance-drift-watcher` evaluates its sources and detects a stale state.
2. The watcher emits `evt-20260308-governance-drift-01`.
3. The event becomes queue item `q-20260308-001`.
4. `weekly-freshness-audit` claims the queue item and writes
   `claimed_at` plus `claim_token`.
5. The automation validates `trigger.yml`, `bindings.yml`, and `policy.yml`.
   In this example the event matches because `warning >= warning` under the
   canonical severity order and the full normalized `source_ref` matches
   `.harmony/orchestration/runtime/**`.
6. An allow decision record is written for the admitted launch.
7. The automation launches `audit-continuous-workflow`.
8. A run record is created:
   - `automation_id`
   - `workflow_ref`
   - `event_id`
   - `queue_item_id`
   - `decision_id`
9. Durable evidence is written under `continuity/runs/<run_id>/`.
10. On success, the queue item is acknowledged by matching `claim_token`,
    receipt is written, and the item is removed from active
   lanes.

### State Transitions

- watcher: remains `active`
- queue item: `pending -> claimed -> removed from active lanes`
- automation: remains `active`
- run: `running -> succeeded|failed|cancelled`

### Evidence Expectations

- watcher event envelope is preserved
- decision record exists for the admitted launch
- queue receipt exists on success
- run links both to queue item and event
- continuity evidence bundle exists

### Failure / Containment Notes

- if the claim expires without ack, the queue item moves to `retry`
- stale ack with the wrong `claim_token` is rejected
- if retries exceed policy, the queue item moves to `dead_letter`
- if policy requires it, repeated failure opens or enriches an incident
- if a later run on the same `coordination_key` loses liveness, only the same
  executor may resume it in v1; otherwise the run is abandoned and containment
  takes over

### What Must NOT Happen

- watcher must not launch the workflow directly
- queue must not target a mission directly
- event-trigger selection must not be inferred from `bindings.yml`
- `replace` must not preempt a workflow that is not cancel-safe

## Example 3: Incident Path

### Involved Surfaces

- `runs`
- `incidents`
- `workflows`
- `missions`
- `continuity`

### Important Contracts

- `contracts/incident-object-contract.md`
- `contracts/run-linkage-contract.md`
- `normative/governance/routing-authority-and-execution-control.md`

### Pseudo Objects

```yaml
incident_id: "inc-20260308-001"
severity: "sev2"
status: "open"
run_ids:
  - "run-20260308-release-readiness-01"
```

### Step-By-Step Flow

1. A material run fails with policy-threshold severity and retains its linked
   `decision_id`.
2. The orchestrator opens incident `inc-20260308-001`.
3. The incident is acknowledged by an owner.
4. A containment or rollback workflow is launched.
5. The containment workflow emits a new run.
6. If follow-up work exceeds one bounded run, a remediation mission is created.
7. The incident moves through:
   - `open -> acknowledged -> mitigating -> monitoring -> resolved`
8. Closure is attempted only after evidence and remediation/waiver are present.
9. Human-confirmed or policy-backed closure moves the incident to `closed`.
10. Post-resolution linkage remains available through:
   - incident -> runs
   - incident -> mission
   - runs -> continuity evidence

### State Transitions

- incident: `open -> acknowledged -> mitigating -> monitoring -> resolved -> closed`
- containment run: `running -> succeeded|failed|cancelled`
- remediation mission: `created -> active` if needed

### Evidence Expectations

- original failing run remains linked
- containment run is linked
- closure evidence exists
- continuity evidence bundles resolve for all linked runs

### Failure / Containment Notes

- incident closure without evidence must block
- escalation remains operator-visible
- containment failure may keep the incident in `mitigating` or raise severity

### What Must NOT Happen

- incident state must not become the policy author for closure or routing
- closing the incident must not delete lineage
- mission remediation must not erase the triggering run context

## Example 4: Blocked Replace Attempt

### Involved Surfaces

- `automations`
- `workflows`
- `runs`
- `continuity`

### Important Contracts

- `contracts/automation-execution-contract.md`
- `contracts/decision-record-contract.md`
- `normative/governance/routing-authority-and-execution-control.md`

### Pseudo Objects

```yaml
automation_id: "weekly-freshness-audit"
concurrency_mode: "replace"
max_concurrency: 1
workflow_ref:
  workflow_group: "audit"
  workflow_id: "audit-continuous-workflow"
```

```yaml
decision_id: "dec-20260308-weekly-freshness-audit-block-01"
outcome: "block"
reason_codes:
  - "workflow-not-cancel-safe-for-replace"
```

### Step-By-Step Flow

1. The automation receives a new eligible launch while a run is already active.
2. The automation evaluates `concurrency_mode=replace`.
3. The target workflow does not declare `execution_controls.cancel_safe: true`.
4. The orchestrator blocks the replacement.
5. A decision record is written under `continuity/decisions/<decision_id>/`.
6. No new run is emitted and the active run continues unchanged.

### Evidence Expectations

- a blocking decision record exists
- the active run remains the current canonical execution
- no replacement run is created

### Failure / Containment Notes

- the active run remains authoritative until a later allowed decision replaces it
- operators may pause the automation or change policy before retrying
- no implicit downgrade to `serialize`, `drop`, or `parallel` is allowed

### What Must NOT Happen

- `replace` must not cancel a workflow that is not explicitly cancel-safe
- a blocked replacement must not emit a new run
- the system must not guess an alternative overlap mode
