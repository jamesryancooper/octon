# Agency

Canonical actor model and governance boundary for the Harmony harness.

## Bounded Surfaces

| Type | Purpose | Index |
|------|---------|-------|
| `_meta/architecture/` | Agency subsystem architecture and specification docs | `_meta/architecture/README.md` |
| `runtime/` | Runtime actor artifacts (`agents/`, `assistants/`, `teams/`) | `runtime/README.md` |
| `governance/` | Cross-agent governance contracts and precedence overlays | `governance/README.md` |
| `practices/` | Human-agent operating practices and commit/PR standards | `practices/README.md` |

## Deprecated

`subagents/` is no longer a first-class artifact type in `.harmony/agency/`.

- Runtime term: "subagent" still means an assistant invocation context spawned by an agent.
- Artifact model: use `runtime/agents/`, `runtime/assistants/`, and `runtime/teams/` only.

## Discovery

Read in this order:

1. `manifest.yml` for routing and registry paths
2. `governance/CONSTITUTION.md` for cross-agent non-negotiables and conscience rules
3. `governance/DELEGATION.md` for delegation protocol and escalation gates
4. `governance/MEMORY.md` for memory/retention/privacy policy
5. `runtime/agents/registry.yml` for agent IDs and delegation rules
6. `runtime/assistants/registry.yml` for alias (`@mention`) resolution
7. `runtime/teams/registry.yml` for composition and handoff policy

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

Cross-agent policies live in `governance/`:

- `governance/CONSTITUTION.md` for non-negotiable governance and red lines.
- `governance/DELEGATION.md` for task handoff rules, authority, and escalation.
- `governance/MEMORY.md` for memory lifecycle and privacy controls.

Conflict precedence is fixed: root `AGENTS.md` -> `CONSTITUTION.md` -> `DELEGATION.md` -> `MEMORY.md` -> agent `AGENT.md` -> agent `SOUL.md`.
