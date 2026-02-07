# Harmony Primitives

This document explains the core building blocks in Harmony and when to use each.

## Quick Reference

| Primitive | Purpose | Invocation | State |
|-----------|---------|------------|-------|
| **Agent** | Autonomous supervisor that orchestrates work | Assigned to workspace/mission | Persistent |
| **Mission** | Durable multi-session orchestration | `/start-mission`, agent command | Persistent (state machine) |
| **Skill** | Composable capability with I/O contract | `/command`, `use skill:`, triggers | Stateless |
| **Assistant** | Specialist subagent for focused tasks | `@mention`, agent delegation | Stateless |
| **Command** | Lightweight entry point | `/command` | Stateless |
| **Checklist** | Quality gate for verification | Referenced at checkpoints | Stateless |
| **Prompt** | Task template with structured I/O | Copy/paste or direct reference | Stateless |
| **Template** | Scaffolding for new structures | Copied to target location | N/A |

> **Note:** Workflows are deprecated and consolidated into Skills. See the workflows → skills migration in `docs/architecture/workspaces/skills/`.

---

## Multi-Agent Hierarchy

The primitives form a hierarchical multi-agent system:

```
┌─────────────────────────────────────────────────────────────────┐
│  AGENT (Supervisor)                                             │
│  • Autonomous, persistent across sessions                       │
│  • Reasons, plans, delegates                                    │
│  • Commands missions                                            │
├─────────────────────────────────────────────────────────────────┤
│           │ commands              │ delegates to                │
│           ▼                       ▼                             │
│  ┌─────────────────┐    ┌─────────────────────────────┐        │
│  │ MISSION         │    │ ASSISTANT (Specialist)      │        │
│  │ (Durable Orch.) │    │ • Focused, stateless        │        │
│  │ • State machine │    │ • @mention invocation       │        │
│  │ • Multi-session │    │ • Uses skills               │        │
│  └────────┬────────┘    └──────────────┬──────────────┘        │
│           │ invokes                     │ uses                  │
│           ▼                             ▼                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  SKILLS (Composable Capabilities)                        │   │
│  │  • Single-session, defined I/O                          │   │
│  │  • agentskills.io compliant                             │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Agents

**Location:** `.harmony/agency/agents/<agent-name>/agent.md`

**Registry:** `.harmony/agency/agents/registry.yml`

**Purpose:** Autonomous supervisors that orchestrate complex work, command missions, and delegate to assistants.

### Characteristics

- **Persistent** — Maintains context and memory across sessions
- **Autonomous** — Perceives, reasons, plans, and decides
- **Supervisory** — Delegates to assistants, commands missions
- **High-level** — Focuses on *what* and *who*, not *how*

### When to Use

- Autonomous orchestration of complex work
- Persistent context across sessions required
- Commands missions (durable, multi-session work)
- Coordinates multiple assistants

### Agent Roles

| Role | Purpose |
|------|---------|
| Planner | Strategic planning, goal decomposition |
| Builder | Implementation, code generation |
| Verifier | Validation, testing, quality assurance |
| Coordinator | Cross-mission orchestration |

### Structure

```yaml
# registry.yml entry
- name: planner
  path: planner/
  role: "Strategic planning and goal decomposition"
  capabilities:
    - goal_decomposition
    - task_planning
    - assistant_delegation
    - mission_command
```

```markdown
# agent.md sections
- Role
- Capabilities
- Operating Principles
- Delegation Rules
- Mission Command
- Context Management
- Escalation
```

---

## Missions

**Location:** `.harmony/missions/<mission-id>/mission.yml`

**Purpose:** Durable, multi-session orchestration units with formal state machines, commanded by agents.

### Characteristics

- **Durable** — Survives restarts, persists state
- **Multi-session** — Designed to span days or weeks
- **State machine** — Formal YAML-defined states and transitions
- **FlowKit-native** — Executes on FlowKit runtime
- **Checkpoint-enabled** — Human approval gates with timeouts

### When to Use

- Work that spans multiple sessions (days/weeks)
- Complex decision trees with >5 branch points
- Human approval gates mid-execution
- Durable execution that survives restarts
- Orchestration of multiple skills

### Structure

```yaml
# mission.yml
name: auth-migration
goal: "Migrate to JWT authentication"
owner: planner  # Agent that commands this mission

states:
  - id: audit
    type: skill
    skill: refactor
    transitions:
      - on: complete → plan

  - id: human-review
    type: checkpoint
    prompt: "Approve migration plan?"
    timeout: 72h
    transitions:
      - on: approved → execute
      - on: rejected → revise
```

### Missions vs Skills

| Aspect | Mission | Skill |
|--------|---------|-------|
| Duration | Days/weeks | Single session |
| State | Persistent state machine | Stateless |
| Branching | Complex (formal DSL) | Simple (prose) |
| Runtime | FlowKit | Agent-interpreted |

---

## Skills

**Location:** `.harmony/capabilities/skills/<skill-id>/SKILL.md`

**Purpose:** Reusable, composable capabilities with explicit input/output contracts.

### Characteristics

- Full `SKILL.md` specification with inputs, outputs, dependencies
- Invoked via `/command`, `use skill: <id>`, or natural language triggers
- Stateless and portable (symlinked to harness directories)
- Writes only to `.harmony/capabilities/skills/outputs/**` and `logs/**`
- Can be chained into pipelines via registry

### When to Use

- Task is reusable across projects or sessions
- Clear discrete inputs → outputs
- You want pipeline composition (chain skills together)
- The capability should be portable to other repositories

### Examples

- `synthesize-research`: notes → synthesis document
- `prompt-refiner`: rough prompt → context-aware refined prompt

### Template

See `.harmony/capabilities/skills/_template/SKILL.md`

---

## Commands

**Location:** `.harmony/capabilities/commands/<command>.md`

**Purpose:** Lightweight entry points—often gateways to workflows or simple operations.

### Characteristics

- Minimal frontmatter: `description`, `access` (human/agent)
- Often delegates to a workflow for implementation
- Access control: `human` (has IDE wrapper) or `agent` (agent-only)
- Symlinked to harness command directories

### When to Use

- Simple atomic operation with lightweight docs
- Quick interface to a complex workflow
- Access control between humans and agents matters
- One-off session task that doesn't need full skill spec

### Examples

- `/refactor` → delegates to `.harmony/orchestration/workflows/refactor/`
- `/recover` → error recovery procedures
- `/validate-frontmatter` → check markdown metadata

---

## Workflows (DEPRECATED)

> **Deprecated:** Workflows are consolidated into Skills. Use Skills for single-session procedural work and Missions for durable multi-session orchestration.

**Former Location:** `.harmony/orchestration/workflows/<workflow-name>/`

**Migration Path:**

| Former Workflow | Migrate To |
|----------------|------------|
| Single-session procedures | **Skill** (phases in SKILL.md) |
| Multi-session durable work | **Mission** (state machine) |
| `refactor/` | `refactor` skill |
| `create-workspace/` | `create-workspace` skill |

**Why deprecated:**

1. Skills can implement multi-phase procedures (proven by `refine-prompt` with 10 phases)
2. Skills provide I/O contracts, audit logging, and progressive disclosure
3. Missions handle durable, multi-session work that workflows couldn't
4. Eliminates cognitive overhead of choosing between workflows and skills

See `docs/architecture/workspaces/skills/` for migration guidance.

---

## Assistants

**Location:** `.harmony/agency/assistants/<assistant-name>/assistant.md`

**Registry:** `.harmony/agency/assistants/registry.yml`

**Purpose:** Specialized subagents that perform focused tasks for agents or humans within the multi-agent hierarchy.

### Characteristics

- **Subagent** — Reports to agents, handles specialized work
- **Stateless** — Inherits context from caller, returns results
- **Focused** — Narrow scope, deep expertise
- **Invokable** — Via `@mention` aliases or agent delegation
- **Skill-enabled** — Can use skills to complete tasks
- **Escalation-aware** — Knows when to escalate to agents/humans

### When to Use

- Focused, specialized task requiring domain expertise
- Consistent output format is important
- Agent needs to delegate scoped work
- Task benefits from a specialist persona

### Assistants vs Agents

| Aspect | Agent | Assistant |
|--------|-------|-----------|
| Role | Supervisor | Specialist subagent |
| Autonomy | High (reasons, plans) | Focused (executes tasks) |
| State | Persistent | Stateless |
| Scope | Broad orchestration | Narrow specialization |

### Examples

- `@reviewer` / `@rev`: Code review for quality, style, correctness, security
- `@refactor` / `@ref`: Code improvement specialist
- `@docs` / `@doc`: Documentation clarity and completeness

### Structure

```yaml
# registry.yml entry
- name: reviewer
  path: reviewer/
  aliases: ["@review", "@rev"]
  description: "Code review specialist..."
```

```markdown
# assistant.md sections
- Mission
- Invocation
- Operating Rules
- Output Format
- Boundaries
- When to Escalate (to agents or humans)
```

---

## Checklists

**Location:** `.harmony/quality/<checklist>.md`

**Purpose:** Quality gates and verification criteria for specific checkpoints.

### Characteristics

- Used at defined points (task completion, session exit, etc.)
- Contains actionable checkbox items
- Often includes common failure modes and prevention
- Referenced by workflows at verification steps

### When to Use

- Ensuring consistent quality at checkpoints
- Preventing common failure modes
- Standardizing "definition of done"
- Session boundaries (start/exit)

### Examples

- `complete.md`: Definition of done for any task
- `session-exit.md`: Checklist before ending a session

### Structure

```markdown
## Before [Action]

- [ ] Criterion 1
- [ ] Criterion 2

## Quality Criteria

### For [Category]
- [ ] Specific check

## Common Failure Modes

| Failure | Prevention |
|---------|------------|
| Mode 1  | How to avoid |
```

---

## Prompts

**Location:** `.harmony/scaffolding/prompts/<prompt>.md` or `.harmony/scaffolding/prompts/<category>/<prompt>.md`

**Purpose:** Task templates with structured context, instructions, and expected output.

### Characteristics

- Frontmatter with `title`, `description`, `access`
- Context section (1-2 sentences)
- Numbered instructions
- Defined output format/template
- Less formal than skills (no I/O contract, no safety policy)

### When to Use

- Common task that benefits from structure
- You want consistent output format
- Task doesn't need full skill machinery
- Quick-start templates for sessions or research

### Examples

- `bootstrap-session.md`: Quick-start a new agent session
- `research/analyze-sources.md`: Analyze research sources
- `research/synthesize-findings.md`: Synthesize research findings

### Structure

```markdown
---
title: Prompt Name
description: What this prompt does
access: human
---

# Prompt Name

## Context
[1-2 sentence setup]

## Instructions
1. Step one
2. Step two

## Output
[Expected format or template]
```

---

## Templates

**Location:** `.harmony/scaffolding/templates/<template-name>/`

**Purpose:** Scaffolding for creating new structures (workspaces, projects, etc.).

### Characteristics

- Directory structure copied to target location
- Contains placeholder files to be customized
- Often used by workflows (e.g., `create-workspace` workflow)
- Not executed—just copied and modified

### When to Use

- Creating new workspaces
- Bootstrapping project structures
- Ensuring consistent initial structure
- Providing starting-point files

### Examples

- `harmony/`: Base .harmony/ structure
- `harmony-docs/`: Documentation-focused variant
- `harmony-node-ts/`: Node.js + TypeScript variant

### Structure

```
templates/
├── workspace/           # Base template
│   ├── START.md
│   ├── scope.md
│   ├── conventions.md
│   ├── catalog.md
│   ├── context/
│   └── progress/
├── harmony-docs/        # Variant for docs projects
└── harmony-node-ts/     # Variant for Node+TS projects
```

---

## Decision Matrix

| Situation | Choose | Reason |
|-----------|--------|--------|
| Autonomous orchestration of complex work | **Agent** | Reasons, plans, delegates |
| Work spanning multiple sessions (days/weeks) | **Mission** | Durable state machine |
| Complex decision trees (>5 branches) | **Mission** | Formal DSL for branching |
| Reusable task with clear I/O | **Skill** | Composable, portable, pipelines |
| Multi-phase single-session procedure | **Skill** | Phases in SKILL.md |
| Quick interface to complex work | **Command** | Lightweight gateway |
| Focused, specialized task | **Assistant** | Domain expertise, consistent output |
| Quality gate at checkpoint | **Checklist** | Consistent verification |
| Common task needing structure | **Prompt** | Template without full skill spec |
| Bootstrapping new structure | **Template** | Copy and customize |
| Cross-project reuse | **Skill** | Symlinked, versioned |
| Delegate work from agent | **Assistant** | Subagent specialization |

---

## Conceptual Groupings

### By Question Answered

| Question | Primitive |
|----------|-----------|
| Who supervises the work? | **Agent** |
| What long-running goal? | **Mission** |
| What reusable capability? | **Skill** |
| Who specializes in this task? | **Assistant** |
| What action to take? | **Command** |
| Is this done correctly? | **Checklist** |
| How do I start this task? | **Prompt** |
| What structure do I copy? | **Template** |

### By Autonomy Level

| Level | Primitive | Description |
|-------|-----------|-------------|
| **High** | Agent | Reasons, plans, decides, orchestrates |
| **Medium** | Mission | Durable execution with checkpoints |
| **Low** | Assistant | Focused execution of assigned tasks |
| **None** | Skill | Composable capability, no autonomy |

### By Lifecycle Phase

| Phase | Primitives |
|-------|------------|
| **Setup** | Template, Prompt (bootstrap) |
| **Planning** | Agent (goal decomposition) |
| **Orchestration** | Agent, Mission |
| **Execution** | Skill, Assistant, Command |
| **Verification** | Checklist, Mission (checkpoint states) |

---

## Example Scenarios

### "Consolidate research notes from multiple files"

→ **Skill** (`synthesize-research`)

Discrete input (notes), discrete output (synthesis doc), reusable across projects.

### "Run a refactor that might take multiple sessions"

→ **Workflow** (`refactor/`)

Checkpointed, idempotent, verification gate ensures completeness before marking done.

### "Quick way to validate markdown frontmatter"

→ **Command** (`/validate-frontmatter`)

Atomic operation, simple interface, no state needed.

### "Get a code review with consistent format"

→ **Assistant** (`@reviewer`)

Persona with defined output format, operating rules, and escalation paths.

### "Ensure task meets quality standards before marking done"

→ **Checklist** (`complete.md`)

Verification gate with actionable criteria and failure mode prevention.

### "Start a new research task with structure"

→ **Prompt** (`research/analyze-sources.md`)

Template with context, instructions, and expected output format.

### "Create a new workspace for a subproject"

→ **Template** (via `create-workspace` workflow)

Scaffolding copied and customized for the new workspace.

### "Chain prompt refinement → research synthesis"

→ **Skills pipeline**

Registry supports `pipelines` section for skill composition without manual orchestration.

---

## Related Resources

| Primitive | Registry | Template | Documentation |
|-----------|----------|----------|---------------|
| Agents | `.harmony/agency/agents/registry.yml` | `.harmony/agency/agents/_template/` | `docs/architecture/workspaces/agents.md` |
| Missions | `.harmony/missions/registry.yml` | `.harmony/missions/_template/` | `docs/architecture/workspaces/missions.md` |
| Skills | `.harmony/capabilities/skills/registry.yml` | `.harmony/capabilities/skills/_template/` | `docs/architecture/workspaces/skills/` |
| Assistants | `.harmony/agency/assistants/registry.yml` | `.harmony/agency/assistants/_template/` | `docs/architecture/workspaces/assistants.md` |
| Commands | — | — | `docs/architecture/workspaces/commands.md` |
| Checklists | — | — | `docs/architecture/workspaces/checklists.md` |
| Prompts | — | — | `docs/architecture/workspaces/prompts.md` |
| Templates | — | `.harmony/scaffolding/templates/` | `docs/architecture/workspaces/templates.md` |

> **Note:** Workflows are deprecated. See Skills and Missions.
