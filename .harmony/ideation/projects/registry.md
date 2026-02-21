# Projects

This registry tracks active, paused, and completed projects.

---

## Active

| Project | Goal | Started | Last Activity |
|---------|------|---------|---------------|
| — | *No active projects* | — | — |

---

## Paused

| Project | Goal | Paused Reason |
|---------|------|---------------|
| — | *No paused projects* | — |

---

## Completed

| Project | Goal | Completed | Outcomes |
|---------|------|-----------|----------|
| — | *No completed projects* | — | — |

---

## How to Use

### Starting a New Project

**Via command (works in any AI harness):**
```text
/research <slug>
```

**From brainstorm:**
1. When a brainstorm graduates, copy `_scaffold/template/` to `projects/<slug>/`
2. Transfer context from the brainstorm file
3. Add entry to **Active** table above

**Manually:**
1. Copy `_scaffold/template/` to `projects/<slug>/`
2. Fill in `project.md` with goal, scope, and key questions
3. Add entry to **Active** table above
4. Begin research, logging progress in `log.md`

### During Research

- Update `log.md` with session notes
- Create additional files as needed (`sources.md`, `notes/`, etc.)
- Update `Last Activity` in registry

### Completing Research

1. Summarize findings in `project.md`
2. Publish findings directly to `cognition/runtime/context/` files
3. Spawn missions if actionable work was identified
4. Move entry from **Active** to **Completed**
5. Note outcomes (where findings went)

### Pausing Research

1. Document pause reason in `project.md`
2. Move entry from **Active** to **Paused**
3. Resume by moving back to **Active**
