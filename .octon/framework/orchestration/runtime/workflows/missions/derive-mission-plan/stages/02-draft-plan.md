---
title: Draft Plan
description: Draft a bounded MissionPlan candidate without decomposing beyond the planning budget.
---

# Draft Plan

Create or update the mission-bound `MissionPlan` control state only after the
mission binding stage passes.

## Required Content

The first pass records:

1. mission objective and strategic outcomes;
2. major workstreams;
3. constraints, scope, and non-scope;
4. risks, assumptions, dependencies, and decision points;
5. planning budget and decomposition depth budget;
6. rolling-wave window;
7. evidence root refs; and
8. rollback or compensation expectations.

## Boundary

The plan is preparation control state. It is not authority, not evidence by
itself, not a run journal, and not an execution queue.

Do not create state outside:

```text
.octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/
.octon/state/evidence/control/execution/planning/<plan-id>/
```
