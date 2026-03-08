# Continuity

Session state and progress tracking.
Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Contents

| File | Purpose | Mutability |
|------|---------|------------|
| `_meta/architecture/README.md` | Continuity subsystem specification docs | reference |
| `log.md` | Append-only session history | append-only |
| `tasks.json` | Structured task list with goal | read-write |
| `entities.json` | Entity state tracking | read-write |
| `next.md` | Immediate actionable steps | read-write |
| `decisions/` | Append-oriented decision evidence artifacts | retention-governed |
| `runs/` | Append-oriented run evidence artifacts | retention-governed |

## Convention Authority

- This domain has no local `practices/` surface.
- It inherits naming and authoring conventions from `/.harmony/conventions.md`.
- `_meta/architecture/` remains a reference surface.

## Contract

### Before Starting Work

1. Read `tasks.json` to identify highest-priority unblocked task.
2. Read `log.md` (latest entry) for recent context.
3. Read `next.md` to follow immediate execution sequencing.

### Before Ending a Session

1. Append session summary to `log.md`. Never modify past entries.
2. Update `tasks.json` status for all affected tasks.
3. Update `entities.json` if entity state changed.
4. Update `next.md` with immediate next actions.
5. Run `bash .harmony/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`.
