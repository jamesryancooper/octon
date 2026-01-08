---
title: Dot-Prefixed Directories
description: Human-led and agent-ignored directories within a .workspace, with autonomy rules.
---

# Dot-Prefixed Directories

Directories within `.workspace/` that start with a dot (`.`) are **off-limits to autonomous agents**. They exist for human use, with some allowing human-led collaboration.

## The Rule

| Prefix | Meaning |
|--------|---------|
| No dot | Agent reads and acts on this content |
| Dot (`.`) | Agent does not access autonomously |

## Autonomy Levels

| Level | Directories | Description |
|-------|-------------|-------------|
| **Never access** | `.humans/`, `.archive/` | Agents must not read, write, or reference under any circumstances |
| **Human-led only** | `.scratch/`, `.inbox/` | Agents may access only when human explicitly directs to specific files |

### Human-Led Collaboration

For `.scratch/` and `.inbox/`, agents MAY assist when ALL of these are true:

1. Human explicitly references a specific file (e.g., "look at `.scratch/ideas.md`")
2. Human requests a concrete action (e.g., "summarize this", "add X")
3. Agent's work stays within the referenced files

**During autonomous operation:** Treat `.scratch/` and `.inbox/` as if they do not exist.

---

## `.humans/`

**Purpose:** Human-facing documentation that agents should never read.

### Structure

```text
.humans/
├── README.md       # Design rationale for the workspace
├── onboarding/     # How to contribute to this area
├── decisions/      # Architecture Decision Records (ADRs)
├── rationale/      # Deep explanations of design choices
└── examples/       # Detailed walkthroughs for humans
```

### When to Use

- Explaining *why* something works the way it does
- Onboarding new human contributors
- Recording decisions that agents don't need to execute
- Providing context that would bloat agent token budgets

### Agent Behavior

Agents MUST NOT:

- Read from `.humans/` when gathering context
- Reference `.humans/` content in their work
- Write to `.humans/`

---

## `.scratch/`

**Purpose:** Persistent human-led thinking, research, and collaboration space.

**Autonomy:** Human-led only.

### Structure

```text
.scratch/
├── README.md       # Purpose, rules, publish workflow
├── ideas/          # Brainstorming, possibilities
├── research/       # Collected findings, analysis
├── daily/          # Date-based notes (YYYY-MM-DD.md)
├── drafts/         # Work-in-progress documents
└── clips/          # Snippets and fragments
```

### When to Use

- Exploring ideas before committing to a direction
- Collecting research and analysis
- Drafting content that isn't ready for agent consumption
- Daily notes and stream-of-consciousness thinking

### Agent Behavior

| Mode | Behavior |
|------|----------|
| Autonomous | MUST NOT scan, read, or write to `.scratch/**` |
| Human-directed | MAY read/edit specific files when human explicitly points to them |

### Lifecycle

1. Human adds thinking, research, or drafts to `.scratch/`
2. Content may remain indefinitely (this is persistent space)
3. When content matures, human promotes to agent-facing locations
4. Use `workflows/promote-from-scratch.md` for structured promotion

### Promotion Workflow

When insights mature, promote distilled summaries to:

| Content Type | Destination |
|--------------|-------------|
| Finalized decisions | `context/decisions.md` |
| Non-negotiables | `context/constraints.md` |
| Domain terms | `context/glossary.md` |
| Next actions | `progress/next.md` |

**Rule:** Never copy raw scratch verbatim. Always summarize and distill.

---

## `.inbox/`

**Purpose:** Temporary staging area for external imports and untriaged artifacts.

**Autonomy:** Human-led only.

### When to Use

- External imports (PDFs, screenshots, copied content)
- Rough drops (quick notes, voice transcripts)
- Untriaged artifacts pending review
- Work-in-progress inputs

### Agent Behavior

| Mode | Behavior |
|------|----------|
| Autonomous | MUST NOT scan, read, or write to `.inbox/**` |
| Human-directed | MAY read/edit specific files when human explicitly points to them |

### Lifecycle

1. Human adds material to `.inbox/`
2. Human reviews and triages material
3. Processed content moves to canonical location (often outside `.workspace/`)
4. Delete or archive processed items

**Key principle:** Items in `.inbox/` are **temporary**. Unlike `.scratch/`, content should eventually move out.

### Difference from `.scratch/`

| Aspect | `.inbox/` | `.scratch/` |
|--------|-----------|-------------|
| Purpose | Temporary staging | Persistent thinking |
| Lifecycle | Move out → delete | May remain indefinitely |
| Content origin | External imports | Internal exploration |
| Destination | Usually outside `.workspace/` | Often `context/` files |

---

## `.archive/`

**Purpose:** Deprecated content retained for reference.

### When to Use

- Preserving outdated content for historical reference
- Retaining superseded workflows or prompts
- Keeping materials that might be useful later but shouldn't inform current work

### Agent Behavior

Agents MUST NOT:

- Read from `.archive/` (content is outdated)
- Write to `.archive/`
- Reference `.archive/` content

### Lifecycle

1. Content becomes outdated or superseded
2. Move to `.archive/` with optional date prefix: `2024-01-15-old-workflow.md`
3. Delete periodically if no longer needed

---

## Why This Convention

1. **Token efficiency** — Agents don't waste context on explanatory content
2. **Clear boundaries** — Simple rules determine what agents access
3. **Human needs met** — Humans have space for thinking, staging, and history
4. **Collaboration mode** — Human-led directories enable explicit collaboration without autonomous scanning
5. **No confusion** — The dot prefix is a universal "handle with care" signal

---

## Example Scenarios

### Scenario: External Import via Inbox

```text
1. Human imports research PDF → .inbox/research-paper.pdf
2. Human: "Summarize .inbox/research-paper.pdf"
3. Agent reads specific file, provides summary
4. Human extracts key insights
5. Human moves content to docs/research/paper-summary.md
6. Human deletes original from .inbox/
```

### Scenario: Collaborative Research in Scratch

```text
1. Human explores authentication options in .scratch/research.md
2. Human: "Review .scratch/research.md and help organize findings"
3. Agent reads specific file, proposes organization
4. Human refines, makes decision
5. Human promotes to context/decisions.md using promote workflow
6. Original research remains in .scratch/ for reference
```

---

## Tooling Enforcement

The `.workspace/agent-autonomy-guard.globs` file contains patterns that autonomous agents should exclude:

```text
.workspace/.scratch/**
.workspace/.inbox/**
.workspace/.humans/**
.workspace/.archive/**
```

Tools that scan, index, or retrieve content should respect these patterns during autonomous operation. Human-directed sessions may override by explicitly referencing specific files.

---

## See Also

- [README.md](./README.md) — Canonical workspace structure reference
- [Taxonomy](./taxonomy.md) — Command and workflow types
- `.workspace/.scratch/README.md` — Scratchpad details and promotion workflow
- `.workspace/.inbox/README.md` — Inbox lifecycle and triage
- `.workspace/workflows/promote-from-scratch.md` — Publishing workflow