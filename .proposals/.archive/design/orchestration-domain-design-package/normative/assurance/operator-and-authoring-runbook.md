# Operator And Authoring Runbook

## Purpose

Provide practical guidance for humans and agents authoring and operating the
orchestration domain within Octon policy.

## Authoring Principles

1. Author contracts before behavior.
2. Register new artifacts before expecting them to route.
3. Fail closed when prerequisites are missing.
4. Keep runtime, governance, practices, and continuity responsibilities
   separate.

## Safe Authoring Workflow

1. Identify the surface and confirm it is the right owner.
2. Update or create the relevant contract first.
3. Add or update discovery artifacts.
4. Add or update the object definition.
5. Add validation and operator guidance.
6. Verify evidence and routing expectations.

## How To Author Each Surface Safely

### `workflows`

- keep procedure definition bounded
- do not embed recurrence or long-lived state
- ensure run emission and evidence linkage are explicit
- declare `execution_controls.cancel_safe` only when cancellation is safe and
  deterministic

### `missions`

- keep scope bounded and owned
- reference workflows, do not redefine them
- record mission-to-run linkage explicitly

### `runs`

- treat as orchestration-facing projection only
- point to continuity evidence rather than duplicating it
- always link material runs to `decision_id`

### `automations`

- define exactly one workflow target
- put trigger selection in `trigger.yml`
- keep parameter mapping in `bindings.yml`
- keep retry/idempotency/concurrency in `policy.yml`

### `watchers`

- define explicit sources, rules, and emitted event contract
- never let watcher logic launch workflows directly

### `queue`

- keep ingress automation-only
- validate item schema and lease semantics
- do not use queue as a human planning backlog
- reject stale acknowledgements that present the wrong `claim_token`

### `incidents`

- keep escalation and closure operator-visible
- require linked runs and closure evidence

### `campaigns`

- keep aggregation strategic
- do not let campaigns own execution

## How To Register New Artifacts

For collection-style surfaces:

1. add or update `manifest.yml`
2. add or update `registry.yml`
3. add the surface object directory
4. add practices and validation references

For infrastructure-style surfaces:

1. update `README.md`
2. update schema/index artifacts
3. verify lane or projection semantics

## How To Inspect Runs

Check in order:

1. orchestration-facing run record
2. by-surface projection
3. linked `decision_id`
4. continuity evidence bundle
5. linked mission or incident context

Questions to answer:

- did the run complete?
- what triggered it?
- what evidence proves the result?
- did it escalate or create follow-up work?

## How To Inspect Decision Records

Check in order:

1. `decision_id`
2. `continuity/decisions/<decision-id>/decision.json`
3. related run, queue item, automation, or incident references

Questions to answer:

- why was the action allowed, blocked, or escalated?
- which reason codes were recorded?
- what approval or prerequisite was missing?

## How To Diagnose Watcher And Queue Issues

### Watchers

Inspect:

- source definitions
- rules
- emitted event contract
- health state
- suppression and cursor state

Common failures:

- unreadable source
- invalid emitted event shape
- duplicate-suppression mistakes

### Queue

Inspect:

- lane placement
- lease metadata
- `claimed_at`
- `claim_token`
- retry count and next availability
- dead-letter reasons
- receipts

Common failures:

- expired claims
- stale acknowledgements using the wrong `claim_token`
- missing target automation
- item stuck in retry without advancing
- ack without receipt

## How To Pause/Resume Automations

Pause when:

- repeated terminal failures occur
- a target workflow is unsafe or invalid
- policy or incident handling requires containment

Resume only after:

- trigger validity is rechecked
- workflow target resolves
- policy prerequisites pass
- operator or policy-backed approval exists where required

## How To Open, Manage, And Close Incidents

### Open

- create incident object
- assign owner
- link triggering runs or workflow context

### Manage

- update timeline on severity or status changes
- link containment and remediation runs
- create mission if follow-up becomes bounded multi-session work

### Close

- ensure closure evidence exists
- ensure remediation evidence or waiver exists
- require explicit closure authority

## How To Reason About Automation Overlap

- `serialize`: defer new launch until the active run completes
- `drop`: suppress duplicate or over-limit launch and inspect the decision record
- `parallel`: allow overlap only up to `max_concurrency`
- `replace`: valid only when the target workflow is marked
  `execution_controls.cancel_safe: true`

## How To Archive Or Retire Missions And Campaigns

### Missions

- archive only after `completed` or `cancelled`
- do not archive active unresolved work

### Campaigns

- archive only after related missions are terminal or explicitly waived
- keep campaign archival separate from mission archival

## Blocked-State And Escalation Paths

When blocked:

- stop before material side effects
- record decision reason
- expose operator-visible blocked status
- require re-validation before retry

Escalate when:

- authority is unclear
- closure approval is required
- policy thresholds are crossed
- break-glass or incident response rules are needed

## What Belongs Where

| Concern | Home |
|---|---|
| active executable/stateful surfaces | `runtime/` |
| authority, policy, escalation, incident policy | `governance/` |
| authoring rules, operator guidance, lifecycle discipline | `practices/` |
| append-oriented evidence and handoff memory | `continuity/` |

## Prohibited Moves

- putting policy rules in runtime state files
- storing durable evidence as live runtime state
- using queue as a human task planner
- embedding workflows inside missions or campaigns
- allowing watchers to bypass automation routing
