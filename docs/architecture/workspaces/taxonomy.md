---
title: Workspace Artifact Taxonomy
description: Classification of commands, workflows, prompts, and their relationships.
---

# Workspace Artifact Taxonomy

This document clarifies the distinctions between workspace artifact types: **commands**, **workflows**, **prompts**, and their relationship to **Cursor commands**. It also calls out **FlowKit flow assets** because they can look similar to workspace workflows but are owned and executed differently.

---

## Quick Reference

| Type | Location | Nature | When to Use |
|------|----------|--------|-------------|
| **Harness Entry Point** | `.<harness>/commands/` | Thin wrapper | Harness-specific invocation (Cursor, Claude Code, Codex) |
| **Workspace Command** | `.harmony/capabilities/commands/` | Deterministic procedure | Atomic, repeatable operation |
| **Workspace Workflow** | `.harmony/orchestration/workflows/` | Multi-step procedure (source of truth) | Complex, sequential operation |
| **Workspace Prompt** | `.harmony/scaffolding/prompts/` | Task template | Context-dependent, requires judgment |
| **Workspace Skill** | `.harmony/capabilities/skills/` | Composable capability | Defined I/O, pipelines, auditability |
| **Assistant** | `.harmony/agency/assistants/` | Focused specialist | Scoped, delegatable tasks |
| **Mission** | `.harmony/orchestration/missions/` | Sub-project | Isolated, time-bounded work |
| **FlowKit Flow (repo-wide)** | `packages/workflows/` | Runnable flow assets | Needs FlowKit runtime/CI/Studio execution |

---

## The Key Distinctions

### Executable vs Template

| Category | Types | Characteristics |
|----------|-------|-----------------|
| **Executable** | Commands, Workflows | Agent follows steps exactly; deterministic output |
| **Template** | Prompts | Agent adapts to situation; output varies |

### Atomic vs Multi-Step

| Category | Types | Characteristics |
|----------|-------|-----------------|
| **Atomic** | Commands | Single action; completes in one operation |
| **Multi-Step** | Workflows | Sequential steps; may span multiple actions |

---

## Terminology

| Term | Location | Triggered By | Scope |
|------|----------|--------------|-------|
| **Harness Entry Point** | `.<harness>/commands/` | User typing `/command` in any AI harness | Repository-wide, harness-specific |
| **Workspace Command** | `.harmony/capabilities/commands/` | Harness delegation or direct agent reference | Workspace-specific, atomic |
| **Workspace Workflow** | `.harmony/orchestration/workflows/` | Harness delegation or direct agent reference | Workspace-specific, multi-step |
| **Workspace Prompt** | `.harmony/scaffolding/prompts/` | Direct agent reference | Workspace-specific, template |
| **FlowKit Flow** | `packages/workflows/` | `pnpm flowkit:run packages/workflows/<flowId>/config.flow.json` or `/run-flow @packages/workflows/<flowId>/config.flow.json` | Repository-wide |

### Supported Harnesses

| Harness | Entry Point Location | Integration |
|---------|---------------------|-------------|
| **Cursor** | `.cursor/commands/` | Slash commands, autocomplete |
| **Claude Code** | `.claude/commands/` | Slash commands |
| **Codex** | `.codex/commands/` | Commands |
| **Future harness** | `.<harness>/commands/` | Harness-specific |

---

## Harness Entry Points

**Location:** `.<harness>/commands/*.md` (e.g., `.cursor/commands/`, `.claude/commands/`, `.codex/commands/`)

Thin wrappers that provide harness-specific invocation for workspace commands or workflows. The actual implementation logic lives in `.harmony/`.

### Design Principle: Universal Harness-Agnostic Pattern

```
┌─────────────────────────────────────────────────────────┐
│  Harness Entry Points (thin wrappers)                   │
├─────────────────┬─────────────────┬─────────────────────┤
│ .cursor/        │ .claude/        │ .codex/             │
│ commands/       │ commands/       │ commands/           │
│ research.md     │ research.md     │ research.md         │
└────────┬────────┴────────┬────────┴──────────┬──────────┘
         │                 │                   │
         ▼                 ▼                   ▼
┌─────────────────────────────────────────────────────────┐
│  .harmony/orchestration/workflows/projects/create-project.md        │
│                                                         │
│  Source of truth — same workflow for all harnesses      │
└─────────────────────────────────────────────────────────┘
```

### Characteristics

- **Thin wrappers** — Only usage syntax and pointer to implementation
- **Harness-specific integration** — Autocomplete, slash commands, etc.
- **Repository-wide scope** — Available everywhere in the repo
- **User-initiated** — Triggered by typing `/command` in chat
- **No business logic** — All logic lives in `.harmony/orchestration/workflows/` or `.harmony/capabilities/commands/`

### Entry Point Template

```markdown
# Command Name `/command-name`

Brief description.

See `.harmony/orchestration/workflows/<category>/<name>/00-overview.md` for full description and steps.

## Usage

\`\`\`text
/command-name <args>
\`\`\`

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `<arg>` | Yes | Description |

## Implementation

Execute the workflow in `.harmony/orchestration/workflows/<category>/<name>/`.

Start with `00-overview.md` and follow each step in sequence.

## References

- **Workflow:** `.harmony/orchestration/workflows/<category>/<name>/`
```

---

## Workspace Commands

**Location:** `.harmony/capabilities/commands/*.md`

Workspace-specific atomic operations that operate on artifacts in the workspace's parent directory.

See [commands.md](./commands.md) for full details and examples.

### Characteristics

- Single-action, atomic operations
- Workspace-specific scope
- Can be triggered by harness entry points or directly by agents
- No harness integration (unless wrapped by a harness entry point)
- **Source of truth** for atomic operations

### Examples

- `format-for-publication.md` — Single formatting action
- `validate-frontmatter.md` — Single validation check
- `lint-conventions.md` — Single lint pass

---

## Workspace Workflows

**Location:** `.harmony/orchestration/workflows/*.md` or `.harmony/orchestration/workflows/<name>/`

Multi-step procedures that operate on artifacts in the workspace's parent directory. Workflows are the **source of truth** for complex operations.

See [workflows.md](./workflows.md) for full details, including the Universal Harness-Agnostic Pattern.

### Characteristics

- Multi-step procedures
- Workspace-specific scope
- Can be triggered by any harness entry point or referenced directly by agents
- No harness integration (unless wrapped by a harness entry point)
- **Source of truth** for multi-step operations
- **Portable** — Same workflow works across Cursor, Claude Code, Codex, etc.

### Examples

- `audit-and-refactor.md` — Multi-step audit procedure
- `publish-to-docs.md` — Multi-step publication workflow
- `create-workspace/` — Subdirectory with sequential steps

---

## Workspace Prompts

**Location:** `.harmony/scaffolding/prompts/*.md`

Task templates that guide agents through context-dependent work requiring judgment or parameterization.

See [prompts.md](./prompts.md) for full details.

### Characteristics

- Templates, not executable procedures
- Require context or parameters from user/situation
- Output varies based on judgment
- Agent adapts template to the specific case

### Examples

- `audit-content.md` — Review content (criteria vary)
- `improve-clarity.md` — Enhance readability (subjective)
- `summarize-changes.md` — Summarize work (context-dependent)

### Command vs Prompt Decision

See `.harmony/catalog.md#command-vs-prompt-decision` for the canonical decision logic.

---

## Assistants

**Location:** `.harmony/agency/assistants/<name>/assistant.md`

Focused specialists that serve agents or humans for scoped, one-off tasks.

See [assistants.md](./assistants.md) for full details.

### Characteristics

- Invoked via `@mention` or agent delegation
- Stateless (inherits context from caller)
- Produces structured output in defined format
- Knows when to escalate

### Assistant vs Agent

| Characteristic | Agent | Assistant |
|----------------|-------|-----------|
| Autonomy | Autonomous, long-running | Invoked for specific tasks |
| Lifecycle | Persistent across sessions | Stateless |
| Scope | Orchestrates broad work | Focused, scoped operations |
| Examples | Planner, Builder, Verifier | Reviewer, Refactor, Docs |

### When to Create an Assistant

- Repeated specialized task
- Task needs consistent output format
- Agent should be able to delegate

---

## Missions

**Location:** `.harmony/orchestration/missions/<slug>/`

Time-bounded sub-projects with isolated progress tracking.

See [missions.md](./missions.md) for full details.

### Characteristics

- Has specific goal and success criteria
- Has an owner (agent, assistant, or human)
- Maintains isolated progress (`tasks.json`, `log.md`)
- Lifecycle: created → active → completed → archived

### Mission Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Created
    Created --> Active
    Active --> Completed
    Active --> Cancelled
    Completed --> Archived
    Cancelled --> Archived
    Archived --> [*]
```

### When to Create a Mission

| Scenario | Use Mission? |
|----------|--------------|
| Parallel workstreams | Yes |
| Time-bounded initiative | Yes |
| Delegatable unit of work | Yes |
| Single task, one session | No |
| Different codebase area | No (use nested workspace) |

---

## Skills

**Location:** `.harmony/capabilities/skills/<id>/skill.md`

Composable capability units with defined inputs, outputs, and behavior.

See [skills.md](./skills.md) for full details.

### Characteristics

- Invoked via `/command` or `use skill: <id>`
- Has defined inputs and outputs (enables composition)
- Writes outputs only to designated paths
- Logs execution for auditability (run logs)
- Progressive disclosure via registry

### Skills vs Other Artifacts

| Characteristic | Skill | Assistant | Workflow | Prompt |
|----------------|-------|-----------|----------|--------|
| **I/O contract** | Yes (typed paths) | No | No | No |
| **Composable** | Yes (pipelines) | No | Loosely | No |
| **Logging** | Required (run logs) | No | No | No |
| **Invocation** | `/command` or explicit | `@mention` | Reference | Reference |
| **Scope** | Composable capability | Focused specialist | Procedure | Template |

### When to Create a Skill

| Scenario | Use Skill? |
|----------|------------|
| Repeated capability with defined I/O | Yes |
| Need to chain operations (pipelines) | Yes |
| Require auditability (run logs) | Yes |
| One-off task requiring judgment | No (use Prompt) |
| Focused specialist role | No (use Assistant) |
| Complex multi-step procedure | No (use Workflow) |

---

## FlowKit Flows (Repo-Wide)

**Location:** `packages/workflows/<flowId>/`

FlowKit flows are **executable flow assets** run by FlowKit (CLI + LangGraph runtime), not workspace workflows.

### Characteristics

- **Machine-wired execution** — flow graphs and semantics are defined by `config.flow.json` + `manifest.yaml`.
- **Repo-wide scope** — used by the FlowKit CLI, CI automation, and LangGraph Studio.
- **Different metadata model** — canonical prompt frontmatter stays minimal; wiring and classification live in config/manifest.

### Choosing Between `.harmony/orchestration/workflows/**` and `packages/workflows/**`

Use this guide when you're deciding *where* a multi-step workflow belongs:

| Dimension | `.harmony/orchestration/workflows/**` (Workspace Workflow) | `packages/workflows/**` (FlowKit Flow Assets) |
|---|---|---|
| Primary purpose | Human/agent **procedure** (“follow these steps”) | Runnable **execution contract** (config + manifest + prompts) |
| How it runs | An agent reads Markdown and follows steps | FlowKit CLI + runtime execute a manifest-defined graph |
| Entry points | Direct agent reference; optional `/…` wrapper via `.cursor/commands/*` | `pnpm flowkit:run …/config.flow.json`; `/run-flow @…/config.flow.json`; apps/CI calling the runner |
| Strengths | Low ceremony; high readability; great for IDE UX and runbooks | Deterministic ordering; structured state/output; easier automation/CI/Studio; clearer “semantics” ownership |
| Weaknesses | Harder to automate reliably; “determinism” depends on agent compliance; limited structured observability | More setup/maintenance; more concepts (config/manifest/runtime); overkill for simple runbooks |
| Best for | Workspace management, procedural checklists, thin tool wrappers | Long-running / repeatable flows, evaluators/assessments, any workflow you want to run from multiple surfaces |

**Rule of thumb**

- If it must be runnable/auditable as a system (CLI/CI/runtime/Studio) → `packages/workflows/<flowId>/`
- If it’s primarily guidance/UX (“how we do this here”, optionally wrapped as a Cursor command) → `.harmony/orchestration/workflows/**`

See `docs/kits/planning-and-orchestration/flowkit/guide.md` for the ownership map and entrypoints.

---

## Decision Guidance

All decision flowcharts and tables are maintained in `.harmony/catalog.md#decision-guidance` as the single source of truth. This includes:

- **Artifact Type Decision** — When to create Cursor commands, workspace commands, workflows, or prompts
- **Command vs Prompt Decision** — Distinguishing deterministic operations from templates
- **Workspace Modification Decision** — Choosing between create, update, migrate, and evaluate

See `.harmony/catalog.md` for complete decision flowcharts and examples.

---

## File Locations Summary

| Type | Location | Scope | Harness Integration |
|------|----------|-------|---------------------|
| Harness Entry Points | `.<harness>/commands/*.md` | Repository-wide | Yes (harness-specific) |
| Workspace Commands | `.harmony/capabilities/commands/*.md` | This workspace only | No (unless wrapped) |
| Workspace Workflows | `.harmony/orchestration/workflows/*.md` | This workspace only | No (unless wrapped) |
| Prompts | `.harmony/scaffolding/prompts/*.md` | Task templates | No |
| Assistants | `.harmony/agency/assistants/<name>/` | Focused specialists | Via @mention |
| Missions | `.harmony/orchestration/missions/<slug>/` | Sub-projects | No |
| Checklists | `.harmony/quality/*.md` | Quality gates | No |
| FlowKit Flow assets | `packages/workflows/<flowId>/` | Repository-wide | No (but can be wrapped via `/run-flow`) |

### Harness Entry Point Directories

| Harness | Directory |
|---------|-----------|
| Cursor | `.cursor/commands/` |
| Claude Code | `.claude/commands/` |
| Codex | `.codex/commands/` |
| Future harness | `.<harness>/commands/` |

---

## See Also

- [Workspace Commands](./commands.md) — Deterministic atomic operations
- [Workspace Workflows](./workflows.md) — Multi-step procedures
- [Workspace Prompts](./prompts.md) — Context-dependent task templates
- [Assistants](./assistants.md) — Focused specialists for scoped tasks
- [Missions](./missions.md) — Time-bounded sub-projects
- [Checklists](./checklists.md) — Quality gates
- [README.md](./README.md) — Canonical workspace structure reference
