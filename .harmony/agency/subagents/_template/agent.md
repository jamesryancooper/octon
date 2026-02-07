---
title: "Agent: [name]"
description: "[One-line description of the agent's role]"
role: [planner|builder|verifier|coordinator]
---

# Agent: [name]

## Role

[Description of the agent's primary role and responsibilities. What kind of work does this agent supervise? What problems does it solve?]

## Capabilities

- **[Capability 1]:** [Description of what this capability enables]
- **[Capability 2]:** [Description of what this capability enables]
- **[Capability 3]:** [Description of what this capability enables]

## Operating Principles

1. [Principle 1: How the agent approaches work]
2. [Principle 2: Core value or constraint]
3. [Principle 3: Quality or safety guideline]

## Delegation Rules

### When to Delegate

| Condition | Delegate To | Rationale |
|-----------|-------------|-----------|
| [Condition 1] | @[assistant] | [Why this assistant is appropriate] |
| [Condition 2] | @[assistant] | [Why this assistant is appropriate] |
| [Condition 3] | @[assistant] | [Why this assistant is appropriate] |

### When to Handle Directly

- [Condition where agent handles work itself]
- [Condition requiring agent-level judgment]
- [Condition where delegation would be inefficient]

## Mission Command

### Missions This Agent Commands

- **[Mission type 1]:** [When to create/command this type]
- **[Mission type 2]:** [When to create/command this type]

### Mission Management

[How the agent manages mission lifecycle:
- How it monitors mission state
- How it handles checkpoints
- How it verifies success criteria
- How it handles mission completion or cancellation]

## Context Management

### Context to Maintain

- [Context item 1: Information the agent tracks across sessions]
- [Context item 2: State that persists]
- [Context item 3: Memory that matters]

### Cross-Session Continuity

[How the agent persists and recovers context:
- Where context is stored
- How it's loaded at session start
- How it's updated during work]

## Escalation

### Escalate to Human When

- [Condition 1: Why human judgment is needed]
- [Condition 2: Why human judgment is needed]
- [Condition 3: Why human judgment is needed]

### Escalation Format

```markdown
## Escalation Request

**Reason:** [Why escalation is needed]

**Context:** [Relevant background]

**Decision Needed:** [What the human must decide]

**Options:**
1. [Option A]: [Implications]
2. [Option B]: [Implications]

**Recommendation:** [Agent's recommendation if any]
```

## Skills Used

| Skill | When Used |
|-------|-----------|
| [skill-id] | [Condition or phase] |
| [skill-id] | [Condition or phase] |

## Example Scenarios

### Scenario 1: [Description]

[How the agent handles this scenario, including delegation and mission command decisions]

### Scenario 2: [Description]

[How the agent handles this scenario, including delegation and mission command decisions]
