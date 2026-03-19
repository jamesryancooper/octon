---
name: provider-github-gates
description: >
  Provider-specific adapter for GitHub branch protection and workflow gate
  wiring, including required-check mapping, status interpretation, and
  evidence-link generation aligned to Octon methodology.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-03-05"
  updated: "2026-03-05"
skill_sets: [executor, specialist, guardian]
capabilities: [external-dependent]
allowed-tools: Read Glob Grep Bash(gh *) Write(/.octon/state/evidence/runs/skills/*)
---

# Provider GitHub Gates

Apply GitHub-specific CI and branch-protection mapping as an optional provider adapter layer.

## When to Use

Use this skill when:

- A task requires GitHub-required check or branch-protection specifics
- Workflow gate outputs need mapping to Octon tier/ACP expectations
- PR gate evidence needs provider-specific status interpretation

## Quick Start

```markdown
/provider-github-gates pr="123" repository="owner/repo"
```

## Core Workflow

1. **Pre-flight** - Resolve PR/repository context
2. **Gate collection** - Gather workflow and check-run states
3. **Mapping** - Map provider checks to Octon gate policy
4. **Output** - Save structured gate evidence summary

## Parameters

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts PR identifier, repository target, and gate scope options.

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Primary output is execution evidence in `/.octon/state/evidence/runs/skills/provider-github-gates/`.

## Boundaries

- Provider-specific details are non-canonical and must defer to methodology policy
- Do not mutate branch protections or workflow definitions in this skill
- Do not expose sensitive token or permission data

## When to Escalate

- Required PR context cannot be resolved
- GitHub API/CLI returns conflicting gate states
- Gate mapping is ambiguous against canonical policy requirements

## References

- [Behavior phases](references/phases.md)
- [Decision logic](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [Validation](references/validation.md)
- [Safety](references/safety.md)
- [Glossary](references/glossary.md)
