---
title: Harness Catalog
description: Index of available commands, workflows, and decision guidance.
---

# Harness Catalog

Available operations and decision guidance in this harness.

---

## Assistants

Focused specialists in `agency/assistants/`:

| Assistant | Aliases | Description |
|-----------|---------|-------------|
| [reviewer](./agency/assistants/reviewer/assistant.md) | `@reviewer`, `@review`, `@rev` | Code review: quality, style, correctness, security |
| [refactor](./agency/assistants/refactor/assistant.md) | `@refactor`, `@ref` | Code restructuring: extract, rename, simplify |
| [docs](./agency/assistants/docs/assistant.md) | `@docs`, `@doc` | Documentation: clarity, completeness, accuracy |

**Invocation:** Type `@name task` in chat or let agents delegate subtasks.

See `agency/manifest.yml` for actor discovery and `agency/assistants/registry.yml` for alias mappings.

---

## Teams

Reusable multi-actor compositions in `agency/teams/`:

| Team | Lead | Members | Description |
|------|------|---------|-------------|
| [delivery-core](./agency/teams/delivery-core/team.md) | `architect` | `architect`, `auditor`, `reviewer`, `refactor`, `docs` | Default end-to-end delivery composition with verification handoffs |

**Invocation:** `use team: <id>` (if supported by caller) or by explicit agent/workflow routing.

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
| [synthesize-research](./capabilities/skills/synthesis/synthesize-research/SKILL.md) | `/synthesize-research` | Synthesize scattered research notes into coherent findings |
| [refine-prompt](./capabilities/skills/synthesis/refine-prompt/SKILL.md) | `/refine-prompt` | Context-aware prompt refinement: analyze repo, inject references, decompose tasks, validate feasibility |
| [audit-ui](./capabilities/skills/quality-gate/audit-ui/SKILL.md) | `/audit-ui` | Audit UI files against live external web design guidelines |
| [react-composition-patterns](./capabilities/skills/foundations/react/composition-patterns/SKILL.md) | `/react-composition-patterns` | Apply React composition patterns: compound components, state lifting, explicit variants |
| [react-best-practices](./capabilities/skills/foundations/react/best-practices/SKILL.md) | `/react-best-practices` | Apply 57 React/Next.js performance rules across 8 categories |
| [react-native-best-practices](./capabilities/skills/foundations/react-native/best-practices/SKILL.md) | `/react-native-best-practices` | Apply 35+ React Native/Expo rules across 14 categories |
| [vercel-deploy](./capabilities/skills/platforms/vercel/deploy/SKILL.md) | `/vercel-deploy` | Package and deploy the project to Vercel |

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
| [create-workflow.md](./capabilities/commands/create-workflow.md) | human | Scaffold a new workflow with gap-aware structure |
| [evaluate-workflow.md](./capabilities/commands/evaluate-workflow.md) | human | Assess a workflow against quality criteria |
| [update-workflow.md](./capabilities/commands/update-workflow.md) | human | Modify an existing workflow to fix gaps |

---

## Workflows

Multi-step procedures in `orchestration/workflows/`.

**Discovery:** Read `orchestration/workflows/manifest.yml` for workflow index (Tier 1). After matching, read `orchestration/workflows/registry.yml` for extended metadata (Tier 2).

### Harness Management

| Workflow | Access | Description |
|----------|--------|-------------|
| [create-harness](./orchestration/workflows/meta/create-harness/00-overview.md) | human | Scaffold a new `.harmony` directory |
| [evaluate-harness](./orchestration/workflows/meta/evaluate-harness/00-overview.md) | human | Evaluate token efficiency and effectiveness |
| [migrate-harness](./orchestration/workflows/meta/migrate-harness/00-overview.md) | human | Upgrade older harness to current conventions |
| [update-harness](./orchestration/workflows/meta/update-harness/00-overview.md) | human | Align with canonical definition |

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
| [create-workflow](./orchestration/workflows/meta/create-workflow/00-overview.md) | human | Scaffold a new workflow with gap remediation features |
| [evaluate-workflow](./orchestration/workflows/meta/evaluate-workflow/00-overview.md) | human | Assess workflow quality and gap coverage |
| [update-workflow](./orchestration/workflows/meta/update-workflow/00-overview.md) | human | Add gap fixes to existing workflows |

### FlowKit (Repo-Wide Tool Integration)

> **Note:** FlowKit workflows are **repo-wide tool integrations**, not harness-management operations. They orchestrate the canonical FlowKit CLI (`pnpm flowkit:run`) and runtime (`agents/runner/runtime`) without duplicating implementation logic. The workflow steps describe *procedure*, not *semantics*—those live in `packages/kits/flowkit` and `agents/runner/runtime/`. Flow assets live in `packages/workflows/<flowId>/`.

| Workflow | Access | Description |
|----------|--------|-------------|
| [run-flow](./orchestration/workflows/flowkit/run-flow/00-overview.md) | human | Execute a FlowKit LangGraph flow from `@packages/workflows/<flowId>/config.flow.json` |

### Quality Gate

| Workflow | Access | Description |
| -------- | ------ | ----------- |
| [orchestrate-audit](./orchestration/workflows/quality-gate/orchestrate-audit/WORKFLOW.md) | human | Coordinate parallel audit-migration runs across codebase partitions |
| [refactor](./orchestration/workflows/quality-gate/refactor(x)/00-overview.md) | human | Execute a verified refactor with exhaustive audit |

---

## Prompts

Task templates in `scaffolding/prompts/`:

| Prompt | Access | Description |
|--------|--------|-------------|
| [bootstrap-session.md](./scaffolding/prompts/bootstrap-session.md) | human | Quick-start a new agent session in a harness. |

> **Note:** Prompts are task templates that require context or judgment. Use `/evaluate-harness` for health assessment.

---

## Decision Guidance

This section contains the canonical decision logic for harness operations. Other documentation references these sections.

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

### Harness Modification Decision {#harness-modification-decision}

When modifying an existing harness:

| Situation | Use | Why |
|-----------|-----|-----|
| Harness missing required files | `/update-harness` | Incremental alignment, adds missing pieces |
| Harness has minor structural gaps | `/update-harness` | Non-destructive fixes |
| Harness uses old file structure (e.g., `agents/` dir) | `/migrate-harness` | Major restructuring needed |
| Major convention changes between versions | `/migrate-harness` | Preserves content while transforming structure |
| Read-only assessment, no changes | `/evaluate-harness` | Produces report only |
| New harness needed | `/create-harness` | Scaffolds from templates |

```text
Does the harness exist?
├── NO → /create-harness
└── YES → Is it structurally correct (current conventions)?
    ├── NO → /migrate-harness (structural transformation)
    └── YES → Do you want to make changes?
        ├── NO → /evaluate-harness (read-only report)
        └── YES → /update-harness (incremental fixes)
```

### When to Create What

| Situation | Create |
|-----------|--------|
| User types `/something` to start a simple action | Cursor Command only |
| User types `/something` to start a complex procedure | Cursor Command + Workflow |
| Agent follows a single deterministic operation | Harness Command |
| Agent follows a multi-step procedure | Harness Workflow |
| Agent needs a template for context-dependent work | Harness Prompt |
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
| [harmony/](./scaffolding/templates/harmony/) | Base .harmony/ template (all harnesses inherit from this) |
| [harmony-docs/](./scaffolding/templates/harmony-docs/) | Scoped template for documentation areas (extends base) |
| [harmony-node-ts/](./scaffolding/templates/harmony-node-ts/) | Scoped template for Node.js/TypeScript packages (extends base) |

Each harness template contains:
- `manifest.json` — Machine-readable structure for `/create-harness`
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
