---
title: Missions
description: Time-bounded sub-projects with isolated progress tracking.
---

# Missions

Missions are **time-bounded sub-projects** within a workspace. They provide isolated progress tracking for parallel workstreams or large initiatives.

## When to Create a Mission

| Scenario | Use Mission? | Alternative |
|----------|--------------|-------------|
| Parallel workstreams | Yes | — |
| Time-bounded initiative | Yes | — |
| Delegatable unit of work | Yes | — |
| Single task, one session | No | Use workspace `tasks.json` |
| Different codebase area | No | Create nested `.harmony` |

## Active Missions

See `registry.yml` for current missions.

## Creating a New Mission

1. Copy `_template/` to `missions/<slug>/`
2. Update `mission.md` with goal, scope, success criteria
3. Register in `registry.yml`

## Mission Structure

```text
missions/<slug>/
├── mission.md     # Goal, scope, owner, status
├── tasks.json     # Mission-specific task list
└── log.md         # Mission-specific progress log
```
