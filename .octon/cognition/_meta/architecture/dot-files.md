---
title: Human-Led Directories
description: The human-led zone within .octon/, with autonomy rules.
---

# Human-Led Directories

The `ideation/` directory within `.octon/` is **off-limits to autonomous agents**. It exists for human use, with human-led collaboration when explicitly directed.

## The Rule

| Directory | Meaning |
| --------- | ------- |
| Most `.octon/` directories | Agent reads and acts on this content |
| `ideation/` | Agent does not access autonomously |

## Ideation Subdirectories

Two directory types within `ideation/` require explicit human direction:

| Directory | Purpose | Autonomy Level |
| --------- | ------- | -------------- |
| `ideation/projects/` | Human-led explorations that produce artifacts | Human-led |
| `ideation/scratchpad/` | Ephemeral content and early-stage idea funnel | Human-led only |

### Why Projects Are Human-Led

Projects (`projects/`) are human-led explorations, not autonomous agent work. Agents assist with projects only when humans explicitly direct them to specific files. This preserves the exploratory, divergent nature of research while allowing findings to flow directly to harness artifacts.

### Human-Led Collaboration

Agents MAY assist with human-led content when ALL of these are true:

1. Human explicitly references a specific file (e.g., "look at `projects/auth-research/findings.md`")
2. Human requests a concrete action (e.g., "summarize this", "add X")
3. Agent's work stays within the referenced files

**During autonomous operation:** Treat `ideation/projects/` and `ideation/scratchpad/` as if they do not exist.

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
orchestration/runtime/missions/         → Committed execution
        ↓
cognition/runtime/context/              → Permanent knowledge
```

---

## `ideation/scratchpad/` Structure

```text
ideation/scratchpad/
├── README.md       # Purpose, rules
├── inbox/          # Temporary staging for imports
├── archive/        # Deprecated content
├── brainstorm/     # Ideas under structured exploration
├── ideas/          # Quick captures, possibilities
├── daily/          # Date-based notes (YYYY-MM-DD.md)
├── drafts/         # Work-in-progress documents
└── clips/          # Snippets and fragments
```

### Subdirectory Purposes

| Subdirectory | Purpose | Lifecycle |
|--------------|---------|-----------|
| `inbox/` | Temporary staging for external imports | Move out when processed |
| `archive/` | Deprecated content retained for reference | Permanent |
| `brainstorm/` | Ideas under structured exploration | Graduate to projects or kill |
| `ideas/` | Quick captures, possibilities | Graduate to brainstorm or die |
| `daily/` | Date-based notes (YYYY-MM-DD.md) | Reference |
| `drafts/` | Work-in-progress documents | Promote when ready |
| `clips/` | Snippets and fragments | Reference |

---

## When to Use Each

### `inbox/` — Temporary Staging

- External imports (PDFs, screenshots, copied content)
- Rough drops (quick notes, voice transcripts)
- Untriaged artifacts pending review

**Lifecycle:** Items should eventually move out or be deleted.

### `archive/` — Deprecated Content

- Outdated content preserved for historical reference
- Superseded workflows or prompts
- Materials that shouldn't inform current work

**Lifecycle:** Permanent reference. Delete periodically if no longer needed.

### `brainstorm/` — Structured Exploration

- Ideas worth more than a quick note
- Single-file exploration before committing to a project
- Filter stage: graduate to projects or kill

**Lifecycle:** Short-term. Graduate survivors to `projects/`, kill the rest.

### `ideas/`, `drafts/`, `daily/`, `clips/`

- Quick captures and brainstorming
- Work-in-progress before maturation
- Stream-of-consciousness notes

---

## Agent Behavior

| Mode | Behavior |
|------|----------|
| Autonomous | MUST NOT scan, read, or write to `ideation/projects/` or `ideation/scratchpad/**` |
| Human-directed | MAY read/edit specific files when human explicitly points to them |

---

## Publishing Findings

When project findings are ready:

| Content Type | Destination |
|--------------|-------------|
| Design decisions | `cognition/runtime/decisions/` (with generated summary in `cognition/runtime/context/decisions.md`) |
| Anti-patterns | `cognition/runtime/context/lessons.md` |
| New terminology | `cognition/runtime/context/glossary.md` |
| Actionable work | Create mission in `orchestration/runtime/missions/` |

Since projects live at harness level, findings flow directly to their destinations without a separate "promotion" step.

**Rule:** Summarize and distill findings; don't copy project notes verbatim.

---

## Why This Convention

1. **Simplicity** — One rule: "don't access `ideation/` autonomously"
2. **Token efficiency** — Agents don't waste context on human-led content
3. **Clear boundaries** — Human-led directories are clearly identified
4. **Human needs met** — Exploration and ephemeral content have their place
5. **Collaboration mode** — Human-directed access when explicitly requested

---

## Example Scenarios

### Scenario: External Import via Inbox

```text
1. Human imports research PDF → ideation/scratchpad/inbox/research-paper.pdf
2. Human: "Summarize ideation/scratchpad/inbox/research-paper.pdf"
3. Agent reads specific file, provides summary
4. Human extracts key insights
5. Human moves content to docs/research/paper-summary.md
6. Human deletes original from ideation/scratchpad/inbox/
```

### Scenario: Collaborative Research in Projects

```text
1. Human explores authentication options in ideation/projects/auth-options/
2. Human: "Review ideation/projects/auth-options/project.md and help organize findings"
3. Agent reads specific file, proposes organization
4. Human refines, makes decision
5. Human adds ADR under cognition/runtime/decisions/ and runs sync script
6. Human marks project completed in registry
```

### Scenario: Brainstorm to Project

```text
1. Human captures idea in ideation/scratchpad/ideas/new-feature.md
2. Human moves to ideation/scratchpad/brainstorm/new-feature.md for exploration
3. Human: "Help me think through the key questions in ideation/scratchpad/brainstorm/new-feature.md"
4. Agent assists with specific file
5. If idea graduates, human creates ideation/projects/new-feature/
6. Brainstorm file archived or deleted
```

### Scenario: Archiving Deprecated Content

```text
1. Workflow becomes outdated
2. Human moves to ideation/scratchpad/archive/2024-01-15-old-workflow.md
3. Agent never sees it during autonomous operation
4. Human can still reference it when needed
```

---

## Tooling Enforcement

The `octon.yml` file declares patterns that autonomous agents should exclude via the `human_led` section:

```text
.octon/ideation/scratchpad/**
.octon/ideation/projects/**
```

Tools that scan, index, or retrieve content should respect these patterns during autonomous operation. Human-directed sessions may override by explicitly referencing specific files.

---

## See Also

- [README.md](./README.md) — Canonical harness structure reference
- [Scratchpad](../../../ideation/_meta/architecture/scratchpad.md) — Ephemeral content and idea funnel
- [Projects](../../../ideation/_meta/architecture/projects.md) — Human-led explorations
- [Taxonomy](./taxonomy.md) — Command and workflow types
- `.octon/ideation/scratchpad/README.md` — Scratchpad details
- `.octon/ideation/projects/README.md` — Projects details
