# Orchestration Failure Playbooks

Operator playbooks for the most common orchestration failure classes.

## Purpose

These playbooks define:

- the first reversible action
- the artifacts to inspect
- the command path to use
- the escalation point

They do not authorize policy exceptions.

## 1. Watcher Source Unreadable

Use when:

- watcher health reports `error`
- the source path cannot be read
- no recent watcher evaluation is visible

First reversible action:

- pause the affected watcher if it is emitting unreliable signals

Inspect:

- `octon orchestration summary --surface watchers`
- `octon orchestration lookup --watcher-id <watcher-id>`
- watcher `state/health.json`
- watcher source definition in `sources.yml`

Escalate when:

- the unreadable source affects incident-worthy automation paths
- repeated source failures suggest broader filesystem or authority problems

## 2. Automation Target Workflow Unresolved

Use when:

- automation health shows target resolution failure
- event routing succeeds but launch admission blocks

First reversible action:

- pause the affected automation rather than mutating watcher definitions or
  queue state

Inspect:

- `octon orchestration summary --surface automations`
- `octon orchestration lookup --automation-id <automation-id>`
- automation `automation.yml`
- workflow discovery via workflow manifest and registry

Escalate when:

- the unresolved target affects multiple automations
- the workflow has drifted from its canonical contract or discovery path

## 3. Queue Item Expired Without Ack

Use when:

- queue summary shows expired leases or retry/dead-letter growth
- a queue item moved out of `claimed/` after lease expiry

First reversible action:

- inspect the item and receipt history before replaying or force-acknowledging

Inspect:

- `octon orchestration summary --surface queue`
- `octon orchestration lookup --queue-item-id <queue-item-id>`
- queue lane file and any matching receipt entries
- linked run or decision, if any

Escalate when:

- expiry repeats for the same automation or executor path
- dead-letter growth suggests systemic execution or lease problems

## 4. Stale Acknowledgement With Wrong `claim_token`

Use when:

- ack fails because the supplied `claim_token` does not match
- receipts exist but the queue item was not correctly finalized

First reversible action:

- stop retrying the stale ack and inspect current queue ownership

Inspect:

- `octon orchestration lookup --queue-item-id <queue-item-id>`
- queue receipt entries
- queue item current lane and claim metadata

Escalate when:

- claim-token mismatches are recurring
- multiple executors appear to be contending for the same queue item

## 5. Active Run Missing Acknowledgement Or Heartbeat

Use when:

- run health shows expired heartbeat
- run health shows missing acknowledgement
- recovery status becomes non-healthy

First reversible action:

- contain the affected automation or incident path before launching more work

Inspect:

- `octon orchestration summary --surface runs`
- `octon orchestration lookup --run-id <run-id>`
- run lease and heartbeat timestamps
- linked decision, queue item, and continuity evidence

Escalate when:

- recovery status is `recovery_pending`
- the same executor path repeatedly loses acknowledgement or heartbeat

## 6. Incident Closure Blocked By Missing Evidence

Use when:

- an operator wants to close an incident
- closure readiness reports blockers
- closure.md exists but readiness still fails

First reversible action:

- do not close the incident; gather or explicitly waive the missing evidence

Inspect:

- `octon orchestration lookup --incident-id <incident-id>`
- `octon orchestration incident closure-readiness --incident-id <incident-id>`
- linked runs, remediation refs, waiver refs, and approval artifacts

Escalate when:

- required evidence cannot be produced
- closure would require a policy exception or severity downgrade

## Boundary

- Prefer the smallest reversible intervention first.
- Use incident governance for closure authority:
  - `/.octon/orchestration/governance/incidents.md`
- Use the production runbook for product rollback and deploy handling:
  - `/.octon/orchestration/governance/production-incident-runbook.md`
