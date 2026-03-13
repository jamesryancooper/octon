---
name: turborepo-taskgraph
description: >
  Platform skill for Turborepo task graph and cache diagnostics, including
  pipeline coverage checks, workspace script alignment, and deterministic
  evidence output for Octon gate triage.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-03-05"
  updated: "2026-03-05"
skill_sets: [executor, specialist, guardian]
capabilities: [external-dependent]
allowed-tools: Read Glob Grep Bash(turbo *) Bash(pnpm turbo *) Write(_ops/state/logs/*)
---

# Turborepo Taskgraph

Diagnose Turborepo task graph and cache behavior as an optional platform adapter workflow.

## When to Use

Use this skill when:

- A task requires Turborepo graph, cache, or pipeline diagnostics
- Workspace scripts and turbo pipeline keys appear misaligned
- CI speed or determinism issues are suspected to be Turbo-related

## Quick Start

```markdown
/turborepo-taskgraph scope="repo" focus="cache"
```

## Core Workflow

1. **Pre-flight** - Resolve workspace and turbo context
2. **Graph diagnostics** - Evaluate pipeline coverage and script parity
3. **Cache diagnostics** - Inspect cache assumptions and drift indicators
4. **Output** - Emit concise findings and remediation steps

## Parameters

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts analysis scope, focus area, and optional target task filters.

## Output Location

Output paths are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

Primary output is execution evidence in `_ops/state/logs/turborepo-taskgraph/`.

## Boundaries

- Treat this as implementation guidance, not canonical governance.
- Do not mutate repository CI/workflow config from this scaffold.
- Keep findings tied to observable task graph evidence.

## When to Escalate

- Turbo command context is unavailable or contradictory
- Task graph evidence conflicts with CI outcomes
- Requested fix would alter governance semantics

## References

- [Behavior phases](references/phases.md)
- [Decision logic](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [Validation](references/validation.md)
- [Safety](references/safety.md)
- [Glossary](references/glossary.md)
- [Dependencies](references/dependencies.md)
