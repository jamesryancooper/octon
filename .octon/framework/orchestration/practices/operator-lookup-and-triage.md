# Operator Lookup And Triage

Operator guidance for inspecting orchestration state through canonical ids and
subordinate operator helpers.

## Purpose

Use this document when you need to answer:

- what happened?
- why did it happen?
- what is running now?
- what is blocked?
- what evidence proves the result?

This guidance is operational only. It does not create new execution authority.

## Default Operator Entry Points

Prefer these commands first:

- `octon orchestration summary --surface all`
- `octon orchestration lookup --run-id <run-id>`
- `octon orchestration lookup --decision-id <decision-id>`
- `octon orchestration lookup --incident-id <incident-id>`
- `octon orchestration lookup --queue-item-id <queue-item-id>`
- `octon orchestration lookup --event-id <event-id>`
- `octon orchestration incident closure-readiness --incident-id <incident-id>`

Use `generate-ops-snapshot.sh` when you need a dated markdown handoff or
operator summary report.

## Lookup Order

Start from the identifier you already have, then move through the canonical
lineage in this order:

1. `decision_id`
   - inspect decision outcome, reason codes, approval refs, and linked run or
     incident ids
2. `run_id`
   - inspect the bound run contract, then inspect orchestration-facing run
     projection, recovery status, and continuity evidence linkage
3. `queue_item_id`
   - inspect current lane, claim/lease state, target automation, and receipts
4. `event_id`
   - inspect watcher event lineage and all downstream queue/run/incident links
5. `incident_id`
   - inspect status, severity, owner, linked runs, and closure blockers
6. `mission_id`
   - inspect mission status, owner, linked runs, and outstanding bounded work

## Practical Triage Flow

1. Start with `summary --surface all`.
2. If one incident already exists, pivot to `lookup --incident-id`.
3. If the problem is execution-specific, pivot to `lookup --run-id`.
4. If the problem is ingress-specific, pivot to `lookup --queue-item-id` or
   `lookup --event-id`.
5. If closure is under consideration, run the closure-readiness check before
   any human closes the incident.

## Surface-Specific Questions

### Runs

Check:

- status
- recovery status
- decision link health
- continuity evidence link health
- lease and heartbeat timestamps

### Queue

Check:

- lane counts
- oldest pending age
- expired lease count
- dead-letter count
- receipt presence for handled items

### Watchers

Check:

- status
- last evaluation time
- last emitted event
- suppressed count
- health or error reason

### Automations

Check:

- status
- last launch attempt
- last successful run
- suppression count
- pause or error reason

### Incidents

Check:

- severity
- owner
- last timeline update
- linked runs
- closure blockers

## Escalation Rules

Escalate immediately when:

- a required lineage hop is missing
- a run is active with expired heartbeat or lease
- the queue shows repeated expiry or dead-letter growth
- incident closure readiness reports missing mandatory evidence
- the next step would require a policy exception or break-glass action

## Boundary

- Treat command output as a projection over canonical artifacts.
- Do not edit runtime or governance files directly as part of triage.
- Use the failure playbooks when a specific failure class is known:
  - `orchestration-failure-playbooks.md`
