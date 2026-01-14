---
title: Workspace Workflows
description: Workspace-scoped multi-step procedures defined in .workspace/workflows/.
---

# Workspace Workflows

Workspace workflows are **workspace-scoped multi-step procedures** defined in `.workspace/workflows/`. They operate on artifacts in the workspace's parent directory.

> **Not FlowKit flows:** `packages/workflows/<flowId>/` contains **FlowKit flow assets** (config + manifest + prompts) executed by FlowKit + the LangGraph runtime. `.workspace/workflows/**` contains **procedures** an agent follows. The seam is `/run-flow`, which delegates to `.workspace/workflows/flowkit/run-flow/*` and runs `@packages/workflows/<flowId>/config.flow.json`.

---

## Universal Harness-Agnostic Pattern

Workspace workflows are designed to be **portable across all AI harnesses**—Cursor, Claude Code, Codex, or any future tool. The pattern separates concerns:

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
│              .workspace/workflows/<name>/                  │
│                                                            │
│   Universal workflow with portable steps that work         │
│   regardless of which harness invokes them                 │
└────────────────────────────────────────────────────────────┘
```

### Design Principles

| Principle | Description |
|-----------|-------------|
| **Workflows are the source of truth** | All execution logic lives in `.workspace/workflows/` |
| **Harness entry points are thin wrappers** | `.cursor/commands/`, `.claude/commands/`, etc. only provide syntax and delegation |
| **No harness-specific logic in workflows** | Workflows should work identically regardless of invoking harness |
| **Workspace is portable** | Copy a `.workspace/` to any repo, and it works with any harness |

### Implementing the Pattern

**1. Create the workflow (source of truth):**

```text
.workspace/workflows/<category>/<name>/
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

See `.workspace/workflows/<category>/<name>/00-overview.md` for full description and steps.

## Usage

\`\`\`text
/command-name <args>
\`\`\`

## Implementation

Execute the workflow in `.workspace/workflows/<category>/<name>/`.

Start with `00-overview.md` and follow each step in sequence.

## References

- **Workflow:** `.workspace/workflows/<category>/<name>/`
```

For other harnesses, create equivalent wrappers in their respective directories (e.g., `.claude/commands/`, `.codex/commands/`).

### Example: Create Project Workflow

**Workflow (source of truth):**
`.workspace/workflows/projects/create-project.md`

**Cursor wrapper:**
`.cursor/commands/research.md` → Points to workflow

**Claude Code wrapper (if needed):**
`.claude/commands/research.md` → Points to same workflow

Both invoke the identical workflow, ensuring consistent behavior.

---

## Invocation

Workspace workflows can be invoked in multiple ways:

| Method | Trigger | Example |
|--------|---------|---------|
| **Direct** | Agent references the workflow | Agent reads `.workspace/workflows/publish-to-docs/00-overview.md` |
| **Wrapped (Cursor)** | User types `/command` in Cursor | `/create-workspace` via `.cursor/commands/` |
| **Wrapped (Claude Code)** | User types `/command` in Claude Code | `/create-workspace` via `.claude/commands/` |
| **Wrapped (Codex)** | User invokes command in Codex | Via `.codex/commands/` |
| **Wrapped (Any Harness)** | Harness-specific entry point | Via `.<harness>/commands/` |

When wrapped by a harness-specific command, the workflow gains that harness's integration features (e.g., autocomplete in Cursor, slash commands in Claude Code).

---

## Structure

Simple workflows can be single files. Complex workflows use subdirectories with numbered step files:

```text
.workspace/workflows/my-workflow/
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

> This frontmatter contract applies to `.workspace/workflows/**` only. FlowKit canonical prompts under `packages/workflows/**` intentionally keep frontmatter minimal; wiring and semantics live in `config.flow.json` and `manifest.yaml`.

---

## Example: Workspace Management Workflows

The workspace management commands demonstrate the **Cursor Command → Workflow** pattern:

| Cursor Command | Delegates To | Purpose |
|----------------|--------------|---------|
| `/create-workspace` | `.workspace/workflows/workspace/create-workspace/` | Scaffold a new `.workspace` directory |
| `/update-workspace` | `.workspace/workflows/workspace/update-workspace/` | Align with canonical definition |
| `/evaluate-workspace` | `.workspace/workflows/workspace/evaluate-workspace/` | Assess token efficiency |

Each workflow subdirectory contains numbered step files for the agent to follow sequentially.

### Architecture

| Layer | Location | Purpose |
|-------|----------|---------|
| **Entry points** | `.<harness>/commands/*.md` | Harness-specific wrappers (Cursor, Claude Code, Codex, etc.) |
| **Implementation** | `.workspace/workflows/<category>/<name>/` | Multi-step procedure the agent executes (source of truth) |
| **Templates** | `.workspace/templates/` | Boilerplate for scaffolding |

### Usage Examples

**Create a new workspace:**

```text
/create-workspace @path/to/target/directory
```

**Update an existing workspace:**

```text
/update-workspace @path/to/.workspace
```

Or for the root workspace:

```text
/update-workspace @.workspace
```

**Evaluate a workspace (read-only):**

```text
/evaluate-workspace @.workspace
```

Or for a nested workspace:

```text
/evaluate-workspace @docs/my-feature/.workspace
```

> **Note:** Workspace management uses the **Harness Entry Point → Workflow** pattern. The workflow is the source of truth; harness-specific commands (`.cursor/commands/`, `.claude/commands/`, etc.) are thin wrappers that provide IDE integration.

---

## See Also

- [Taxonomy](./taxonomy.md) — Harness entry points, workspace commands, workflows, and their relationships
- [Workspace Commands](./commands.md) — Workspace-scoped atomic operations
- [README.md](./README.md) — Canonical workspace structure reference
