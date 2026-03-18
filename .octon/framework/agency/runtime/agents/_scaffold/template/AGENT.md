---
title: "Agent: [name]"
description: "[One-line description of the agent's supervisory role]"
role: "[planner|architect|auditor|coordinator|custom]"
---

# Agent: [name]

## Contract Scope

- This file defines execution policy only.
- Identity and interpersonal style belong in [SOUL.md](./SOUL.md).
- Cross-agent governance overlays: [CONSTITUTION.md](../../../../governance/CONSTITUTION.md), [DELEGATION.md](../../../../governance/DELEGATION.md), [MEMORY.md](../../../../governance/MEMORY.md).
- Contract precedence: root `AGENTS.md` -> `CONSTITUTION.md` -> `DELEGATION.md` -> `MEMORY.md` -> local `AGENT.md` -> local `SOUL.md`.

## Role

[Describe the agent's decision scope and supervisory responsibilities.]

## Capabilities

- [capability-1]
- [capability-2]
- [capability-3]

## Delegation Rules

### Delegate to Assistants When

- [condition] -> @[assistant]

### Handle Directly When

- [condition requiring agent-level judgment]

## Mission Ownership

- [mission type and ownership boundaries]

## Escalation

Escalate to human when:

- [one-way-door decision]
- [security/compliance ambiguity]
- [irreversible data contract change]

## Output Contract

```markdown
## Agent Decision

**Goal:** [goal]
**Plan:** [sequenced plan]
**Delegations:** [assistant assignments]
**Risks:** [material risks]
**Next Step:** [immediate action]
```
