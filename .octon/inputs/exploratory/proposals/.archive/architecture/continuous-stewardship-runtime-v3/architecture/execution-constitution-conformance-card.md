# Execution Constitution Conformance Card

## Authority

Stewardship durable meaning lives under `framework/**` and `instance/**` only.
`state/control/**` stores operational truth, `state/evidence/**` stores proof,
`state/continuity/**` stores resumable context, `generated/**` stores derived
read models only, and `inputs/**` remains non-authoritative.

## Control

Stewardship control records do not replace mission-control leases, Mission
Queues, Action Slices, run contracts, or run journals. Stewardship only decides
whether and when to hand bounded work into v1/v2.

## Evidence

Every trigger, admission, idle, renewal, campaign candidate, mission handoff, and
closeout decision must retain evidence.

## Material Execution

Stewardship does not directly execute material work. Material execution remains
subject to run contracts, context packs, execution authorization, authorized
effect tokens, evidence, replay/disclosure, rollback posture, and closeout.

## Anti-Infinite-Loop Rule

The service may be long-lived. Epochs, missions, action slices, and runs must be
finite. No work occurs outside an active epoch and no work is created without a
recognized trigger and admission decision.
