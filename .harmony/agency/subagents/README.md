---
title: Agents
description: Autonomous supervisors that orchestrate missions, delegate to assistants, and coordinate complex work.
---

# Agents

Agents are **autonomous AI supervisors** that perceive their environment, reason, plan, and take actions to achieve complex goals. They orchestrate missions, delegate to assistants, and maintain context across sessions.

## Agents vs Assistants

| Characteristic | Agent | Assistant |
|----------------|-------|-----------|
| **Autonomy** | High — reasons, plans, decides | Low — executes assigned tasks |
| **Lifecycle** | Persistent across sessions | Stateless (inherits context) |
| **Scope** | Broad — orchestrates complex work | Focused — scoped operations |
| **State** | Maintains context and memory | No persistent state |
| **Invocation** | Assigned to missions or workspaces | `@mention` or delegation |
| **Delegation** | Delegates to assistants | Escalates to agents/humans |
| **Primary role** | Supervisor | Specialist |

```
┌─────────────────────────────────────────────────────────────────┐
│  AGENT (Supervisor)                                             │
│  Planner, Builder, Verifier, Coordinator                        │
│                                                                 │
│  • Perceives workspace state                                    │
│  • Reasons about goals and constraints                          │
│  • Plans execution strategy                                     │
│  • Delegates to assistants                                      │
│  • Commands missions                                            │
│  • Maintains context across sessions                            │
│                                                                 │
│              │ delegates           │ commands                   │
│              ▼                     ▼                            │
│  ┌─────────────────┐    ┌─────────────────────┐                │
│  │  ASSISTANT      │    │  MISSION            │                │
│  │  (Specialist)   │    │  (Durable Work)     │                │
│  │  @reviewer      │    │  auth-migration     │                │
│  │  @refactor      │    │  billing-v2         │                │
│  └─────────────────┘    └─────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

## Available Agents

| Name | Role | Scope |
|------|------|-------|
| planner | Strategic planning, goal decomposition | Workspace-wide |
| builder | Implementation, code generation | Task-specific |
| verifier | Validation, testing, quality assurance | Task-specific |
| coordinator | Cross-mission orchestration | Multi-mission |

> **Note:** Agent definitions are in development. See `registry.yml` for current status.

## Agent Capabilities

### 1. Perception

Agents perceive their environment by:

- Reading workspace state (`.harmony/continuity/`, `missions/`)
- Analyzing codebase structure and patterns
- Understanding current mission goals and constraints
- Monitoring assistant outputs and task completion

### 2. Reasoning

Agents reason about:

- Goal decomposition (breaking complex goals into sub-goals)
- Constraint satisfaction (respecting workspace conventions)
- Risk assessment (identifying potential issues)
- Priority ordering (what to do first)

### 3. Planning

Agents create plans by:

- Identifying required tasks and dependencies
- Selecting appropriate assistants for delegation
- Sequencing work for efficiency
- Establishing checkpoints and verification gates

### 4. Delegation

Agents delegate by:

- Assigning focused tasks to assistants
- Providing necessary context for the task
- Specifying expected output format
- Handling escalations from assistants

### 5. Orchestration

Agents orchestrate by:

- Commanding missions (long-running durable work)
- Coordinating multiple assistants
- Managing mission state and checkpoints
- Ensuring mission success criteria are met

## Directory Structure

```text
.harmony/agency/agents/
├── README.md              # This file
├── registry.yml           # Agent index and configuration
├── _template/             # Template for new agents
│   └── agent.md
├── planner/
│   └── agent.md           # Planner agent spec
├── builder/
│   └── agent.md           # Builder agent spec
└── verifier/
    └── agent.md           # Verifier agent spec

.harmony/agency/agents/
├── README.md              # Workspace-specific agents
└── registry.yml           # Extends shared registry
```

## Registry Format

The `registry.yml` maps agent roles to definitions:

```yaml
schema_version: "1.0"
default: planner  # Default agent for workspace

agents:
  - name: planner
    path: planner/
    role: "Strategic planning and goal decomposition"
    capabilities:
      - goal_decomposition
      - task_planning
      - assistant_delegation
      - mission_command

  - name: builder
    path: builder/
    role: "Implementation and code generation"
    capabilities:
      - code_generation
      - skill_execution
      - test_writing

  - name: verifier
    path: verifier/
    role: "Validation and quality assurance"
    capabilities:
      - test_execution
      - code_review
      - checklist_verification
```

## Agent Specification Format

Each `agent.md` follows this structure:

```markdown
---
title: "Agent: [name]"
description: "[One-line description]"
role: [planner|builder|verifier|coordinator]
---

# Agent: [name]

## Role

[Description of the agent's primary role and responsibilities.]

## Capabilities

- [Capability 1]
- [Capability 2]

## Operating Principles

1. [Principle 1]
2. [Principle 2]

## Delegation Rules

### When to Delegate to Assistants

- [Condition 1] → delegate to @[assistant]
- [Condition 2] → delegate to @[assistant]

### When to Handle Directly

- [Condition where agent handles work itself]

## Mission Command

### Missions This Agent Commands

- [Mission type 1]
- [Mission type 2]

### Mission Lifecycle Management

[How the agent manages mission state and checkpoints]

## Context Management

### What Context to Maintain

- [Context item 1]
- [Context item 2]

### Cross-Session Continuity

[How the agent maintains context across sessions]

## Escalation

### When to Escalate to Human

- [Condition 1]
- [Condition 2]
```

## Relationship to Other Primitives

### Agents → Missions

Agents **command** missions. A mission is a durable, multi-session orchestration unit that an agent owns and drives to completion.

```yaml
# Mission owned by planner agent
missions/auth-migration/mission.yml:
  owner: planner
  states:
    - id: audit
      skill: refactor
    - id: human-review
      type: checkpoint
```

### Agents → Assistants

Agents **delegate** to assistants. When focused, specialized work is needed, the agent assigns the task to an appropriate assistant.

```text
Agent: "I need a code review for this change."
→ Delegates to @reviewer
→ Reviewer executes and returns findings
→ Agent incorporates findings into plan
```

### Agents → Skills

Agents can **invoke** skills directly for capability execution, or skills can be invoked by missions that agents command.

```text
Agent commanding mission:
  Mission state invokes skill: refactor
  Skill executes and returns output
  Mission transitions to next state
```

## When to Define a New Agent

| Scenario | Define Agent? | Alternative |
|----------|---------------|-------------|
| Autonomous orchestration needed | Yes | — |
| Persistent context across sessions | Yes | — |
| Commands missions | Yes | — |
| Focused, stateless specialist task | No | Create Assistant |
| Composable capability with I/O | No | Create Skill |
| One-off task, no persistence | No | Use existing agent |

## Tiered Model

| Location | Scope | Purpose |
|----------|-------|---------|
| `.harmony/agency/agents/` | Shared across workspaces | Portable agent definitions |
| `.harmony/agency/agents/` | Workspace-specific | Override or extend shared agents |

Workspace agents can:

- Override shared agent behavior for project-specific needs
- Add new agents specific to the workspace
- Extend shared agents with additional capabilities

## See Also

- [Assistants](../assistants/README.md) — Focused specialists
- [Skills](../skills/README.md) — Composable capabilities
- [Missions](../../.harmony/orchestration/missions/README.md) — Durable orchestration
- `docs/architecture/workspaces/agents.md` — Full agent documentation
