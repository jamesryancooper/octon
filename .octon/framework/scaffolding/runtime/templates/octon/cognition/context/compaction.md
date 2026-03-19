---
title: Compaction Strategy
description: Token compaction strategies for keeping content within budget
---

# Compaction Strategy

## When to Compact

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

## Before Ending a Long Session

1. Update `state/continuity/repo/log.md` with summary
2. Commit pending changes with descriptive message
3. Note decisions/rationale for future context
4. Update `state/continuity/repo/tasks.json` status

## Note-Taking Pattern

For complex work, maintain notes in `state/continuity/repo/log.md`:

```markdown
**Decisions:**
- Chose X over Y because [reason]

**Files touched:**
- path/to/file.ts — [what changed]

**Open questions:**
- [question for next session]
```
