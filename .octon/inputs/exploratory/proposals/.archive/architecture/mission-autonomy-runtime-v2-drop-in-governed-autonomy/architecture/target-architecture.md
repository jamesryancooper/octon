# Target Architecture: Mission Autonomy Runtime v2

## Target state

Mission Autonomy Runtime v2 turns a v1 Work Package into bounded mission continuation. It opens or verifies mission state, creates and enforces an Autonomy Window, maintains a Mission Queue, selects bounded Action Slices, compiles the next governed run-contract candidate, refreshes context/support/capability posture, enforces lease/budget/circuit-breaker gates, resolves mission-aware Decision Requests, executes only through the existing run lifecycle and authorization path, emits Continuation Decisions, updates continuity, and closes runs/missions/Engagements with retained evidence.

## Target sequence

1. Resolve Engagement.
2. Resolve Work Package.
3. Open or verify Mission Charter.
4. Open or verify Autonomy Window.
5. Verify mission-control lease.
6. Verify autonomy budget.
7. Verify circuit breakers.
8. Refresh Project Profile if stale.
9. Refresh support-target posture.
10. Refresh capability/connector posture.
11. Refresh context baseline.
12. Select next Action Slice.
13. Compile next run-contract candidate.
14. Build run-bound context pack.
15. Evaluate policy and approvals.
16. Authorize.
17. Execute governed run.
18. Validate result.
19. Update Mission Queue.
20. Update continuity.
21. Emit Continuation Decision.
22. Continue, pause, stage, escalate, revoke, close, or fail.

## Primitive definitions

### Autonomy Window

Operator-visible wrapper over mission charter, mission-control lease, autonomy budget, circuit breakers, allowed execution postures, allowed action classes, max concurrent runs, context freshness policy, connector posture, stop conditions, review cadence, and closeout rules.

It is not authority to bypass support targets, policy, capability admission, context-pack requirements, or material-effect authorization.

### Mission Runner

Governed continuation engine that consumes Engagement and Work Package state, opens/verifies mission state, selects Action Slices, compiles run-contract candidates, refreshes posture, invokes existing run lifecycle and authorization, emits Continuation Decisions, and pauses/stages/escalates/revokes/closes when required.

### Mission Queue

Canonical control structure for bounded next work. It tracks Action Slices, dependencies, status, risk/materiality, required capabilities, validation needs, rollback expectations, evidence profile, Decision Request dependencies, and run-contract refs.

### Action Slice

Bounded unit of planned mission work that can compile into a governed run-contract candidate. It does not replace a run contract. Existing `action-slice-v1.schema.json` should be operationalized rather than replaced.

### Continuation Decision

Canonical post-run decision: `continue`, `pause`, `stage`, `escalate`, `revoke`, `close`, or `fail`. It must cite run outcome, validation result, budget state, breaker state, lease state, context freshness, support posture, capability posture, unresolved Decision Requests, and mission success/failure criteria.

### Mission Run Ledger

Mission-level index of all governed runs belonging to the mission. It links run IDs, action slices, run contracts, statuses, closeout state, evidence completeness, rollback disposition, replay/disclosure readiness, and continuity updates. It does not replace per-run journals.

### Mission Evidence Profile

Mission-level extension of v1 Evidence Profile. Minimum profiles:

- `mission_observe`
- `mission_repo_consequential`
- `mission_boundary_sensitive_stage_only`
- `mission_connector_limited`
- `mission_closeout_required`

### Mission-Aware Decision Request

Extension of v1 Decision Request that can block or resolve one Action Slice, one run, one capability, one connector operation, mission continuation, mission lease extension, and mission closeout.

### Limited Connector Admission

Narrow v2 admission model based on:

`Connector -> operation -> capability packs -> material-effect classes -> support posture -> policy -> authorization`

MCP/tool/API/browser surfaces are connector/service operations. MCP is not a giant capability pack.

## MVP posture

- One active Mission per Engagement.
- One active run at a time.
- Repo-local governed continuation.
- Stage-only connector admission hooks only; live connector admission is blocked in v2 MVP.
- Broad effectful external autonomy deferred.
