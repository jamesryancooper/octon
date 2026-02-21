---
title: Lessons Learned
description: Anti-patterns and failures to avoid repeating
---

# Lessons Learned

Things that didn't work and why. Consult before proposing approaches.

## Anti-Patterns

| Pattern | Why It Failed | Do Instead |
|---------|---------------|------------|
| Reading entire large files | Blows token budget, loses focus | Use targeted searches, read specific line ranges |
| Skipping progress updates | Breaks session continuity | Always update `continuity/log.md` before session end |
| Deep nesting in workflows | Hard to follow, agents lose track | Keep workflows to 3-7 steps, use sub-workflows |
| Explanatory prose in agent files | Wastes tokens, agents need actions | Move rationale to `ideation/scratchpad/` or `docs/`, keep agent content terse |
| Vague task descriptions | Agents interpret differently each time | Use specific, verifiable task descriptions |

## Failed Approaches

Specific attempts that didn't work. Include context so future sessions understand.

| Date | Attempted | Outcome | Learning |
|------|-----------|---------|----------|
| — | — | — | — |

## Recording Lessons

When something fails:

1. Add to **Anti-Patterns** if it's a general pattern to avoid
2. Add to **Failed Approaches** if it's a specific attempt with context
3. Reference the relevant task or session in `continuity/log.md`

### Anti-Pattern Format

```markdown
| Pattern | Why It Failed | Do Instead |
|---------|---------------|------------|
| [What was tried] | [Why it didn't work] | [Preferred approach] |
```

### Failed Approach Format

```markdown
| Date | Attempted | Outcome | Learning |
|------|-----------|---------|----------|
| YYYY-MM-DD | [What was tried] | [What happened] | [Key takeaway] |
```

