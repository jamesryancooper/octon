# WS1 — Authority engine and artifact-native authorization routing

## Purpose

Make authority truly first-class and runtime-consumed, not mostly host-workflow-shaped.

## Audit findings addressed

F-02, F-03, F-04

## Exact repo paths / subsystems to change

- `.octon/framework/engine/runtime/crates/authority_engine/**`
- `.octon/framework/engine/runtime/crates/kernel/src/authorization.rs`
- `.octon/framework/constitution/contracts/authority/**`
- `.octon/state/control/execution/approvals/**`
- `.octon/state/control/execution/exceptions/**`
- `.octon/state/control/execution/revocations/**`
- `.octon/state/evidence/control/execution/**`
- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/ai-review-gate.yml`
- `.octon/framework/engine/runtime/adapters/host/github-control-plane.yml`

## Deliverables

- Independent authority engine implementation modules (policy load, artifact resolution, decision evaluation, receipt writing).
- Runtime-native ApprovalRequest / ApprovalGrant / ExceptionLease / Revocation / QuorumPolicy / DecisionArtifact consumers.
- Host projection workflows downgraded to adapter witnesses and mirrors rather than canonical authority minting points.
- Fail-closed handling for missing, expired, revoked, or unsupported authority artifacts.

## Implementation sequence

1. **Stabilize the current path**
   - confirm the exact live behavior on the listed subsystems
   - write a red/green acceptance matrix before editing
2. **Implement the cutover in runtime terms**
   - make the new target-state surface real in code and emitted artifacts
   - keep compatibility only where the packet explicitly allows it
3. **Backfill evidence**
   - update run evidence, proof, disclosure, and governance overlays so the new truth path is inspectable
4. **Delete or demote obsolete scaffolding**
   - remove what is no longer load-bearing
   - where removal is unsafe in the same step, register a named retirement trigger and owner

## Acceptance criteria

- [ ] authority_engine no longer re-exports kernel authorization code as its core implementation.
- [ ] Kernel calls a stable authority-engine API to evaluate grants, leases, revocations, and approval requirements.
- [ ] A run can be authorized or denied correctly without GitHub labels/comments/checks existing.
- [ ] GitHub remains an explicit non-authoritative adapter in both contract and runtime behavior.

## Dependencies

- `WS0`

## Claim criteria unlocked by this workstream

- Authority moved out of host semantics claim
- First-class approval/grant/lease/revocation claim

## Required evidence before calling this workstream complete

- code diff showing the new live path
- updated contract/artifact examples where applicable
- routine run evidence from the supported consequential envelope
- validator or workflow output proving the new gate/path is enforced
- explicit deletion or retirement note for any legacy surface touched

## Anti-patterns to avoid

- leaving the old surface on the critical path while calling the new one canonical
- proving the workstream only with a special closure or migration run
- treating new schema files as sufficient evidence of runtime completion
- widening support or claims during the workstream before proof/disclosure catch up
