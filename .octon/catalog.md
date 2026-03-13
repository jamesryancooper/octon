---
title: Harness Catalog
description: Index of available commands, workflows, and decision guidance.
---

# Harness Catalog

Available operations and decision guidance in this harness.

## Canonical Specification

The canonical cross-subsystem spec is:

- [`.octon/cognition/_meta/architecture/specification.md`](./cognition/_meta/architecture/specification.md)

Subsystem expansion specs:

- [`.octon/agency/_meta/architecture/specification.md`](./agency/_meta/architecture/specification.md)
- [`.octon/capabilities/_meta/architecture/specification.md`](./capabilities/_meta/architecture/specification.md)
- [`.octon/orchestration/_meta/architecture/specification.md`](./orchestration/_meta/architecture/specification.md)

## Domain Profiles

Top-level domain shape is classified by profile (rather than naming
conventions):

- `bounded-surfaces` (`runtime/`, `governance/`, `practices/`)
- `state-tracking`
- `human-led`
- `artifact-sink`

Canonical registry:

- [`.octon/cognition/governance/domain-profiles.yml`](./cognition/governance/domain-profiles.yml)

---

## Assistants

Focused specialists in `agency/runtime/assistants/`:

| Assistant | Aliases | Description |
|-----------|---------|-------------|
| [reviewer](./agency/runtime/assistants/reviewer/assistant.md) | `@reviewer`, `@review`, `@rev` | Code review: quality, style, correctness, security |
| [refactor](./agency/runtime/assistants/refactor/assistant.md) | `@refactor`, `@ref` | Code restructuring: extract, rename, simplify |
| [docs](./agency/runtime/assistants/docs/assistant.md) | `@docs`, `@doc` | Documentation: clarity, completeness, accuracy |

**Invocation:** Type `@name task` in chat or let agents delegate subtasks.

See `agency/manifest.yml` for actor discovery and `agency/runtime/assistants/registry.yml` for alias mappings.

---

## Teams

Reusable multi-actor compositions in `agency/runtime/teams/`:

| Team | Lead | Members | Description |
|------|------|---------|-------------|
| [delivery-core](./agency/runtime/teams/delivery-core/team.md) | `architect` | `architect`, `auditor`, `reviewer`, `refactor`, `docs` | Default end-to-end delivery composition with verification handoffs |

**Invocation:** `use team: <id>` (if supported by caller) or by explicit agent/workflow routing.

---

## Missions

Time-bounded sub-projects in `orchestration/runtime/missions/`:

| Status | Count | Description |
|--------|-------|-------------|
| Active | See `registry.yml` | Currently in progress |
| Archived | See `orchestration/runtime/missions/.archive/` | Completed or cancelled |

**Lifecycle:** Created → Active → Completed → Archived

See `orchestration/runtime/missions/README.md` for when to create a mission.

---

## Skills

Composable capabilities in `capabilities/runtime/skills/`:

| Skill | Commands | Description |
|-------|----------|-------------|
| [synthesize-research](./capabilities/runtime/skills/synthesis/synthesize-research/SKILL.md) | `/synthesize-research` | Synthesize scattered research notes into coherent findings |
| [refine-prompt](./capabilities/runtime/skills/synthesis/refine-prompt/SKILL.md) | `/refine-prompt` | Context-aware prompt refinement: analyze repo, inject references, decompose tasks, validate feasibility |
| [audit-domain-architecture](./capabilities/runtime/skills/audit/audit-domain-architecture/SKILL.md) | `/audit-domain-architecture` | Independent architecture critique for any Octon domain using external robustness criteria |
| [audit-ui](./capabilities/runtime/skills/audit/audit-ui/SKILL.md) | `/audit-ui` | Audit UI files against live external web design guidelines |
| [react-composition-patterns](./capabilities/runtime/skills/foundations/react/composition-patterns/SKILL.md) | `/react-composition-patterns` | Apply React composition patterns: compound components, state lifting, explicit variants |
| [react-best-practices](./capabilities/runtime/skills/foundations/react/best-practices/SKILL.md) | `/react-best-practices` | Apply 57 React/Next.js performance rules across 8 categories |
| [react-native-best-practices](./capabilities/runtime/skills/foundations/react-native/best-practices/SKILL.md) | `/react-native-best-practices` | Apply 35+ React Native/Expo rules across 14 categories |
| [vercel-deploy](./capabilities/runtime/skills/platforms/vercel/deploy/SKILL.md) | `/vercel-deploy` | Package and deploy the project to Vercel |

**Invocation:** Use `/command` in chat or `use skill: skill-id` for explicit selection.

**Pipelines:** Skills chain via inputs/outputs. See `capabilities/runtime/skills/registry.yml` for pipelines.

**Progressive disclosure:** Read `capabilities/runtime/skills/registry.yml` first, load SKILL.md only when needed.

See `capabilities/runtime/skills/README.md` for creating and using skills.

---

## Commands

Atomic operations in `capabilities/runtime/commands/`:

| Command | Access | Description |
|---------|--------|-------------|
| [init.md](./capabilities/runtime/commands/init.md) | human | Initialize canonical `.octon` bootstrap files plus repo-root ingress adapters (`.octon/AGENTS.md`, `.octon/OBJECTIVE.md`, `intent.contract.yml`, root `AGENTS.md`, root `CLAUDE.md`, `alignment-check`, optional `BOOT*.md`) |
| [studio.md](./capabilities/runtime/commands/studio.md) | human | Launch Octon Studio for workflow graph design, read-only orchestration operations, and safe staged edits |
| [recover.md](./capabilities/runtime/commands/recover.md) | human | Recovery procedures for common agent failure modes |
| [audit-skills-system-expansion.md](./capabilities/runtime/commands/audit-skills-system-expansion.md) | human | Invoke the skills-system expansion evaluation prompt through a slash-style command wrapper |
| [alignment-check.md](./capabilities/runtime/commands/alignment-check.md) | human | Run profile-based alignment checks across harness aspects |
| [validate-frontmatter.md](./capabilities/runtime/commands/validate-frontmatter.md) | human | Validate YAML frontmatter in markdown files |
| [create-workflow.md](./capabilities/runtime/commands/create-workflow.md) | human | Scaffold a new workflow with gap-aware structure |
| [evaluate-workflow.md](./capabilities/runtime/commands/evaluate-workflow.md) | human | Assess a workflow against quality criteria |
| [update-workflow.md](./capabilities/runtime/commands/update-workflow.md) | human | Modify an existing workflow to fix gaps |

---

## Tools

Invocation-driven atomic tool capability in `capabilities/runtime/tools/`.

### Packs

| Pack ID | Purpose | Included Tools |
|---|---|---|
| `read-only` | Read-only file access | `Read`, `Glob`, `Grep` |
| `file-ops` | File read/write ops | `Read`, `Write`, `Glob`, `Grep` |
| `full-edit` | Full edit toolkit | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| `web-access` | Web fetch/search | `WebFetch`, `WebSearch` |
| `shell-safe` | Scoped shell utilities | `Bash(mkdir)`, `Bash(cp)`, `Bash(mv)`, `Bash(ln)` |
| `ci-integration` | CI and GitHub operations | `Bash(gh)`, `Bash(npm)`, `Bash(npx)` |

### Usage Example

```yaml
allowed-tools: pack:read-only Write(_ops/state/logs/*)
```

---

## Services

Invocation-driven composite capabilities with typed I/O contracts in `capabilities/runtime/services/`.

| Service | Interface | Category | Description |
|---|---|---|---|
| [guard](./capabilities/runtime/services/governance/guard/guide.md) | `shell` | guard | Content safety checks and sanitization |
| [prompt](./capabilities/runtime/services/modeling/prompt/guide.md) | `library` | prompt | Prompt rendering/token contracts |
| [cost](./capabilities/runtime/services/operations/cost/guide.md) | `shell` | cost | Budget estimation and usage tracking |
| [flow](./capabilities/runtime/services/execution/flow/guide.md) | `mcp` | flow | Native-first flow execution with optional LangGraph adapter |

### Usage Example

```yaml
allowed-tools: pack:read-only Write(_ops/state/logs/*)
allowed-services: guard cost
```

---

## Workflows

Multi-step procedures in `orchestration/runtime/workflows/`.

**Discovery:** Read `orchestration/runtime/workflows/manifest.yml` for workflow index (Tier 1). After matching, read `orchestration/runtime/workflows/registry.yml` for extended metadata (Tier 2).

### Harness Management

| Workflow | Access | Description |
|----------|--------|-------------|
| [evaluate-harness](./orchestration/runtime/workflows/meta/evaluate-harness/00-overview.md) | human | Evaluate token efficiency and effectiveness |
| [migrate-harness](./orchestration/runtime/workflows/meta/migrate-harness/00-overview.md) | human | Upgrade older harness to current conventions |
| [update-harness](./orchestration/runtime/workflows/meta/update-harness/00-overview.md) | human | Align with canonical definition |

### Projects

| Workflow | Access | Description |
|----------|--------|-------------|
| [create-project](./orchestration/runtime/workflows/projects/create-project.md) | human | Scaffold a new project in `projects/` |

### Missions

| Workflow | Access | Description |
|----------|--------|-------------|
| [create-mission](./orchestration/runtime/workflows/missions/create-mission/00-overview.md) | human | Scaffold a new mission from template |
| [complete-mission](./orchestration/runtime/workflows/missions/complete-mission/00-overview.md) | human | Archive a completed mission |

### Workflow Management

| Workflow | Access | Description |
|----------|--------|-------------|
| [create-workflow](./orchestration/runtime/workflows/meta/create-workflow/00-overview.md) | human | Scaffold a new workflow with gap remediation features |
| [evaluate-workflow](./orchestration/runtime/workflows/meta/evaluate-workflow/00-overview.md) | human | Assess workflow quality and gap coverage |
| [update-workflow](./orchestration/runtime/workflows/meta/update-workflow/00-overview.md) | human | Add gap fixes to existing workflows |

### Audit And Quality Gate

| Workflow | Access | Description |
| -------- | ------ | ----------- |
| [audit-orchestration](./orchestration/runtime/workflows/audit/audit-orchestration/README.md) | human | Coordinate bounded multi-pass audits with deterministic bundle evidence |
| [audit-pre-release](./orchestration/runtime/workflows/audit/audit-pre-release/README.md) | human | Merge bounded audit stages into a release recommendation with explicit done-gate |
| [audit-documentation](./orchestration/runtime/workflows/audit/audit-documentation/README.md) | human | Run bounded docs-as-code audit and emit recommendation with convergence metadata |
| [refactor](./orchestration/runtime/workflows/refactor/refactor/00-overview.md) | human | Execute a verified refactor with exhaustive audit |

---

## Prompts

Task templates in `scaffolding/practices/prompts/`:

| Prompt | Access | Description |
|--------|--------|-------------|
| [bootstrap-session.md](./scaffolding/practices/prompts/bootstrap-session.md) | human | Quick-start a new agent session in a harness. |

> **Note:** Prompts are task templates that require context or judgment. Use `/evaluate-harness` for health assessment.

---

## Decision Guidance

This section contains the canonical decision logic for harness operations. Other documentation references these sections.

### Which Subsystem? {#which-subsystem}

```text
Is this instruction-driven (agent reads and follows)?
├── YES
│   ├── Atomic? → Command
│   └── Composite? → Skill
└── NO (invocation-driven; agent calls it)
    ├── Atomic? → Tool
    └── Composite with typed contract? → Service
```

### What interface_type for a service? {#service-interface-type-decision}

```text
Can logic run as POSIX shell?
├── YES, pure computation/file ops → shell
├── NO, needs runtime library → library
└── NO, communicates over network → mcp
```

### Artifact Type Decision {#artifact-type-decision}

When creating a new artifact, use this flowchart:

```text
Is this triggered by a user typing /something in Cursor chat?
├── YES → Create a Cursor Command (.cursor/commands/)
│   └── If execution is non-trivial, delegate to Workflow/Skill/Service
└── NO → Is this instruction-driven (agent reads and follows)?
    ├── YES
    │   ├── Requires context/judgment template? → Prompt
    │   ├── Atomic deterministic action? → Command
    │   └── Composite reusable procedure? → Skill or Workflow
    └── NO (invocation-driven)
        ├── Atomic call/result unit? → Tool
        └── Composite typed domain capability? → Service
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
| No harness exists yet | Adopt the repo-root bundle, then run `/init` | Harness-modification workflows assume an existing root harness |

```text
Does the harness exist?
├── NO → adopt the repo-root bundle, then run /init
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
| Agent invokes an atomic callable operation | Harness Tool |
| Agent invokes composite typed domain capability | Harness Service |
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

Background knowledge in `cognition/runtime/context/`:

| File | Description |
|------|-------------|
| [decisions.md](./cognition/runtime/context/decisions.md) | Agent-readable decision summaries. |
| [lessons.md](./cognition/runtime/context/lessons.md) | Anti-patterns and failures to avoid. |
| [glossary.md](./cognition/runtime/context/glossary.md) | Domain-specific terminology. |
| [dependencies.md](./cognition/runtime/context/dependencies.md) | External systems and references. |
| [constraints.md](./cognition/runtime/context/constraints.md) | Technical and business rules. |
| [compaction.md](./cognition/runtime/context/compaction.md) | Token compaction strategies. |
| [tools.md](./cognition/runtime/context/tools.md) | Available tools reference. |

---

## Checklists

Quality gates in `assurance/`:

| File | Description |
|------|-------------|
| [complete.md](./assurance/practices/complete.md) | Definition of done for tasks |
| [session-exit.md](./assurance/practices/session-exit.md) | Steps before ending a session |

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

Boilerplate in `scaffolding/runtime/templates/`:

| Template | Description |
|----------|-------------|
| [bootstrap/AGENTS.md](./scaffolding/runtime/bootstrap/AGENTS.md) | Canonical `/.octon/AGENTS.md` bootstrap source |
| [bootstrap/BOOT.md](./scaffolding/runtime/bootstrap/BOOT.md) | Optional recurring startup checklist template |
| [bootstrap/BOOTSTRAP.md](./scaffolding/runtime/bootstrap/BOOTSTRAP.md) | Optional one-time bootstrap checklist template |
| [bootstrap/alignment-check](./scaffolding/runtime/bootstrap/alignment-check) | Template for root `alignment-check` shim generated by `/init` |
| [cursor-command.md](./scaffolding/runtime/templates/cursor-command.md) | Template for Cursor command wrappers |
| [document.md](./scaffolding/runtime/templates/document.md) | Template for general documents |
| [octon/](./scaffolding/runtime/templates/octon/) | Base repo-root `.octon/` template |

The root harness template contains:
- `manifest.json` — Machine-readable template metadata

---

## Scripts

| Script | Description |
|--------|-------------|
| [scaffolding/runtime/_ops/scripts/init-project.sh](./scaffolding/runtime/_ops/scripts/init-project.sh) | Stable wrapper path for the canonical bootstrap generator that writes `.octon`-local authored files plus root ingress adapters |
| [init.sh](./init.sh) | Health check: verifies required files/directories exist |

**Usage:** Run `.octon/scaffolding/runtime/_ops/scripts/init-project.sh --list-objectives` to inspect common use cases, then run `.octon/scaffolding/runtime/_ops/scripts/init-project.sh --objective <id>` from repo root (or use `/init`) for project bootstrap. This writes canonical authored files under `/.octon/` and refreshes the root `AGENTS.md` and `CLAUDE.md` ingress adapters. Add `--with-boot-files` to generate `BOOT.md` and `BOOTSTRAP.md`. Run `.octon/init.sh` from `.octon/` for harness health checks.

---

## Access Key

| Value | Meaning |
|-------|---------|
| `human` | Has a Cursor command wrapper in `.cursor/commands/` |
| `agent` | Agent-only; no IDE integration |
