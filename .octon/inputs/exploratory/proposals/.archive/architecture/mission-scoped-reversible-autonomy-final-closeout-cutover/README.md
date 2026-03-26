# Mission-Scoped Reversible Autonomy Final Closeout Cutover

Historical status: implemented and archived. The runtime closeout evidence for
this packet lives in ADR 067 and the matching migration evidence bundle under
`/.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-final-closeout-cutover/`.

This package is the **final, implementation-scoped architecture proposal** for bringing the Mission-Scoped Reversible Autonomy Operating Model (MSRAOM) to a truly finished, steady, fully correct state in Octon.

It is a **big-bang, clean-break, atomic closeout packet**.

It does not redesign MSRAOM.
It does not open another remediation cycle.
It finishes the existing operating model and closes every issue identified in the package's [implementation audit](./resources/implementation-audit.md).

## Audit baseline

This proposal package is scoped directly against the findings and remediation list in [resources/implementation-audit.md](./resources/implementation-audit.md).
The gap analysis, remediation ledger, implementation plan, validation plan, and acceptance criteria below all exist to close that audit without opening a follow-on packet.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- current repo baseline: `0.6.2`
- recommended closeout release: `0.6.3`
- cutover style:
  - `atomic`
  - `clean-break`
  - `repo-wide`
  - `pre-1.0`
  - `final-closeout`
- cutover promise: **no known MSRAOM completeness or correctness gaps remain after merge**

## What this packet closes

This packet closes the remaining gaps confirmed in the [implementation audit](./resources/implementation-audit.md) by:

- making the **mission lifecycle** unambiguous and atomic
- choosing and enforcing one canonical rule for how mission control state is created before a mission may become active
- making **slice-linked forward intent** mandatory for material autonomous work
- normalizing **scenario resolution**, effective scenario family, boundary-class precedence, and route freshness invariants
- broadening **retained control-plane evidence** so every meaningful control mutation leaves a receipt
- tightening **autonomy-burn** and **breaker** recomputation into a real runtime/evidence loop
- making mission/operator summaries and machine mission views universal for active autonomous missions
- adding the missing lifecycle, intent, route, evidence, and burn/breaker validators to **blocking CI**
- removing the last doc/runtime and schema/runtime ambiguities that still prevent a clean “done” verdict

## Why another packet is still needed

Octon already has a substantial MSRAOM implementation:

- MSRAOM is the canonical operating model.
- Mission authority, mission-control truth, scenario resolution, summaries, digests, and mission-aware runtime contracts exist.
- ACP, grants, receipts, reversibility, recovery windows, and `STAGE_ONLY` remain the normative execution-governance spine.
- The main architecture-conformance workflow already runs mission-runtime, scenario, effective-state, and generated-view checks.

What still prevents a fully clean closeout is smaller, but still material:

- the generic mission scaffold still looks pre-cutover even though seeding exists
- the lifecycle rule for when control truth must exist is not yet explicit enough
- slice-linked forward intent exists but is not yet proven as a universal invariant for all material autonomous work
- control-plane evidence coverage is not yet broad enough to prove every meaningful mutation
- autonomy-burn and breaker recomputation is not yet framed as one explicit retained-evidence-driven loop
- scenario-family and boundary precedence are good, but not fully normalized
- summaries and mission views exist, but their universality is still more implied than enforced

This packet closes those issues **without creating a new model, a second control plane, or a follow-on remediation backlog**.

## Reading order

1. `architecture/target-architecture.md`
2. `resources/implementation-audit.md`
3. `resources/current-state-gap-analysis.md`
4. `resources/final-remediation-ledger.md`
5. `resources/lifecycle-and-activation-cutover.md`
6. `resources/intent-slice-and-route-enforcement.md`
7. `resources/scenario-resolution-normalization.md`
8. `resources/interaction-scheduling-and-evidence.md`
9. `resources/burn-breaker-and-safing-automation.md`
10. `resources/summaries-projections-and-read-models.md`
11. `resources/validator-and-ci-wiring.md`
12. `architecture/implementation-plan.md`
13. `architecture/acceptance-criteria.md`
14. `architecture/validation-plan.md`
15. `navigation/source-of-truth-map.md`
16. `navigation/change-map.md`
17. `architecture/cutover-checklist.md`

## Non-negotiable cutover rules

1. **One live model only.** There is no dual live autonomy model after merge.
2. **No deferred remediations.** Every known issue from the [implementation audit](./resources/implementation-audit.md) is closed in this packet.
3. **No second control plane.** Binding control state remains only under canonical `/.octon/state/**` surfaces.
4. **No active material autonomy without seeded mission control state.**
5. **No material autonomous work without a current intent entry and referenced action slice.**
6. **No generic recovery fallback for material autonomy.**
7. **No summary-only implementation.** Generated views never substitute for missing canonical control or evidence.
8. **No lifecycle ambiguity.** Mission creation, seeding, activation, scheduling, summaries, and evidence all follow one explicit rule set.
9. **No CI blind spots.** Lifecycle, route, scenario, evidence, and generated-view conformance are all blocking.
10. **No docs overclaim.** Canonical docs must exactly match runtime, validation, and generated behavior.

## Exit path

Promote this packet into durable runtime, policy, contract, validation, migration, and decision surfaces; cut the `0.6.3` closeout release; archive the earlier `mission-scoped-reversible-autonomy-steady-state-cutover` packet and this packet; and treat MSRAOM as complete canonical architecture unless a later ADR explicitly supersedes it.
