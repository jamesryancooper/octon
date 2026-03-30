# Agency

Canonical actor model and governance boundary for the Octon harness.
Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Bounded Surfaces

| Type | Purpose | Index |
|------|---------|-------|
| `_meta/architecture/` | Agency subsystem architecture and specification docs | `_meta/architecture/README.md` |
| `runtime/` | Runtime actor artifacts (`agents/`, `assistants/`, `teams/`) | `runtime/README.md` |
| `governance/` | Supporting delegation and memory overlays beneath the orchestrator path | `governance/README.md` |
| `practices/` | Human-agent operating practices and commit/PR standards | `practices/README.md` |

## Convention Authority

- Domain-local naming, authoring, and operating conventions belong in `practices/`.
- `_meta/architecture/` is reference architecture, not the canonical conventions surface.
- Cross-domain baseline conventions come from `/.octon/instance/bootstrap/conventions.md`.

## Deprecated

`subagents/` is no longer a first-class artifact type in `.octon/framework/agency/`.

- Runtime term: "subagent" still means an assistant invocation context spawned by an agent.
- Artifact model: use `runtime/agents/`, `runtime/assistants/`, and `runtime/teams/` only.

## Discovery

Read in this order:

1. `manifest.yml` for routing and registry paths
2. `runtime/agents/registry.yml` for accountable execution roles and activation criteria
3. `runtime/agents/orchestrator/AGENT.md` for the kernel execution profile
4. `governance/DELEGATION.md` when delegation boundaries matter
5. `governance/MEMORY.md` when durable memory rules matter
6. `runtime/assistants/registry.yml` for alias (`@mention`) resolution
7. `runtime/teams/registry.yml` for composition and handoff policy

## Interaction Model

```text
ORCHESTRATOR (Default Owner) -> delegates -> ASSISTANT (Specialist) -> uses -> SKILL
TEAM (Composition) -> coordinates -> AGENTS + ASSISTANTS
```

## Agent Contract Model

Each agent directory contains:

- `AGENT.md` for execution policy and runtime-backed role boundaries.
- No scaffolded identity overlay. Legacy `SOUL.md` overlays are tolerated only
  as non-authoritative historical artifacts outside the required path.

## Cross-Agent Contracts

Cross-agent policies live in `governance/`:

- `governance/DELEGATION.md` for task handoff rules, authority, and escalation.
- `governance/MEMORY.md` for memory lifecycle and privacy controls.
- `governance/CONSTITUTION.md` remains a historical shim only.

Agency kernel path is fixed: `framework/constitution/**` -> `instance/ingress/AGENTS.md` -> `runtime/agents/orchestrator/AGENT.md`. Governance shims are supporting overlays, not required constitutional layers.
