# Mission-Scoped Reversible Autonomy Operating Model Cutover

This is a temporary, implementation-scoped architecture proposal for
`mission-scoped-reversible-autonomy`.

It defines the clean-break, atomic integration of the Mission-Scoped
Reversible Autonomy Operating Model into Octon's runtime, governance,
mission authority, execution control, retained evidence, and derived
operator read models.

It is not itself canonical runtime, documentation, policy, or contract
authority. The promoted surfaces named below become the lasting authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Ratify one atomic, pre-1.0 cutover that makes
  Mission-Scoped Reversible Autonomy the canonical operating model for
  long-running and always-running Octon agents by upgrading mission
  authority, execution contracts, mutable control truth, retained control
  evidence, operator read models, and runtime/policy enforcement together,
  with no dual control plane and no approval-heavy default workflow.

## Promotion Targets

- `.octon/octon.yml`
- `.octon/README.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/instance/cognition/context/shared/migrations/`
- `.octon/instance/cognition/decisions/`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/cognition/governance/principles/`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/engine/runtime/config/`
- `.octon/framework/engine/runtime/crates/kernel/`
- `.octon/framework/engine/runtime/crates/policy_engine/`
- `.octon/framework/orchestration/runtime/workflows/`
- `.octon/framework/assurance/runtime/`
- `.octon/instance/orchestration/missions/`
- `.octon/instance/governance/policies/`
- `.octon/instance/governance/ownership/`
- `.octon/state/control/execution/`
- `.octon/state/evidence/control/`
- `.octon/state/evidence/migration/`
- `.octon/state/evidence/runs/`
- `.octon/state/continuity/repo/`
- `.octon/generated/cognition/`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/mission-scoped-reversible-autonomy.md`
4. `resources/current-state-gap-analysis.md`
5. `/.octon/generated/proposals/registry.yml`
6. `navigation/artifact-catalog.md`
7. `navigation/source-of-truth-map.md`
8. `architecture/target-architecture.md`
9. `architecture/acceptance-criteria.md`
10. `architecture/implementation-plan.md`
11. `architecture/validation-plan.md`
12. `architecture/cutover-checklist.md`

## Supporting Resources

This proposal is intentionally self-contained.
It is the implementation-guiding synthesis of the Mission-Scoped Reversible
Autonomy research, Octon-native governance constraints, the live repo delta,
and the concrete validation and cutover scaffolding required for a single
promotion.

- `resources/mission-scoped-reversible-autonomy.md` is the conceptual source
  document for the final operating model and primitive catalog.
- `resources/current-state-gap-analysis.md` captures the live repo delta that
  makes this cutover necessary and highlights why the migration is structurally
  large but operationally light today.
- `navigation/artifact-catalog.md` inventories the proposal package so the
  implementation work does not depend on tribal knowledge.
- `navigation/source-of-truth-map.md` identifies the durable target surface
  for each authority, control, evidence, and enforcement concern.
- `architecture/validation-plan.md` defines the blocking validators, scenario
  suite, and merge gates that keep the cutover atomic and fail closed.
- `architecture/cutover-checklist.md` defines the branch-level execution
  sequence, post-merge checks, and rollback triggers.

## Exit Path

Promote the mission-authority upgrade, mission-autonomy policy, ownership
registry, v2 execution/policy contracts, mission-scoped control-state
surfaces, control-plane evidence receipts, generated Now/Next/Recent/Recover
views, schedule and digest routing semantics, autonomy burn budgets, circuit
breakers, safing rules, conformance tests, and the cutover's durable migration
plan, evidence bundle, and ADR into durable Octon surfaces, then archive this
proposal once no implementation or documentation path depends on proposal-local
guidance.

## Registry

Add or update the matching entry in
`/.octon/generated/proposals/registry.yml` when this proposal is created,
archived, rejected, or materially reclassified. The registry is a committed
discovery projection only.
