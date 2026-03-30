---
title: Harness Agency
description: Canonical entrypoint for actor taxonomy, contracts, architecture, and rollout for the agency subsystem.
---

# Harness Agency

This is the canonical documentation entrypoint for the `.octon/framework/agency` subsystem.

Repo-local constitutional supremacy lives under
`/.octon/framework/constitution/**`. Agency governance files below are
subordinate subsystem application contracts, not the top-level constitutional
kernel.

## Canonical Set

- `.octon/framework/agency/_meta/architecture/specification.md`
- `.octon/framework/agency/_meta/architecture/architecture.md`
- `.octon/framework/agency/_meta/architecture/finalization-plan.md`

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

- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/agency/manifest.yml`
- `.octon/framework/agency/governance/DELEGATION.md`
- `.octon/framework/agency/governance/MEMORY.md`
- `.octon/framework/agency/runtime/agents/registry.yml`
- `.octon/framework/agency/runtime/agents/orchestrator/AGENT.md`
- `.octon/framework/agency/runtime/assistants/registry.yml`
- `.octon/framework/agency/runtime/teams/registry.yml`

## Legacy Compatibility

`.octon/framework/agency/_meta/architecture/agents.md` and `.octon/framework/agency/_meta/architecture/assistants.md` are retained as compatibility stubs and are superseded by this canonical set.
