---
title: Agency Subsystem Specification
description: Canonical specification for actors, invocation, contracts, and boundaries in .octon/agency.
spec_refs:
  - OCTON-SPEC-101
  - OCTON-SPEC-004
  - OCTON-SPEC-006
---

# Agency Subsystem Specification

## Purpose

Define a single, stable contract for the `.octon/agency` subsystem that:

- clarifies actor types and responsibilities,
- removes ambiguous overlap,
- aligns with AGENTS.md-first guidance while keeping Octon-specific structure,
- integrates cleanly with skills, workflows, missions, and continuity artifacts.

## Specification Scope

This specification covers:

- actor taxonomy (`agents`, `assistants`, `teams`, `subagents` handling),
- invocation and delegation model,
- configuration artifacts and schemas,
- subsystem interaction contracts,
- invariants and guardrails for safety and maintainability.

It does not define runtime engine implementation details (scheduler internals, process model, transport).

## External Alignment Principles

This specification aligns to and expands on AGENTS.md ecosystem guidance:

- Use plain markdown as the primary instruction surface.
- Keep hierarchy explicit and deterministic (nearest/local instructions take precedence).
- Prefer simple, high-signal instructions over deeply nested indirection.
- Treat agent instructions as durable operational contracts, not ad hoc notes.

References:

- [agents.md](https://agents.md/)
- [OpenAI Codex AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md/)
- [A complete guide to AGENTS.md](https://www.aihero.dev/a-complete-guide-to-agents-md)
- [Vercel: AGENTS.md outperforms skills in evals](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals)
- [Claude Code memory documentation](https://code.claude.com/docs/en/memory)
- [Devin AGENTS.md onboarding](https://docs.devin.ai/onboard-devin/agents-md)

## External Source Alignment Matrix

| Source | Applied Guidance in This Spec |
|---|---|
| `agents.md` | Keep instructions local, explicit, and precedence-aware. |
| OpenAI Codex AGENTS guide | Use nearest-in-scope instruction model and avoid hidden routing behavior. |
| AI Hero AGENTS guide | Keep agent contracts concise and role-focused to avoid instruction bloat. |
| Vercel AGENTS findings | Prefer simple instruction architecture over extra abstraction layers with weak signal. |
| Claude memory docs | Keep hierarchy clear and deterministic across root/project/local instruction scopes. |
| Devin AGENTS docs | Treat AGENTS.md-like files as durable operational policy with practical examples. |

## Canonical Actor Taxonomy

### Decision Summary

| Actor Type | Status | Rationale |
|---|---|---|
| `agents` | Keep | Needed for autonomous planning, orchestration, and cross-session ownership. |
| `assistants` | Keep | Needed for focused, reusable specialist execution and direct human routing. |
| `teams` | Keep (as composition artifact) | Needed to declare reusable multi-actor compositions for complex work. |
| `subagents` | Remove as first-class artifact type | Redundant with assistant behavior; currently ambiguous and duplicative in repository state. |

### Canonical Definitions

#### `agent`

Autonomous supervisor that can:

- reason and plan,
- own mission lifecycle,
- delegate to assistants,
- invoke skills and workflows within policy,
- maintain cross-session continuity.

#### `assistant`

Focused specialist executor that:

- performs bounded tasks,
- can be invoked by `@mention` or agent delegation,
- is stateless between invocations,
- escalates to an agent or human when task exceeds scope.

#### `team`

Reusable composition of actors and routing policy that:

- defines role membership and responsibilities,
- defines orchestration handoffs,
- does not introduce a new execution primitive.

A `team` is a configuration and coordination abstraction, not a separate runtime actor class.

#### `subagent` (term treatment)

Retained only as runtime terminology:

- "subagent" means an assistant invocation context spawned by an agent.
- No `.octon/agency/subagents/` artifact class exists in the finalized specification.

## Invocation and Delegation Contract

### Human Invocation

Supported patterns:

- `@assistant_alias <task>` for direct assistant routing.
- `/workflow-command ...` for workflow entry points.
- `/skill-command ...` or `use skill: <id>` for direct skill execution.
- `use team: <id>` (optional extension) for team-orchestrated execution.

### Agent Invocation

Allowed:

- agent delegates task to assistant,
- agent invokes workflow,
- agent invokes skill,
- agent escalates to human.

Not allowed by default:

- assistant directly invoking another assistant in uncontrolled recursion,
- assistant directly creating/owning mission lifecycle,
- skill invoking agent/assistant (except explicitly designated delegator skills with policy gates).

### Skill and Workflow Interaction Rule

- Workflows may orchestrate agents, assistants, and skills.
- Skills are bounded capability units and should not orchestrate agency actors by default.
- Delegation from a skill requires explicit declaration (`delegator` capability + policy approval).

## Agency Configuration Artifacts

### Required Files

```text
.octon/agency/
├── README.md
├── governance/
│   ├── CONSTITUTION.md
│   ├── DELEGATION.md
│   └── MEMORY.md
├── manifest.yml
├── runtime/
│   ├── agents/
│   │   ├── registry.yml
│   │   ├── _scaffold/template/AGENT.md
│   │   ├── _scaffold/template/SOUL.md
│   │   └── <id>/
│   │       ├── AGENT.md
│   │       └── SOUL.md
│   ├── assistants/
│   │   ├── registry.yml
│   │   ├── _scaffold/template/assistant.md
│   │   └── <id>/assistant.md
│   └── teams/
│       ├── registry.yml
│       ├── _scaffold/template/team.md
│       └── <id>/team.md
└── practices/
    └── *.md
```

`subagents/` is deprecated and removed after migration.

### `agency/manifest.yml` (new)

Single discovery index for actor registries and default routing.

Example:

```yaml
schema_version: "1.0"
default_agent: architect
routing:
  assistant_prefix: "@"
  ambiguity_resolution: "ask"
registries:
  agents: "runtime/agents/registry.yml"
  assistants: "runtime/assistants/registry.yml"
  teams: "runtime/teams/registry.yml"
```

### Cross-Agent Governance Contracts

Required governance contracts:

- `governance/CONSTITUTION.md`: non-negotiable policy, conscience rubric, and red lines.
- `governance/DELEGATION.md`: delegation authority, handoff protocol, and escalation.
- `governance/MEMORY.md`: memory classes, retention policy, and privacy boundaries.

Precedence:

`AGENTS.md` -> `CONSTITUTION.md` -> `DELEGATION.md` -> `MEMORY.md` -> `runtime/agents/<id>/AGENT.md` -> `runtime/agents/<id>/SOUL.md`

### `runtime/agents/registry.yml`

Minimum fields:

- `id`
- `path`
- `contract` (default `AGENT.md`)
- `soul` (default `SOUL.md`)
- `role`
- `capabilities`
- `delegates_to.assistants`
- `allowed_skills` (optional allowlist)
- `allowed_workflows` (optional allowlist)

### `runtime/assistants/registry.yml`

Minimum fields:

- `id`
- `path`
- `aliases`
- `description`
- `escalates_to`
- `allowed_skills` (optional allowlist)

### `runtime/teams/registry.yml`

Minimum fields:

- `id`
- `path`
- `purpose`
- `lead_agent`
- `members` (agents and assistants)
- `handoff_policy`
- `default_workflow` (optional)

## Actor Document Contracts

### Agent Execution Contract (`AGENT.md`)

Must define:

- role and scope,
- planning/orchestration rules,
- delegation rules,
- mission ownership rules,
- escalation rules,
- quality/security boundaries,
- output contract.

### Agent Identity Contract (`SOUL.md`)

Must define:

- philosophy,
- identity and values,
- communication posture,
- ambiguity handling stance,
- hard behavioral boundaries,
- explicit cross-reference to `AGENT.md`.

### Assistant Document (`assistant.md`)

Must define:

- mission,
- invocation syntax,
- operating rules,
- boundaries,
- escalation triggers,
- output format.

### Team Document (`team.md`)

Must define:

- mission and usage conditions,
- lead + member roles,
- sequencing/handoff pattern,
- failure/escalation handling,
- expected outputs.

## Subsystem Interaction Contracts

### Agency <-> Skills

- Skills provide deterministic capabilities.
- Agents/assistants consume skills.
- Skill usage by actor type can be constrained by allowlists.
- Skill-level tool permissions remain governed by `SKILL.md` `allowed-tools`.

### Agency <-> Workflows

- Workflows are source-of-truth procedures.
- Agents can command workflow execution.
- Teams can bind to workflows for reusable orchestration.
- Workflow steps may reference actor assignments (extension field).

### Agency <-> Missions

- Missions are durable units owned by agents.
- Assistants contribute to missions via delegated subtasks.
- Teams may coordinate multiple mission phases but ownership remains explicit.

### Agency <-> Cognition and Continuity

- Agents read/write continuity artifacts according to append-only rules.
- Assistants should avoid mutating durable continuity state directly unless delegated.
- Team-level execution should record which actor produced which output for traceability.

### Agency <-> Quality

- Any actor-mediated change is subject to quality gates (`assurance/practices/complete.md`, checks, tests, audits).
- High-risk delegated work requires explicit verification before mission completion.

## Invariants

- Exactly one canonical definition per actor id.
- Assistant aliases resolve unambiguously in nearest harness scope.
- No circular delegation chains between assistants.
- Mission ownership is explicit and singular at any point in time.
- Skills remain bounded units; orchestration belongs to agents/workflows.
- Historical continuity artifacts remain append-only.

## Security and Safety Constraints

- Least-privilege by actor type and task.
- No implicit privilege escalation through delegation.
- No secret material in actor logs or output templates.
- Escalate to human for ambiguous one-way-door decisions (schema, data migration, security boundary).

## Deprecations and Clean-Break Enforcement

### Deprecated

- `.octon/agency/subagents/` as a top-level artifact class.

No compatibility window is allowed for agency artifact boundaries.

During migration and after merge:

- Legacy locations (`agents/`, `assistants/`, `teams/`, root governance files, `subagents/`) must not be present as active contract surfaces.
- New definitions must be authored only under `runtime/agents/`, `runtime/assistants/`, and `runtime/teams/`.

## Validation Requirements

Automated checks should enforce:

- schema shape and required fields for all registries,
- cross-reference integrity (`path` targets exist),
- required governance contracts (`governance/CONSTITUTION.md`, `governance/DELEGATION.md`, `governance/MEMORY.md`),
- `CONSTITUTION.md` includes `Conscience` with `Decision Rubric` and `Red Lines`,
- required `AGENT.md` + `SOUL.md` for every agent path,
- required `Philosophy` section for every `SOUL.md`,
- alias uniqueness,
- actor id uniqueness,
- capitalization rule (`AGENT.md`, not `agent.md`),
- no `subagents/` references after deprecation window,
- policy constraints for skill delegation from actors.

## Acceptance Criteria

The agency subsystem is considered spec-compliant when:

- actor taxonomy is reduced to `agents`, `assistants`, `teams` in artifacts,
- `subagents` role is explicitly documented as runtime term only,
- invocation and delegation policies are documented and enforced,
- registry schemas are validated in CI,
- interactions with skills/workflows/missions are deterministic and documented.
