---
title: Start Here
description: Boot sequence and orientation for the root .harmony harness.
---

# .harmony: Start Here

## Inheritance

This workspace extends `.harmony/` for shared infrastructure.

| Component | Local (Project-Specific) | Shared (in `.harmony/`) |
|-----------|--------------------------|-------------------------|
| Assistants | `.harmony/agency/assistants/` | `.harmony/agency/assistants/` |
| Templates | `.harmony/scaffolding/templates/` | `.harmony/scaffolding/templates/` |
| Workflows | `.harmony/orchestration/workflows/` | `.harmony/orchestration/workflows/` |
| Skills | `.harmony/capabilities/skills/` | `.harmony/capabilities/skills/` |
| Commands | `.harmony/capabilities/commands/` | `.harmony/capabilities/commands/` |
| Prompts | `.harmony/scaffolding/prompts/` | `.harmony/scaffolding/prompts/` |
| Context | `.harmony/cognition/context/` | `.harmony/cognition/context/` |
| Checklists | `.harmony/quality/` | `.harmony/quality/` |

**Resolution:** All resources now live under `.harmony/`.

---

## Structure

```text
.harmony/
├── START.md        ← You are here
├── scope.md        ← Boundaries
├── conventions.md  ← Style rules
├── catalog.md      ← Available operations
│
├── agency/
│   └── assistants/     ← Focused specialists (@mention invocation)
│
├── capabilities/
│   ├── skills/         ← Composable capabilities
│   └── commands/       ← Atomic operations
│
├── cognition/
│   └── context/        ← Decisions, lessons, glossary
│
├── continuity/         ← log.md, tasks.json, entities.json
│
├── orchestration/
│   ├── workflows/      ← Multi-step procedures
│   └── missions/       ← Time-bounded sub-projects
│
├── scaffolding/
│   ├── templates/      ← Boilerplate for new content
│   ├── prompts/        ← Task templates
│   └── examples/       ← Reference patterns
│
├── quality/            ← complete.md, session-exit.md
│
├── ideation/           ← Human-led zone (IGNORE)
│   ├── scratchpad/     ← Temporary staging (inbox/, archive/, etc.)
│   └── projects/       ← Committed research
│
└── output/             ← Reports, drafts, artifacts
```

## Boot Sequence

1. **Read `scope.md`** → Know boundaries
2. **Read `conventions.md`** → Know style rules
3. **Scan `catalog.md`** → Know available operations and assistants
4. **Read `continuity/log.md`** → Know what's been done
5. **Read `continuity/tasks.json`** → Know current priorities
6. **Check `orchestration/missions/registry.yml`** → Know active missions (if any)
7. **Begin** highest-priority unblocked task
8. **Before finishing:** Complete `quality/session-exit.md`, verify against `quality/complete.md`

## Assistants

Assistants are focused specialists available via `@mention`:

- `@reviewer` / `@rev` — Code review
- `@refactor` / `@ref` — Code restructuring
- `@docs` / `@doc` — Documentation

See `assistants/registry.yml` for full list and `catalog.md` for details.

## Visibility & Autonomy Rules

Two directories are **human-led**. Agents MUST NOT access them autonomously.

| Directory              | Purpose                          | Autonomy           |
|------------------------|----------------------------------|--------------------|
| `ideation/projects/`   | Human-led explorations           | **Human-led only** |
| `ideation/scratchpad/` | Ephemeral content and idea funnel | **Human-led only** |

**Scratchpad subdirectories (`ideation/scratchpad/`):** `inbox/` (staging), `archive/` (deprecated), `brainstorm/` (exploration), `ideas/`, `drafts/`, `daily/`.

### Human-Led Collaboration

Agents MAY access `ideation/projects/` or `ideation/scratchpad/` ONLY when:

1. Human explicitly points to specific file(s)
2. Human requests a concrete change
3. Agent work stays scoped to referenced files

**During autonomous operation:** Treat these paths as if they do not exist.

---

## The Funnel

Ideas flow from ephemeral scratchpad to committed work:

```
ideation/scratchpad/ideas/      → Quick captures (most die here)
        ↓
ideation/scratchpad/brainstorm/ → Structured exploration (filter stage)
        ↓
ideation/projects/              → Committed research (produces artifacts)
        ↓
orchestration/missions/         → Committed execution
        ↓
cognition/context/              → Permanent knowledge
```

---

## Where Things Go

| Content | Destination | Lifecycle |
|---------|-------------|-----------|
| External imports, raw drops | `ideation/scratchpad/inbox/` | Temporary → triage → move out |
| Quick ideas | `ideation/scratchpad/ideas/` | May graduate or die |
| Ideas worth exploring | `ideation/scratchpad/brainstorm/` | Graduate to projects or kill |
| Committed research | `ideation/projects/<slug>/` | Until findings published |
| Deprecated content | `ideation/scratchpad/archive/` | Permanent reference |
| Finalized decisions | `cognition/context/decisions.md` | Permanent |
| Constraints, non-negotiables | `cognition/context/constraints.md` | Permanent |
| Next actions | `continuity/next.md` | Active |
| Domain terminology | `cognition/context/glossary.md` | Reference |
| Lessons learned | `cognition/context/lessons.md` | Reference |

**Publishing findings:** Project findings flow directly to `context/` files without a separate promotion step.

---

## When Stuck

- Check `continuity/tasks.json` for blocked items and their blockers
- Check `cognition/context/lessons.md` for anti-patterns to avoid
- Check `cognition/context/decisions.md` for relevant past decisions
- Review `scaffolding/prompts/` for relevant task templates
- If truly blocked, document the blocker in `continuity/log.md` and stop
