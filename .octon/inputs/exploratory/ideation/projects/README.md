---
title: Projects
description: Human-led explorations that produce workspace artifacts.
---

# Projects

Projects are **human-led explorations** that produce artifacts feeding the main workspace. They provide isolated scope, memory, and continuity for structured research spanning multiple sessions.

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
ideation/projects/              Committed research (produces artifacts)
        ↓
orchestration/missions/         Committed execution (ships deliverables)
        ↓
cognition/runtime/context/              Permanent workspace knowledge
```

Most ideas die in `ideas/`. Some graduate to `brainstorm/`. Survivors become projects. Projects feed `cognition/runtime/context/` directly or spawn `orchestration/missions/`.

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
| **Completed** | Findings published to workspace |

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
2. **Publish to workspace** — update relevant `cognition/runtime/context/` files directly
3. **Spawn missions** if actionable work was identified
4. **Move registry entry** from **Active** to **Completed**
5. **Note outcomes** — what was published and where

Unlike the old scratchpad model, there's no separate "promotion" step. Projects live in the workspace, so findings flow directly to `cognition/runtime/context/decisions.md`, `cognition/runtime/context/lessons.md`, etc.

---

## See Also

- [`orchestration/missions/`](../../orchestration/missions/README.md) — Convergent execution workstreams
- [`ideation/scratchpad/brainstorm/`](../scratchpad/brainstorm/README.md) — Pre-project exploration
- [`cognition/runtime/context/`](../../cognition/runtime/context/) — Where findings get published
- [`docs/architecture/workspaces/projects.md`](../../docs/architecture/workspaces/projects.md) — Full architecture documentation
