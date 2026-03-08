# Runtime, Enforcement, Validation, And Failure Handling

## Runtime And Storage Model

Persistent storage required for:

- automations
- watchers
- queue items
- runs
- decisions
- coordination locks
- incidents
- approval artifacts
- approver authority registry

Requires atomicity:

- queue claim transitions
- lock acquisition and renewal
- run creation before side effects
- decision creation before side effects

Requires CAS semantics:

- queue claim
- coordination lock acquire / renew / transfer
- run-owner update during recovery when ownership changes

Requires leasing / heartbeats:

- coordination locks
- active run ownership

Can be eventually consistent:

- derived run projections
- counters and dashboards
- non-authoritative summaries

Time assumptions:

- one authoritative clock domain for lease and expiry comparisons
- ISO timestamps everywhere
- timezone-aware schedule resolution
- monotonic lock version increments

Idempotency must be enforced at:

- event-driven automation launches
- scheduled automation windows
- recovery / replay entry points

## Enforcement Points And Invariants

| Invariant | Enforced Where | Proof Artifact | Violation Response |
|---|---|---|---|
| No side effects before decision record | launch admission path | decision record | block execution |
| No side effects before lock acquisition | coordination manager + launcher | decision `lock_status`, lock artifact | block/defer/escalate |
| No privileged action without valid approval | policy evaluator | approval artifact + approver registry | escalate/block |
| No active run without executor owner or recovery eligibility | run writer + reconciler | run liveness fields | `recovery_pending` |
| No second exclusive owner on same coordination key | coordination manager | lock artifact | contention outcome |
| No launch with invalid bindings | automation controller | binding validation result + decision record | block |
| No stale claim ack | queue manager | receipt + claim token comparison | reject and record failed handling |
| No incident close without evidence and authority | incident manager | closure evidence + approval | block |

## Validator Scope

### Static / Package Validation

Must enforce:

- required normative docs exist
- required hardening and closure sections exist
- all declared schema-backed contracts have schemas plus valid and invalid
  fixtures
- workflow execution metadata schema
- coordination lock schema
- approval artifact schema
- approver registry schema
- automation bindings schema
- retry taxonomy validity
- schedule grammar validity
- active-run liveness fields in fixtures

### Runtime Enforcement

Must enforce:

- lock acquisition before side effects
- approval freshness and approver authority at admission time
- executor ack before side-effectful steps
- heartbeat lease validity
- stale-run reconciliation
- queue claim token correctness

Cannot be proven statically:

- actual lock acquisition in live runtime
- real approver revocation freshness at runtime
- real executor liveness
- real absence of side effects before lock/decision except through runtime
  ordering code

## Failure Handling Blueprint

| Failure | Expected Behavior | Required Persistence Updates | Recovery Type |
|---|---|---|---|
| trigger/schema error | block activation or routing | decision record or validation failure | blocked |
| binding failure | block launch | decision record with binding failure | blocked |
| policy subsystem unavailable | fail closed | decision or operator-visible error | escalated |
| queue claim CAS failure | reload and retry selection | none or failed handling record | automatic retry |
| lock contention | defer/block/escalate by entry mode | decision record, maybe queue retry | automatic or blocked |
| executor crash before ack | `recovery_pending` | run update | automatic reconciliation |
| heartbeat expiry | `recovery_pending` | run + maybe lock state update | automatic reconciliation |
| orphaned decision | no speculative start | controller error/incident | automatic or escalated |
| incomplete side-effect evidence | block completion/closure | run inconsistency visible | blocked |
| approval expiry before admission | reject privileged action | decision record | blocked/escalated |
| lost lock during execution | stop new side effects, recover | run + lock + incident updates | escalated/recovery |
