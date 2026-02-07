---
title: Create Project
description: Scaffold a new project in projects/.
access: human
---

# Create Project

Scaffold a new project with isolated scope, memory, and continuity.

## Usage

```text
/research <slug>
```

**Example:**
```text
/research agent-memory-patterns
```

## Prerequisites

- Project slug must be lowercase with hyphens (e.g., `auth-patterns`)
- No existing project with the same slug in `projects/`

## Steps

1. **Validate slug**
   - Must be lowercase with hyphens only (`^[a-z][a-z0-9-]*$`)
   - Must not already exist in `projects/`
   - If invalid → STOP, report error with valid format

2. **Copy template**
   - Copy `projects/_template/` to `projects/<slug>/`

3. **Initialize project.md**
   - Replace `[topic]` with the slug (human-readable form)
   - Set `started:` to today's date (YYYY-MM-DD)
   - Set `last_activity:` to today's date

4. **Initialize log.md**
   - Replace `[topic]` with the slug
   - Add creation entry with today's date

5. **Update registry**
   - Add row to **Active** table in `projects/registry.md`:
     ```markdown
     | [<slug>](./<slug>/) | [Pending goal] | YYYY-MM-DD | YYYY-MM-DD |
     ```
   - Remove placeholder row if present

6. **Prompt for goal** (interactive)
   - Ask: "What is the goal of this project?"
   - Update Goal section in `project.md` with response
   - Update registry entry with goal summary

7. **Confirm**
   - Report: "Created project: `<slug>`"
   - List files created
   - Suggest next steps

## Output

A new project directory ready for work:

```text
projects/<slug>/
├── project.md     # Ready for scope/questions definition
├── log.md         # Creation entry logged
└── resources.md   # Workspace resource references
```

## The Funnel

Projects sit in a pipeline from ideas to executed work:

```
ideation/scratchpad/ideas/      → Quick captures (most die here)
        ↓
ideation/scratchpad/brainstorm/ → Structured exploration (filter stage)
        ↓
projects/               → Committed research (produces artifacts)
        ↓
missions/               → Committed execution
        ↓
context/                → Permanent knowledge
```

## Next Steps After Creation

1. Refine the goal in `project.md`
2. Define scope (in/out of scope)
3. Add key questions to answer
4. Begin research, logging progress in `log.md`

## Related

- [Projects](../../../docs/architecture/workspaces/projects.md) — Full documentation
- [Registry](../../projects/registry.md) — Project tracking
- [Brainstorm](../../ideation/scratchpad/brainstorm/README.md) — Upstream exploration
