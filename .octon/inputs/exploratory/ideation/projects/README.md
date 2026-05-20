---
title: Projects
description: Human-led explorations that may inform governed work.
---

# Projects

Projects are **human-led explorations** that may inform governed Octon work.
They provide isolated scope, memory, and continuity for structured research
spanning multiple sessions. Project material remains non-authoritative input
until a separate governed proposal, plan, Change, retained evidence update, or
durable authored edit outside `inputs/**` promotes the relevant findings.

---

## Projects vs. Missions

| Aspect | Project | Mission |
|--------|---------|---------|
| **Purpose** | Divergent exploration | Convergent execution |
| **Autonomy** | Human-led | Agent-accessible |
| **Output** | Insights, decisions, learnings | Completed deliverables |
| **Trigger** | Questions to answer | Work to execute |
| **Lifecycle** | Open-ended | Time-bounded |

**Decision heuristic:**
- Need to **investigate or explore** something? → Project
- Need to **execute and deliver** something? → Mission

---

## The Funnel

Projects sit in a pipeline from raw ideas to executed work:

```
ideation/scratchpad/ideas/      Quick captures (most ephemeral)
        ↓
ideation/scratchpad/brainstorm/ Structured exploration (filter stage)
        ↓
ideation/projects/              Committed research (non-authoritative input)
        ↓
governed proposal, plan, Change, retained evidence update, or durable edit
        ↓
durable surface outside inputs/** after validation and evidence
```

Most ideas die in `ideas/`. Some graduate to `brainstorm/`. Survivors become
projects. Projects may inform a governed proposal, plan, Change, retained
evidence update, or durable authored edit outside `inputs/**`.

---

## Directory Structure

```text
projects/
├── README.md           # You are here
├── registry.md         # Index of all projects by status
├── _scaffold/template/          # Template for new projects
│   ├── project.md
│   ├── log.md
│   └── resources.md
└── <project-slug>/     # Active project
    ├── project.md      # Goal, scope, questions, findings
    ├── log.md          # Session progress notes
    ├── resources.md    # Links to useful workspace resources
    └── [additional files as needed]
```

---

## Autonomy Rules

Projects are **human-led**. Agents assist only when explicitly directed.

| Mode | Agent Behavior |
|------|----------------|
| **Autonomous** | MUST NOT scan or autonomously access `projects/` |
| **Human-directed** | MAY access specific files when human explicitly points to them |

### Valid Collaboration

```text
Human: "Review projects/auth-research/findings.md and help organize"
Agent: [Reads specific file, assists as directed]
```

### Invalid Autonomous Action

```text
Agent: "I found relevant notes in projects/..."
→ VIOLATION: Agent scanned projects/ without human direction
```

---

## Project Lifecycle

```
Created → Active → Completed → Archived
              ↘ Paused → Active (resume)
```

| Status | Description |
|--------|-------------|
| **Active** | Research in progress |
| **Paused** | Temporarily on hold (document reason) |
| **Completed** | Governed route chosen and outcome recorded |

Required route: governed proposal, plan, Change, retained evidence update, or durable authored edit outside `inputs/**`.

---

## Creating a Project

### Via Command

```text
/research <slug>
```

### From Brainstorm

When a brainstorm graduates:
1. Copy `_scaffold/template/` to `projects/<slug>/`
2. Transfer context from brainstorm file
3. Add entry to `registry.md` under **Active**
4. Archive or delete the brainstorm file

### Manually

1. Copy `_scaffold/template/` to `projects/<slug>/`
2. Fill in `project.md` with goal, scope, and key questions
3. Add entry to `registry.md` under **Active**
4. Begin research, logging progress in `log.md`

---

## During Research

| Activity | How |
|----------|-----|
| Log progress | Update `log.md` at end of each session |
| Track findings | Summarize insights in `project.md` as you go |
| Update registry | Keep `Last Activity` current |
| Use workspace resources | Leverage assistants and prompts via `resources.md` |

---

## Completing Research

When findings are ready:

1. **Summarize findings** in `project.md` Findings Summary section
2. **Choose a governed route** — proposal, plan, Change, retained evidence
   update, or durable authored edit outside `inputs/**`
3. **Record validation and evidence** required by that governed route
4. **Move registry entry** from **Active** to **Completed**
5. **Note outcomes** — what route consumed the findings and where durable
   output landed

Projects remain non-authoritative input. Findings become durable only through a
separate governed proposal, plan, Change, retained evidence update, or durable
authored edit outside `inputs/**`.

---

## See Also

- [`ideation/scratchpad/brainstorm/`](../scratchpad/brainstorm/README.md) — Pre-project exploration
- [`docs/architecture/workspaces/projects.md`](../../docs/architecture/workspaces/projects.md) — Full architecture documentation
