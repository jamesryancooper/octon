---
title: Workspace Agents
description: Autonomous supervisors that orchestrate missions, delegate to assistants, and coordinate complex work.
---

# Workspace Agents

Agents are **autonomous AI supervisors** that perceive their environment, reason, plan, and take actions to achieve complex goals. They represent the highest level of autonomy in the Harmony multi-agent architecture, orchestrating missions, delegating to assistants, and maintaining context across sessions.

---

## What is an Agent?

An agent is an autonomous AI entity that:

- **Perceives** workspace state, codebase structure, and task context
- **Reasons** about goals, constraints, and trade-offs
- **Plans** execution strategies and task sequences
- **Delegates** focused work to specialized assistants
- **Commands** missions (durable, multi-session orchestration)
- **Maintains** context and memory across sessions

Agents are the **supervisors** in a multi-agent system. They break complex problems into manageable components, coordinate specialists (assistants), and drive work to completion.

---

## Multi-Agent Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        WORKSPACE                                 │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  AGENT (Supervisor)                                       │   │
│  │  • Perceives environment                                  │   │
│  │  • Reasons about goals                                    │   │
│  │  • Plans execution                                        │   │
│  │  • Maintains cross-session context                        │   │
│  └─────────────────────┬────────────────────────────────────┘   │
│                        │                                         │
│           ┌────────────┴────────────┐                           │
│           │                         │                            │
│           ▼                         ▼                            │
│  ┌─────────────────┐      ┌─────────────────┐                   │
│  │ MISSIONS        │      │ ASSISTANTS      │                   │
│  │ (Durable Orch.) │      │ (Specialists)   │                   │
│  │                 │      │                 │                   │
│  │ auth-migration  │      │ @reviewer       │                   │
│  │ billing-v2      │      │ @refactor       │                   │
│  │ docs-overhaul   │      │ @docs           │                   │
│  └────────┬────────┘      └────────┬────────┘                   │
│           │                        │                             │
│           │ invokes                │ uses                        │
│           ▼                        ▼                             │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  SKILLS (Composable Capabilities)                         │   │
│  │  refactor, create-workspace, synthesize-research, ...    │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Agents vs Assistants

The distinction between agents and assistants is fundamental to the multi-agent architecture:

| Characteristic | Agent (Supervisor) | Assistant (Specialist) |
|----------------|-------------------|------------------------|
| **Autonomy** | High — reasons, plans, decides | Low — executes assigned tasks |
| **Lifecycle** | Persistent across sessions | Stateless (inherits context) |
| **Scope** | Broad — orchestrates complex work | Focused — scoped operations |
| **State** | Maintains context and memory | No persistent state |
| **Invocation** | Assigned to missions/workspaces | `@mention` or delegation |
| **Delegation** | Delegates to assistants | Escalates to agents/humans |
| **Primary role** | Supervisor, coordinator | Specialist, executor |
| **Examples** | Planner, Builder, Verifier | Reviewer, Refactor, Docs |

### The Supervisor-Specialist Relationship

```mermaid
graph TB
    subgraph Agent [Agent - Planner]
        perceive[Perceive State]
        reason[Reason About Goals]
        plan[Plan Execution]
        delegate[Delegate Tasks]
    end

    subgraph Assistants [Assistants]
        reviewer[@reviewer]
        refactor[@refactor]
        docs[@docs]
    end

    subgraph Skills [Skills]
        skill1[refactor skill]
        skill2[synthesize skill]
    end

    perceive --> reason
    reason --> plan
    plan --> delegate

    delegate -->|"review this PR"| reviewer
    delegate -->|"extract method"| refactor
    delegate -->|"update docs"| docs

    reviewer -->|uses| skill1
    refactor -->|uses| skill1
    docs -->|uses| skill2
```

**Key insight:** Agents think about *what* needs to be done and *who* should do it. Assistants focus on *how* to do their specific task well.

---

## Agent Capabilities

### 1. Perception

Agents perceive their environment by:

- **Reading workspace state** — `progress/`, `missions/`, `context/`
- **Analyzing codebase** — Structure, patterns, conventions
- **Understanding goals** — Mission objectives, success criteria
- **Monitoring progress** — Task completion, blockers, risks

### 2. Reasoning

Agents reason about:

- **Goal decomposition** — Breaking complex goals into sub-goals
- **Constraint satisfaction** — Respecting conventions and rules
- **Risk assessment** — Identifying potential issues early
- **Trade-off analysis** — Balancing competing concerns
- **Priority ordering** — Determining what to do first

### 3. Planning

Agents create plans by:

- **Identifying tasks** — What needs to be done
- **Mapping dependencies** — What depends on what
- **Selecting assistants** — Who should do each task
- **Sequencing work** — Optimal ordering for efficiency
- **Establishing checkpoints** — Verification and approval gates

### 4. Delegation

Agents delegate by:

- **Assigning focused tasks** — Scoped work for specialists
- **Providing context** — Necessary information for the task
- **Specifying outputs** — Expected format and criteria
- **Handling escalations** — Responding to assistant questions

### 5. Mission Command

Agents command missions by:

- **Owning mission lifecycle** — Created → Active → Completed
- **Managing state transitions** — Driving the state machine forward
- **Coordinating checkpoints** — Human approval gates
- **Ensuring success criteria** — Verifying mission completion

---

## Agent Roles

### Planner

**Role:** Strategic planning and goal decomposition

**Responsibilities:**

- Decompose complex goals into actionable tasks
- Create execution plans with dependencies
- Assign missions and coordinate their completion
- Make architectural decisions

**Delegates to:** All assistants based on task type

### Builder

**Role:** Implementation and code generation

**Responsibilities:**

- Implement features and fixes
- Execute skills for code transformation
- Write tests for new code
- Ensure code quality standards

**Delegates to:** @reviewer (code review), @docs (documentation)

### Verifier

**Role:** Validation and quality assurance

**Responsibilities:**

- Verify task completion against criteria
- Run tests and validation checks
- Ensure consistency with conventions
- Gate mission transitions

**Delegates to:** @reviewer (deep review), @refactor (cleanup)

### Coordinator

**Role:** Cross-mission orchestration

**Responsibilities:**

- Coordinate work across multiple missions
- Resolve conflicts and dependencies
- Ensure workspace-wide consistency
- Escalate cross-cutting concerns

**Delegates to:** Other agents, all assistants

---

## Directory Structure

```text
.harmony/agency/agents/                # Shared agent definitions
├── README.md                   # Overview and quick reference
├── registry.yml                # Agent index and capabilities
├── _template/                  # Template for new agents
│   └── agent.md
├── planner/
│   └── agent.md                # Planner specification
├── builder/
│   └── agent.md                # Builder specification
└── verifier/
    └── agent.md                # Verifier specification

.harmony/agency/agents/              # Workspace-specific agents
├── README.md                   # Workspace agent extensions
├── registry.yml                # Extends shared registry
└── <custom-agent>/             # Project-specific agents
    └── agent.md
```

---

## Registry Format

The `registry.yml` indexes agents and their capabilities:

```yaml
schema_version: "1.0"
default: planner  # Default agent for this workspace

agents:
  - name: planner
    path: planner/
    role: "Strategic planning and goal decomposition"
    capabilities:
      - goal_decomposition
      - task_planning
      - assistant_delegation
      - mission_command
    delegates_to:
      - "@reviewer"
      - "@refactor"
      - "@docs"

  - name: builder
    path: builder/
    role: "Implementation and code generation"
    capabilities:
      - code_generation
      - skill_execution
      - test_writing
    delegates_to:
      - "@reviewer"
      - "@docs"

  - name: verifier
    path: verifier/
    role: "Validation and quality assurance"
    capabilities:
      - test_execution
      - code_review
      - checklist_verification
    delegates_to:
      - "@reviewer"
      - "@refactor"
```

---

## Agent Specification Format

Each `agent.md` defines an agent's behavior:

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

- [Capability 1]: [Description]
- [Capability 2]: [Description]

## Operating Principles

1. [Principle 1]
2. [Principle 2]
3. [Principle 3]

## Delegation Rules

### When to Delegate

| Condition | Delegate To | Rationale |
|-----------|-------------|-----------|
| Code review needed | @reviewer | Specialist in quality |
| Refactoring required | @refactor | Specialist in restructuring |
| Documentation update | @docs | Specialist in clarity |

### When to Handle Directly

- [Condition where agent handles work itself]
- [Condition requiring agent-level judgment]

## Mission Command

### Missions This Agent Commands

- [Mission type 1]: [When to create/command]
- [Mission type 2]: [When to create/command]

### Mission Management

[How the agent manages mission lifecycle, checkpoints, and success criteria]

## Context Management

### Context to Maintain

- [Context item 1]
- [Context item 2]

### Cross-Session Continuity

[How the agent persists and recovers context across sessions]

## Escalation

### Escalate to Human When

- [Condition 1]: [Why human judgment needed]
- [Condition 2]: [Why human judgment needed]
```

---

## Relationship to Missions

Agents **command** missions. A mission is a durable, multi-session orchestration unit that runs on the FlowKit runtime. The agent owns the mission and drives it to completion.

```yaml
# Mission assigned to planner agent
# .harmony/orchestration/missions/auth-migration/mission.yml

name: auth-migration
goal: "Migrate from session-based to JWT authentication"
owner: planner  # ← Agent that commands this mission

states:
  - id: audit
    type: skill
    skill: refactor
    params:
      phase: audit
    transitions:
      - on: complete → plan

  - id: plan
    type: skill
    skill: refactor
    params:
      phase: plan
    transitions:
      - on: ready → human-review

  - id: human-review
    type: checkpoint
    prompt: "Review migration plan and approve"
    transitions:
      - on: approved → execute
      - on: rejected → plan
```

**Agent responsibilities for missions:**

1. **Create** missions when complex, durable work is identified
2. **Own** the mission lifecycle (Active → Completed)
3. **Drive** state transitions by invoking skills and handling checkpoints
4. **Verify** success criteria before completing the mission

---

## Relationship to Assistants

Agents **delegate** to assistants when focused, specialized work is needed.

```text
┌─────────────────────────────────────────────────────────────────┐
│  Agent: Planner                                                 │
│                                                                 │
│  "I've analyzed the task. I need a code review before merging." │
│                                                                 │
│       ┌───────────────────────────────────────────────────┐    │
│       │  Delegation                                        │    │
│       │  Task: "Review the authentication changes"         │    │
│       │  Context: PR #123, files: src/auth/**             │    │
│       │  Expected: Structured review with verdict          │    │
│       └───────────────────────────┬───────────────────────┘    │
│                                   │                             │
│                                   ▼                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Assistant: @reviewer                                    │   │
│  │                                                          │   │
│  │  [Executes focused review task]                         │   │
│  │  [Returns structured findings]                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                   │                             │
│                                   ▼                             │
│  Agent receives findings, incorporates into plan                │
└─────────────────────────────────────────────────────────────────┘
```

**Delegation rules:**

- Delegate when **specialist focus** improves quality
- Delegate when **consistent output format** is important
- Delegate when task is **self-contained** and scoped
- Keep when **judgment across domains** is required
- Keep when **context from multiple sources** is needed

---

## When to Define a New Agent

| Scenario | Create Agent? | Alternative |
|----------|---------------|-------------|
| Autonomous orchestration needed | Yes | — |
| Persistent context across sessions | Yes | — |
| Commands missions (durable work) | Yes | — |
| Coordinates multiple assistants | Yes | — |
| Focused, stateless specialist task | No | Create Assistant |
| Composable capability with I/O | No | Create Skill |
| One-off task, no persistence | No | Use existing agent |

---

## Tiered Model (`.harmony/` vs workspace-specific)

| Location | Scope | Purpose |
|----------|-------|---------|
| `.harmony/agency/agents/` | Shared across workspaces | Portable agent definitions |
| `.harmony/agency/agents/` | Workspace-specific | Override or extend shared agents |

**Workspace agents can:**

- Override shared agent behavior for project-specific needs
- Add project-specific agents (e.g., `security-agent` for a security-focused project)
- Extend shared agents with additional capabilities or delegation rules

**Merge behavior:** Workspace definitions extend (not replace) shared definitions. If a workspace agent has the same `name` as a shared agent, the workspace definition wins.

---

## Decision Heuristic

```
Is the work...
├── Autonomous, requiring judgment and planning?
│   └── Needs to persist across sessions?
│       └── Yes → AGENT (supervisor)
│       └── No, one-off → Use existing agent
├── Focused, specialized task?
│   └── ASSISTANT (specialist)
├── Composable capability with I/O?
│   └── SKILL (capability)
└── Durable, multi-session orchestration?
    └── MISSION (owned by an agent)
```

---

## See Also

- [Assistants](./assistants.md) — Focused specialists that serve agents
- [Missions](./missions.md) — Durable orchestration units commanded by agents
- [Skills](./skills/README.md) — Composable capabilities used by agents and assistants
- [Taxonomy](./taxonomy.md) — Classification of all workspace artifacts
- `.harmony/agency/agents/` — Shared agent definitions
- `.harmony/cognition/context/primitives.md` — All Harmony primitives
