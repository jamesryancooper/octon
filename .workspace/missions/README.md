---
title: Missions
description: Time-bounded sub-projects with isolated progress tracking.
---

# Missions

Missions are **time-bounded sub-projects** within a workspace. They provide isolated progress tracking for parallel workstreams or large initiatives.

## When to Create a Mission

| Scenario | Use Mission? | Alternative |
|----------|--------------|-------------|
| Parallel workstreams in same area | Yes | — |
| Time-bounded initiative (weeks) | Yes | — |
| Delegatable unit of work | Yes | — |
| Single task, completes in one session | No | Use workspace `tasks.json` |
| Different codebase area | No | Create nested `.workspace` |

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
4. **Archived:** Moved to `.archive/` via `/complete-mission`

## Creating a New Mission

Use the workflow: `/create-mission <slug>`

Or manually:
1. Copy `_template/` to a new directory: `missions/<slug>/`
2. Update `mission.md` with goal, scope, success criteria
3. Register in `registry.yml`

## Mission Structure

```text
missions/<slug>/
├── mission.md     # Goal, scope, owner, status
├── tasks.json     # Mission-specific task list
├── log.md         # Mission-specific progress log
└── context/       # Mission-specific decisions (optional)
```

## Relationship to Workspace Progress

- **Workspace `progress/`**: Cross-cutting session log, workspace-level tasks
- **Mission `tasks.json`**: Isolated tasks for this specific initiative
- **Mission `log.md`**: Isolated progress for this specific initiative

Missions roll up to workspace-level progress but maintain their own isolated tracking.
