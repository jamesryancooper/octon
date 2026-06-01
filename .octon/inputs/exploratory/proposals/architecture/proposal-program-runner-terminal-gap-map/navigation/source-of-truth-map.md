# Source Of Truth Map

## Precedence

1. Current repo state and deterministic validators.
2. Retained run/control/evidence records under `.octon/state/**`.
3. Authored runtime, workflow, lifecycle, proposal, and governance contracts.
4. Fresh generated/effective projections used only through their declared
   non-authority handle posture.
5. Parent program source material and postmortem recommendations as lineage.
6. This proposal packet as temporary, proposal-local evidence.

## Durable Authorities And Runtime Surfaces

- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/workflow_leaf.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/observer.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/adapter.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/authorization.rs`
- `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh`

## Parent Program Lineage

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening/support/proposal-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening/resources/source-postmortem-recommendations.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening/resources/source-traceability-matrix.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening/resources/child-packet-index.yml`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening/architecture/child-packet-contract.md`

Parent program evidence coordinates sequence and child readiness. It does not
satisfy this child packet's review receipt, implementation-grade receipt,
implementation receipt, validation verdict, closeout receipt, archive metadata,
or terminal outcome.

## Generated And Evidence Surfaces

- `.octon/generated/effective/runtime/route-bundle.yml`
- `.octon/generated/effective/runtime/route-bundle.lock.yml`
- `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/`
- `.octon/generated/effective/capabilities/routing.effective.yml`
- `.octon/generated/proposals/registry.yml`
- `.octon/state/control/execution/runs/lifecycle-proposal-packet-1780278333695-b544297b/`
- `.octon/state/evidence/runs/lifecycle-proposal-packet-1780278333695-b544297b/`

Generated surfaces remain derived and non-authoritative. The proposal registry
is discovery-only. Retained run/control/evidence roots are factual evidence but
do not widen proposal scope or authorize durable promotion.

## Boundary Rules

- Scheduler route inventory must come from lifecycle contracts and fresh
  effective projections, not prompt bundles alone.
- Workflow-owned promotion and archive mutation remain workflow-owned.
- Change closeout and worktree cleanup remain `closeout-change`,
  `closeout-worktree`, or cleanup-helper owned.
- Parent program evidence may summarize child outcomes, but child receipts and
  terminal outcomes remain child-owned.
- This packet may update only packet-local files during revision.
