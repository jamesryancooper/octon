---
title: Teams
description: Reusable multi-actor compositions that coordinate agents and assistants.
---

# Teams

Teams define reusable collaboration topologies across agents and assistants.

A team is a composition artifact, not a separate runtime actor class.

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
├── _template/team.md
└── <id>/team.md
```
