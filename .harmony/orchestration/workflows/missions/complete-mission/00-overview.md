---
title: Complete Mission
description: Archive a completed mission.
access: human
version: "1.1.0"
depends_on:
  - workflow: missions/create-mission
    condition: "Mission must exist"
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Complete Mission

Archive a mission after completion or cancellation.

## Usage

```text
/complete-mission <slug> [--cancelled]
```

## Prerequisites

- Mission must exist in `missions/<slug>/`
- Mission should have success criteria met (or be cancelled)

## Steps

1. **Validate mission exists** — Check `missions/<slug>/` exists
2. **Verify completion** — Check success criteria in `mission.md` (skip if `--cancelled`)
3. **Update mission.md** — Set status to `completed` or `cancelled`
4. **Final log entry** — Add completion entry to `log.md`
5. **Move to archive** — Move `missions/<slug>/` to `missions/.archive/<slug>/`
6. **Update registry** — Move from `active` to `archived` in `registry.yml`
7. **Confirm** — Report success

## Output

Mission moved to archive:

```text
missions/.archive/<slug>/
├── mission.md     # Status: completed/cancelled
├── tasks.json     # Final task state
└── log.md         # Completion entry logged
```

## Flags

| Flag | Description |
|------|-------------|
| `--cancelled` | Mark as cancelled instead of completed |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.1.0 | 2025-01-14 | Added gap remediation fields |
| 1.0.0 | 2025-01-05 | Initial version |

## Related

- [Create Mission](../create-mission/00-overview.md) — Scaffold a new mission
- [Missions README](../../../missions/README.md) — Overview of missions
