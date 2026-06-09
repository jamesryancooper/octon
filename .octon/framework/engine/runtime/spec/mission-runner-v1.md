# Mission Runner v1

The Mission Runner is the deterministic control-plane loop for Mission Autonomy
Runtime v2.

It consumes v1 Engagement and Change Package state, verifies mission controls,
selects one Mission Queue Action Slice, prepares a run-contract candidate, emits
Continuation Decisions, and updates mission evidence and continuity.

The Mission Runner may prepare or submit candidates through the existing run
lifecycle. It must not execute material work directly, ask a model what to do
without queue/control grounding, widen support scope, activate new capabilities,
or treat generated projections, chat, labels, comments, dashboards, or inputs as
authority.

Unattended runner posture is proof-first: route dispatch requires retained
authorization or delegation proof before execution, and useful operator views do
not become authority. Missing, stale, contradictory, or scope-mismatched proof
blocks before dispatch as `authorization-proof-failed`; unsafe resume, policy
override, unresolved risk acceptance, and other human-only boundaries block as
`human-boundary-blocked`.

Fail-closed outcomes include `pause`, `stage`, `escalate`, `revoke`, `fail`,
`requires_decision`, `authorization-proof-failed`, and
`human-boundary-blocked`.
