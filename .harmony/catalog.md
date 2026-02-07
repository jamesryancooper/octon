---
title: Workspace Catalog
description: Index of available commands, workflows, and decision guidance.
---

# Workspace Catalog

Available operations and decision guidance in this workspace.

---

## Assistants

Focused specialists in `agency/assistants/`:

| Assistant | Aliases | Description |
|-----------|---------|-------------|
| [reviewer](./agency/assistants/reviewer/assistant.md) | `@review`, `@rev` | Code review: quality, style, correctness, security |
| [refactor](./agency/assistants/refactor/assistant.md) | `@refactor`, `@ref` | Code restructuring: extract, rename, simplify |
| [docs](./agency/assistants/docs/assistant.md) | `@docs`, `@doc` | Documentation: clarity, completeness, accuracy |

**Invocation:** Type `@name task` in chat or let agents delegate subtasks.

See `agency/assistants/registry.yml` for the full @mention mapping.

---

## Missions

Time-bounded sub-projects in `orchestration/missions/`:

| Status | Count | Description |
|--------|-------|-------------|
| Active | See `registry.yml` | Currently in progress |
| Archived | See `orchestration/missions/.archive/` | Completed or cancelled |

**Lifecycle:** Created → Active → Completed → Archived

See `orchestration/missions/README.md` for when to create a mission.

---

## Skills

Composable capabilities in `capabilities/skills/`:

| Skill | Commands | Description |
|-------|----------|-------------|
| [synthesize-research](./capabilities/skills/synthesize-research/SKILL.md) | `/synthesize-research` | Synthesize scattered research notes into coherent findings |
| [prompt-refiner](../.harmony/capabilities/skills/prompt-refiner/SKILL.md) | `/refine-prompt` | Context-aware prompt refinement: analyze repo, inject references, decompose tasks, validate feasibility |

**Invocation:** Use `/command` in chat or `use skill: skill-id` for explicit selection.

**Pipelines:** Skills chain via inputs/outputs. See `capabilities/skills/registry.yml` for pipelines.

**Progressive disclosure:** Read `capabilities/skills/registry.yml` first, load SKILL.md only when needed.

See `capabilities/skills/README.md` for creating and using skills.

---

## Commands

Atomic operations in `capabilities/commands/`:

| Command | Access | Description |
|---------|--------|-------------|
| [recover.md](./capabilities/commands/recover.md) | human | Recovery procedures for common agent failure modes |
| [validate-frontmatter.md](./capabilities/commands/validate-frontmatter.md) | human | Validate YAML frontmatter in markdown files |
| [create-workflow.md](../.harmony/capabilities/commands/create-workflow.md) | human | Scaffold a new workflow with gap-aware structure |
| [evaluate-workflow.md](../.harmony/capabilities/commands/evaluate-workflow.md) | human | Assess a workflow against quality criteria |
| [update-workflow.md](../.harmony/capabilities/commands/update-workflow.md) | human | Modify an existing workflow to fix gaps |

---

## Workflows

Multi-step procedures in `orchestration/workflows/`:

### Workspace Management

| Workflow | Access | Description |
|----------|--------|-------------|
| [create-workspace](./orchestration/workflows/workspace/create-workspace/00-overview.md) | human | Scaffold a new `.harmony` directory |
| [evaluate-workspace](./orchestration/workflows/workspace/evaluate-workspace/00-overview.md) | human | Evaluate token efficiency and effectiveness |
| [migrate-workspace](./orchestration/workflows/workspace/migrate-workspace/00-overview.md) | human | Upgrade older workspace to current conventions |
| [update-workspace](./orchestration/workflows/workspace/update-workspace/00-overview.md) | human | Align with canonical definition |

### Projects

| Workflow | Access | Description |
|----------|--------|-------------|
| [create-project](./orchestration/workflows/projects/create-project.md) | human | Scaffold a new project in `projects/` |

### Missions

| Workflow | Access | Description |
|----------|--------|-------------|
| [create-mission](./orchestration/workflows/missions/create-mission/00-overview.md) | human | Scaffold a new mission from template |
| [complete-mission](./orchestration/workflows/missions/complete-mission/00-overview.md) | human | Archive a completed mission |

### Workflow Management

| Workflow | Access | Description |
|----------|--------|-------------|
| [create-workflow](../.harmony/orchestration/workflows/workflows/create-workflow/00-overview.md) | human | Scaffold a new workflow with gap remediation features |
| [evaluate-workflow](../.harmony/orchestration/workflows/workflows/evaluate-workflow/00-overview.md) | human | Assess workflow quality and gap coverage |
| [update-workflow](../.harmony/orchestration/workflows/workflows/update-workflow/00-overview.md) | human | Add gap fixes to existing workflows |

### FlowKit (Repo-Wide Tool Integration)

> **Note:** FlowKit workflows are **repo-wide tool integrations**, not workspace-management operations. They orchestrate the canonical FlowKit CLI (`pnpm flowkit:run`) and runtime (`agents/runner/runtime`) without duplicating implementation logic. The workflow steps describe *procedure*, not *semantics*—those live in `packages/kits/flowkit` and `agents/runner/runtime/`. Flow assets live in `packages/workflows/<flowId>/`.

| Workflow | Access | Description |
|----------|--------|-------------|
| [run-flow](./orchestration/workflows/flowkit/run-flow/00-overview.md) | human | Execute a FlowKit LangGraph flow from `@packages/workflows/<flowId>/config.flow.json` |

---

## Prompts

Task templates in `scaffolding/prompts/`:

| Prompt | Access | Description |
|--------|--------|-------------|
| [bootstrap-session.md](./scaffolding/prompts/bootstrap-session.md) | human | Quick-start a new agent session in a workspace. |

> **Note:** Prompts are task templates that require context or judgment. Use `/evaluate-workspace` for health assessment.

---

## Decision Guidance

This section contains the canonical decision logic for workspace operations. Other documentation references these sections.

> **Note:** If you're creating a FlowKit flow (runnable via `pnpm flowkit:run` / `flowkit run` and backed by `config.flow.json` + `manifest.yaml`), put it in `packages/workflows/<flowId>/`. `.harmony/orchestration/workflows/**` is for procedural runbooks (including `/run-flow`), not flow assets.

### Artifact Type Decision {#artifact-type-decision}

When creating a new artifact, use this flowchart:

```text
Is this triggered by a user typing /something in Cursor chat?
├── YES → Create a Cursor Command (.cursor/commands/)
│   └── Is the procedure complex (3+ steps)?
│       ├── YES → Also create a Workflow (.harmony/orchestration/workflows/)
│       └── NO → Is it a single atomic action?
│           ├── YES → Also create a Command (.harmony/capabilities/commands/)
│           └── NO → Procedure fits in Cursor command file
└── NO → Is this something an agent uses?
    ├── YES → Does it require context/judgment?
    │   ├── YES → Create a Prompt (.harmony/scaffolding/prompts/)
    │   └── NO → Is it atomic (single action)?
    │       ├── YES → Create a Command (.harmony/capabilities/commands/)
    │       └── NO → Create a Workflow (.harmony/orchestration/workflows/)
    └── NO → Maybe it's a Checklist (quality gate)
```

### Command vs Prompt Decision {#command-vs-prompt-decision}

| Question | If YES | If NO |
|----------|--------|-------|
| Can agent execute without asking questions? | Command | Prompt |
| Is output deterministic (same input → same output)? | Command | Prompt |
| Does it require user-provided context? | Prompt | Command |
| Does it require agent judgment? | Prompt | Command |

```text
Can the agent execute this without asking questions?
├── YES → It's a Command (deterministic, self-contained)
└── NO → Does it need user context or agent judgment?
    ├── YES → It's a Prompt (template, adaptable)
    └── NO → It might be a Checklist (verification gate)
```

#### Examples

| File | Type | Reason |
|------|------|--------|
| `validate-frontmatter.md` | Command | Deterministic check with fixed rules |
| `recover.md` | Command | Fixed steps for known error types |
| `audit-content.md` | Prompt | Criteria vary, judgment needed |
| `improve-clarity.md` | Prompt | "Clarity" is subjective |

### Workspace Modification Decision {#workspace-modification-decision}

When modifying an existing workspace:

| Situation | Use | Why |
|-----------|-----|-----|
| Workspace missing required files | `/update-workspace` | Incremental alignment, adds missing pieces |
| Workspace has minor structural gaps | `/update-workspace` | Non-destructive fixes |
| Workspace uses old file structure (e.g., `agents/` dir) | `/migrate-workspace` | Major restructuring needed |
| Major convention changes between versions | `/migrate-workspace` | Preserves content while transforming structure |
| Read-only assessment, no changes | `/evaluate-workspace` | Produces report only |
| New workspace needed | `/create-workspace` | Scaffolds from templates |

```text
Does the workspace exist?
├── NO → /create-workspace
└── YES → Is it structurally correct (current conventions)?
    ├── NO → /migrate-workspace (structural transformation)
    └── YES → Do you want to make changes?
        ├── NO → /evaluate-workspace (read-only report)
        └── YES → /update-workspace (incremental fixes)
```

### When to Create What

| Situation | Create |
|-----------|--------|
| User types `/something` to start a simple action | Cursor Command only |
| User types `/something` to start a complex procedure | Cursor Command + Workflow |
| Agent follows a single deterministic operation | Workspace Command |
| Agent follows a multi-step procedure | Workspace Workflow |
| Agent needs a template for context-dependent work | Workspace Prompt |
| Repository-wide action with IDE integration | Cursor Command |
| Verification before completing work | Checklist |

### IDE Integration Decision {#ide-integration-decision}

When deciding between `access: human` (Cursor command wrapper) vs `access: agent` (agent-only):

| Question | If YES | If NO |
|----------|--------|-------|
| Will humans frequently trigger this from IDE? | `human` | `agent` |
| Does it require IDE context (open files, cursor position)? | `human` | `agent` |
| Is it a common starting point for work? | `human` | `agent` |
| Is it only used as a sub-procedure of other operations? | `agent` | `human` |

```text
Will humans frequently trigger this directly?
├── YES → access: human (create Cursor command wrapper)
└── NO → Is it only used by other agent operations?
    ├── YES → access: agent (no IDE integration needed)
    └── NO → Consider access: human for discoverability
```

---

## Context

Background knowledge in `cognition/context/`:

| File | Description |
|------|-------------|
| [decisions.md](./cognition/context/decisions.md) | Agent-readable decision summaries. |
| [lessons.md](./cognition/context/lessons.md) | Anti-patterns and failures to avoid. |
| [glossary.md](./cognition/context/glossary.md) | Domain-specific terminology. |
| [dependencies.md](./cognition/context/dependencies.md) | External systems and references. |
| [constraints.md](./cognition/context/constraints.md) | Technical and business rules. |
| [compaction.md](./cognition/context/compaction.md) | Token compaction strategies. |
| [tools.md](./cognition/context/tools.md) | Available tools reference. |

---

## Checklists

Quality gates in `quality/`:

| File | Description |
|------|-------------|
| [complete.md](./quality/complete.md) | Definition of done for tasks |
| [session-exit.md](./quality/session-exit.md) | Steps before ending a session |

---

## Progress Artifacts

Session continuity in `continuity/`:

| File | Description |
|------|-------------|
| [log.md](./continuity/log.md) | Append-only session history |
| [tasks.json](./continuity/tasks.json) | Structured task list with goal |
| [entities.json](./continuity/entities.json) | Entity state tracking |
| [next.md](./continuity/next.md) | Immediate actionable steps (promoted from `ideation/scratchpad/`) |

---

## Templates

Boilerplate in `scaffolding/templates/`:

| Template | Description |
|----------|-------------|
| [cursor-command.md](./scaffolding/templates/cursor-command.md) | Template for Cursor command wrappers |
| [document.md](./scaffolding/templates/document.md) | Template for general documents |
| [harmony/](./scaffolding/templates/harmony/) | Base .harmony/ template (all workspaces inherit from this) |
| [harmony-docs/](./scaffolding/templates/harmony-docs/) | Scoped template for documentation areas (extends base) |
| [harmony-node-ts/](./scaffolding/templates/harmony-node-ts/) | Scoped template for Node.js/TypeScript packages (extends base) |

Each workspace template contains:
- `manifest.json` — Machine-readable structure for `/create-workspace`
- `MANIFEST.md` — Human-readable documentation (scoped templates only)

---

## Scripts

| Script | Description |
|--------|-------------|
| [init.sh](./init.sh) | Health check: verifies required files/directories exist |

**Usage:** Run `./init.sh` from the `.harmony/` directory to verify structure integrity.

---

## Access Key

| Value | Meaning |
|-------|---------|
| `human` | Has a Cursor command wrapper in `.cursor/commands/` |
| `agent` | Agent-only; no IDE integration |
