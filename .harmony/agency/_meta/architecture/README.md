---
title: Harness Agency
description: Canonical entrypoint for actor taxonomy, contracts, architecture, and rollout for the agency subsystem.
---

# Harness Agency

This is the canonical documentation entrypoint for the `.harmony/agency` subsystem.

## Canonical Set

- `.harmony/agency/_meta/architecture/specification.md`
- `.harmony/agency/_meta/architecture/architecture.md`
- `.harmony/agency/_meta/architecture/finalization-plan.md`

## Actor Taxonomy

| Type | Role |
|------|------|
| `agents` | Autonomous supervisors (planning, orchestration, mission ownership) |
| `assistants` | Stateless specialists for bounded delegated execution |
| `teams` | Reusable compositions of agents and assistants |

`subagents` is not a first-class artifact type. It remains runtime terminology for delegated assistant contexts.

## Invocation Model

- Human: `@assistant`, workflow command, skill command.
- Agent: delegate to assistant, invoke workflow, invoke skill, escalate to human.
- Team: composition policy coordinating agents and assistants.

## Source-of-Truth Files

- `.harmony/agency/manifest.yml`
- `.harmony/agency/governance/CONSTITUTION.md`
- `.harmony/agency/governance/DELEGATION.md`
- `.harmony/agency/governance/MEMORY.md`
- `.harmony/agency/runtime/agents/registry.yml`
- `.harmony/agency/runtime/assistants/registry.yml`
- `.harmony/agency/runtime/teams/registry.yml`

## Legacy Compatibility

`.harmony/agency/_meta/architecture/agents.md` and `.harmony/agency/_meta/architecture/assistants.md` are retained as compatibility stubs and are superseded by this canonical set.
