# Mission Lifecycle Standards

These standards define operating discipline for mission-based orchestration.

## Scope

Applies to mission artifacts under
`/.octon/orchestration/runtime/missions/`.

## Mission Creation Standard

Create a mission only when work is time-bounded, multi-step, and needs isolated
tracking from harness-wide `continuity/` artifacts.

Do not create a mission for a single-session or trivial change; use
`/.octon/continuity/tasks.json` instead.

## Required Mission Artifacts

Each active mission must include:

- `mission.yml` with canonical `mission_id`, `title`, `summary`, `status`,
  `owner`, `created_at`, and `success_criteria`.
- `mission.md` as optional subordinate narrative guidance.
- `tasks.json` with machine-readable task state.
- `log.md` with append-only progress entries.
- `context/` for mission-local context when needed.

Mission registration must be present in
`/.octon/orchestration/runtime/missions/registry.yml`.

Authority order is:

`registry.yml -> mission.yml -> mission.md`

## Lifecycle Transition Standards

1. **Created -> Active**
   - `mission.yml` exists and is the canonical mission object.
   - Mission has explicit owner.
   - Success criteria are concrete and measurable.
   - Registry entry is present.
2. **Active -> Completed**
   - `mission.yml` status reflects completion.
   - Success criteria are satisfied.
   - Mission task list is reconciled.
   - Final mission log summary is recorded.
3. **Completed/Cancelled -> Archived**
   - `mission.yml` records `status=archived` and `archived_from_status`.
   - Mission moved under `.archive/`.
   - Registry status updated to reflect terminal state.
   - Any follow-up work is moved to harness continuity artifacts.

## Operating Discipline

- Update mission `tasks.json` and `log.md` in the same change set as material
  mission progress.
- Keep mission scope bounded; if scope expands materially, split or create a
  follow-on mission.
- Update `mission.yml` linkage fields when mission/workflow/run relationships
  change materially.
- Link mission outcomes to durable evidence in
  typed subdirectories under `/.octon/output/reports/` when verification
  artifacts are produced.
- Material execution evidence belongs in `/.octon/continuity/runs/`.
- Material routing and authority decisions belong in
  `/.octon/continuity/decisions/`.
- Mission-owned workflow invocations must emit runs carrying `mission_id` and
  linked `decision_id`.

## Boundary Rules

- Mission runtime artifacts and registries remain under `runtime/missions/`.
- Incident policy and escalation protocol remain under `governance/`.
- Lifecycle and authoring discipline standards remain under `practices/`.
- `mission.md`, `tasks.json`, `log.md`, and `context/` must not replace
  `mission.yml` as the authoritative lifecycle object.
