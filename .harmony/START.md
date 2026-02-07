---
title: Start Here
description: Boot sequence and orientation for the root .workspace harness.
---

# .workspace: Start Here

## Inheritance

This workspace extends `.harmony/` for shared infrastructure.

| Component | Local (Project-Specific) | Shared (in `.harmony/`) |
|-----------|--------------------------|-------------------------|
| Assistants | `.workspace/assistants/` | `.harmony/assistants/` |
| Templates | `.workspace/templates/` | `.harmony/templates/` |
| Workflows | `.workspace/workflows/` | `.harmony/workflows/` |
| Skills | `.workspace/skills/` | `.harmony/skills/` |
| Commands | `.workspace/commands/` | `.harmony/commands/` |
| Prompts | `.workspace/prompts/` | `.harmony/prompts/` |
| Context | `.workspace/context/` | `.harmony/context/` |
| Checklists | `.workspace/checklists/` | `.harmony/checklists/` |

**Resolution:** Local overrides shared. Check `.workspace/` first, then `.harmony/`.

---

## Structure

```text
.workspace/
├── START.md        ← You are here
├── scope.md        ← Boundaries
├── conventions.md  ← Style rules
├── catalog.md      ← Available operations
│
├── assistants/     ← Focused specialists (@mention invocation)
├── missions/       ← Time-bounded sub-projects (agent-accessible)
├── projects/       ← Human-led explorations (produces artifacts)
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
└── .scratchpad/    ← Human-led zone (IGNORE)
    ├── inbox/      ← Temporary staging
    ├── archive/    ← Deprecated content
    ├── brainstorm/ ← Ideas under exploration
    ├── ideas/      ← Quick captures
    └── ...
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

Two directories are **human-led**. Agents MUST NOT access them autonomously.

| Directory | Purpose | Autonomy |
|-----------|---------|----------|
| `projects/` | Human-led explorations | **Human-led only** |
| `.scratchpad/` | Ephemeral content and idea funnel | **Human-led only** |

**Scratchpad subdirectories:** `inbox/` (staging), `archive/` (deprecated), `brainstorm/` (exploration), `ideas/`, `drafts/`, `daily/`.

### Human-Led Collaboration

Agents MAY access `projects/` or `.scratchpad/` ONLY when:

1. Human explicitly points to specific file(s)
2. Human requests a concrete change
3. Agent work stays scoped to referenced files

**During autonomous operation:** Treat these paths as if they do not exist.

---

## The Funnel

Ideas flow from ephemeral scratchpad to committed work:

```
.scratchpad/ideas/      → Quick captures (most die here)
        ↓
.scratchpad/brainstorm/ → Structured exploration (filter stage)
        ↓
projects/               → Committed research (produces artifacts)
        ↓
missions/               → Committed execution
        ↓
context/                → Permanent knowledge
```

---

## Where Things Go

| Content | Destination | Lifecycle |
|---------|-------------|-----------|
| External imports, raw drops | `.scratchpad/inbox/` | Temporary → triage → move out |
| Quick ideas | `.scratchpad/ideas/` | May graduate or die |
| Ideas worth exploring | `.scratchpad/brainstorm/` | Graduate to projects or kill |
| Committed research | `projects/<slug>/` | Until findings published |
| Deprecated content | `.scratchpad/archive/` | Permanent reference |
| Finalized decisions | `context/decisions.md` | Permanent |
| Constraints, non-negotiables | `context/constraints.md` | Permanent |
| Next actions | `progress/next.md` | Active |
| Domain terminology | `context/glossary.md` | Reference |
| Lessons learned | `context/lessons.md` | Reference |

**Publishing findings:** Project findings flow directly to `context/` files without a separate promotion step.

---

## When Stuck

- Check `progress/tasks.json` for blocked items and their blockers
- Check `context/lessons.md` for anti-patterns to avoid
- Check `context/decisions.md` for relevant past decisions
- Review `prompts/` for relevant task templates
- If truly blocked, document the blocker in `progress/log.md` and stop
