# Agency

Canonical actor model for the Harmony harness.

## Actor Types

| Type | Purpose | Index |
|------|---------|-------|
| `architecture/` | Agency subsystem architecture and specification docs | `architecture/README.md` |
| `practices/` | Human-agent operating practices and commit/PR standards | `practices/README.md` |
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
2. `CONSTITUTION.md` for cross-agent non-negotiables and conscience rules
3. `DELEGATION.md` for delegation protocol and escalation gates
4. `MEMORY.md` for memory/retention/privacy policy
5. `agents/registry.yml` for agent IDs and delegation rules
6. `assistants/registry.yml` for alias (`@mention`) resolution
7. `teams/registry.yml` for composition and handoff policy

## Interaction Model

```text
AGENT (Supervisor) -> delegates -> ASSISTANT (Specialist) -> uses -> SKILL
TEAM (Composition) -> coordinates -> AGENTS + ASSISTANTS
```

## Agent Contract Split

Each agent directory contains:

- `AGENT.md` for execution policy and orchestration behavior.
- `SOUL.md` for identity and interpersonal behavior.

## Cross-Agent Contracts

Cross-agent policies live at the agency root:

- `CONSTITUTION.md` for non-negotiable governance and red lines.
- `DELEGATION.md` for task handoff rules, authority, and escalation.
- `MEMORY.md` for memory lifecycle and privacy controls.

Conflict precedence is fixed: root `AGENTS.md` -> `CONSTITUTION.md` -> `DELEGATION.md` -> `MEMORY.md` -> agent `AGENT.md` -> agent `SOUL.md`.
