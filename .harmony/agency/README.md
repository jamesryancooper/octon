# Workspace Agents

This workspace inherits agent definitions from `.harmony/agency/agents/`.

## Inherited Agents

| Agent | Role | Capabilities |
|-------|------|--------------|
| planner | Strategic planning | Goal decomposition, task planning, delegation |
| builder | Implementation | Code generation, skill execution, testing |
| verifier | Quality assurance | Validation, review, checklist verification |

See `.harmony/agency/agents/registry.yml` for the full list.

## Workspace-Specific Agents

Add project-specific agents here to:

- Override shared agent behavior for this project
- Add agents specific to this workspace's domain
- Extend shared agents with additional capabilities

## Creating a Workspace Agent

1. Copy `.harmony/agency/agents/_template/` to `.harmony/agency/agents/<name>/`
2. Update `agent.md` with role, capabilities, and delegation rules
3. Register in `.harmony/agency/agents/registry.yml`

## Relationship to Assistants

Agents are **supervisors** that delegate to assistants (subagents):

```
AGENT (Supervisor)
  │ commands missions
  │ delegates to assistants
  ▼
ASSISTANT (@reviewer, @refactor, @docs)
  │ uses skills
  ▼
SKILL (refactor, synthesize, create-workspace)
```

See `.harmony/agency/agents/README.md` for full agent documentation.
