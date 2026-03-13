# Octon Agent and Assistant Standard

This document defines the **universal standard for agents and assistants** within the Octon multi-agent architecture. It establishes portable, framework-agnostic definitions that work across any harness (Cursor, Claude Code, Codex, or custom implementations).

---

## Design Goals

The Octon agent/assistant standard MUST be:

1. **Portable**: Works as plain files/folders in git, symlinked to harness directories
2. **Harness-agnostic**: Doesn't assume a specific LLM API or orchestration runtime
3. **Framework-agnostic**: Can be mapped to LangGraph, Semantic Kernel, or custom code
4. **Composable**: Agents delegate to assistants; assistants use skills
5. **Progressive disclosure**: Discovery metadata first, full instructions on activation

---

## Multi-Agent Hierarchy

The Octon architecture establishes a clear hierarchy:

```
┌─────────────────────────────────────────────────────────────────┐
│  AGENT (Supervisor)                                             │
│  Planner, Builder, Verifier, Coordinator                        │
│                                                                 │
│  • Autonomous: perceives, reasons, plans, decides               │
│  • Persistent: maintains context across sessions                │
│  • Orchestrates: commands missions, delegates to assistants     │
│                                                                 │
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

### Agents vs Assistants

| Characteristic | Agent (Supervisor) | Assistant (Specialist) |
|----------------|-------------------|------------------------|
| **Autonomy** | High — reasons, plans, decides | Focused — executes assigned tasks |
| **Lifecycle** | Persistent across sessions | Stateless (inherits context) |
| **Scope** | Broad — orchestrates complex work | Narrow — scoped operations |
| **State** | Maintains context and memory | No persistent state |
| **Invocation** | Assigned to missions/workspaces | `@mention` or delegation |
| **Delegation** | Delegates **to** assistants | Escalates **to** agents/humans |
| **Primary role** | Supervisor, coordinator | Specialist, executor |

---

## Directory Structure

### Shared Foundation (`.octon/`)

```text
.octon/
├── agents/                    # Shared agent definitions
│   ├── README.md              # Agent overview
│   ├── registry.yml           # Agent index and configuration
│   ├── _template/             # Template for new agents
│   │   └── agent.md
│   ├── planner/
│   │   └── agent.md           # Planner specification
│   ├── builder/
│   │   └── agent.md           # Builder specification
│   └── verifier/
│       └── agent.md           # Verifier specification
│
└── assistants/                # Shared assistant definitions
    ├── README.md              # Assistant overview
    ├── registry.yml           # @mention mapping
    ├── _template/             # Template for new assistants
    │   └── assistant.md
    ├── reviewer/
    │   └── assistant.md       # Reviewer specification
    ├── refactor/
    │   └── assistant.md       # Refactor specification
    └── docs/
        └── assistant.md       # Docs writer specification
```

### Workspace Layer (`.workspace/`)

```text
.workspace/
├── agents/                    # Workspace-specific agents
│   ├── README.md              # Override or extend shared
│   ├── registry.yml           # Extends shared registry
│   └── <custom-agent>/        # Project-specific agents
│       └── agent.md
│
└── assistants/                # Workspace-specific assistants
    ├── README.md              # Override or extend shared
    ├── registry.yml           # Extends shared registry
    └── <custom-assistant>/    # Project-specific assistants
        └── assistant.md
```

### Inheritance Rule

**Workspace extends shared.** Resolution order:

1. Check `.workspace/` first
2. Fall back to `.octon/`
3. If same `name` exists in both, workspace definition wins

---

## Agent Specification Format

### `registry.yml`

```yaml
# .octon/agents/registry.yml
schema_version: "1.0"
default: planner  # Default agent for workspace

agents:
  - name: planner
    path: planner/
    role: "Strategic planning, goal decomposition, and work orchestration"
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
    role: "Implementation, code generation, and feature development"
    capabilities:
      - code_generation
      - skill_execution
      - test_writing
      - feature_implementation
    delegates_to:
      - "@reviewer"
      - "@docs"

  - name: verifier
    path: verifier/
    role: "Validation, testing, and quality assurance"
    capabilities:
      - test_execution
      - code_review
      - checklist_verification
      - quality_assurance
    delegates_to:
      - "@reviewer"
      - "@refactor"
```

### Registry Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Agent identifier (lowercase, hyphens allowed) |
| `path` | Yes | Relative path to agent directory |
| `role` | Yes | One-line description of responsibilities |
| `capabilities` | Yes | List of capabilities (for discovery/routing) |
| `delegates_to` | No | Assistants this agent delegates to |

### `agent.md` Format

```markdown
---
title: "Agent: [name]"
description: "[One-line description of the agent's role]"
role: [planner|builder|verifier|coordinator]
---

# Agent: [name]

## Role

[Description of the agent's primary role and responsibilities.]

## Capabilities

- **[Capability 1]:** [Description]
- **[Capability 2]:** [Description]

## Operating Principles

1. [Principle 1]
2. [Principle 2]

## Delegation Rules

### When to Delegate

| Condition | Delegate To | Rationale |
|-----------|-------------|-----------|
| Code review needed | @reviewer | Specialist in quality |
| Refactoring required | @refactor | Specialist in restructuring |

### When to Handle Directly

- [Condition where agent handles work itself]
- [Condition requiring agent-level judgment]

## Mission Command

### Missions This Agent Commands

- **[Mission type]:** [When to create/command]

### Mission Management

[How the agent manages mission lifecycle, checkpoints, success criteria]

## Context Management

### Context to Maintain

- [Context item 1]
- [Context item 2]

### Cross-Session Continuity

[How context persists and recovers across sessions]

## Escalation

### Escalate to Human When

- [Condition]: [Why human judgment needed]

## Skills Used

| Skill | When Used |
|-------|-----------|
| [skill-id] | [Condition or phase] |
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Format: "Agent: [name]" |
| `description` | Yes | One-line description (1-256 chars) |
| `role` | Yes | One of: `planner`, `builder`, `verifier`, `coordinator` |

---

## Assistant Specification Format

### `registry.yml`

```yaml
# .octon/assistants/registry.yml
schema_version: "1.0"
default: null  # Optional default assistant

assistants:
  - name: reviewer
    path: reviewer/
    aliases: ["@review", "@rev"]
    description: "Code review specialist for quality, style, and correctness."

  - name: refactor
    path: refactor/
    aliases: ["@refactor", "@ref"]
    description: "Refactoring specialist for code improvements."

  - name: docs
    path: docs/
    aliases: ["@docs", "@doc"]
    description: "Documentation specialist for clarity and completeness."
```

### Registry Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Assistant identifier |
| `path` | Yes | Relative path to assistant directory |
| `aliases` | Yes | @mention triggers (including primary) |
| `description` | Yes | One-line description |

### `assistant.md` Format

```markdown
---
title: "Assistant: [name]"
description: "[One-line description]"
access: agent
---

# Assistant: [name]

## Mission

[One sentence defining what this assistant does.]

## Invocation

- **Direct:** Human types `@[name] [task]` in chat
- **Delegated:** Agent delegates subtask to this assistant

## Operating Rules

1. [Rule 1]
2. [Rule 2]

## Output Format

[Structured output template]

## Boundaries

- Never [constraint 1]
- Prefer [preference 1]

## When to Escalate

- If [condition], escalate to [agent/human]

## Skills Used

| Skill | When Used |
|-------|-----------|
| [skill-id] | [Condition] |
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Format: "Assistant: [name]" |
| `description` | Yes | One-line description (1-256 chars) |
| `access` | Yes | `human`, `agent`, or `both` |

---

## Progressive Disclosure

Both agents and assistants follow a three-stage disclosure pattern:

1. **Discovery**: Load only `registry.yml` entries (name, role/description, capabilities/aliases)
2. **Activation**: Load full `agent.md` or `assistant.md` body
3. **Execution**: Load referenced skills, scripts, or context files as needed

This mirrors the skill progressive disclosure pattern and keeps context windows efficient.

---

## Invocation Patterns

### Agent Invocation

Agents are assigned to workspaces or missions, not invoked directly:

```yaml
# .workspace/progress/current-state.json
{
  "active_agent": "planner",
  "assigned_missions": ["auth-migration", "billing-v2"]
}
```

### Assistant Invocation

**Direct (human):**
```text
@reviewer Check this PR for security issues
@refactor Extract method from this large function
@docs Improve the API documentation clarity
```

**Delegated (agent):**
```text
Agent: "I need a code review for the authentication changes."
→ Delegates to @reviewer
→ Reviewer executes and returns structured findings
→ Agent incorporates findings into plan
```

### @mention Router Rules

| Rule | Description |
|------|-------------|
| **Turn-level** | If message starts with `@name`, route entire turn to that assistant |
| **Inline delegation** | If `@name` appears mid-message, treat as subtask delegation |
| **Locality** | Nearest `registry.yml` wins (workspace overrides shared) |

---

## Relationship to Other Primitives

### Agents → Missions

Agents **command** missions. A mission is a durable, multi-session orchestration unit.

```yaml
# .workspace/missions/auth-migration/mission.yml
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
```

### Agents → Assistants

Agents **delegate** to assistants when focused, specialized work is needed.

```text
Agent perceives: "PR ready for review"
Agent plans: "Delegate code review to specialist"
Agent delegates: → @reviewer
Reviewer executes: Returns structured findings
Agent incorporates: Findings inform next decision
```

### Assistants → Skills

Assistants **use** skills to complete tasks. Skills are composable capabilities with defined I/O.

```text
@reviewer invoked: "Review auth changes"
Reviewer uses: security-checklist skill
Skill executes: Returns findings
Reviewer formats: Structured review output
```

### Agents → Skills

Agents can invoke skills directly (via missions) or indirectly (via assistants).

```text
Mission state: "Execute refactor skill"
Skill invoked: refactor skill runs
Output captured: Results stored in mission state
Mission transitions: Next state based on output
```

---

## Delegation Contract

When an agent delegates to an assistant, the delegation includes:

| Element | Description |
|---------|-------------|
| **Task** | Clear description of what to do |
| **Context** | Relevant information for the task |
| **Expected output** | Format and criteria for results |
| **Escalation path** | What to do if blocked |

### Example Delegation

```markdown
## Delegation: Code Review

**To:** @reviewer

**Task:** Review the authentication changes in PR #123

**Context:**
- Files: `src/auth/**`
- Focus: Security implications of session → JWT migration
- Constraints: Must maintain backward compatibility

**Expected Output:**
- Verdict: Approve / Request Changes / Needs Discussion
- Findings: Severity-tagged (Critical/Important/Minor)
- Suggested patches: Code blocks with fixes

**If Blocked:**
- Unclear requirements → Request human clarification
- Architectural concerns → Escalate to Planner agent
```

---

## Context Sharing

### Agent Context (Persistent)

Agents maintain context across sessions via:

```text
.workspace/
├── progress/
│   ├── current-state.json    # Active agent, missions, phase
│   └── session-log.md        # Cross-session continuity
├── missions/
│   └── <mission>/
│       └── state.json        # Mission-specific state
└── context/
    └── decisions.md          # Architectural decisions
```

### Assistant Context (Inherited)

Assistants receive context from callers:

| Source | What's Shared |
|--------|---------------|
| Agent delegation | Task, relevant files, constraints |
| Human @mention | Message context, referenced files |
| Mission state | Current phase, prior skill outputs |

Assistants do not persist state—they complete their task and return results.

---

## When to Define Each

| Scenario | Create | Rationale |
|----------|--------|-----------|
| Autonomous orchestration needed | **Agent** | Reasons, plans, delegates |
| Persistent context across sessions | **Agent** | Memory required |
| Commands missions (durable work) | **Agent** | Owns lifecycle |
| Focused, specialized task | **Assistant** | Domain expertise |
| Consistent output format needed | **Assistant** | Structured results |
| Agent should be able to delegate | **Assistant** | Specialist available |
| Composable capability with I/O | **Skill** | Reusable capability |
| One-off task, no reuse | — | Use existing primitives |

---

## Security and Safety

### Tool Access

Agents and assistants follow skill safety policies:

```yaml
# From SKILL.md allowed-tools section
allowed-tools:
  - Read         # Always safe
  - Grep         # Search only
  - StrReplace   # Edit existing files
deny-by-default: true
```

### Escalation Requirements

Both agents and assistants MUST escalate to humans when:

- **Irreversible actions** — Destructive operations require confirmation
- **Security-sensitive** — Credentials, permissions, access control
- **Ambiguous requirements** — Unclear success criteria
- **Out of scope** — Task exceeds defined boundaries

### Audit Trail

All agent/assistant actions are logged:

```text
.workspace/skills/logs/runs/
└── YYYY-MM-DD_HHMMSS_<skill-id>.log
```

---

## Minimal Working Examples

### Example: Planner Agent

```markdown
---
title: "Agent: Planner"
description: "Strategic planning, goal decomposition, and work orchestration"
role: planner
---

# Agent: Planner

## Role

Decompose complex goals into actionable tasks, create execution plans, 
and coordinate work across assistants and missions.

## Capabilities

- **Goal decomposition:** Break complex goals into sub-goals
- **Task planning:** Create sequenced plans with dependencies
- **Assistant delegation:** Assign focused work to specialists
- **Mission command:** Own and drive durable orchestration

## Operating Principles

1. Clarify before acting — understand goals and constraints first
2. Delegate specialist work — use assistants for focused tasks
3. Verify before completing — ensure success criteria are met

## Delegation Rules

### When to Delegate

| Condition | Delegate To | Rationale |
|-----------|-------------|-----------|
| Code review needed | @reviewer | Quality specialist |
| Refactoring required | @refactor | Restructuring specialist |
| Documentation update | @docs | Clarity specialist |

### When to Handle Directly

- Strategic decisions requiring cross-domain judgment
- Mission creation and lifecycle management
- Conflict resolution between competing priorities

## Mission Command

### Missions This Agent Commands

- **Migration missions:** Multi-phase system changes
- **Feature missions:** Complex feature development

### Mission Management

Monitor mission state, handle checkpoint approvals, verify success 
criteria, and mark missions complete.

## Context Management

### Context to Maintain

- Active goals and their decomposition
- Mission states and blockers
- Recent assistant outputs and findings

### Cross-Session Continuity

Load context from `.workspace/progress/` at session start.
Update `current-state.json` after significant decisions.

## Escalation

### Escalate to Human When

- Architectural decisions with long-term implications
- Conflicting requirements that need clarification
- Security-sensitive changes requiring approval
```

### Example: Reviewer Assistant

```markdown
---
title: "Assistant: Reviewer"
description: "Code review specialist for quality, style, correctness, and security"
access: agent
---

# Assistant: Reviewer

## Mission

Review code changes for quality, style, correctness, and security issues, 
providing actionable feedback with specific recommendations.

## Invocation

- **Direct:** Human types `@reviewer [task]` or `@rev [task]`
- **Delegated:** Agent delegates review subtask

## Operating Rules

1. Focus on the specific code or changes provided
2. Prioritize by severity: security > correctness > style
3. Provide actionable feedback with line references
4. Suggest fixes, not just problems

## Output Format

### Review Summary
**Verdict:** [Approve / Request Changes / Needs Discussion]

### Findings
- **Critical:** [severity-tagged findings]
- **Important:** [severity-tagged findings]
- **Minor:** [severity-tagged findings]

### Suggested Patches
[Code blocks with fixes]

## Boundaries

- Never approve code with security vulnerabilities
- Stay within the scope of provided changes
- Don't make architectural recommendations (escalate those)

## When to Escalate

- Architectural concerns → Escalate to Planner agent
- Unclear requirements → Request human clarification
- Security vulnerabilities found → Flag for immediate human review
```

---

## Harness Integration

### Symlink Pattern

Harness directories integrate via symlinks:

```text
.cursor/agents/planner    → ../../.octon/agents/planner
.claude/agents/planner    → ../../.octon/agents/planner
.codex/agents/planner     → ../../.octon/agents/planner

.cursor/assistants/reviewer  → ../../.octon/assistants/reviewer
.claude/assistants/reviewer  → ../../.octon/assistants/reviewer
```

### Benefits

| Benefit | Description |
|---------|-------------|
| Single source of truth | Definition lives in `.octon/` |
| Harness portability | Same agent/assistant works everywhere |
| Easy updates | Change once, all harnesses get update |

---

## See Also

| Resource | Location |
|----------|----------|
| Agent README | `.octon/agents/README.md` |
| Agent Registry | `.octon/agents/registry.yml` |
| Agent Template | `.octon/agents/_template/agent.md` |
| Assistant README | `.octon/assistants/README.md` |
| Assistant Registry | `.octon/assistants/registry.yml` |
| Assistant Template | `.octon/assistants/_template/assistant.md` |
| Primitives Overview | `.octon/context/primitives.md` |
| Skills Specification | `docs/architecture/workspaces/skills/` |
| Agents Architecture | `docs/architecture/workspaces/agents.md` |
| Assistants Architecture | `docs/architecture/workspaces/assistants.md` |
