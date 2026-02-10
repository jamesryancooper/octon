---
title: Orchestration Reference
description: Task coordination and dependency management for spec-to-implementation.
---

# Orchestration Reference

## Dependency Management

### Dependency Types

| Type | Example | Handling |
|------|---------|---------|
| Hard dependency | "T03 needs T01's database table" | T03 cannot start until T01 is done |
| Soft dependency | "T06 works better after T03 but can use mocks" | T06 can start with mocks, finalize after T03 |
| Interface contract | "T03 and T06 share an API contract" | Define contract first, implement in parallel |

### Dependency Graph Rules

1. The graph must be acyclic (no circular dependencies)
2. If a cycle is detected, break it by extracting a shared interface task
3. Maximum dependency chain depth: 5 (deeper chains indicate over-sequencing)
4. Prefer wide graphs (parallelizable) over deep chains (sequential)

## Milestone Coordination

Each milestone should:

- Contain 3-8 tasks
- Deliver a testable, working increment
- Have a clear "done" definition
- Be demonstrable to stakeholders
