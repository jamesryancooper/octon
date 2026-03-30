# Phase 4 Change Inventory

## Summary

- Added authored proof suites for functional, behavioral, maintainability, and
  recovery assurance.
- Added substantive authored lab domains for scenarios, replay, shadow, and
  faults, plus retained lab evidence that exercises those domains.
- Converted provider review execution into evaluator adapters and a generic
  evaluator adapter runner.
- Added Phase 4 CI/local enforcement and backfilled seeded run evidence to use
  the stronger proof-plane and lab model.

## Proof-Plane Enforcement Added

- Authored suite registries and suite definitions now exist under:
  - `/.octon/framework/assurance/functional/suites/**`
  - `/.octon/framework/assurance/behavioral/suites/**`
  - `/.octon/framework/assurance/maintainability/suites/**`
  - `/.octon/framework/assurance/recovery/suites/**`
- Added validator:
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-phase4-proof-lab-enforcement.sh`
- Updated `architecture-conformance.yml` to run that validator.

## Lab Domain Implementation

- Added authored roots:
  - `/.octon/framework/lab/scenarios/**`
  - `/.octon/framework/lab/replay/**`
  - `/.octon/framework/lab/shadow/**`
  - `/.octon/framework/lab/faults/**`
  - `/.octon/framework/lab/probes/**`
- Added retained evidence roots:
  - `/.octon/state/evidence/lab/replays/**`
  - `/.octon/state/evidence/lab/shadow-runs/**`
  - `/.octon/state/evidence/lab/faults/**`
- Backfilled supported-tier scenario/replay/shadow/fault evidence for
  `run-wave3-runtime-bridge-20260327`.

## Evaluator Adapter Changes

- Added:
  - `/.octon/framework/assurance/evaluators/adapters/registry.yml`
  - `/.octon/framework/assurance/evaluators/adapters/openai-review.yml`
  - `/.octon/framework/assurance/evaluators/adapters/anthropic-review.yml`
  - `/.octon/framework/assurance/evaluators/runtime/_ops/scripts/run-evaluator-adapter.sh`
- Updated:
  - `/.octon/framework/assurance/evaluators/{README.md,review-routing.yml}`
  - `/.github/workflows/ai-review-gate.yml`
- Backfilled run-level evaluator evidence so the boundary-sensitive run cites
  the adapter manifests.

## Phase 4 Exit Status

- All proof planes exist: satisfied by the authored suites, retained run proof
  reports, and assurance family metadata.
- Structural and governance remain blocking: satisfied by the assurance family
  and preserved CI gates.
- At least one supported tier has behavioral and recovery evidence: satisfied
  by the repo-local-transitional wave3 run and retained lab scenario/replay/
  shadow/fault artifacts.
- Lab domain runs scenario/replay/shadow or fault interfaces in substance:
  satisfied by the authored lab domains, retained lab evidence roots, and
  Phase 4 validator enforcement.
