# Adoption Roadmap

## Intent

The mature model should be adopted in phases. Harmony does not need every
surface immediately.

## Phase 1: Strengthen The Existing Foundation

Target surfaces:

- `workflows`
- `missions`
- `continuity/runs` as durable evidence
- incident governance guidance

Goals:

- keep workflow and mission contracts clean
- strengthen evidence expectations for workflow execution
- make mission-workflow linkage explicit

Exit criteria:

- all material workflows have clear verification gates
- mission ownership and progress tracking stay bounded
- run evidence is easy to trace from material execution

## Phase 2: Formalize `runs` As A First-Class Orchestration Surface

Target surfaces:

- `runs`

Goals:

- introduce explicit orchestration-facing run identity and status
- keep durable evidence in `continuity/runs/`
- make relationships across workflows, missions, automations, and incidents
  queryable

Exit criteria:

- run lineage is navigable
- run status is visible without parsing raw evidence bundles
- retention remains continuity-governed

## Phase 3: Add Recurring And Event-Triggered Launch

Target surfaces:

- `automations`

Goals:

- move recurrence and unattended launch behavior out of workflows
- add pause/resume, retry, and operator-visible automation status

Exit criteria:

- no workflow needs to simulate a scheduler
- recurring execution is policy-bounded and inspectable

## Phase 4: Add Event-Driven Scale Surfaces

Target surfaces:

- `watchers`
- `queue`

Goals:

- support event-driven autonomy
- add safe intake buffering and backpressure

Exit criteria:

- event sources do not launch workflows directly without control points
- queue state, retries, and dead-letter behavior are visible and deterministic

## Phase 5: Add Operational Incident State

Target surfaces:

- `incidents` runtime state, if needed

Goals:

- represent incidents as first-class operational objects
- connect incidents to run lineage and remediation work

Exit criteria:

- containment, remediation, and closure are all evidence-backed
- incident operations stay human-governed

## Phase 6: Add Strategic Coordination

Target surfaces:

- `campaigns`

Goals:

- coordinate multiple missions under one larger objective
- provide risk and milestone rollups

Exit criteria:

- multiple missions need shared coordination often enough to justify the
  surface
- campaign state is simpler than the ad hoc alternatives it replaces

## Recommended Adoption Sequence

1. `workflows`
2. `missions`
3. `runs`
4. `automations`
5. `incidents`
6. `queue`
7. `watchers`
8. `campaigns`

This sequence preserves minimal sufficient complexity while still moving Harmony
toward mature autonomous operation.
