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

When an agent starts working in `docs/harmony/ai/methodology/`, it can immediately find relevant context in `.workspace/` without searching the entire repository. This is critical because:

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
│
├── prompts/              # Reusable task templates
├── workflows/            # Multi-step procedures
├── commands/             # Single-action instructions
├── context/              # Background knowledge (glossary, dependencies)
│
├── progress/             # Session-to-session continuity
│   ├── log.md            # What's been done (append-only)
│   └── tasks.json        # Structured task list with status
│
├── checklists/           # Verification and quality gates
│   └── done.md           # Definition of done, quality criteria
│
├── templates/            # Boilerplate for new content
├── examples/             # Reference patterns (minimal, copyable)
│
├── .humans/              # Human-facing documentation (AGENTS: IGNORE)
│   ├── README.md         # This file - design rationale
│   ├── onboarding/       # How to contribute
│   ├── decisions/        # ADRs
│   ├── rationale/        # Deep explanations
│   └── examples/         # Detailed walkthroughs
│
├── .inbox/               # Unprocessed materials (AGENTS: IGNORE, created as needed)
└── .archive/             # Deprecated content (AGENTS: IGNORE, created as needed)
```

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

The "ignore dot-prefixed" convention applies **inside** `.workspace`, not to `.workspace` itself. Three directories within `.workspace` are explicitly **off-limits to agents**:

| Directory | Purpose | Why agents ignore it |
|-----------|---------|----------------------|
| `.humans/` | Design rationale and human documentation | Explanatory content, not actionable instructions |
| `.inbox/` | Staging area for unprocessed materials | Content is unvetted and may be incomplete or irrelevant |
| `.archive/` | Historical materials retained for reference | Content is outdated and should not inform current work |

**Agents should:**

- Never read from `.humans/`, `.inbox/`, or `.archive/` when gathering context
- Never write to these directories
- Never reference content from these directories in their work

**Humans use these directories to:**

- Understand design decisions and rationale (`.humans/`)
- Stage materials for later review (`.inbox/`)
- Preserve institutional memory without cluttering active content (`.archive/`)

---

## Design Rationale

### Root-Level Files

The root-level files form an **orientation layer**—the first things an agent reads before diving into subdirectories.

| File | Purpose |
|------|---------|
| `START.md` | Boot sequence, prerequisites, first actions |
| `scope.md` | Boundaries, in/out of scope, decision authority |
| `conventions.md` | Style rules, terminology, formatting standards |

### Root-Level Directories (Agent-Facing)

| Directory | Purpose |
|-----------|---------|
| `prompts/` | Reusable task templates for common operations |
| `workflows/` | Multi-step procedures (e.g., "add new document") |
| `commands/` | Atomic operations (e.g., "format for publication") |
| `context/` | Background knowledge: glossary, dependencies |
| `progress/` | Session continuity: log.md, tasks.json |
| `checklists/` | Quality gates: done.md |
| `templates/` | Boilerplate for creating new content |
| `examples/` | Minimal, copyable reference patterns |

### Dot-Prefixed Directories (Human-Facing)

| Directory | Purpose |
|-----------|---------|
| `.humans/` | Design rationale, onboarding, ADRs, detailed examples |
| `.inbox/` | Staging area for unprocessed materials |
| `.archive/` | Deprecated content retained for reference |

---

## Benefits of This Approach

1. **Agent Efficiency** — An agent reads `START.md` and immediately knows how to begin useful work

2. **Human-Agent Parity** — The same structure helps human developers; it's onboarding documentation that also works for agents

3. **Incremental Adoption** — Start with high-churn areas; the convention scales as needed

4. **Domain Specialization** — Each area can define its own checklists, workflows, and prompts

5. **Reduced "One-Shotting"** — Explicit task lists and incremental workflows guide agents toward smaller, verifiable steps

6. **One Simple Rule** — Dot prefix = ignore. No wrapper directories needed.

---

## The Meta-Pattern

What we're developing is essentially a **recursive documentation pattern**:

- The main content is the *what*
- The `.workspace` is the *how* and *why* of working on that content

This mirrors how effective engineering teams operate: not just code, but runbooks, playbooks, and institutional knowledge that lives close to the code it supports.

The `.workspace` directory formalizes this for the age of AI agents, creating a **co-located harness** that enables effective, incremental, well-tested work across context windows.

---

## Token Budget Guidelines

For agent-facing content (everything without dot prefix):

| Scope             | Target   | Max   |
|-------------------|----------|-------|
| Total harness     | ~2,000    | ~5,000 |
| Single file       | ~300      | ~500   |
| START.md (boot)   | ~200      | ~300   |

**Rationale:** A compact harness leaves maximum context window for actual work while forcing discipline about what's truly essential.

---

## Available Commands

Cursor slash commands for working with `.workspace` directories.

| Command | Purpose |
|---------|---------|
| `/create-workspace` | Scaffold a new `.workspace` in a target directory |
| `/evaluate-workspace` | Evaluate a `.workspace` for token efficiency |

---

### `/create-workspace`

Scaffold a new `.workspace` directory in a target location, customized to the directory's context.

**Usage:**

```
/create-workspace @path/to/target/directory
```

**What it does:**

1. **Validates** the target directory exists
2. **Analyzes** directory context:
   - Identifies type (code, docs, config, hybrid)
   - Detects naming conventions, style configs
   - Finds key files and entry points
3. **Gathers** context from you:
   - Scope description
   - In-scope/out-of-scope work
   - Quality checks required
   - Setup prerequisites
4. **Creates** the `.workspace/` structure
5. **Customizes** templates based on analysis:
   - `scope.md` — Your scope + detected boundaries
   - `conventions.md` — Detected patterns + domain rules
   - `done.md` — Detected quality gates (tests, lint, build)
   - `START.md` — Setup steps + key entry points
   - `tasks.json` — Context-appropriate initial tasks

**Example:**

```
/create-workspace @packages/ui-kit/
```

The agent will analyze `packages/ui-kit/`, detect it's a Node/TypeScript project, find test configs, and ask you about scope before generating customized workspace files.

**Files created:**

```text
.workspace/
├── START.md          ← Customized boot sequence
├── scope.md          ← Your scope + boundaries
├── conventions.md    ← Detected patterns
├── progress/
│   ├── log.md        ← Creation context
│   └── tasks.json    ← Context-appropriate tasks
└── checklists/
    └── done.md       ← Detected quality gates
```

**Reference:** 
- Command: `.cursor/commands/create-workspace.md`
- Workflow: `.workspace/workflows/create-workspace.md`
- Templates: `.workspace/templates/`

---

### `/evaluate-workspace`

Evaluate a `.workspace` directory for token efficiency and agent effectiveness.

**Usage:**

```
/evaluate-workspace @.workspace
```

Or for a nested workspace:

```
/evaluate-workspace @docs/my-feature/.workspace
```

**What it does:**

1. Reads all agent-facing files in the target `.workspace`
2. Assesses each file for essentiality, efficiency, redundancy
3. Estimates token counts against budgets
4. Produces an evaluation report with recommendations

**Output sections:**

1. Token Analysis — Files with estimated tokens vs budget
2. Keep — Elements to retain
3. Cut/Merge — Elements to consolidate
4. Move to `.humans/` — Human-facing content
5. Minimal structure — Proposed lean structure
6. Gaps — Missing essential elements

**Reference:**
- Command: `.cursor/commands/evaluate-workspace.md`
- Prompt: `.workspace/prompts/evaluate-workspace.md`
