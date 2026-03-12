# Mission Workflow Binding Contract

## Purpose

Define how missions reference, invoke, and link to workflows without turning
missions into workflow-definition containers.

## Binding Model

Mission linkage fields live in `mission.yml` under
`mission-object-contract.md`.

Missions may reference workflows through canonical workflow references such as:

```yaml
workflow_ref:
  workflow_group: "audit"
  workflow_id: "audit-continuous-workflow"
```

Mission-level linkage fields stored in `mission.yml` may include:

- `default_workflow_refs[]`
- `active_run_ids[]`
- `recent_run_ids[]`
- `related_run_ids[]`

## Invocation Rules

1. Missions may launch workflows through bounded orchestration paths.
2. A mission owner or delegated actor may invoke a workflow in mission context.
3. Every mission-owned workflow invocation must emit a run.
4. Every mission-owned material invocation must emit a decision record before or
   with the resulting run.
5. Mission context must be carried in the run as `mission_id`.
6. `mission.md` may explain why a workflow matters to the mission, but it must
   not replace `mission.yml` as the source of workflow references or run
   linkage.

## Workflow Execution Controls

- Workflow definition artifacts may define machine-readable execution controls
  for orchestration-time behavior.
- `execution_controls.cancel_safe: true|false` is the canonical control used by
  automation `replace` semantics.
- Omitted `execution_controls.cancel_safe` is treated as `false`.

## Ownership Semantics

- mission owns initiative intent
- workflow owns bounded procedure definition
- run owns execution instance

No one of these may silently replace the other.

## Follow-Up Work Representation

When a mission creates follow-up work:

- bounded reusable procedure -> reference workflow
- bounded multi-session initiative -> new or existing mission task/context
- exception or containment -> incident linkage plus run linkage

## Invariants

- missions may reference workflows, but may not define or fork workflow logic
- mission-owned runs must carry `mission_id`
- mission-owned runs must carry `decision_id`
- workflow execution history does not live inside workflow definitions

## Prohibited Coupling Patterns

- embedding workflow step content in mission files
- mission-specific workflow forks without a new canonical workflow identity
- using mission state as a substitute for run evidence
