# Mission-Scoped Reversible Autonomy Completeness And Integration Cutover

This is a temporary, implementation-scoped architecture proposal for
`mission-scoped-reversible-autonomy-completion-cutover`.

It is the **big-bang, clean-break, atomic remediation package** for finishing
and correcting the implementation of the Mission-Scoped Reversible Autonomy
Operating Model (MSRAOM) in Octon after the initial cutover landed only
partially.

This package is **not** canonical runtime, policy, or contract authority.
Its job is to drive one repo-wide completion pass that removes the remaining
gaps, resolves architectural contradictions, and makes MSRAOM complete,
integrated, and operator-legible.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- current repo baseline: `0.5.6`
- recommended cutover release: `0.6.0`
- cutover style: `atomic`, `clean break`, `pre-1.0`, `repo-wide`

### Summary

Ratify one final MSRAOM completion cutover that upgrades the repo from a
**partially integrated** operating-model implementation to a **fully
integrated** one by landing all missing contracts, mission-control surfaces,
runtime consumers, schedule/directive semantics, control-plane evidence,
generated operator read models, scenario resolution, conformance tests, and
contradiction cleanup in one merge set.

## Why This Proposal Exists

Octon already has the right backbone in place:

- Mission-Scoped Reversible Autonomy is declared canonical.
- Mission authority, mission-autonomy policy, ownership registry, and v2
  execution/policy contracts exist.
- ACP, grants, receipts, reversibility, and `STAGE_ONLY` remain the normative
  execution-governance spine.

What remains incomplete is the **control-plane and operator-plane integration**
that turns those declarations into a complete operating model:

- missing or weakly integrated per-mission control contracts
- incomplete forward intent publication
- incomplete schedule/directive runtime behavior
- incomplete autonomy-burn and breaker automation
- incomplete safing and break-glass integration
- missing mission/operator read models (`Now / Next / Recent / Recover`)
- missing retained control-plane evidence emission
- no materialized scenario-resolution layer
- stale or contradictory runtime readers and placeholder-only summary/control
  surfaces

This package closes those gaps as one atomic implementation proposal.

The package includes `resources/implementation-audit.md` as the source audit
artifact for the derived gap analysis and remediation materials.

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
- `.octon/generated/effective/`
- `.octon/generated/cognition/`

## Reading Order

1. `architecture/target-architecture.md`
2. `resources/implementation-audit.md`
3. `resources/current-state-gap-analysis.md`
4. `resources/mission-control-contracts.md`
5. `resources/scenario-routing-design.md`
6. `architecture/implementation-plan.md`
7. `architecture/acceptance-criteria.md`
8. `architecture/validation-plan.md`
9. `navigation/source-of-truth-map.md`
10. `architecture/cutover-checklist.md`

## Non-Negotiable Cutover Rules

1. **One live model only.** There must be no long-lived dual live operating
   model after merge.
2. **Pre-1.0 atomic update.** Historical receipts remain; live runtime behavior
   changes in one cutover.
3. **No second control plane.** All binding control state lives in canonical
   repo surfaces under `/.octon/`.
4. **No docs overclaim.** Any surface described as canonical or generated must
   exist, be wired, and be validated before the cutover merges.
5. **No placeholder-only completion.** `.gitkeep` is not an implementation.
6. **No hardcoded fallback autonomy semantics.** Effective mission behavior
   must be policy- and state-derived.
7. **Scenario routing is derived, not a new authority registry.**

## Exit Path

Promote this proposal into durable runtime, policy, contract, and assurance
surfaces; write the cutover plan and evidence bundle under canonical migration
and decision roots; validate the scenario suite; then archive this proposal once
no implementation or documentation path depends on proposal-local guidance.
