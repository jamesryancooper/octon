---
title: Mission Recover
description: Generated mission recovery summary.
mutability: generated
generated_from:
  - /.octon/generated/effective/orchestration/missions/mission-autonomy-live-validation/scenario-resolution.yml
  - /.octon/state/evidence/runs/**
  - /.octon/state/evidence/control/execution/**
  - /.octon/state/control/execution/missions/mission-autonomy-live-validation/mode-state.yml
  - .octon/state/control/execution/missions/mission-autonomy-live-validation/action-slices/steady-state-housekeeping.yml
generated_at: "2026-04-13T16:34:19Z"
generator_version: "0.6.18"
---

# Mission Recover

- mission_id: `mission-autonomy-live-validation`
- recovery_window: `P30D`
- route_ref: `.octon/generated/effective/orchestration/missions/mission-autonomy-live-validation/scenario-resolution.yml`
- recovery_source: `/.octon/state/evidence/runs/`
- replay_pointer_ref: `/.octon/state/evidence/runs/run-wave3-runtime-bridge-20260327/replay-pointers.yml`
- mode_state: `/.octon/state/control/execution/missions/mission-autonomy-live-validation/mode-state.yml`
