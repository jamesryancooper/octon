# .workspace: Start Here

## Structure

```text
.workspace/
├── START.md        ← You are here
├── scope.md        ← Boundaries
├── conventions.md  ← Style rules
│
├── prompts/        ← Task templates
├── workflows/      ← Multi-step procedures
├── commands/       ← Atomic operations
├── context/        ← Glossary, dependencies
│
├── progress/       ← log.md, tasks.json
├── checklists/     ← Quality gates
├── templates/      ← Boilerplate for new content
├── examples/       ← Reference patterns
│
├── .humans/        ← Human docs (IGNORE)
├── .inbox/         ← Staging (IGNORE, created as needed)
└── .archive/       ← Deprecated (IGNORE, created as needed)
```

## Boot Sequence

1. **Read `scope.md`** → Know boundaries
2. **Read `conventions.md`** → Know style rules
3. **Read `progress/log.md`** → Know what's been done
4. **Read `progress/tasks.json`** → Know current priorities
5. **Begin** highest-priority unblocked task
6. **Before finishing:** Update `progress/log.md`, verify against `checklists/done.md`

## Off-Limits (Never Read)

| Directory | Reason |
|-----------|--------|
| `.humans/` | Human documentation, not agent instructions |
| `.inbox/` | Unprocessed, unvetted materials |
| `.archive/` | Outdated, deprecated content |

## When Stuck

- Check `progress/tasks.json` for blocked items and their blockers
- Review `prompts/` for relevant task templates
- If truly blocked, document the blocker in `progress/log.md` and stop
