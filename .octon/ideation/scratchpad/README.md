---
title: Human-Led Zone
description: The single human-led directory for thinking, staging, and archives.
---

# .scratchpad/: Human-Led Zone

This directory consolidates all **human-led content** — a space where humans can explore ideas, stage imports, archive deprecated content, and collaborate with agents under explicit direction.

---

## Structure

```text
.scratchpad/
├── README.md       # You are here
├── inbox/          # Temporary staging for imports
├── archive/        # Deprecated content
├── brainstorm/     # Ideas under structured exploration
├── ideas/          # Quick captures and possibilities
├── daily/          # Date-based notes (YYYY-MM-DD.md)
├── drafts/         # Work-in-progress documents
└── clips/          # Snippets and fragments
```

---

## The Funnel

Ideas flow from raw captures to committed work:

```
.scratchpad/                    .octon/
┌─────────────────────┐        ┌─────────────────────┐
│ ideas/              │        │ ideation/projects/  │
│ (quick captures)    │───────▶│ (committed research)│
│         ↓           │        │         ↓           │
│ brainstorm/         │────┘   │ orchestration/      │
│ (explore before     │        │   missions/         │
│  committing)        │        │         ↓           │
└─────────────────────┘        │ cognition/runtime/context/  │
                               │ (permanent knowledge)│
                               └─────────────────────┘
```

| Stage | Location | Purpose | Graduation |
|-------|----------|---------|------------|
| Capture | `ideas/` | Quick notes, "what if" | → `brainstorm/` or die |
| Explore | `brainstorm/` | Validate before committing | → `projects/` or kill |
| Research | `projects/` | Committed exploration | → `context/` or `missions/` |
| Execute | `missions/` | Committed execution | → shipped work |

Most ideas die in `ideas/`. That's the point — low friction capture, aggressive filtering.

---

## Subdirectory Purposes

| Subdirectory | Purpose | Lifecycle |
|--------------|---------|-----------|
| `inbox/` | Temporary staging for external imports | Move out when processed |
| `archive/` | Deprecated content retained for reference | Permanent |
| `brainstorm/` | Ideas under structured exploration | Graduate or kill |
| `ideas/` | Quick captures, possibilities | May graduate or die |
| `daily/` | Date-based notes (YYYY-MM-DD.md) | Reference |
| `drafts/` | Work-in-progress documents | Promote when ready |
| `clips/` | Snippets, quotes, code fragments | Reference |

---

## Autonomy Rules

**This directory is human-led. Agents must not access it autonomously.**

| Rule | Description |
|------|-------------|
| **No autonomous access** | Agents MUST NOT scan, read, or write to `.scratchpad/**` during autonomous operation |
| **Human-directed only** | Agents MAY read/edit files here ONLY when a human explicitly points to specific files AND requests specific changes |
| **Scoped edits** | When directed, agent work stays scoped to the referenced files |
| **Invisible to agents** | During autonomous operation, agents behave as if this path does not exist |

### When an Agent May Assist

Agents can help with `.scratchpad/` content when ALL of these are true:

1. Human explicitly references a specific file (e.g., "look at `.scratchpad/brainstorm/auth.md`")
2. Human requests a concrete action (e.g., "summarize this", "add X to the list")
3. Agent's work stays within the referenced files

### Example: Valid Collaboration

```text
Human: "Review .scratchpad/brainstorm/new-feature.md and help clarify the key questions"
Agent: [Reads the specific file, provides help as directed]
```

### Example: Invalid Autonomous Action

```text
Agent: "I noticed some interesting notes in .scratchpad/ideas.md that might help..."
→ VIOLATION: Agent scanned .scratchpad/ without explicit human direction
```

---

## inbox/: Temporary Staging

Use `inbox/` for:

- External imports (PDFs, screenshots, copied content)
- Rough drops (quick notes, voice transcripts)
- Untriaged artifacts pending review

**Lifecycle:** Items should eventually move out or be deleted. Unlike other subdirectories, `inbox/` content is temporary.

---

## archive/: Deprecated Content

Use `archive/` for:

- Outdated content preserved for historical reference
- Superseded workflows or prompts
- Materials that shouldn't inform current work

**Lifecycle:** Permanent reference. Delete periodically if no longer needed. Consider date prefixes: `2024-01-15-old-workflow.md`.

---

## brainstorm/: Structured Exploration

Use `brainstorm/` to explore ideas before committing to full projects.

### When to Use

| Scenario | Use Brainstorm? | Alternative |
|----------|-----------------|-------------|
| Idea worth more than a note | Yes | — |
| Need to validate before committing | Yes | — |
| Quick thought, low stakes | No | Keep in `ideas/` |
| Already confident it's worth pursuing | No | Create project directly |

### Format

Single file per topic (not directories). See `brainstorm/README.md` for template.

### Lifecycle

```
Created → Exploring → Verdict
                        ├── Graduated → projects/
                        ├── Killed → delete or archive
                        └── Parked → revisit later
```

---

## ideas/: Quick Captures

Use `ideas/` for:

- One-liner thoughts
- "What if" explorations
- Unfiltered brainstorming

**When to graduate:** If you find yourself adding substantial structure or spending multiple sessions, move to `brainstorm/`.

---

## Relationship to Workspace

```
.octon/
├── ideation/
│   ├── projects/        # Graduated from brainstorm/
│   └── scratchpad/      # Human-led zone (you are here)
│       ├── brainstorm/  # Pre-project exploration
│       ├── ideas/       # Raw captures
│       └── ...
├── orchestration/
│   └── missions/        # Execution workstreams
├── cognition/
│   └── context/         # Permanent knowledge
└── continuity/          # Session tracking
```

Projects have graduated from scratchpad to workspace-level because they frequently produce artifacts that feed the main workspace. The scratchpad now focuses on truly ephemeral content and the early-stage funnel (`ideas/` → `brainstorm/`).

---

## Git Hygiene

**Default:** This directory structure and README are committed to share the convention.

**Content:** Individual notes (especially `daily/`) may be personal. Options:

1. **Commit everything** — Team shares research openly
2. **Selective gitignore** — Add `daily/*.md` to `.gitignore` if notes are personal
3. **Keep structure only** — `.gitkeep` files preserve directories without content

---

## See Also

- [`.octon/START.md`](../START.md) — Boot sequence with visibility rules
- [`.octon/ideation/projects/`](../projects/README.md) — Graduated exploration space
- [`docs/architecture/workspaces/scratchpad.md`](../../../docs/architecture/workspaces/scratchpad.md) — Full architecture documentation
