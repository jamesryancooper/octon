# Authority Control Evidence Map

| Planning concern | Correct placement | Forbidden placement |
| --- | --- | --- |
| Planning doctrine | `.octon/framework/engine/runtime/spec/mission-plan-v1.md` | `inputs/**`, `generated/**`, `state/**` |
| Planning schemas | `.octon/framework/engine/runtime/spec/*plan*.schema.json` | proposal packet only |
| Planning lifecycle rules | framework runtime spec and validators | generated dashboards |
| Instance enablement | `.octon/instance/governance/policies/hierarchical-planning.yml` | retained evidence |
| Mission-to-plan binding | mission digest plus mission-local `state/control/**` plan root | generated plan views |
| Plan control state | `.octon/state/control/execution/missions/<mission-id>/plans/**` | `framework/**`, `instance/**`, `generated/**`, `inputs/**` |
| Plan mutation evidence | `.octon/state/evidence/control/execution/planning/**` | plan prose alone |
| Human decisions and approvals | existing approvals and decision roots under `state/control/execution/**` and `state/evidence/control/execution/**` | plan node fields alone |
| Work-package compilation rules | mission workflow plus runtime spec | ad hoc prompt instructions |
| Execution queue candidates | plan control root until compiled; run contract after binding | generated task board |
| Run execution | `.octon/state/control/execution/runs/<run-id>/**` | plan tree |
| Run evidence | `.octon/state/evidence/runs/<run-id>/**` | plan node fields alone |
| Mission continuity | `.octon/state/continuity/repo/missions/<mission-id>/**` | generated summaries |
| Operator visualization | `.octon/generated/cognition/projections/materialized/planning/**` | authority, control, or evidence roots |
| Proposal lineage | `.octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer/` | runtime resolution |

## Class-Root Invariants

- Authored authority remains in `framework/**` and `instance/**`.
- Mutable control truth remains in `state/control/**`.
- Retained proof remains in `state/evidence/**`.
- Continuity remains in `state/continuity/**`.
- Generated outputs remain rebuildable and derived-only.
- Proposal inputs remain temporary lineage and never become runtime or policy
  dependencies.
