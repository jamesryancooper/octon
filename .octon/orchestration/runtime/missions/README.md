---
title: Missions
description: Time-bounded sub-projects with isolated progress tracking.
---

# Missions

Missions are **time-bounded sub-projects** within a harness. They provide isolated progress tracking for parallel workstreams or large initiatives.

Authority order for live mission surfaces is:

`registry.yml -> mission.yml -> mission.md`

`mission.yml` is the canonical mission object for identity, lifecycle, owner,
success criteria, and cross-surface linkage. `mission.md`, `tasks.json`,
`log.md`, and `context/` remain subordinate mission-local guidance or state.

## When to Create a Mission

| Scenario | Use Mission? | Alternative |
|----------|--------------|-------------|
| Parallel workstreams in same area | Yes | — |
| Time-bounded initiative (weeks) | Yes | — |
| Delegatable unit of work | Yes | — |
| Single task, completes in one session | No | Use harness `tasks.json` |
| Different codebase area | No | Use repo-root domain context or start a separate mission |

## Active Missions

See `registry.yml` for current active and archived missions.

## Mission Lifecycle

```
Created → Active → Completed → Archived
                 ↘ Cancelled → Archived
```

1. **Created:** Scaffolded via `/create-mission`
2. **Active:** Work in progress with isolated log and tasks
3. **Completed:** Success criteria met
4. **Archived:** Moved to `missions/.archive/` via `/complete-mission`

## Creating a New Mission

Use the workflow: `/create-mission <slug>`

Or manually:
1. Copy `_scaffold/template/` to a new directory: `missions/<slug>/`
2. Update `mission.yml` with title, summary, owner, lifecycle state, and
   success criteria
3. Update `mission.md` with bounded narrative context
4. Register in `registry.yml`

## Mission Structure

```text
missions/<slug>/
├── mission.yml    # Canonical machine-readable mission object
├── mission.md     # Optional narrative brief subordinate to mission.yml
├── tasks.json     # Mission-specific task list
├── log.md         # Mission-specific progress log
└── context/       # Mission-specific local context
```

## Relationship to Harness Progress

- **Harness `continuity/`**: Cross-cutting session log, harness-level tasks
- **Mission `tasks.json`**: Isolated tasks for this specific initiative
- **Mission `log.md`**: Isolated progress for this specific initiative

Missions roll up to harness-level progress but maintain their own isolated tracking.

## Optional Linkage Fields

`mission.yml` may also carry optional linkage fields:

- `campaign_id`
- `default_workflow_refs`
- `active_run_ids`
- `recent_run_ids`
- `related_run_ids`

Use these fields to link mission intent to strategic context, canonical
workflow references, and material run lineage. Do not move this linkage into
`registry.yml`; the registry remains the discovery and lifecycle index.
