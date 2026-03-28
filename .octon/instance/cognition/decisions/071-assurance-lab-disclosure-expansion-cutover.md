# ADR 071: Assurance, Lab, And Disclosure Expansion Cutover

- Date: 2026-03-27
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-27-assurance-lab-disclosure-expansion-cutover/plan.md`
  - `/.octon/state/evidence/migration/2026-03-27-assurance-lab-disclosure-expansion-cutover/`
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/fully-unified-execution-constitution-for-governed-autonomous-work/`
  - `/.octon/instance/cognition/decisions/070-runtime-lifecycle-normalization-cutover.md`

## Context

Wave 3 normalized the run root as the execution-time unit of truth, but the
retained evidence model still leaned heavily on structural/gating proofs plus
basic receipts and replay pointers.

That left four Wave 4 gaps:

- assurance was still mostly structural/governance rather than a first-class
  multi-plane proof model
- lab and observability lacked durable authored surfaces of their own
- consequential runs still lacked a normalized RunCard disclosure artifact
- system-level support claims still lacked a bounded HarnessCard tied to the
  support-target matrix

## Decision

Promote Wave 4 as a pre-1.0 transitional cutover.

Rules:

1. `framework/constitution/contracts/assurance/**` and
   `framework/constitution/contracts/disclosure/**` are now active
   constitutional contract families.
2. Structural and governance gates remain the live blocking baseline; Wave 4
   adds functional, behavioral, recovery, and evaluator proof planes rather
   than replacing prior gates.
3. Behavioral claims must cite retained lab, replay, scenario, or shadow-run
   evidence.
4. Consequential runs must retain proof-plane, observability, replay, and
   disclosure families beside the canonical run root.
5. RunCards and HarnessCards summarize retained authority and evidence but do
   not mint or widen authority.
6. Support claims remain bounded by `instance/governance/support-targets.yml`.

## Consequences

### Benefits

- Consequential runs become interpretable through retained RunCards rather than
  only raw receipts.
- Support claims now have a bounded, replay-backed HarnessCard path.
- Lab and observability gain explicit authored homes instead of living only as
  ad hoc assurance logic.

### Costs

- Run bundles and validators now carry more retained evidence families.
- Older runs may need additional backfill until every consequential bundle
  carries the full Wave 4 evidence set.
- Evaluator proof exists as a first-class plane, but it remains mostly
  `not_required` for this repo-local transitional support tier.

### Follow-on Work

1. Broaden the lab scenario catalog beyond the initial Wave 4 seed.
2. Add stronger evaluator workflows for higher-risk support tiers.
3. Continue toward Wave 5 adapter/support-target hardening and Wave 6
   retirement cleanup.
