# Workspace Assistants

Assistants are **specialized subagents** within the Harmony multi-agent architecture. They provide focused modularity for complex problems by operating with their own context, skills, and tools to complete scoped tasks.

## Multi-Agent Hierarchy

```
AGENT (Supervisor)
  │ delegates to
  ▼
ASSISTANT (Specialist Subagent)  ← You are here
  │ uses
  ▼
SKILL (Capability)
```

Assistants serve agents by handling specialized work that benefits from domain focus. They are stateless—inheriting context from the calling agent or human, completing their task, and returning results.

## Inherited from `.harmony/`

| Assistant | Aliases | Specialization |
|-----------|---------|----------------|
| reviewer | `@review`, `@rev` | Code review: quality, style, correctness, security |
| refactor | `@refactor`, `@ref` | Code restructuring: extract, rename, simplify |
| docs | `@docs`, `@doc` | Documentation: clarity, completeness, accuracy |

See `.harmony/assistants/registry.yml` for the full list.

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

## Workspace-Specific Assistants

Add project-specific assistants here to:

- Override shared assistant behavior for this project
- Add specialists specific to this workspace's domain
- Extend shared assistants with project-specific rules

### Creating a Workspace Assistant

1. Copy `.harmony/assistants/_template/` to `.workspace/assistants/<name>/`
2. Update `assistant.md` with mission, rules, and output format
3. Register in `.workspace/assistants/registry.yml`
4. Define escalation rules (when to escalate to agents or humans)

## See Also

- `.harmony/assistants/` — Shared assistant definitions
- `.workspace/agents/` — Agents that delegate to assistants
- `docs/architecture/workspaces/assistants.md` — Full assistant documentation
