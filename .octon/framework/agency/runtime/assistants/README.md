---
title: Assistants
description: Focused specialists that perform bounded tasks for agents or humans.
---

# Assistants

Assistants are focused specialists within the Octon agency model. They provide bounded execution for scoped tasks and can be invoked directly by humans or delegated to by agents.

They are optional overlays, not constitutional kernel authority surfaces.

## Assistants in the Multi-Agent Hierarchy

```
AGENT (Supervisor)
  │ delegates to
  ▼
ASSISTANT (Specialist)
  │ uses
  ▼
SKILL (Capability)
```

Assistants serve the accountable orchestrator or verifier by handling specialized work that benefits from domain focus. They are stateless, inheriting context from the caller and returning structured output.

## Available Assistants

| Name | Aliases | Description |
|------|---------|-------------|
| reviewer | `@reviewer`, `@review`, `@rev` | Code review: quality, style, correctness |
| refactor | `@refactor`, `@ref` | Code restructuring: extract, rename, simplify |
| docs | `@docs`, `@doc` | Documentation: clarity, completeness, accuracy |

## Assistants vs Agents

| Characteristic | Agent (Accountable Role) | Assistant (Specialist) |
|----------------|-------------------|------------------------|
| **Role** | Accountable owner | Specialist |
| **Autonomy** | High — reasons, plans, decides | Focused — executes assigned tasks |
| **Lifecycle** | Persistent across sessions | Stateless (inherits context) |
| **Scope** | Broad — orchestrates complex work | Narrow — scoped operations |
| **Invocation** | Assigned to harness/mission | `@mention` or delegation |
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

1. Copy `_scaffold/template/` to a new directory: `runtime/assistants/<name>/`
2. Update `assistant.md` with mission, rules, and output format
3. Register in `registry.yml`
4. Define escalation rules (when to escalate to agents or humans)

## Registry Format

See `registry.yml` for the alias and escalation mapping configuration.

## See Also

- [Agents](../agents/README.md) — Accountable roles that delegate to assistants
- [Skills](../../../capabilities/runtime/skills/README.md) — Capabilities that assistants use
- `.octon/framework/agency/_meta/architecture/assistants.md` — Full assistant documentation
