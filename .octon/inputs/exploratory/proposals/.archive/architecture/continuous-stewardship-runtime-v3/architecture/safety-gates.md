# Safety and Governance Gates

## Program Authority Gate

No Stewardship Program may become active without durable authority under
`instance/stewardship/programs/<program-id>/` and corresponding control/evidence
roots.

## Epoch Gate

No stewardship work may occur outside an active Stewardship Epoch.

## Trigger Gate

No work may be created without a recognized trigger, scheduled review, prior
mission follow-up, or explicit human objective.

## Admission Gate

No trigger may become work until a Stewardship Admission Decision is emitted.

## Idle Gate

If no admissible work exists, Octon must emit an Idle Decision and stop work
until the next review or trigger.

## Renewal Gate

No epoch may renew unless prior closeout is complete, budget/breakers permit,
support posture remains valid, context/profile assumptions are fresh enough, no
blocking Decision Requests remain, and renewal does not widen authority silently.

## Campaign Gate

No campaign may be promoted or used unless campaign promotion criteria are met.
Campaigns remain optional coordination rollups, not execution containers or
mission replacements.

## V2 Mission Gate

All admitted work must pass through v2 Mission Runner and its Autonomy Window,
Mission Queue, Action Slice, lease, budget, breaker, context, support,
capability, Decision Request, run-contract, authorization, and closeout gates.

## Run Gate

All material execution must pass through existing governed run lifecycle and
execution authorization.

## Progress Gate

Octon must stop, idle, or escalate if the same trigger repeats without
resolution, missions repeatedly fail, Action Slices churn without reducing work,
validation cannot pass, success criteria cannot be evaluated, the repo remains
unchanged despite repeated work, scope expands merely to stay busy, or closeout
cannot be achieved.

## Closeout Gate

Epoch closure requires all admitted triggers resolved/denied/deferred/converted,
spawned missions closed or carried forward, evidence complete, rollback and
replay/disclosure posture known, continuity updated, Renewal Decision emitted,
and no unresolved blocking Decision Requests.
