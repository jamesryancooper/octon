---
name: provider-vercel-delivery
description: >
  Provider-specific delivery adapter for Vercel workflows including preview
  deployment checks, guarded promotion/rollback patterns, feature-flag rollout
  coordination, and evidence capture for Octon methodology receipts.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-03-05"
  updated: "2026-03-05"
skill_sets: [executor, specialist, guardian, integrator]
capabilities: [external-dependent, external-output]
allowed-tools: Read Glob Grep Bash(vercel *) Write(/.octon/state/evidence/runs/skills/*)
---

# Provider Vercel Delivery

Apply Vercel-specific delivery operations as an optional adapter layer to provider-agnostic Octon policy.

## When to Use

Use this skill when:

- A task explicitly requests Vercel preview/promote/rollback semantics
- CI evidence must include Vercel deployment metadata
- Feature-flag rollout is performed through Vercel-specific controls

## Quick Start

```markdown
/provider-vercel-delivery target="preview" environment="production"
```

## Core Workflow

1. **Pre-flight** - Verify Vercel CLI context and deployment target
2. **Delivery action** - Run provider-specific preview/promote/rollback step
3. **Evidence capture** - Record deployment URL/state and receipt notes
4. **Output** - Save run log with provider outputs

## Parameters

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts target environment, operation mode, and evidence-link inputs.

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Primary output is execution evidence in `/.octon/state/evidence/runs/skills/provider-vercel-delivery/`.

## Boundaries

- Treat this as optional provider adapter guidance, never canonical governance
- Do not bypass ACP or CI gate requirements
- Do not expose tokens, secrets, or sensitive environment values

## When to Escalate

- Vercel CLI/auth context is unavailable
- Deployment status is contradictory across evidence sources
- Requested action conflicts with repository governance constraints

## References

- [Behavior phases](references/phases.md)
- [Decision logic](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [Validation](references/validation.md)
- [Safety](references/safety.md)
- [Glossary](references/glossary.md)
