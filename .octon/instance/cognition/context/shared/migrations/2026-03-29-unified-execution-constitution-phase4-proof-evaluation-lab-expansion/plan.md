---
title: Unified Execution Constitution Phase 4 Proof Evaluation And Lab Expansion
description: Atomic migration record for proof-plane enforcement, substantive lab domains, and evaluator adapter cutover.
---

# Migration Plan

## Governing Input

- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/README.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/implementation-plan.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/verification-evaluation-lab-model.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/acceptance-criteria.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/resources/unified-execution-constitution-audit.md`

## Profile Selection Receipt

- Date: 2026-03-29
- Version source(s): `/version.txt`, `/.octon/octon.yml`
- Current version before cutover: `0.6.7`
- Target version after cutover: `0.6.7`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - downtime tolerance: medium; the work changes proof-plane enforcement, lab
    surfaces, evaluator routing, and CI, but all affected paths are repo-local
    and can move together
  - external consumer coordination ability: not required; the cutover is
    internal to the harness, workflows, and retained sample evidence
  - data migration and backfill needs: medium; seeded run/lab evidence and
    evaluator routing must be strengthened to exercise the new proof and lab
    model
  - rollback mechanism: revert the Phase 4 change set to restore the thinner
    proof-plane and lab scaffolding
  - blast radius and uncertainty: high; the change touches authored
    assurance/lab surfaces, evaluator adapters, sample evidence, and CI gates
  - compliance and policy constraints: structural/governance gates must not be
    weakened, and at least one supported tier must retain real behavioral and
    recovery evidence
- Hard-gate outcomes:
  - target-state correctness requires substantive functional, behavioral,
    maintainability, and recovery suites rather than README-only placeholders
  - lab scenario/replay/shadow/fault domains must exist as authored roots with
    retained evidence, not just flat schemas
  - provider-specific review execution must route through evaluator adapters
    rather than remaining hard-coded workflow cases
- Tie-break status: `atomic` selected because the proof/lab/evaluator model can
  move in one coherent branch without a staged coexistence window
- Transitional Exception Note: N/A
- `transitional_exception_note`: N/A

## Implementation Summary

- Name: Unified execution constitution Phase 4 proof evaluation and lab
  expansion
- Owner: Octon maintainers
- Motivation: preserve structural/governance gates while adding real
  proof-plane suites, substantive lab domains, and evaluator adapters with CI
  enforcement
- Scope:
  - strengthen the assurance family and authored proof-plane surfaces
  - create top-level `framework/lab/{scenarios,replay,shadow,faults}` domains
    in substance
  - add retained lab evidence for replay/shadow/fault exercises
  - convert AI provider review execution into evaluator adapters
  - add Phase 4 validation and CI enforcement

## Atomic Execution

1. Preserve structural/governance gates as blocking proof planes.
2. Add authored functional/behavioral/maintainability/recovery suites and make
   them validator-enforced.
3. Create substantive lab scenario/replay/shadow/fault domains and backfill
   retained evidence that exercises them.
4. Route provider reviews through evaluator adapter manifests and a generic
   evaluator adapter runner.
5. Update CI and local validators so the Phase 4 exit criteria are
   machine-checkable.

## Impact Map

### Assurance model and enforcement

- `/.octon/framework/constitution/contracts/assurance/**`
- `/.octon/framework/assurance/{functional,behavioral,maintainability,recovery}/**`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-phase4-proof-lab-enforcement.sh`
- `/.github/workflows/{architecture-conformance.yml,assurance-weight-gates.yml}`

### Lab domains and retained evidence

- `/.octon/framework/lab/**`
- `/.octon/state/evidence/lab/**`
- `/.octon/state/evidence/runs/run-wave3-runtime-bridge-20260327/assurance/**`
- `/.octon/state/evidence/runs/run-wave4-benchmark-evaluator-20260327/assurance/**`

### Evaluator adapters

- `/.octon/framework/assurance/evaluators/**`
- `/.octon/framework/agency/_ops/scripts/ai-gate/**`
- `/.github/workflows/ai-review-gate.yml`

## Verification Evidence

- ADR:
  `/.octon/instance/cognition/decisions/080-unified-execution-constitution-phase4-proof-evaluation-lab-expansion.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase4-proof-evaluation-lab-expansion/`

## Rollback

- revert the Phase 4 change set
- remove the authored proof suites, new lab domains, retained lab replay/shadow/fault evidence,
  and evaluator adapter manifests introduced here
- restore the prior thinner proof-plane and provider-review workflow model only
  if the full Phase 4 branch is being reverted
