# Mission: mission-autonomy-live-validation

## Goal

Keep one bounded live mission in the repo that exercises the completed
Mission-Scoped Reversible Autonomy path on real repo surfaces without requiring
external effects.

## Mission Class

- `maintenance`
- This mission should inherit the low-risk maintenance defaults: `notify`,
  `interruptible_scheduled`, skip overlap, latest-only backfill, and explicit
  safe interruption.

## Owner

- Accountable owner: `operator://octon-maintainers`
- Additional interested parties should consume the generated operator digest,
  not out-of-band mission state.

## Scope

- In scope:
  - `/.octon/instance/orchestration/missions/mission-autonomy-live-validation/**`
  - `/.octon/state/control/execution/missions/mission-autonomy-live-validation/**`
  - `/.octon/state/continuity/repo/missions/mission-autonomy-live-validation/**`
  - `/.octon/generated/effective/orchestration/missions/mission-autonomy-live-validation/**`
  - `/.octon/generated/cognition/summaries/missions/mission-autonomy-live-validation/**`
  - `/.octon/generated/cognition/projections/materialized/missions/mission-autonomy-live-validation/mission-view.yml`
- Allowed action classes:
  - `repo-maintenance`
- Explicit exclusions:
  - external network effects
  - release, publishing, or public communication flows
  - irreversible or destructive action classes

## Risk And Safing

- Risk ceiling: `ACP-1`
- Safe subset:
  - `observe_only`
  - `stage_only`
- Must never proceed on silence for destructive, irreversible, or externally
  effectful work

## Schedule Intent

- Default posture is `interruptible_scheduled`, but the seeded lease should
  stay paused until a human intentionally resumes it
- Preview and digest behavior should remain route-derived and visible through
  the generated mission/operator views

## Objective Binding

- This mission remains the continuity container for the live validation lane.
- Consequential work bound to this mission should publish a run contract under
  `/.octon/state/control/execution/runs/<run-id>/run-contract.yml`.
- Retry, stage-only, and resumable attempts belong under
  `/.octon/state/control/execution/runs/<run-id>/stage-attempts/`.
- Mission-only execution remains a transitional compatibility path with an
  explicit retirement gate.

## Notes

This mission exists to give the MSRAOM closeout one real, low-risk live target
for seed-before-active lifecycle validation, slice-linked intent, route
publication, authorize-update handling, reducer-driven trust tightening,
summary generation, and closeout proof.
