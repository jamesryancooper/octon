# Mission Continuation v1

Mission continuation is the post-v1 governed runtime sequence:

1. Verify an active Autonomy Window.
2. Verify an active, unexpired, scoped, recently reviewed mission-control lease.
3. Verify autonomy budget is healthy.
4. Verify circuit breakers are clear and recently recomputed.
5. Verify Project Profile, Change Package, support, capability, connector, and
   context posture are available.
6. Select one Action Slice.
7. Compile one run-contract candidate.
8. Emit or reuse a mission-aware Decision Request.
9. Emit a Continuation Decision.
10. Hand off to `octon run start --contract` only when Decision Requests are
    resolved and retained authorization or delegation proof exists for the
    selected dispatch.

Continuation Decisions record whether the Mission Runner should continue,
pause, stage, escalate, revoke, close, or fail. They are evidence-bearing mission
control decisions, not execution approvals.

Generated mission views and Continuation Decision summaries may report proof
state but cannot authorize dispatch. Unsafe resume, contradictory evidence,
stale proof, missing proof, unsupported invocation mode, or scope mismatch must
route to `authorization-proof-failed` or `human-boundary-blocked` instead of a
generic approval-required posture.
