---
title: "Team: [id]"
description: "[One-line purpose for this team composition]"
---

# Team: [id]

## Purpose

[Describe when this team should be used and what it optimizes for.]

## Composition

- **Lead Agent:** [agent-id]
- **Agents:** [agent-id, ...]
- **Assistants:** [assistant-id, ...]

## Handoff Policy

1. [lead agent planning step]
2. [assistant execution step]
3. [verification/escalation step]

## Workflow Alignment

- **Default workflow (if any):** [workflow-id or none]
- **Optional workflows:** [workflow-id, ...]
- **When to use each:** [short routing notes]

## Composite Skill Alignment

- **Preferred composite skills:** [skill-id, ...]
- **Optional composite skills:** [skill-id, ...]
- **Policy constraints:** [which bundles are disallowed for this team]

## Escalation Rules

- [when to escalate to human]
- [when to pause and request clarification]

## Output Contract

```markdown
## Team Execution Summary

**Team:** [id]
**Lead:** [agent-id]
**Delegations:** [who did what]
**Verification:** [what was checked]
**Outcome:** [result]
```
