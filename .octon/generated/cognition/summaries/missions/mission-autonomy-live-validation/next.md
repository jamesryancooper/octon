---
title: Mission Next
description: Generated next-step mission summary.
mutability: generated
generated_from:
  - /.octon/generated/effective/orchestration/missions/mission-autonomy-live-validation/scenario-resolution.yml
  - /.octon/state/control/execution/missions/mission-autonomy-live-validation/intent-register.yml
  - /.octon/state/continuity/repo/missions/mission-autonomy-live-validation/next-actions.yml
  - .octon/state/control/execution/missions/mission-autonomy-live-validation/action-slices/steady-state-housekeeping.yml
generated_at: "2026-03-28T03:50:20Z"
generator_version: "0.6.7"
---

# Mission Next

- mission_id: `mission-autonomy-live-validation`
- digest_route: `preview_plus_closure_digest`
- recovery_window: `P30D`
- current_slice_ref: `.octon/state/control/execution/missions/mission-autonomy-live-validation/action-slices/steady-state-housekeeping.yml`
- next_slice_ref: `.octon/state/control/execution/missions/mission-autonomy-live-validation/action-slices/steady-state-housekeeping.yml`
- intent_register: `/.octon/state/control/execution/missions/mission-autonomy-live-validation/intent-register.yml`
- next_actions: `/.octon/state/continuity/repo/missions/mission-autonomy-live-validation/next-actions.yml`
