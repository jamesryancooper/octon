# Acceptance Criteria

Conditions that prove the target architecture has landed. Each is objective and
checkable. AC-1..AC-4 are content; AC-5..AC-7 are wiring/consistency; AC-8..AC-10
are boundary/invariant; AC-11..AC-12 are validation/evidence.

## Method Docs Authored

- **AC-1.** `architectural-review/tradeoff-review-method.md` exists and follows the
  shared contract shape (question, use cases, non-goals, required inputs, lens
  profile, required output sections, escalation rules, fail-closed output
  boundary, related). Its output contract includes an option matrix,
  quality-attribute assessment, per-option tradeoff/risk/reversibility analysis, a
  recommendation with rejected alternatives, and ADR-ready decision-record input.
- **AC-2.** `failure-mode-review-method.md` exists with the same shape and an
  output contract covering the failure-mode catalog (authority inflation, stale
  evidence, generated-output misuse, bypass paths, partial execution, zombie runs,
  rollback gaps, operator confusion), per-mode detection/containment, recovery
  posture, required validators/negative controls, and an unresolved-failure
  blocker list.
- **AC-3.** `evolution-fitness-review-method.md` exists with the same shape and an
  output contract covering fitness functions, drift triggers, retirement triggers,
  compatibility posture, validator needs, and a revisit cadence with owner.
- **AC-4.** `boundary-authority-review-method.md` exists with the same shape and an
  output contract covering the actual-vs-claimed authority map,
  accidental-control-surface findings, a containment plan (move into
  `framework/**`/`instance/**` vs demote to evidence/projection), fail-closed and
  support-claim implications, and a blocker list.

## Wiring And Consistency

- **AC-5.** Each doc's filename equals `<slug>.md` for its canonical `naming.yml`
  slug, and each of the four companion `methods.catalog` entries carries
  `doc: <slug>.md`.
- **AC-6.** Each doc's Lens Profile lists exactly the required and optional lens
  ids from `lens-bank.yml` `method_profiles.<slug>` (verbatim), cites the profile
  pointer, and asserts no private lens catalog. Every cited lens id exists in
  `lens-bank.yml` `lenses[].id`.
- **AC-7.** `README.md` References section links all four new docs; the
  canonical-names table and Methods-And-Selection prose are unchanged.

## Boundaries And Invariants

- **AC-8.** `failure-mode-review-method.md` states the Architecture Readiness
  Audit's mandatory failure-mode analysis owns readiness scoring; the method
  issues no readiness verdict.
- **AC-9.** `boundary-authority-review-method.md` states the Surface Architecture
  Audit owns single-unit `contract-first`/`mixed`/`markdown-first`/`human-led`
  classification, escalates single-unit follow-ups to it, and ships Octon-only in
  v1.
- **AC-10.** Every doc states its output is retained evidence or proposal input
  only, never a lifecycle gate or implementation authority, and that the
  pre-integration support receipt remains the only lifecycle-gating review
  artifact. Balanced remains the default method. No new mechanism, routed workflow
  mode, lifecycle gate, evidence root, schema, validator, or command facade is
  introduced. All changes stay under `architectural-review/`.

## Validation And Evidence

- **AC-11.** The deterministic doc/registry consistency check
  (`validation-plan.md` §1) passes for all four docs, and
  `validate-architectural-review-naming.sh`,
  `validate-architectural-review-lens-references.sh`, and
  `validate-architectural-review-routing.sh` each report `errors=0`.
- **AC-12.** `validate-proposal-standard.sh --package <this packet>
  --skip-registry-check` reports no errors; child-owned evidence is retained under
  `.octon/state/evidence/validation/proposals/companion-architecture-review-methods/`;
  and no evidence is written under `generated/**`.

## Closeout Gate

`implemented`/closeout is forbidden unless AC-1..AC-12 hold and the required
post-implementation gate receipts (conformance, drift/churn) plus the strict
pre-integration architecture review receipt pass. If any gate cannot pass, the
packet records the blocker and uses a blocked/deferred report outcome or a
rejected/superseded archive disposition instead of claiming successful
implementation.
