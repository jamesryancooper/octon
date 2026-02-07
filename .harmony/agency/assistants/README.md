---
title: Assistants
description: Specialized subagents that perform focused tasks for agents or humans.
---

# Assistants

Assistants are **specialized subagents** within the Harmony multi-agent architecture. They provide focused modularity for complex problems by operating with their own context, skills, and tools to complete scoped tasks.

## Assistants in the Multi-Agent Hierarchy

```
AGENT (Supervisor)
  │ delegates to
  ▼
ASSISTANT (Specialist Subagent)
  │ uses
  ▼
SKILL (Capability)
```

Assistants serve agents by handling specialized work that benefits from domain focus. They are stateless—inheriting context from the calling agent or human, completing their task, and returning results.

## Available Assistants

| Name | Aliases | Description |
|------|---------|-------------|
| reviewer | `@review`, `@rev` | Code review: quality, style, correctness |
| refactor | `@refactor`, `@ref` | Code restructuring: extract, rename, simplify |
| docs | `@docs`, `@doc` | Documentation: clarity, completeness, accuracy |

## Assistants vs Agents

| Characteristic | Agent (Supervisor) | Assistant (Specialist) |
|----------------|-------------------|------------------------|
| **Role** | Supervisor | Subagent |
| **Autonomy** | High — reasons, plans, decides | Focused — executes assigned tasks |
| **Lifecycle** | Persistent across sessions | Stateless (inherits context) |
| **Scope** | Broad — orchestrates complex work | Narrow — scoped operations |
| **Invocation** | Assigned to workspace/mission | `@mention` or delegation |
| **Delegation** | Delegates **to** assistants | Escalates **to** agents/humans |

## Invocation

**Direct (human):**
```text
@reviewer Check this PR for security issues
@refactor Extract method from this large function
@docs Improve clarity of this README
```

**Delegated (agent):**
```text
Agent: "I need a code review for the authentication changes."
→ Delegates to @reviewer
→ Reviewer executes and returns structured findings
→ Agent incorporates findings into plan
```

## Creating a New Assistant

1. Copy `_template/` to a new directory: `assistants/<name>/`
2. Update `assistant.md` with mission, rules, and output format
3. Register in `registry.yml`
4. Define escalation rules (when to escalate to agents or humans)

## Registry Format

See `registry.yml` for the @mention mapping configuration.

## See Also

- [Agents](../agents/README.md) — Supervisors that delegate to assistants
- [Skills](../skills/README.md) — Capabilities that assistants use
- `docs/architecture/workspaces/assistants.md` — Full assistant documentation
