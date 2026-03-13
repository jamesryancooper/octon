---
title: Teams
description: Reusable multi-actor compositions that coordinate agents and assistants.
---

# Teams

Teams define reusable collaboration topologies across agents and assistants.

A team is a composition artifact, not a separate runtime actor class.

## Composition Boundaries

Teams coordinate actor handoffs. They complement, but do not replace:

- **Composite Skills** (`.octon/capabilities/runtime/skills/composite-skills.md`):
  reusable capability bundles.
- **Workflows** (`.octon/orchestration/runtime/workflows/`):
  ordered procedural execution plans.

In practice:

- Teams decide **who** does the work and how escalations happen.
- Workflows decide **when/what sequence** steps run.
- Composite Skills decide **what reusable capability bundle** is invoked.

## Use Cases

- Repeated cross-role execution patterns
- Consistent handoff policy for high-risk work
- Standardized actor bundles for common delivery modes

## Discovery

Read `registry.yml` for routing metadata and each `team.md` for behavior contracts.

## Layout

```text
teams/
├── registry.yml
├── _scaffold/template/team.md
└── <id>/team.md
```
