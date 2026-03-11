---
title: Create Mission
description: Scaffold a new mission from template.
access: human
version: "1.1.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
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

## Failure Conditions

- Mission slug is invalid -> STOP, report the required slug format
- Mission already exists -> STOP, use the existing mission or choose a new slug
- Mission scaffold template is missing -> STOP, restore the mission template before continuing

## Steps

1. **Validate slug** — Check format and uniqueness
2. **Copy template** — Copy `missions/_scaffold/template/` to `missions/<slug>/`
3. **Initialize mission.yml** — Update canonical mission identity, lifecycle,
   owner, summary, success criteria, and linkage placeholders
4. **Initialize mission.md** — Keep bounded narrative context subordinate to
   `mission.yml`
5. **Initialize tasks.json** — Set mission identifier
6. **Initialize log.md** — Add creation entry with date
7. **Update registry** — Add mission to `active` list in `registry.yml`
7. **Confirm** — Report success and next steps

## Output

A new mission directory ready for work:

```text
missions/<slug>/
├── mission.yml    # Canonical mission object
├── mission.md     # Narrative context subordinate to mission.yml
├── tasks.json     # Empty task list
├── log.md         # Creation entry logged
└── context/       # Mission-local context
```

## Required Outcome

- [ ] `missions/<slug>/` exists with initialized mission artifacts
- [ ] Mission registry is updated
- [ ] Operator receives the next-step guidance after creation

## Next Steps After Creation

1. Edit `mission.yml` to define owner, lifecycle state, success criteria, and
   optional workflow/run linkage
2. Update `mission.md` with bounded narrative context
3. Add initial tasks to `tasks.json`
4. Begin work on the mission

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.1.0 | 2025-01-14 | Added gap remediation fields |
| 1.0.0 | 2025-01-05 | Initial version |

## Related

- [Complete Mission](../complete-mission/00-overview.md) — Archive a completed mission
- [Missions README](../../../missions/README.md) — Overview of missions
