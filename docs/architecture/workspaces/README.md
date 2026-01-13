---
title: The .workspace Directory
description: Canonical reference for the localized agent harness pattern.
---

# The `.workspace` Directory: A Localized Agent Harness

## Terminology

| Term | Meaning |
|------|---------|
| Harness | The `.workspace` support structure |
| Boot sequence | Steps to orient and begin work |
| Cold start | First session without prior context |
| Token budget | Maximum tokens for agent-facing content |

---

## Core Concept

A `.workspace` directory is a **co-located support structure** that contains everything needed to effectively work on a specific area of your project. It's the "working memory" and "instruction set" for that part of the codebase—useful to both human developers and AI agents.

The key insight: **context should live close to where it's needed**.

Rather than maintaining a single, monolithic set of agent instructions at the repo root, `.workspace` directories allow you to create **domain-specific harnesses** tailored to the unique needs of each area.

---

## Why Locality Matters

1. **Scoped Context Reduces Noise**

When an agent starts working in `docs/ai/methodology/`, it can immediately find relevant context in `.workspace/` without searching the entire repository. This is critical because:

- Agents have limited context windows
- Irrelevant context dilutes attention
- Domain-specific instructions are more precise than generic ones

2. **Different Areas Have Different Needs**

Your methodology documentation has different workflows than, say, a React component library or an API service. A `.workspace` directory lets you define:

- Area-specific checklists and quality criteria
- Relevant style guides and conventions
- Tailored prompts for common tasks
- Domain-appropriate verification steps

3. **Discoverability**

An agent (or human) landing in a directory can immediately ask: "Is there a `.workspace` here?" If yes, they know exactly where to find context, instructions, and progress tracking. It's a **convention that scales**.

4. **Encapsulation of Working State**

Agents struggle when they "arrive with no memory of what came before." A `.workspace` directory provides a persistent location for:

- Progress tracking across sessions
- Work-in-progress artifacts
- Decision logs and rationale

---

## Full Structure Reference

```text
.workspace/
├── START.md              # Boot sequence (read first)
├── scope.md              # Boundaries and responsibilities
├── conventions.md        # Style and formatting rules
├── catalog.md            # Index of commands and workflows
│
├── assistants/           # Focused specialists (serve agents/humans)
│   ├── registry.yml      # @mention mappings
│   ├── _template/        # New assistant template
│   │   └── assistant.md
│   └── <name>/
│       └── assistant.md  # Specialist definition
│
├── missions/             # Time-bounded sub-projects
│   ├── registry.yml      # Active/archived index
│   ├── _template/        # New mission template
│   └── <mission-slug>/
│       ├── mission.md    # Goal, scope, owner
│       ├── tasks.json    # Mission-specific tasks
│       └── log.md        # Mission-specific progress
│
├── skills/               # Composable capabilities
│   ├── registry.yml      # Skill catalog (progressive disclosure)
│   ├── _template/        # New skill template
│   │   └── skill.md
│   ├── <skill-id>/       # Individual skills
│   │   └── skill.md      # Skill definition
│   ├── sources/          # Standard input folder
│   ├── outputs/          # Standard output folders
│   └── logs/runs/        # Execution logs
│
├── prompts/              # Reusable task templates
├── workflows/            # Multi-step procedures
├── commands/             # Atomic operations
├── context/              # Background knowledge and memory
│   ├── decisions.md      # Agent-readable decision summaries
│   ├── lessons.md        # Anti-patterns and failures to avoid
│   ├── glossary.md       # Domain-specific terminology
│   └── ...               # dependencies.md, constraints.md
│
├── progress/             # Session-to-session continuity
│   ├── log.md            # What's been done (append-only)
│   ├── tasks.json        # Structured task list with goal
│   └── entities.json     # Entity state tracking (optional)
│
├── checklists/           # Verification and quality gates
│   ├── complete.md           # Definition of done, quality criteria
│   └── session-exit.md   # Steps before ending a session
│
├── templates/            # Boilerplate for new content
├── examples/             # Reference patterns (minimal, copyable)
│
├── .humans/              # Human-facing documentation (AGENTS: NEVER ACCESS)
│   ├── README.md         # This file - design rationale
│   ├── onboarding/       # How to contribute
│   ├── decisions/        # Full ADRs (agent-readable summaries in context/)
│   ├── rationale/        # Deep explanations
│   └── examples/         # Detailed walkthroughs
│
├── .scratch/             # Human-led thinking/research (AGENTS: HUMAN-LED ONLY)
│   ├── README.md         # Purpose, rules, publish workflow
│   ├── projects/         # Isolated research projects
│   │   ├── registry.md
│   │   ├── _template/
│   │   └── <project-slug>/
│   ├── ideas/            # Brainstorming, possibilities
│   ├── daily/            # Date-based notes (YYYY-MM-DD.md)
│   ├── drafts/           # Work-in-progress documents
│   └── clips/            # Snippets and fragments
│
├── .inbox/               # Human-led staging (AGENTS: HUMAN-LED ONLY)
└── .archive/             # Deprecated content (AGENTS: NEVER ACCESS)
```

### Structure Categorization

| Category | Items | Description |
|----------|-------|-------------|
| **Required** | `START.md`, `scope.md`, `conventions.md`, `catalog.md`, `progress/`, `checklists/complete.md`, `prompts/`, `workflows/`, `commands/`, `context/` | MUST exist in every workspace |
| **Recommended** | `checklists/session-exit.md` | SHOULD exist for session continuity |
| **Standard** | `templates/`, `examples/`, `assistants/`, `missions/` | Create as needed for the workspace's use case |
| **Agent-ignored** | `.humans/`, `.scratch/`, `.inbox/`, `.archive/` | Dot-prefixed; agents MUST NOT access autonomously |

---

## The Flat Structure Philosophy

Everything at root level (without dot prefix) is **agent-facing**. Everything with a dot prefix is **agent-ignored**.

| Prefix | Meaning |
|--------|---------|
| No dot | Agent reads this |
| Dot (`.`) | Agent ignores this |

This single rule eliminates the need for a wrapper directory like `agents/`. The entire `.workspace` root is the agent's domain—except for dot-prefixed directories.

---

## Agent Ignore Convention

### Why `.workspace` itself is dot-prefixed

The `.workspace` directory uses a dot prefix to signal "supporting infrastructure, not primary content." This follows conventions like `.git/`, `.vscode/`, and `.github/`—directories that tooling actively uses but that aren't the main content of a project.

**Agents should actively look for `.workspace`** when starting work in an area. The dot prefix indicates "this is where you find your harness," not "ignore this."

### Dot-prefixed directories *within* `.workspace`

The "ignore dot-prefixed" convention applies **inside** `.workspace`, not to `.workspace` itself. Four directories within `.workspace` are **off-limits to autonomous agents**:

| Directory | Purpose | Autonomy Level |
|-----------|---------|----------------|
| `.humans/` | Design rationale and human documentation | **Never access** |
| `.scratch/` | Persistent thinking, research, drafts | **Human-led only** |
| `.inbox/` | Temporary staging for external imports | **Human-led only** |
| `.archive/` | Historical materials retained for reference | **Never access** |

#### Never-Access Directories

Agents MUST NOT read, write, or reference content from `.humans/` or `.archive/` under any circumstances.

#### Human-Led Directories

`.scratch/` and `.inbox/` have a special collaboration mode:

| Rule | Description |
|------|-------------|
| **No autonomous access** | Agents MUST NOT scan, read, or write during autonomous operation |
| **Human-directed only** | Agents MAY access ONLY when a human explicitly points to specific files AND requests specific changes |
| **Scoped work** | When directed, agent work stays within the referenced files |

**Example: Valid collaboration**

```text
Human: "Review .scratch/projects/auth-research/findings.md and summarize"
Agent: [Reads the specific file, provides summary as directed]
```

**Example: Invalid autonomous action**

```text
Agent: "I noticed some relevant notes in .scratch/ that might help..."
→ VIOLATION: Agent scanned .scratch/ without explicit human direction
```

#### Human Use of These Directories

- **`.humans/`** — Understand design decisions and rationale
- **`.scratch/`** — Persistent thinking, research, collaborative drafting
- **`.inbox/`** — Temporary staging for external imports (move out when processed)
- **`.archive/`** — Preserve institutional memory without cluttering active content

#### Promotion Workflow

When content in `.scratch/` matures, humans promote distilled insights to agent-facing locations using the `workflows/promote-from-scratch.md` workflow.

| Scratch Content | Promotes To |
|-----------------|-------------|
| Finalized decisions | `context/decisions.md` |
| Non-negotiables | `context/constraints.md` |
| Domain terms | `context/glossary.md` |
| Next actions | `progress/next.md` |

**Rule:** Never copy raw scratch verbatim. Always summarize and distill.

---

## Design Rationale

### Root-Level Files

The root-level files form an **orientation layer**—the first things an agent reads before diving into subdirectories.

| File | Purpose |
|------|---------|
| `START.md` | Boot sequence, prerequisites, first actions |
| `scope.md` | Boundaries, in/out of scope, decision authority |
| `conventions.md` | Style rules, terminology, formatting standards |
| `catalog.md` | Index of available commands and workflows in this workspace |

### Root-Level Directories (Agent-Facing)

| Directory | Purpose |
|-----------|---------|
| `assistants/` | Focused specialists invoked via @mention or delegation |
| `missions/` | Time-bounded sub-projects with isolated progress |
| `prompts/` | Reusable task templates for common operations |
| `workflows/` | Multi-step procedures (e.g., "add new document") |
| `commands/` | Workspace-specific atomic operations (e.g., "format for publication") |
| `context/` | Background knowledge: glossary, dependencies |
| `progress/` | Session continuity: log.md, tasks.json |
| `checklists/` | Quality gates: complete.md |
| `templates/` | Boilerplate for creating new content |
| `examples/` | Minimal, copyable reference patterns |

### Dot-Prefixed Directories (Human-Facing)

| Directory | Purpose | Autonomy |
|-----------|---------|----------|
| `.humans/` | Design rationale, onboarding, ADRs | Never access |
| `.scratch/` | Persistent thinking, research, drafts | Human-led only |
| `.inbox/` | Temporary staging for imports | Human-led only |
| `.archive/` | Deprecated content retained for reference | Never access |

See [Dot-Prefixed Directories](./dot-files.md) for detailed autonomy rules.

---

## Benefits of This Approach

1. **Agent Efficiency** — An agent reads `START.md` and immediately knows how to begin useful work

2. **Human-Agent Parity** — The same structure helps human developers; it's onboarding documentation that also works for agents

3. **Incremental Adoption** — Start with high-churn areas; the convention scales as needed

4. **Domain Specialization** — Each area can define its own checklists, workflows, and prompts

5. **Reduced "One-Shotting"** — Explicit task lists and incremental workflows guide agents toward smaller, verifiable steps

6. **One Simple Rule** — Dot prefix = ignore. No wrapper directories needed.

---

## When to Create a Workspace

Not every directory needs a `.workspace`. Use this guide to decide.

### Create a workspace when

| Situation | Why it helps |
|-----------|--------------|
| **Large monorepo with distinct areas** | Each area gets scoped context; agents don't load irrelevant instructions |
| **Multi-session or long-running tasks** | Progress tracking survives context window resets |
| **Complex constraints or conventions** | Domain-specific rules are captured where they're needed |
| **Multiple agents working in parallel** | Each area has its own task list and progress log |
| **High-churn areas** | Frequent work benefits from established patterns and checklists |
| **Areas with unique workflows** | Custom prompts and procedures live close to where they're used |

### Skip the workspace when

| Situation | Why it's overkill |
|-----------|-------------------|
| **Small, single-purpose repos** | A root README suffices |
| **One-shot tasks** | No continuity needed; just do the work |
| **Areas where a README suffices** | If scope/conventions/progress aren't complex, don't add ceremony |
| **Rarely touched directories** | Maintenance burden exceeds benefit |
| **Leaf directories with no sub-work** | A single file doesn't need a harness |

### Key strengths

| Strength | What it addresses |
|----------|-------------------|
| **Locality** | Guidance for X lives next to X—no hunting through centralized docs |
| **Scoped context** | Agent loads only relevant context, not the entire repo |
| **Continuity** | `progress/log.md` + `tasks.json` survive context resets |
| **Explicit boundaries** | `scope.md` prevents scope creep; agent knows when to stop |
| **Quality gates** | `complete.md` checklist prevents premature completion |
| **Separation** | Agent-facing vs human-facing is explicit (`.humans/`) |

### Risks to watch

| Risk | Mitigation |
|------|------------|
| **Proliferation** | Don't create workspaces everywhere—only where sustained agent work happens |
| **Drift** | Use the workspace Cursor rule to enforce consistency; consider a linter |
| **Maintenance burden** | Keep workspaces minimal; archive stale ones |
| **Discovery** | Cursor rules auto-trigger; boot sequence is standardized |
| **Duplication** | Factor shared content to a parent workspace or central location |

### The decision heuristic

Ask: **"Will an agent work here across multiple sessions, with domain-specific constraints?"**

- **Yes** → Create a workspace
- **No** → A README or inline comments suffice

---

## The Meta-Pattern

What we're developing is essentially a **recursive documentation pattern**:

- The main content is the *what*
- The `.workspace` is the *how* and *why* of working on that content

This mirrors how effective engineering teams operate: not just code, but runbooks, playbooks, and institutional knowledge that lives close to the code it supports.

The `.workspace` directory formalizes this for the age of AI agents, creating a **co-located harness** that enables effective, incremental, well-tested work across context windows.

---

## Universal Harness-Agnostic Pattern

Workspaces are designed to be **portable across all AI harnesses**—Cursor, Claude Code, Codex, or any future tool.

### Design Principle

```
┌────────────────────────────────────────────────────────────┐
│                     AI Harnesses                           │
├──────────────┬──────────────┬──────────────┬──────────────┤
│    Cursor    │  Claude Code │    Codex     │    Future    │
│  /command    │  /command    │  /command    │   /command   │
│              │              │              │              │
│  .cursor/    │  .claude/    │  .codex/     │  .<harness>/ │
│  commands/   │  commands/   │  commands/   │   commands/  │
└──────┬───────┴──────┬───────┴──────┬───────┴──────┬───────┘
       │              │              │              │
       ▼              ▼              ▼              ▼
┌────────────────────────────────────────────────────────────┐
│              .workspace/workflows/<name>/                  │
│                                                            │
│   Source of truth — same workflow for all harnesses        │
└────────────────────────────────────────────────────────────┘
```

| Principle | Description |
|-----------|-------------|
| **Workflows are the source of truth** | All execution logic lives in `.workspace/workflows/` |
| **Harness entry points are thin wrappers** | `.<harness>/commands/` only provides syntax and delegation |
| **No harness-specific logic in workflows** | Workflows work identically regardless of invoking harness |
| **Workspace is portable** | Copy a `.workspace/` to any repo, and it works with any harness |

See [workflows.md](./workflows.md) for the full implementation pattern.

---

## Harness Integration

### Cursor

The `.cursor/rules/workspace/RULE.md` provides context when editing `.workspace/` files. It:

- Triggers on glob pattern `**/.workspace/**`
- Points agents to canonical references
- Provides key principles and token budget guidelines
- Uses "Apply Intelligently" (not always-apply) to avoid unnecessary context in non-workspace sessions

### Harness Entry Points

Harness-specific commands wrap workspace workflows for integration:

| Command | Delegates To | Purpose |
|---------|--------------|---------|
| `/create-workspace` | `.workspace/workflows/workspace/create-workspace/` | Scaffold a new workspace |
| `/update-workspace` | `.workspace/workflows/workspace/update-workspace/` | Align with canonical definition |
| `/evaluate-workspace` | `.workspace/workflows/workspace/evaluate-workspace/` | Assess token efficiency |
| `/migrate-workspace` | `.workspace/workflows/workspace/migrate-workspace/` | Upgrade older workspace |
| `/research` | `.workspace/workflows/scratch/create-research-project/` | Create research project |
| `/bootstrap` | `.workspace/prompts/bootstrap-session.md` | Quick-start a session |

These commands live in `.<harness>/commands/` (e.g., `.cursor/commands/`, `.claude/commands/`) and are thin wrappers that point to the workflows.

---

## Token Budget Guidelines

See `.cursor/rules/workspace/RULE.md` for the authoritative token budget table that agents use when working with workspace files.

**Summary:** Target ~2,000 tokens total, ~300 per file, ~200 for START.md. A compact harness leaves maximum context window for actual work.

---

## Related Documentation

### Core Concepts

- [Taxonomy](./taxonomy.md) — Harness entry points, workspace commands, workflows, and their relationships
- [Workspace Workflows](./workflows.md) — Multi-step procedures and the Universal Harness-Agnostic Pattern
- [Workspace Commands](./commands.md) — Workspace-scoped atomic operations
- [Assistants](./assistants.md) — Focused specialists for scoped tasks
- [Missions](./missions.md) — Time-bounded sub-projects
- [Skills](./skills.md) — Composable capabilities with defined I/O

### Directory Documentation

- [Dot-Prefixed Directories](./dot-files.md) — `.humans/`, `.scratch/`, `.inbox/`, `.archive/` and autonomy rules
- [Scratch Area](./scratch.md) — Human-led thinking space with research projects
- [Research Projects](./projects.md) — Human-led, multi-session investigations
- [Prompts](./prompts.md) — Reusable task templates
- [Templates](./templates.md) — Boilerplate for new content
- [Examples](./examples.md) — Reference patterns
- [Progress](./progress.md) — Session continuity tracking
- [Context](./context.md) — Background knowledge
- [Checklists](./checklists.md) — Quality gates
- [Scripts](./scripts.md) — Shell utilities for workspace maintenance
