# Wave 3 Change Inventory

## Constitutional And Structural Authority

- Added `/.octon/framework/constitution/contracts/runtime/**`
- Activated the runtime contract family in
  `/.octon/framework/constitution/contracts/registry.yml`
- Recorded the Wave 3 `release_state`, `change_profile`, and Profile Selection
  Receipt in
  `/.octon/instance/cognition/context/shared/migrations/2026-03-27-runtime-lifecycle-normalization-cutover/`
- Added ADR
  `/.octon/instance/cognition/decisions/070-runtime-lifecycle-normalization-cutover.md`

## Runtime Lifecycle Writers

- Normalized engine authorization and execution flows around canonical run
  control and run evidence roots in
  `/.octon/framework/engine/runtime/crates/kernel/src/authorization.rs`
- Added canonical runtime lifecycle evidence helpers in
  `/.octon/framework/engine/runtime/crates/core/src/{config.rs,execution_integrity.rs,trace.rs}`
- Expanded orchestration run tooling in
  `/.octon/framework/orchestration/runtime/_ops/scripts/write-run.sh`
  and `/.octon/framework/orchestration/runtime/runs/_ops/scripts/validate-runs.sh`
- Added canonical runtime-state, rollback-posture, checkpoint, replay, trace
  pointer, and retained-evidence families beneath
  `/.octon/state/control/execution/runs/**` and
  `/.octon/state/evidence/runs/**`
- Corrected orchestration mission discovery to resolve mission authority from
  `/.octon/instance/orchestration/missions/**`

## Mission Bridge And Generated Read Models

- Updated mission summaries and mission-view generation in
  `/.octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`
- Extended `mission-view-v1` to require `run_evidence_refs`
- Updated mission docs and registry metadata so transitional mission-backed
  flows point at the Wave 3 lifecycle receipt while still treating mission as
  the continuity container
- Seeded a real transitional mission-backed run root:
  `/.octon/state/control/execution/runs/run-wave3-runtime-bridge-20260327/**`
  and matching evidence under
  `/.octon/state/evidence/runs/run-wave3-runtime-bridge-20260327/**`

## Publication State Refresh

- Republished extension publication state so root-manifest hashes and
  generation locks are current
- Republished capability routing so the broad runtime-effective-state sweep is
  fully green again

## Validators And Docs

- Added
  `/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-lifecycle-normalization.sh`
- Updated harness, architecture, mission-view, mission-summary, mission
  source-of-truth, runtime-effective-state, and alignment-profile validators
- Updated `/.octon/README.md`, bootstrap docs, architecture docs, state docs,
  and runtime/operator guidance to point at the canonical Wave 3 lifecycle
  families
