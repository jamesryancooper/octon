# Bootstrap Session

## Context

Quick-start a new agent session in a `.workspace`-enabled directory.

## Instructions

1. **Locate workspace**
   - Check for `.workspace/` in current directory
   - If not found, check parent directories
   - If none exists, suggest `/create-workspace`

2. **Execute boot sequence**
   ```
   1. Read scope.md → Know boundaries
   2. Read conventions.md → Know style rules
   3. Read progress/log.md → Know what's been done
   4. Read progress/tasks.json → Know priorities
   ```

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
