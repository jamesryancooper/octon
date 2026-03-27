---
title: Mission Now
description: Generated current-state mission summary.
mutability: generated
generated_from:
  - /.octon/instance/orchestration/missions/mission-autonomy-live-validation/mission.yml
  - /.octon/generated/effective/orchestration/missions/mission-autonomy-live-validation/scenario-resolution.yml
  - /.octon/state/control/execution/missions/mission-autonomy-live-validation/mode-state.yml
  - /.octon/state/control/execution/missions/mission-autonomy-live-validation/intent-register.yml
  - /.octon/state/control/execution/missions/mission-autonomy-live-validation/autonomy-budget.yml
  - /.octon/state/control/execution/missions/mission-autonomy-live-validation/circuit-breakers.yml
  - .octon/state/control/execution/missions/mission-autonomy-live-validation/action-slices/steady-state-housekeeping.yml
generated_at: "2026-03-27T03:32:40Z"
generator_version: "0.6.3"
---

# Mission Now

- mission_id: `mission-autonomy-live-validation`
- title: `Mission: mission-autonomy-live-validation`
- status: `active`
- mission_class: `maintenance`
- effective_scenario_family: `maintenance.repo_housekeeping`
- effective_action_class: `git.commit`
- owner_ref: `operator://octon-maintainers`
- oversight_mode: `notify`
- execution_posture: `interruptible_scheduled`
- safety_state: `paused`
- safe_interrupt_boundary_class: `task_boundary`
- phase: `planning`
- autonomy_budget_state: `healthy`
- breaker_state: `clear`
- recovery_window: `P30D`
- scenario_route_generated_at: `2026-03-27T03:32:40Z`
- scenario_route_fresh_until: `2026-03-27T03:47:40Z`
