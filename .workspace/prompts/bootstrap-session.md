---
title: Bootstrap Session
description: Quick-start a new agent session in a workspace.
access: human
---

# Bootstrap Session

## Context

Quick-start a new agent session in a `.workspace`-enabled directory.

## Instructions

1. **Locate workspace**
   - Check for `.workspace/` in current directory
   - If not found, check parent directories
   - If none exists, suggest `/create-workspace`

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

**Workspace:** [path]
**Scope:** [1-line summary]
**Last activity:** [date]

**Current task:** [highest priority unblocked]
**Blockers:** [if any]

**Ready to begin:** [task description]
```
