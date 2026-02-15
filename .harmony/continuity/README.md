# Continuity

Session state and progress tracking.

## Contents

| File | Purpose | Mutability |
|------|---------|------------|
| `_meta/architecture/README.md` | Continuity subsystem specification docs | reference |
| `log.md` | Append-only session history | append-only |
| `tasks.json` | Structured task list with goal | read-write |
| `entities.json` | Entity state tracking | read-write |
| `next.md` | Immediate actionable steps | read-write |

## Contract

### Before Starting Work

1. Read `tasks.json` to identify highest-priority unblocked task.
2. Read `log.md` (latest entry) for recent context.

### Before Ending a Session

1. Append session summary to `log.md`. Never modify past entries.
2. Update `tasks.json` status for all affected tasks.
3. Update `entities.json` if entity state changed.
4. Update `next.md` with immediate next actions.
