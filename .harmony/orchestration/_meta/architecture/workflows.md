---
title: Harness Workflows
description: Harness-scoped multi-step procedures defined in .harmony/orchestration/workflows/.
---

# Harness Workflows

Harness workflows are **harness-scoped multi-step procedures** defined in `.harmony/orchestration/workflows/`. They operate on artifacts in the harness's parent directory.

> **Not FlowKit flows:** `<flow-assets>/<flowId>/` contains **FlowKit flow assets** (config + manifest + prompts) executed by FlowKit + the LangGraph runtime. `.harmony/orchestration/workflows/**` contains **procedures** an agent follows. The seam is `/run-flow`, which delegates to `.harmony/orchestration/workflows/flowkit/run-flow/*` and runs `@path/to/config.flow.json`.

---

## Universal Harness-Agnostic Pattern

Harness workflows are designed to be **portable across all AI harnesses**—Cursor, Claude Code, Codex, or any future tool. The pattern separates concerns:

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
       │              │              │              │
       ▼              ▼              ▼              ▼
┌────────────────────────────────────────────────────────────┐
│              .harmony/orchestration/workflows/<name>/                  │
│                                                            │
│   Universal workflow with portable steps that work         │
│   regardless of which harness invokes them                 │
└────────────────────────────────────────────────────────────┘
```

### Design Principles

| Principle | Description |
|-----------|-------------|
| **Workflows are the source of truth** | All execution logic lives in `.harmony/orchestration/workflows/` |
| **Harness entry points are thin wrappers** | `.cursor/commands/`, `.claude/commands/`, etc. only provide syntax and delegation |
| **No harness-specific logic in workflows** | Workflows should work identically regardless of invoking harness |
| **Harness is portable** | Copy a `.harmony/` to any repo, and it works with any harness |

### Implementing the Pattern

**1. Create the workflow (source of truth):**

```text
.harmony/orchestration/workflows/<category>/<name>/
├── 00-overview.md     # Purpose, prereqs, steps, references
├── 01-step-one.md     # First step (if multi-step)
├── 02-step-two.md     # Second step
└── ...
```

**2. Create thin harness wrappers (entry points):**

For Cursor:
```text
.cursor/commands/<name>.md
```

```markdown
# Command Name `/command-name`

Brief description.

See `.harmony/orchestration/workflows/<category>/<name>/00-overview.md` for full description and steps.

## Usage

\`\`\`text
/command-name <args>
\`\`\`

## Implementation

Execute the workflow in `.harmony/orchestration/workflows/<category>/<name>/`.

Start with `00-overview.md` and follow each step in sequence.

## References

- **Workflow:** `.harmony/orchestration/workflows/<category>/<name>/`
```

For other harnesses, create equivalent wrappers in their respective directories (e.g., `.claude/commands/`, `.codex/commands/`).

### Example: Create Project Workflow

**Workflow (source of truth):**
`.harmony/orchestration/workflows/projects/create-project.md`

**Cursor wrapper:**
`.cursor/commands/research.md` → Points to workflow

**Claude Code wrapper (if needed):**
`.claude/commands/research.md` → Points to same workflow

Both invoke the identical workflow, ensuring consistent behavior.

---

## Invocation

Harness workflows can be invoked in multiple ways:

| Method | Trigger | Example |
|--------|---------|---------|
| **Direct** | Agent references the workflow | Agent reads `.harmony/orchestration/workflows/publish-to-docs/00-overview.md` |
| **Wrapped (Cursor)** | User types `/command` in Cursor | `/create-harness` via `.cursor/commands/` |
| **Wrapped (Claude Code)** | User types `/command` in Claude Code | `/create-harness` via `.claude/commands/` |
| **Wrapped (Codex)** | User invokes command in Codex | Via `.codex/commands/` |
| **Wrapped (Any Harness)** | Harness-specific entry point | Via `.<harness>/commands/` |

When wrapped by a harness-specific command, the workflow gains that harness's integration features (e.g., autocomplete in Cursor, slash commands in Claude Code).

---

## Structure

Simple workflows can be single files. Complex workflows use subdirectories with numbered step files:

```text
.harmony/orchestration/workflows/my-workflow/
├── 00-overview.md
├── 01-first-step.md
├── 02-second-step.md
└── 03-final-step.md
```

The `00-overview.md` file should contain:

- Purpose description
- Target specification
- Prerequisites
- Failure conditions
- Step list with links
- References

### Frontmatter Requirements

Workflow overview files (`00-overview.md`) require YAML frontmatter:

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Workflow title |
| `description` | Yes | Brief summary (max 160 characters) |
| `access` | Yes | `human` (has Cursor command wrapper) or `agent` (agent-only) |

> This frontmatter contract applies to `.harmony/orchestration/workflows/**` only. FlowKit canonical prompts under `<flow-assets>/**` intentionally keep frontmatter minimal; wiring and semantics live in `config.flow.json` and `manifest.yaml`.

---

## Example: Harness Management Workflows

The harness management commands demonstrate the **Cursor Command → Workflow** pattern:

| Cursor Command | Delegates To | Purpose |
|----------------|--------------|---------|
| `/create-harness` | `.harmony/orchestration/workflows/meta/create-harness/` | Scaffold a new `.harmony` directory |
| `/update-harness` | `.harmony/orchestration/workflows/meta/update-harness/` | Align with canonical definition |
| `/evaluate-harness` | `.harmony/orchestration/workflows/meta/evaluate-harness/` | Assess token efficiency |

Each workflow subdirectory contains numbered step files for the agent to follow sequentially.

### Architecture

| Layer | Location | Purpose |
|-------|----------|---------|
| **Entry points** | `.<harness>/commands/*.md` | Harness-specific wrappers (Cursor, Claude Code, Codex, etc.) |
| **Implementation** | `.harmony/orchestration/workflows/<category>/<name>/` | Multi-step procedure the agent executes (source of truth) |
| **Templates** | `.harmony/scaffolding/templates/` | Boilerplate for scaffolding |

### Usage Examples

**Create a new harness:**

```text
/create-harness @path/to/target/directory
```

**Update an existing harness:**

```text
/update-harness @path/to/.harmony
```

Or for the root harness:

```text
/update-harness @.harmony
```

**Evaluate a harness (read-only):**

```text
/evaluate-harness @.harmony
```

Or for a nested harness:

```text
/evaluate-harness @docs/my-feature/.harmony
```

> **Note:** Harness management uses the **Harness Entry Point → Workflow** pattern. The workflow is the source of truth; harness-specific commands (`.cursor/commands/`, `.claude/commands/`, etc.) are thin wrappers that provide IDE integration.

---

## See Also

- [Taxonomy](../../../cognition/_meta/architecture/taxonomy.md) — Harness entry points, harness commands, workflows, and their relationships
- [Harness Commands](../../../capabilities/_meta/architecture/commands.md) — Harness-scoped atomic operations
- [README.md](./README.md) — Canonical harness structure reference
