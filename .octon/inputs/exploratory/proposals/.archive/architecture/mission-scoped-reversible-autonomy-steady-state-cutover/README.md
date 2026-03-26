# Mission-Scoped Reversible Autonomy Steady-State Cutover

Historical status: implemented and archived. The runtime closeout evidence for
this packet lives in ADR 066 and the matching migration evidence bundle under
`/.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-steady-state-cutover/`.

This package is the **final, implementation-scoped architecture proposal**
for bringing the Mission-Scoped Reversible Autonomy Operating Model (MSRAOM)
to a clean, steady, fully completed state in Octon.

It is a **big-bang, clean-break, atomic cutover packet**. It does not create
a new operating model. It finishes the existing one.

This packet supersedes the earlier
`mission-scoped-reversible-autonomy-completion-cutover` package. The repo now
contains a substantial MSRAOM implementation, but a small set of unresolved
runtime, scaffolding, routing, evidence, and validation gaps still prevent the
model from being honestly called complete.

The attached implementation audit makes that status explicit: the repo is
**partially complete with moderate gaps**, not materially incomplete, but not
yet cut over cleanly enough to call the operating model done.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- current repo baseline: `0.6.0`
- recommended steady-state release: `0.6.1`
- cutover style: `atomic`, `clean break`, `repo-wide`, `pre-1.0`
- cutover promise: **no deferred corrective work remains after merge**

## Summary

Land one final repo-wide cutover that makes MSRAOM actually *done* by:

- finishing mission scaffolding and automatic state seeding
- tightening the mission-control contract family
- making forward intent publication mandatory for material autonomous work
- wiring route generation, mode state, scheduler behavior, directives, and
  authorize-updates together
- normalizing scenario resolution and safe-boundary taxonomy
- removing generic fallback autonomy semantics
- materializing all operator and machine read models as standard outputs
- broadening retained control-plane evidence coverage
- proving behavior with blocking runtime-contract and scenario conformance gates
- fixing the audit-confirmed version-parity defect between `version.txt` and
  `.octon/octon.yml`
- removing every remaining doc/runtime or schema/runtime contradiction

## Why Another Packet Is Needed

The repo already has the hard parts of MSRAOM:

- Mission-Scoped Reversible Autonomy is canonical.
- Mission authority, mission-autonomy policy, ownership routing, and v2
  execution contracts exist.
- ACP, grants, receipts, reversibility, recovery windows, and `STAGE_ONLY`
  remain the normative execution-governance spine.
- A live-validation mission demonstrates control files, generated summaries,
  operator digests, and a scenario-resolution artifact.

What still prevents a clean steady state is not the conceptual model. It is
the last layer of implementation glue and correctness hardening:

- mission scaffolds still do not create the full control-file family
- the interaction grammar is not yet fully expressed in control truth
- the live route exists, but route linkage and route freshness are not yet
  treated as hard invariants everywhere
- material autonomous work can still degrade toward empty-intent or generic
  route behavior
- safe-boundary taxonomy is not fully normalized
- mission projections are still not first-class generated outputs
- control-plane evidence coverage is still too narrow
- autonomy-burn and breaker state exist, but their update path is not yet a
  fully enforced steady-state mechanism
- CI still does not prove the full runtime-contract and scenario suite

This packet closes **all** of those issues in one merge set. It does not leave
a follow-on remediation backlog.

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
- `.octon/framework/orchestration/runtime/`
- `.octon/framework/assurance/runtime/`
- `.octon/instance/orchestration/missions/`
- `.octon/instance/governance/policies/`
- `.octon/instance/governance/ownership/`
- `.octon/state/control/execution/`
- `.octon/state/evidence/control/`
- `.octon/state/evidence/runs/`
- `.octon/state/continuity/repo/`
- `.octon/generated/effective/`
- `.octon/generated/cognition/`
- `.github/workflows/`

## Reading Order

1. `architecture/target-architecture.md`
2. `resources/current-state-gap-analysis.md`
3. `resources/implementation-audit.md`
4. `resources/final-remediation-ledger.md`
5. `resources/mission-control-contract-deltas.md`
6. `resources/scenario-resolution-normalization.md`
7. `resources/operator-and-evidence-plane.md`
8. `resources/scaffold-and-reader-alignment.md`
9. `resources/ci-and-validator-wiring.md`
10. `architecture/implementation-plan.md`
11. `architecture/acceptance-criteria.md`
12. `architecture/validation-plan.md`
13. `navigation/source-of-truth-map.md`
14. `architecture/cutover-checklist.md`

## Non-Negotiable Cutover Rules

1. **One live model only.** There is no long-lived dual live autonomy model
   after merge.
2. **No remediations deferred.** Every currently known correctness or
   completeness issue is closed in this packet.
3. **No second control plane.** Binding control state remains under canonical
   `/.octon/state/**` surfaces only.
4. **No empty-intent material autonomy.** Material autonomous work may not
   proceed without a current intent entry and current slice reference.
5. **No generic recovery fallback.** If route, slice, or policy cannot derive
   recovery semantics, the runtime must tighten to `STAGE_ONLY`, `SAFE`, or
   `DENY`.
6. **No placeholder-only generated roots.** Any generated root named in the
   manifest must contain real materialized outputs or be removed from the live
   contract.
7. **No docs overclaim.** Canonical docs must exactly match runtime and
   generated behavior.
8. **No CI blind spots.** Mission-runtime contracts and scenario conformance
   must be blocking.

## Exit Path

Promote this packet into durable runtime, policy, contract, validation,
migration, and decision surfaces; cut the steady-state release; archive both
the prior completion-cutover package and this packet; and treat MSRAOM as
completed canonical architecture unless a later ADR explicitly supersedes it.
