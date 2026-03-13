---
title: Bootstrap Session
description: Quick-start a new agent session in a harness.
access: human
---

# Bootstrap Session

## Context

Quick-start a new agent session in a `.octon`-enabled directory.

## Instructions

1. **Locate harness**
   - Check for `.octon/` at the repository root
   - If none exists, stop and note that the repo-root harness must be adopted before session bootstrap can continue

2. **Execute boot sequence**
   Follow the boot sequence in `START.md`

3. **Assess state**
   - Identify highest-priority unblocked task
   - Check for blockers
   - Note any stale progress (>7 days)

4. **Report ready state**

## Output

```markdown
## Session Bootstrap

**Harness:** [path]
**Scope:** [1-line summary]
**Last activity:** [date]

**Current task:** [highest priority unblocked]
**Blockers:** [if any]

**Ready to begin:** [task description]
```
