---
title: Agency Runtime
description: Runtime actor artifacts for the agency subsystem, including agents, assistants, and teams.
---

# Agency Runtime

`runtime/` is the runtime artifact boundary for agency execution.

## Contents

| Path | Purpose | Index |
|------|---------|-------|
| `agents/` | Autonomous supervisors (planning, orchestration, mission ownership) | `agents/registry.yml` |
| `assistants/` | Focused specialists invoked by `@mention` or delegation | `assistants/registry.yml` |
| `teams/` | Reusable multi-actor compositions with handoff policy | `teams/registry.yml` |
