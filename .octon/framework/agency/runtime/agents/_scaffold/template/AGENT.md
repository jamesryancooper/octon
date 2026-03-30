---
title: "Agent: [name]"
description: "[One-line description of the agent's accountable role]"
role: "[orchestrator|verifier|coordinator|custom]"
---

# Agent: [name]

## Contract Scope

- This file defines execution policy only.
- Supporting overlays: [DELEGATION.md](../../../../governance/DELEGATION.md), [MEMORY.md](../../../../governance/MEMORY.md).
- Contract precedence: `framework/constitution/**` -> `instance/ingress/AGENTS.md` -> local `AGENT.md`.

## Role

[Describe the agent's decision scope and why this role has real boundary value.]

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

## Runtime Discipline

- [runtime evidence roots that back execution discipline]
- [how memory discipline is enforced by runtime artifacts]

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
