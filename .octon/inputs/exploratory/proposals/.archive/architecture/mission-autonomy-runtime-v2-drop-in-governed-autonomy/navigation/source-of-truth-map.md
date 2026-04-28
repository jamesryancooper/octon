# Source of Truth Map

## Proposal-local precedence

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/implementation-plan.md`
6. `architecture/acceptance-criteria.md`
7. `navigation/artifact-catalog.md`
8. `README.md`

## Durable Octon authorities referenced

- Constitutional kernel: `.octon/framework/constitution/**`
- Structural authority model: `.octon/framework/cognition/_meta/architecture/**`
- Workspace objective authority: `.octon/instance/charter/{workspace.md,workspace.yml}`
- Ingress/bootstrap authority: `.octon/instance/ingress/**`, `.octon/instance/bootstrap/**`
- Mission authority: `.octon/instance/orchestration/missions/**`
- Governance authority: `.octon/instance/governance/**`
- Runtime contracts: `.octon/framework/engine/runtime/spec/**`
- Run control: `.octon/state/control/execution/runs/**`
- Retained run evidence: `.octon/state/evidence/runs/**`
- Run disclosure: `.octon/state/evidence/disclosure/runs/**`

## Proposed v2 durable authorities

- Framework contracts for Autonomy Window, Mission Queue, Continuation Decision, Mission Run Ledger, Mission Closeout, connector operation/admission, and Mission Evidence Profile.
- Repo-owned mission-continuation, autonomy-window, connector-admission, and mission-closeout policies.
- Connector declarations and admission records under repo-owned governance roots.

## Proposed v2 control/evidence/continuity roots

- Mission control: `.octon/state/control/execution/missions/<mission-id>/**`
- Active mission binding: `.octon/state/control/engagements/<engagement-id>/active-mission.yml`
- Mission evidence: `.octon/state/evidence/control/execution/missions/<mission-id>/**`
- Mission continuity: `.octon/state/continuity/repo/missions/<mission-id>/**`
- Mission read models: `.octon/generated/cognition/projections/materialized/missions/**`

## Boundary rules

- `framework/**` and `instance/**` are authored authority.
- `state/control/**` is operational truth.
- `state/evidence/**` is retained proof.
- `state/continuity/**` is resumable context, not authority.
- `generated/**` is derived-only.
- `inputs/**` is non-authoritative.
- Proposal paths cannot become runtime, policy, support, or execution sources.
