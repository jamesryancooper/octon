# Missions

`/.octon/instance/orchestration/missions/` is the canonical repo-instance home
for durable mission definitions and mission-scoped orchestration artifacts.

## Purpose

- keep repo-owned missions under the instance authority layer
- separate durable mission definitions from framework workflows and mutable
  continuity state
- provide one canonical registry and scaffolding surface for mission creation
- allow missions to reference one or more locality `scope_id` values without
  turning missions into locality authority

## Layout

```text
.octon/instance/orchestration/missions/
  README.md
  registry.yml
  .archive/
  _scaffold/template/
    mission.yml
    mission.md
    tasks.json
    log.md
  <mission-id>/
    mission.yml
    mission.md
    tasks.json
    log.md
    context/
```

## Boundary Rules

- mission authority lives here under `instance/**`
- active mission charters use `octon-mission-v2`
- mission remains the continuity container rather than the atomic execution
  unit
- consequential runs bind per-run objective contracts under
  `state/control/execution/runs/<run-id>/**`
- missions may reference scope ids, but scope identity still lives under
  `instance/locality/**`
- mission-local mutable execution control truth belongs under
  `state/control/execution/missions/<mission-id>/**`
- mission-local retained control evidence belongs under
  `state/evidence/control/execution/**`
- mission-local effective scenario routing belongs under
  `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`
- mission-local retained execution evidence belongs under
  `state/evidence/runs/**`
- mission-local generated summaries and mission views must consume bound
  per-run receipts, checkpoints, replay pointers, and rollback posture when
  runs exist
- mission-local continuity belongs under
  `state/continuity/repo/missions/<mission-id>/**`
- stage attempts, retries, and staged previews belong under the bound run root
  rather than under mission authority
- framework workflows may create or complete missions, but they are not the
  authority surface for mission definitions
