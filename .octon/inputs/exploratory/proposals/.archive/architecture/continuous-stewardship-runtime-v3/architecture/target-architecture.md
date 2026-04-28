# Target Architecture

## Summary

Continuous Stewardship Runtime v3 is the long-running availability layer above
v1 and v2. It lets Octon remain active as a governed stewardship service without
creating an infinite execution loop.

The target architecture is:

```text
Stewardship Program
  -> Stewardship Epoch
    -> optional Campaign Coordination Hook
      -> Engagement / Work Package handoff
        -> v2 Mission Runner
          -> Mission Queue
            -> Action Slice
              -> Run Contract
                -> Governed Run
```

The service can be indefinite; every unit of work remains finite.

## Stewardship Program

A Stewardship Program is a long-lived repo-scoped care agreement. It defines the
stewardship objective, cared-for scope, allowed and prohibited domains, renewal
cadence, observation cadence, autonomy ceiling, allowed mission classes, default
safing subset, default evidence/budget/breaker profiles, recognized triggers,
idle rules, renewal rules, human review requirements, and closure rules.

A Stewardship Program does not execute work. It may authorize creation or
renewal of finite Stewardship Epochs and bounded mission candidates.

## Stewardship Epoch

A Stewardship Epoch is a finite renewable operating window. No stewardship work
may occur outside an active epoch. Epochs define start/end time, review deadline,
allowed mission and action classes, max missions/runs, budget profile,
circuit-breaker profile, trigger set, idle threshold, closeout requirements, and
renewal eligibility.

## Event-Driven Triggering

V3 admits work from normalized triggers, not from a perpetual model loop.
Recognized trigger classes include scheduled review, repo change, CI failure,
dependency drift, support posture drift, context staleness, Project Profile
staleness, Work Package assumption expiry, Decision Request resolved, human
objective, prior mission follow-up, validation evidence age-out, connector
posture drift, and generated/effective handle staleness.

A trigger is not authority. It only enters admission evaluation.

## Admission and Idle

A Stewardship Admission Decision converts a trigger into `no_op`, `idle`,
`decision_request`, `mission_candidate`, `campaign_candidate`, `denied`, or
`deferred`. If no admissible work exists, Octon emits an Idle Decision and stops
work until the next review or trigger.

Idle is a successful governed state.

## Renewal

At epoch close, Octon emits a Renewal Decision: `renew`, `close`, `pause`,
`escalate`, `revoke`, or `idle_until_next_trigger`. Renewal requires closeout
evidence, budget/breaker status, unresolved-risk review, Decision Request status,
and confirmation that renewal does not silently widen authority.

## Optional Campaign Coordination

Campaigns remain optional coordination rollups. They may group multiple active
missions only when evidence shows shared objectives, milestones, waiver or risk
tracking, or deterministic portfolio rollup need. Campaigns must not launch
workflows, claim queues, own runs, replace missions, or become stewardship.

## Runtime Execution Boundary

Stewardship never executes material work directly. Admitted work must pass into
v1/v2 surfaces and then through v2 Mission Runner, Mission Queue, Action Slice,
run-contract binding, context pack, policy evaluation, execution authorization,
run lifecycle, evidence retention, replay/disclosure, rollback posture, and
closeout gates.
