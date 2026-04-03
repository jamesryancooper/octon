---
title: Teams
description: Reusable multi-actor compositions that coordinate agents and assistants.
---

# Teams

Teams define reusable collaboration topologies across accountable roles and assistants.

A team is a composition artifact, not a separate runtime actor class or constitutional kernel surface.

## Composition Boundaries

Teams coordinate actor handoffs. They complement, but do not replace:

- **Composite Skills** (`.octon/framework/capabilities/runtime/skills/composite-skills.md`):
  reusable capability bundles.
- **Workflows** (`.octon/framework/orchestration/runtime/workflows/`):
  ordered procedural execution plans.

In practice:

- Teams decide **who** does the work and how escalations happen.
- Workflows decide **when/what sequence** steps run.
- Composite Skills decide **what reusable capability bundle** is invoked.

## Use Cases

- Repeated cross-role execution patterns
- Consistent handoff policy for high-risk work
- Standardized actor bundles for common delivery modes where independent verification or context isolation matters

## Discovery

Read `registry.yml` for routing metadata and each `team.md` for behavior contracts.

## Layout

```text
teams/
├── registry.yml
├── _scaffold/template/team.md
└── <id>/team.md
```
