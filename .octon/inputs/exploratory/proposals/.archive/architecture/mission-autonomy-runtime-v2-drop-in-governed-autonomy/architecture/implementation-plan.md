# Implementation Plan

## Workstream 1 — Framework contracts

Add or standardize:

- `framework/engine/runtime/spec/autonomy-window-v1.schema.json`
- `framework/engine/runtime/spec/mission-queue-v1.schema.json`
- `framework/engine/runtime/spec/mission-continuation-decision-v1.schema.json`
- `framework/engine/runtime/spec/mission-run-ledger-v1.schema.json`
- `framework/engine/runtime/spec/mission-closeout-v1.schema.json`
- `framework/engine/runtime/spec/connector-operation-v1.schema.json`
- `framework/engine/runtime/spec/connector-admission-v1.schema.json`
- `framework/engine/runtime/spec/mission-evidence-profile-v1.schema.json`
- `framework/engine/runtime/spec/mission-runner-v1.md`
- `framework/engine/runtime/spec/mission-continuation-v1.md`

Each contract must reference existing run lifecycle, execution authorization, context-pack, evidence-store, support-target, policy-interface, autonomy-budget, circuit-breaker, and mission-control-lease contracts.

## Workstream 2 — Instance governance policies

Add:

- `instance/governance/policies/mission-continuation.yml`
- `instance/governance/policies/autonomy-window.yml`
- `instance/governance/policies/connector-admission.yml`
- `instance/governance/policies/mission-closeout.yml`

Defaults:

- one active mission per Engagement;
- one active run at a time;
- repo-local live support only;
- broad connector live admission disabled;
- continuation denied on expired lease, exhausted budget, tripped/latched breaker, stale context, support drift, capability drift, missing rollback posture, unresolved blocking Decision Request, or incomplete evidence.

## Workstream 3 — Runtime control/evidence state

Define runtime-created structures under:

- `state/control/engagements/<engagement-id>/active-mission.yml`
- `state/control/execution/missions/<mission-id>/{lease.yml,autonomy-window.yml,autonomy-budget.yml,circuit-breakers.yml,queue.yml,runs.yml,closeout.yml}`
- `state/control/execution/missions/<mission-id>/continuation-decisions/<decision-id>.yml`
- `state/evidence/control/execution/missions/<mission-id>/**`
- `state/continuity/repo/missions/<mission-id>/**`

## Workstream 4 — Mission Runner implementation

Implement a runtime Mission Runner that:

1. resolves v1 Engagement and Work Package;
2. opens/verifies mission charter;
3. opens/verifies Autonomy Window;
4. enforces lease/budget/breakers;
5. refreshes profile/support/capability/context posture;
6. selects the next Action Slice;
7. compiles next run-contract candidate;
8. builds/validates run-bound context pack;
9. evaluates policy and approvals;
10. authorizes;
11. executes through existing run path;
12. records Continuation Decision;
13. updates Mission Queue, Mission Run Ledger, evidence, and continuity.

## Workstream 5 — CLI

Add:

- `octon continue`
- `octon mission open --engagement <id>`
- `octon mission status --mission-id <id>`
- `octon mission continue --mission-id <id>`
- `octon mission pause --mission-id <id>`
- `octon mission resume --mission-id <id>`
- `octon mission revoke --mission-id <id>`
- `octon mission close --mission-id <id>`
- `octon mission queue --mission-id <id>`
- `octon mission next --mission-id <id>`
- `octon decide list`
- `octon decide resolve <decision-id>`
- `octon connector inspect`
- `octon connector admit --stage-only`

## Workstream 6 — Mission-aware Decision Requests

Extend v1 Decision Requests to block or resolve:

- Action Slice;
- run;
- capability;
- connector operation;
- mission continuation;
- mission lease extension;
- mission closeout.

## Workstream 7 — Validators/tests

Add validation for schema validity, placement correctness, lease/budget/breaker/context/support/capability/connector/progress/closeout gates, no generated/input authority dependency, no run lifecycle bypass, and CLI parse/help behavior.

## Implementation sequence

1. Contracts.
2. Policies.
3. Validators.
4. Runtime serializers.
5. Prepare-only Mission Runner.
6. Queue/Decision/Ledger persistence.
7. CLI inspection/status.
8. Gated continuation through run-first path.
9. Closeout.
10. Generated read models.
11. Full validation and retained promotion evidence.
