# Step 2: Classify Content

## Content Classification

Classify each piece of content:

| Classification | Destination |
|----------------|-------------|
| Agent-facing | Stays in `.harmony/` |
| Human-facing | Moves to `ideation/scratchpad/` |

## Token Budget Check

Check token budgets per `docs/architecture/harness/README.md#token-budget-guidelines`:

| Scope | Target | Max |
|-------|--------|-----|
| Total harness | ~2,000 | ~5,000 |
| Single file | ~300 | ~500 |
| START.md (boot) | ~200 | ~300 |

## Progress Review

Review `continuity/log.md` for:
- Staleness (>30 days since last update)
- Completeness (proper session format)
- Continuity (clear thread across sessions)

Review `continuity/tasks.json` for:
- Schema compliance
- Blocked task resolution
- Task rot (old pending tasks)

