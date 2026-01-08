---
title: Start Here
description: Boot sequence and orientation for the root .workspace harness.
---

# .workspace: Start Here

## Structure

```text
.workspace/
├── START.md        ← You are here
├── scope.md        ← Boundaries
├── conventions.md  ← Style rules
├── catalog.md      ← Available operations
│
├── assistants/     ← Focused specialists (@mention invocation)
├── missions/       ← Time-bounded sub-projects
│
├── prompts/        ← Task templates
├── workflows/      ← Multi-step procedures
├── commands/       ← Atomic operations
├── context/        ← Decisions, lessons, glossary
│
├── progress/       ← log.md, tasks.json, entities.json
├── checklists/     ← complete.md, session-exit.md
├── templates/      ← Boilerplate for new content
├── examples/       ← Reference patterns
│
├── .humans/        ← Human docs (IGNORE)
├── .scratch/       ← Human thinking/research (IGNORE)
├── .inbox/         ← Human staging (IGNORE)
└── .archive/       ← Deprecated (IGNORE)
```

## Boot Sequence

1. **Read `scope.md`** → Know boundaries
2. **Read `conventions.md`** → Know style rules
3. **Scan `catalog.md`** → Know available operations and assistants
4. **Read `progress/log.md`** → Know what's been done
5. **Read `progress/tasks.json`** → Know current priorities
6. **Check `missions/registry.yml`** → Know active missions (if any)
7. **Begin** highest-priority unblocked task
8. **Before finishing:** Complete `checklists/session-exit.md`, verify against `checklists/complete.md`

## Assistants

Assistants are focused specialists available via `@mention`:

- `@reviewer` / `@rev` — Code review
- `@refactor` / `@ref` — Code restructuring
- `@docs` / `@doc` — Documentation

See `assistants/registry.yml` for full list and `catalog.md` for details.

## Visibility & Autonomy Rules

Dot-prefixed directories are **human-led zones**. Agents MUST NOT access them autonomously.

| Directory | Purpose | Autonomy |
|-----------|---------|----------|
| `.humans/` | Human documentation | **Never access** |
| `.scratch/` | Persistent thinking/research | **Human-led only** |
| `.inbox/` | Temporary staging for imports | **Human-led only** |
| `.archive/` | Deprecated content | **Never access** |

### Human-Led Collaboration

Agents MAY access `.scratch/` and `.inbox/` ONLY when:

1. Human explicitly points to specific file(s)
2. Human requests a concrete change
3. Agent work stays scoped to referenced files

**During autonomous operation:** Treat these paths as if they do not exist.

---

## Where Things Go

| Content | Destination | Lifecycle |
|---------|-------------|-----------|
| External imports, raw drops | `.inbox/` | Temporary → triage → move out |
| Thinking, research, drafts | `.scratch/` | Persistent (may stay indefinitely) |
| Finalized decisions | `context/decisions.md` | Permanent |
| Constraints, non-negotiables | `context/constraints.md` | Permanent |
| Next actions | `progress/next.md` | Active |
| Domain terminology | `context/glossary.md` | Reference |
| Lessons learned | `context/lessons.md` | Reference |

**Promote workflow:** When `.scratch/` content matures, use `workflows/promote-from-scratch.md` to publish to agent-facing artifacts.

---

## When Stuck

- Check `progress/tasks.json` for blocked items and their blockers
- Check `context/lessons.md` for anti-patterns to avoid
- Check `context/decisions.md` for relevant past decisions
- Review `prompts/` for relevant task templates
- If truly blocked, document the blocker in `progress/log.md` and stop
