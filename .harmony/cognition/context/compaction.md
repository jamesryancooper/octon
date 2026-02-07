# Compaction Strategy

## When to compact

- Approaching context limits
- Before ending a long session
- After completing a major milestone

## Preserve

- Architectural decisions made
- Unresolved bugs/issues
- Current task state and blockers
- File paths touched
- Key learnings

## Discard

- Raw tool outputs (already processed)
- Intermediate debugging steps
- Superseded plans
- Verbose error messages (keep summary)

## Before ending a long session

1. Update `continuity/log.md` with summary
2. Commit pending changes with descriptive message
3. Note decisions/rationale for future context
4. Update `tasks.json` status

## Note-taking pattern

For complex work, maintain notes in `continuity/log.md`:

```markdown
**Decisions:**
- Chose X over Y because [reason]

**Files touched:**
- path/to/file.ts — [what changed]

**Open questions:**
- [question for next session]
```
