# Acceptance Criteria

## Packet-level acceptance

- Proposal manifests are valid and path-consistent.
- Architecture docs define target state, implementation plan, validation plan, acceptance criteria, file-change map, cutover, rollback, and promotion readiness.
- Resources contain a repository-grounded architecture evaluation.
- Packet does not claim runtime authority while under `inputs/exploratory/proposals/**`.

## Architecture acceptance

- Engagement is added as the operator-facing assignment container without replacing run contracts.
- Project Profile is added as repo-local durable orientation authority only when backed by retained source evidence.
- Objective Brief is added only as per-engagement candidate/control state and does not rewrite or replace the workspace-charter pair.
- Work Package is added as the compiler output that bridges objective and first run-contract readiness.
- Decision Request unifies operator-facing approvals/escalations without becoming a rival approval control plane.
- Evidence Profile supports at least `orientation-only`, `stage-only`, and `repo-consequential`.
- Preflight Evidence Lane permits orientation/adoption evidence while forbidding project-code mutation and external side effects.
- Tool/MCP/API/browser Connector posture is machine-readable stage/block/deny policy in v1 and cannot authorize effectful use.

## Runtime acceptance

- `octon start`, `octon profile`, `octon plan`, and `octon arm --prepare-only` exist or are otherwise exposed by the kernel.
- First run-contract candidate can be generated but not executed without existing authorization path.
- Existing `octon run start --contract` remains the material execution entrypoint.
- A valid compiler output can reach `ready_for_authorization` for repo-local supported work.
- Unsupported surfaces produce `stage_only`, `blocked`, `denied`, or `requires_decision`, never silent live admission.
- `octon decide` resolves Decision Requests into canonical low-level artifacts but cannot authorize material execution by itself.
- `octon status` reads Engagement control/evidence state and optional non-authoritative projections.

## Governance acceptance

- No chat history, generated summary, host UI, external dashboard, or proposal-local file is used as authority.
- All promotion targets live outside the proposal workspace.
- Generated projections remain traceable and non-authoritative.
- Support claims are not widened.
- Material side effects remain subject to engine-owned authorization and typed effect verification.

## MVP acceptance

The MVP is complete when Octon can demonstrate:

1. one Engagement;
2. one Project Profile;
3. one per-engagement Objective Brief candidate/control record;
4. one Work Package;
5. one Decision Request set;
6. one context-pack request;
7. one first run-contract candidate;
8. one existing `octon run start --contract` handoff;
9. no effectful MCP/API/browser execution;
10. no unattended mission loop.

These criteria define promotion readiness. They do not by themselves certify
that the live worktree is archive-ready; closure still requires validator output
and demonstration evidence.
