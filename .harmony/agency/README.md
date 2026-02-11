# Agency

Canonical actor model for the Harmony harness.

## Actor Types

| Type | Purpose | Index |
|------|---------|-------|
| `agents/` | Autonomous supervisors (planning, orchestration, mission ownership) | `agents/registry.yml` |
| `assistants/` | Focused specialists invoked by `@mention` or delegation | `assistants/registry.yml` |
| `teams/` | Reusable multi-actor compositions with handoff policy | `teams/registry.yml` |

## Deprecated

`subagents/` is no longer a first-class artifact type in `.harmony/agency/`.

- Runtime term: "subagent" still means an assistant invocation context spawned by an agent.
- Artifact model: use `agents/`, `assistants/`, and `teams/` only.

## Discovery

Read in this order:

1. `manifest.yml` for routing and registry paths
2. `agents/registry.yml` for agent IDs and delegation rules
3. `assistants/registry.yml` for alias (`@mention`) resolution
4. `teams/registry.yml` for composition and handoff policy

## Interaction Model

```text
AGENT (Supervisor) -> delegates -> ASSISTANT (Specialist) -> uses -> SKILL
TEAM (Composition) -> coordinates -> AGENTS + ASSISTANTS
```
