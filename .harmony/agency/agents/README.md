---
title: Agents
description: Autonomous supervisors that reason, plan, orchestrate, and own mission lifecycle.
---

# Agents

Agents are persistent supervisors in the agency subsystem.

## Responsibilities

- Reason about goals and constraints
- Plan and sequence work
- Delegate scoped tasks to assistants
- Own mission lifecycle and completion criteria
- Escalate one-way-door decisions to humans

## Discovery

Use `registry.yml` for actor routing metadata and `agent.md` for behavioral contracts.

## Layout

```text
agents/
├── registry.yml
├── _template/agent.md
└── <id>/agent.md
```
