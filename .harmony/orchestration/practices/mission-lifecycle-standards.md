# Mission Lifecycle Standards

These standards define operating discipline for mission-based orchestration.

## Scope

Applies to mission artifacts under
`/.harmony/orchestration/runtime/missions/`.

## Mission Creation Standard

Create a mission only when work is time-bounded, multi-step, and needs isolated
tracking from harness-wide `continuity/` artifacts.

Do not create a mission for a single-session or trivial change; use
`/.harmony/continuity/tasks.json` instead.

## Required Mission Artifacts

Each active mission must include:

- `mission.md` with goal, scope, owner, and success criteria.
- `mission.md` may also carry optional linkage fields:
  `campaign_id`, `default_workflow_refs`, and `related_run_ids`.
- `tasks.json` with machine-readable task state.
- `log.md` with append-only progress entries.

Mission registration must be present in
`/.harmony/orchestration/runtime/missions/registry.yml`.

## Lifecycle Transition Standards

1. **Created -> Active**
   - Mission has explicit owner.
   - Success criteria are concrete and measurable.
   - Registry entry is present.
2. **Active -> Completed**
   - Success criteria are satisfied.
   - Mission task list is reconciled.
   - Final mission log summary is recorded.
3. **Completed/Cancelled -> Archived**
   - Mission moved under `.archive/`.
   - Registry status updated to reflect terminal state.
   - Any follow-up work is moved to harness continuity artifacts.

## Operating Discipline

- Update mission `tasks.json` and `log.md` in the same change set as material
  mission progress.
- Keep mission scope bounded; if scope expands materially, split or create a
  follow-on mission.
- Update `mission.md` linkage fields when mission/workflow/run relationships
  change materially.
- Link mission outcomes to durable evidence in
  `/.harmony/output/reports/` when verification artifacts are produced.
- Material execution evidence belongs in `/.harmony/continuity/runs/`.
- Material routing and authority decisions belong in
  `/.harmony/continuity/decisions/`.

## Boundary Rules

- Mission runtime artifacts and registries remain under `runtime/missions/`.
- Incident policy and escalation protocol remain under `governance/`.
- Lifecycle and authoring discipline standards remain under `practices/`.
