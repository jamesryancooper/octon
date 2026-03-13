---
title: Brainstorm
description: Structured exploration of ideas before committing to full projects.
---

# Brainstorm

The brainstorm directory is a **filter stage** between raw ideas and committed projects. Use it to explore whether an idea is worth the investment of a full project.

---

## The Funnel

```
ideas/        →  brainstorm/  →  projects/
(capture)        (explore)       (commit)
```

| Stage | Purpose | Effort | Survival Rate |
|-------|---------|--------|---------------|
| `ideas/` | Quick capture | Minimal | ~10% graduate |
| `brainstorm/` | Structured exploration | Light | ~30% graduate |
| `projects/` | Full research | Significant | Most complete |

---

## When to Brainstorm

| Scenario | Use Brainstorm? | Alternative |
|----------|-----------------|-------------|
| Idea worth more than a note | Yes | — |
| Need to validate before committing | Yes | — |
| Multi-session exploration likely | Maybe | Skip to project |
| Quick thought, low stakes | No | Keep in `ideas/` |
| Already confident it's worth pursuing | No | Create project directly |

---

## Brainstorm Format

Each brainstorm is a **single file** (not a directory). Keep it lightweight.

```text
brainstorm/
├── README.md                    # You are here
├── <topic-slug>.md              # Active brainstorm
├── <another-topic>.md           # Another brainstorm
└── ...
```

### Template

```markdown
---
topic: [topic name]
created: YYYY-MM-DD
status: exploring | graduated | killed | parked
---

# Brainstorm: [Topic]

## The Idea

[What's the core idea? What triggered this exploration?]

## Why It Might Matter

[What's the potential value? Why is this worth thinking about?]

## Exploration Notes

[Free-form notes as you explore. What are you learning?]

### [Date]
- [Note]
- [Note]

### [Date]
- [Note]

## Key Questions

- [Question that needs answering]
- [Question that needs answering]

## Verdict

**Status:** [exploring | graduated | killed | parked]

**Reasoning:** [Why this verdict?]

**Next:**
- [ ] [If graduating] Create project: `projects/<slug>/`
- [ ] [If killing] Archive or delete this file
- [ ] [If parking] Note when to revisit
```

---

## Lifecycle

```
Created → Exploring → Verdict
                        ├── Graduated → projects/
                        ├── Killed → delete or archive
                        └── Parked → revisit later
```

| Status | Meaning |
|--------|---------|
| **exploring** | Actively thinking about this |
| **graduated** | Worth a full project — create one |
| **killed** | Not worth pursuing — archive or delete |
| **parked** | Interesting but not now — revisit later |

---

## Graduating to Project

When a brainstorm graduates:

1. Create project directory: `projects/<slug>/`
2. Copy `_scaffold/template/` files into it
3. Transfer relevant context from brainstorm
4. Update brainstorm status to `graduated`
5. Add entry to `projects/registry.md`
6. Optionally delete brainstorm file (project is the record now)

---

## Best Practices

- **Stay lightweight** — Brainstorms are single files, not directories
- **Time-box exploration** — If you're spending multiple sessions, graduate to project
- **Be willing to kill** — Most ideas shouldn't become projects
- **Capture reasoning** — Future you will want to know why you killed/parked something
- **Don't over-structure** — This is thinking space, not documentation

---

## See Also

- [`ideas/`](../ideas/README.md) — Raw idea capture (upstream)
- [`projects/`](../../projects/README.md) — Committed research (downstream)
