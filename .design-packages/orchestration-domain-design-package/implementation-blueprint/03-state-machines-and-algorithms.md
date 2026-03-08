# State Machines And Core Algorithms

## Core State Machines

### Execution Run

| State | Allowed Transitions | Trigger | Invalid Transitions | Invariants |
|---|---|---|---|---|
| `running` | `succeeded`, `failed`, `cancelled` | executor completion / cancellation | any terminal -> `running` | one executor owner, valid lease, decision linked |
| `succeeded` | none | terminal success | back to active | `completed_at` required |
| `failed` | none | terminal failure | back to active | summary + evidence required |
| `cancelled` | none | policy/operator/executor cancel | back to active | lineage preserved |

Run liveness substate:

| Recovery Status | Allowed Transitions | Trigger | Invariants |
|---|---|---|---|
| `healthy` | `suspect` | missed expected liveness signal | executor ack + heartbeat current |
| `suspect` | `healthy`, `recovery_pending` | heartbeat restore or lease expiry | no duplicate side effects assumed |
| `recovery_pending` | `recovered`, `abandoned` | reconciler decision | no relaunch on same key without resolution |
| `recovered` | terminal or `healthy` | resumed ownership | lineage preserved |
| `abandoned` | none except follow-up work | explicit authority | run not silently reused |

### Queue Item

| State | Allowed Transitions | Trigger | Invalid Transitions | Invariants |
|---|---|---|---|---|
| `pending` | `claimed`, `dead_letter` | claim or quarantine | `pending -> retry` without failure semantics | target automation required |
| `claimed` | removed, `retry`, `dead_letter` | ack, lease expiry, failure | second simultaneous claim | one active claim token |
| `retry` | `claimed`, `dead_letter` | next eligibility or ceiling | direct ack without claim | attempt count monotonic |
| `dead_letter` | none | terminal | re-entry to active lanes | terminal quarantine |

### Coordination Lock

| State | Allowed Transitions | Trigger | Invalid Transitions | Invariants |
|---|---|---|---|---|
| `held` | `released`, `expired`, `transferred` | terminal run, expiry, recovery transfer | second held owner on exclusive key | one held exclusive owner/key |
| `released` | none | normal release | held again without new acquisition | `released_at` required |
| `expired` | none or transfer via new lock | liveness expiry | silent reuse | lineage preserved |
| `transferred` | none | explicit recovery transfer | implicit transfer | `previous_lock_id` required |

### Approval Validity

| State | Allowed Transitions | Trigger | Invalid Transitions | Invariants |
|---|---|---|---|---|
| valid | expired / revoked | time or registry revocation | use outside scope | approval + approver both valid |
| expired | none | time passes | valid again without new artifact | not accepted |
| revoked | none | registry revocation | valid again without new registry entry | revocation wins |

## Core Algorithms

### Trigger Matching

Purpose:
- map one watcher event to zero or more automations

Inputs:
- watcher event
- active automations

Outputs:
- matching automation set
- queue items
- routing decisions

Ordered steps:

1. filter active event-triggered automations
2. compute selector results for watcher id, event type, severity threshold, and
   source glob
3. apply `match_mode`
4. apply target hint intersection if present
5. sort remaining candidates lexically by `automation_id`
6. create one queue item per surviving candidate

Fail-closed behavior:
- no match or invalid selector behavior blocks queue creation

### Schedule Evaluation

Purpose:
- emit due scheduled launch attempts

Inputs:
- scheduled automation
- current time
- timezone

Outputs:
- due schedule-window ids

Ordered steps:

1. resolve cadence grammar
2. compute windows anchored from local midnight for `hourly:N`
3. apply DST rules
4. apply `missed_run_policy`
5. derive schedule-window idempotency key

Fail-closed:
- invalid schedule blocks activation

### Event Dedupe

Purpose:
- suppress semantically duplicate launches

Inputs:
- event
- automation
- optional `dedupe_window`
- existing lineage

Outputs:
- suppress/admit decision

Ordered steps:

1. compute event-dedupe key
2. search admitted, active, and terminal lineage for same key
3. if within `dedupe_window`, suppress and emit decision

Fail-closed:
- if dedupe cannot be evaluated, block admission

### Parameter Binding Validation

Purpose:
- convert event fields into workflow inputs

Inputs:
- binding contract
- event

Outputs:
- validated parameter map or block

Ordered steps:

1. validate binding object shape
2. resolve `from` source paths
3. apply optional defaults
4. enforce `value_type`

Fail-closed:
- missing required input or type mismatch blocks

### Dependency Resolution

Purpose:
- decide readiness for a material action

Inputs:
- orchestration unit
- refs
- artifacts
- state
- policy

Outputs:
- `allow` / `block` / `escalate`

Ordered steps:

1. load authoritative definitions
2. resolve refs
3. validate artifacts/contracts
4. validate lifecycle state
5. validate approvals/policy
6. compute idempotency
7. derive coordination key if needed

Fail-closed:
- ambiguity blocks or escalates

### Policy Evaluation

Purpose:
- enforce scope and privileged-action rules

Inputs:
- objective scope
- surface policy
- action class
- approvals

Outputs:
- decision basis

Ordered steps:

1. verify action is in objective scope
2. verify surface-local policy
3. if privileged, verify approval artifact and approver authority
4. record reason codes

Fail-closed:
- missing approval or authority escalates or blocks

### Approval Verification

Purpose:
- prove privileged action authorization

Inputs:
- approval artifact
- approver registry
- requested action

Outputs:
- valid/invalid result
- scope hash

Ordered steps:

1. load approval artifact
2. check expiry
3. load approver registry entry by `approved_by`
4. reject if missing, expired, or revoked
5. compare scope, action, optional workflow group, and coordination key
6. emit scope hash

Fail-closed:
- any mismatch blocks

### Coordination-Key Derivation

Purpose:
- identify the shared target for side-effect control

Inputs:
- workflow metadata strategy
- launch inputs/context

Outputs:
- `coordination_key`

Ordered steps:

1. resolve strategy kind
2. extract declared source fields
3. apply format template
4. require non-empty result

Fail-closed:
- missing or ambiguous input blocks launch

### Lock Acquisition / Renewal / Release

Purpose:
- prevent conflicting side effects

Inputs:
- coordination key
- lock class
- run id
- heartbeat

Outputs:
- lock acquired / deferred / failed / released

Ordered steps:

1. read current lock by key
2. CAS acquire if no conflicting held lock
3. on success, persist held lock with lease
4. renew on heartbeat
5. release on terminal run

Fail-closed:
- no side effects until acquisition succeeds

### Launch Admission

Purpose:
- convert eligible request into executing workflow

Inputs:
- resolved workflow metadata
- parameter map
- decision basis
- lock result

Outputs:
- decision record
- run record
- executor launch request

Ordered steps:

1. verify prerequisites
2. verify approval if needed
3. acquire lock if needed
4. write decision record
5. create run
6. send launch request
7. wait for executor ack before side-effectful execution

Fail-closed:
- any missing step blocks or escalates

### Retry Classification

Purpose:
- decide if retry is permitted

Inputs:
- failure class
- policy
- attempts
- current eligibility

Outputs:
- retry / dead-letter / pause / error

Ordered steps:

1. check failure class in canonical retry list
2. check attempt ceiling
3. check idempotency and overlap safety
4. apply backoff mode

Fail-closed:
- unknown failure class is non-retryable

### Stale-Run Reconciliation

Purpose:
- recover orphaned or stale active runs

Inputs:
- run liveness fields
- coordination lock
- incident policy

Outputs:
- recovered / abandoned / recovery_pending transitions

Ordered steps:

1. detect missing ack or expired heartbeat
2. mark `recovery_pending`
3. preserve same coordination key
4. reconciler chooses resume / transfer / abandon
5. update run and incident as needed

Fail-closed:
- no new side-effectful execution on same key until recovery resolves

## Residual Algorithm Ambiguities

- severity ordering semantics
- `source_ref_globs` matching dialect
- reconciler choice policy for resume vs transfer vs abandon
