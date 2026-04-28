# Mission Autonomy Runtime v2

Mission Autonomy Runtime v2 is Octon's bounded continuation layer. It starts
after the v1 Engagement / Project Profile / Work Package compiler has prepared a
governed Work Package and first run-contract candidate.

v1 makes Octon safe to start. v2 makes Octon safe to continue.

## Lifecycle

1. Resolve one active Engagement.
2. Resolve one active Work Package.
3. Open or verify one Mission.
4. Open or verify one Autonomy Window.
5. Verify mission-control lease, autonomy budget, and circuit breakers.
6. Refresh project, support, capability, connector, and context posture.
7. Select one bounded Action Slice from the Mission Queue.
8. Compile one next run-contract candidate.
9. Emit mission-aware Decision Requests when approval or escalation is needed.
10. Hand execution to `octon run start --contract`; do not bypass run lifecycle.
11. Index governed runs in the Mission Run Ledger.
12. Emit Continuation Decisions.
13. Close the mission only after closeout gates pass.

## Canonical Surfaces

- Framework contracts: `/.octon/framework/engine/runtime/spec/*`
- Mission authority: `/.octon/instance/orchestration/missions/**`
- Repo governance: `/.octon/instance/governance/policies/*`
- Mission control truth: `/.octon/state/control/execution/missions/**`
- Mission control evidence: `/.octon/state/evidence/control/execution/missions/**`
- Mission continuity: `/.octon/state/continuity/repo/missions/**`
- Generated read models: `/.octon/generated/cognition/projections/materialized/missions/**`

Generated mission projections are not control or authority.

## MVP Boundary

The v2 MVP supports one active Engagement, one active Mission per Engagement,
one active Work Package, one active Autonomy Window, and one active run at a
time. It prepares and can submit governed run-contract candidates through the
existing run lifecycle. Broad MCP, API, browser-driving, deployment, credential,
multi-repo, destructive, and fully unattended autonomy remain deferred.

## Runtime Boundary

Autonomy Window, Mission Queue, Continuation Decision, and Mission Run Ledger do
not authorize execution. Every material run still requires `run-contract-v3`,
context-pack readiness, support posture, capability posture, rollback posture,
policy treatment, retained evidence, and execution authorization.
