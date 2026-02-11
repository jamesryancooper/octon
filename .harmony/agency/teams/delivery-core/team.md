---
title: "Team: delivery-core"
description: "Default multi-actor composition for end-to-end delivery with quality verification."
---

# Team: delivery-core

## Purpose

Use this team for non-trivial changes that require architecture, implementation, and verification handoffs.

## Composition

- **Lead Agent:** architect
- **Agents:** architect, auditor
- **Assistants:** reviewer, refactor, docs

## Handoff Policy

1. `architect` defines scope, risks, and execution sequence.
2. `architect` delegates bounded subtasks to assistants.
3. `auditor` performs material-risk verification before completion.

## Escalation Rules

Escalate to human when:

- requirements are ambiguous and choice is irreversible,
- security/compliance tradeoffs are unresolved,
- verification surfaces a high-severity unresolved risk.

## Output Contract

```markdown
## Team Execution Summary

**Team:** delivery-core
**Lead:** architect
**Delegations:** [assistant tasks and outputs]
**Verification:** [auditor findings and status]
**Outcome:** [complete / blocked / escalated]
```
