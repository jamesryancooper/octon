---
title: Create Mission
description: Scaffold a new mission from template.
access: human
---

# Create Mission

Scaffold a new mission with isolated progress tracking.

## Usage

```text
/create-mission <slug>
```

## Prerequisites

- Mission slug must be lowercase with hyphens (e.g., `auth-overhaul`)
- No existing mission with the same slug

## Steps

1. **Validate slug** — Check format and uniqueness
2. **Copy template** — Copy `missions/_template/` to `missions/<slug>/`
3. **Initialize mission.md** — Update with slug, start date, placeholder goal
4. **Initialize tasks.json** — Set mission name
5. **Initialize log.md** — Add creation entry with date
6. **Update registry** — Add mission to `active` list in `registry.yml`
7. **Confirm** — Report success and next steps

## Output

A new mission directory ready for work:

```text
missions/<slug>/
├── mission.md     # Ready for goal/scope definition
├── tasks.json     # Empty task list
└── log.md         # Creation entry logged
```

## Next Steps After Creation

1. Edit `mission.md` to define goal, scope, and success criteria
2. Assign an owner (agent role or @assistant)
3. Add initial tasks to `tasks.json`
4. Begin work on the mission

## Related

- [Complete Mission](../complete-mission/00-overview.md) — Archive a completed mission
- [Missions README](../../missions/README.md) — Overview of missions
