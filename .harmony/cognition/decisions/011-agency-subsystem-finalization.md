---
title: "ADR-011: Agency Subsystem Finalization"
description: Finalize actor taxonomy and contracts for .harmony/agency by consolidating subagents into the canonical model.
status: accepted
date: 2026-02-11
---

# ADR-011: Agency Subsystem Finalization

## Context

The agency subsystem had four actor categories in artifacts (`agents`, `assistants`, `subagents`, `teams`) but only `assistants` had a concrete operational model. `subagents` duplicated agent semantics and introduced taxonomy ambiguity in routing, documentation, and validation.

## Decision

Adopt a three-type artifact model:

- `agents` (autonomous supervisors)
- `assistants` (bounded specialist executors)
- `teams` (reusable actor compositions)

`subagents` is removed as a first-class artifact category. The term remains runtime terminology for delegated assistant invocation contexts.

## Rationale

- Reduces conceptual overlap and routing ambiguity.
- Preserves orchestration power with lower configuration complexity.
- Aligns with AGENTS.md-style instruction hierarchies emphasizing clear local roles.
- Keeps workflows and skills boundaries intact (orchestration vs capability execution).

## Consequences

- New canonical discovery path: `.harmony/agency/manifest.yml`.
- New/normalized registries for agents, assistants, and teams.
- Legacy `subagents/` artifacts are migrated and decommissioned.
- CI validation must enforce schema and prevent reintroduction of deprecated artifacts.

## Alternatives Considered

1. Keep all four actor types.
   - Rejected: sustained ambiguity and duplicated maintenance surface.
2. Drop teams and keep only agents + assistants.
   - Rejected: no reusable composition primitive for repeated multi-role execution.

## Implementation Notes

Execution tracked by:

- `docs/architecture/harness/agency-specification.md`
- `docs/architecture/harness/agency-architecture.md`
- `docs/architecture/harness/agency-finalization-plan.md`
