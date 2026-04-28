# Mission Runner v1

The Mission Runner is the deterministic control-plane loop for Mission Autonomy
Runtime v2.

It consumes v1 Engagement and Work Package state, verifies mission controls,
selects one Mission Queue Action Slice, prepares a run-contract candidate, emits
Continuation Decisions, and updates mission evidence and continuity.

The Mission Runner may prepare or submit candidates through the existing run
lifecycle. It must not execute material work directly, ask a model what to do
without queue/control grounding, widen support scope, activate new capabilities,
or treat generated projections, chat, labels, comments, dashboards, or inputs as
authority.

Fail-closed outcomes are `pause`, `stage`, `escalate`, `revoke`, `fail`, and
`requires_decision`.
