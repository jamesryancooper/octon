# Source Lineage

## Primary Source

The primary source is the operator-provided planning thesis in the current
session on 2026-05-05. The thesis recommends adopting hierarchical planning
only as a bounded optional Mission Plan Compiler layer, subordinate to mission
authority and existing run-contract execution.

The full operator-provided analysis is preserved as proposal-local source
material at `resources/bounded-planning-layer-source-analysis.md`. That file is
lineage and rationale only; it is not runtime, policy, control, evidence, or
promotion authority.

## Normalized Source Claims

- Octon is already a governed runtime with explicit mission, run, authority,
  evidence, rollback, support-target, and proposal-packet machinery.
- Hierarchical planning is useful only when mission-bound, evidence-backed,
  and compiler-style.
- The planning layer should help answer which bounded work packages should be
  staged, validated, approved, and compiled into run contracts.
- The planning layer must not decide Octon authority, bypass authorization, or
  act as a second orchestrator.
- The executable leaf should be an `action-slice-v1` candidate.
- Planning control belongs under mission-local `state/control/**` paths only
  after durable schemas and validators exist.
- Plan mutation evidence belongs under `state/evidence/control/execution/**`.
- Generated planning views are derived operator read models only.
- Proposal packet material remains non-authoritative lineage.

## Local Repository Sources Checked

- `AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/constitution/ownership/roles.yml`
- `.octon/framework/constitution/contracts/registry.yml`
- `.octon/instance/charter/workspace.md`
- `.octon/instance/charter/workspace.yml`
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
- `.octon/inputs/exploratory/proposals/README.md`
- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`
- `.octon/README.md`
- `.octon/framework/orchestration/runtime/missions/README.md`
- `.octon/framework/orchestration/runtime/runs/README.md`
- `.octon/framework/engine/runtime/spec/action-slice-v1.schema.json`
- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `.octon/framework/engine/runtime/spec/run-journal-v1.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/instance/governance/support-targets.yml`

## Source Translation

This packet translates the operator thesis into an architecture proposal with
explicit promotion targets, placement rules, lifecycle, schemas, validation
coverage, governance gates, rollback posture, and implementation-grade
completeness review.

The preserved source resource was added after initial packet creation to keep
the packet audit trail complete while maintaining the existing proposal-local
non-authority boundary.
