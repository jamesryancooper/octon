---
title: Unified Execution Constitution Phase 3 Runtime And Evidence Normalization
description: Atomic migration record for canonical run-manifest adoption, A/B/C evidence classification, and external immutable replay indexing.
---

# Migration Plan

## Governing Input

- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/README.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/implementation-plan.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/runtime-evidence-model.md`
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
  - downtime tolerance: medium; the cutover changes canonical runtime and
    evidence topology, but all affected paths are repo-local and can move in a
    single branch
  - external consumer coordination ability: not required; the cutover is
    internal to the Octon harness and sample run bundles
  - data migration and backfill needs: medium; seeded run bundles and runtime
    validators must be backfilled to the new run-manifest and evidence
    classification model
  - rollback mechanism: revert the Phase 3 change set to restore the prior
    `runtime-state.yml`-as-stand-in model and remove the new classification and
    external index artifacts
  - blast radius and uncertainty: high; the change touches runtime contracts,
    run writers, sample run bundles, retention policy, and closeout validators
  - compliance and policy constraints: run state must be resumable from
    retained artifacts, evidence classes must align to the packet’s A/B/C
    model, and supported boundary-sensitive runs must prove replay indexing via
    immutable external index entries
- Hard-gate outcomes:
  - target-state correctness requires a dedicated `run-manifest.yml` instead of
    continuing to overload `runtime-state.yml`
  - the packet’s Class A/B/C model must be explicit in canonical contracts and
    per-run retained evidence, not just described in prose
  - external immutable replay/index integration must be exercised for at least
    one supported run class in the live repo
- Tie-break status: `atomic` selected because no staged coexistence window is
  needed once the dedicated manifest and classification artifacts are added
- Transitional Exception Note: N/A
- `transitional_exception_note`: N/A

## Implementation Summary

- Name: Unified execution constitution Phase 3 runtime and evidence
  normalization
- Owner: Octon maintainers
- Motivation: codify the canonical run-manifest model, separate mutable
  runtime state from bound run topology, classify retained evidence using the
  packet’s A/B/C model, and require external immutable replay indexing for the
  supported boundary-sensitive run class
- Scope:
  - add canonical `run-manifest.yml` contracts and bindings
  - normalize `runtime-state.yml`, `handoff.yml`, `replay-pointers.yml`, and
    retained evidence around that manifest
  - add per-run `evidence-classification.yml`
  - update replay manifests and external replay index contracts
  - backfill seeded wave3/wave4 runs, with wave4 exercising external immutable
    replay indexing
  - add explicit Phase 3 validation

## Atomic Execution

1. Add `run-manifest-v1` and adopt `run-manifest.yml` as the canonical
   run-topology artifact beneath the bound run contract.
2. Reduce `runtime-state.yml` to mutable execution status and point continuity
   at manifest, replay pointers, and evidence classification.
3. Codify the packet’s A/B/C evidence-classification model and write
   `evidence-classification.yml` for seeded runs.
4. Add external immutable replay index artifacts for the
   `release-and-boundary-sensitive` supported run class.
5. Update validators and projections so Phase 3 exit criteria are
   machine-checkable.

## Impact Map

### Runtime contract model

- `/.octon/framework/constitution/contracts/runtime/**`
- `/.octon/framework/constitution/contracts/objective/run-contract-v1.schema.json`
- `/.octon/framework/constitution/precedence/normative.yml`
- `/.octon/framework/engine/runtime/{README.md,config/policy-interface.yml,spec/policy-interface-v1.md}`
- `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `/.octon/framework/engine/runtime/crates/kernel/src/authorization.rs`
- `/.octon/framework/orchestration/runtime/_ops/scripts/{orchestration-runtime-common.sh,write-run.sh}`

### Retention and replay normalization

- `/.octon/framework/constitution/contracts/retention/**`
- `/.octon/framework/lab/runtime/{README.md,contracts/replay-manifest-v1.schema.json}`
- `/.octon/instance/governance/contracts/disclosure-retention.yml`
- `/.octon/state/evidence/external-index/**`
- `/.octon/state/evidence/runs/**`

### Sample runs and projections

- `/.octon/state/control/execution/runs/run-wave3-runtime-bridge-20260327/**`
- `/.octon/state/control/execution/runs/run-wave4-benchmark-evaluator-20260327/**`
- `/.octon/state/continuity/runs/{run-wave3-runtime-bridge-20260327,run-wave4-benchmark-evaluator-20260327}/handoff.yml`
- `/.octon/framework/orchestration/runtime/runs/{run-wave3-runtime-bridge-20260327.yml,run-wave4-benchmark-evaluator-20260327.yml}`

### Validation and governance records

- `/.octon/framework/orchestration/runtime/runs/_ops/scripts/validate-runs.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/{validate-harness-structure.sh,validate-runtime-lifecycle-normalization.sh,validate-execution-constitution-closeout.sh,validate-unified-execution-phase3-runtime-evidence-normalization.sh}`
- `/.octon/instance/cognition/decisions/079-unified-execution-constitution-phase3-runtime-evidence-normalization.md`
- `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase3-runtime-evidence-normalization/`

## Verification Evidence

- ADR:
  `/.octon/instance/cognition/decisions/079-unified-execution-constitution-phase3-runtime-evidence-normalization.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase3-runtime-evidence-normalization/`

## Rollback

- revert the Phase 3 change set
- remove `run-manifest.yml`, `evidence-classification.yml`, and
  `state/evidence/external-index/runs/**` sample artifacts introduced here
- restore validators and retained run bundles to the prior
  `runtime-state.yml`-centered topology only if the entire branch is being
  reverted
