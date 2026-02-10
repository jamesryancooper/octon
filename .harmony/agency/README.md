# Agency

Agent hierarchy: agents, assistants, subagents, teams.

## Contents

| Subdirectory | Purpose | Index |
|--------------|---------|-------|
| `agents/` | Autonomous supervisors (architect, auditor) | — |
| `assistants/` | Specialist subagents invoked via @mention | `assistants/registry.yml` |
| `subagents/` | Delegated workers with defined capabilities | `subagents/registry.yml` |
| `teams/` | Multi-agent team definitions | — |

## Interaction Model

**Referenced.** Look up agents and assistants by name or role. Use `assistants/registry.yml` for @mention resolution. Use `subagents/registry.yml` for delegation routing.

## Hierarchy

```
AGENT (Supervisor) → delegates to → ASSISTANT (Specialist) → uses → SKILL (Capability)
```

See subdirectory READMEs for detail.
