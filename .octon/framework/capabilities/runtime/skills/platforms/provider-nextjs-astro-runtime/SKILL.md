---
name: provider-nextjs-astro-runtime
description: >
  Provider-and-framework adapter for Next.js and Astro runtime nuances,
  including observability bootstrap, caching/runtime semantics, and security
  header placement as optional implementation guidance.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-03-05"
  updated: "2026-03-05"
skill_sets: [executor, specialist, guardian]
capabilities: []
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/runs/skills/*)
---

# Provider Nextjs Astro Runtime

Apply framework-specific runtime guidance for Next.js and Astro as an optional adapter layer.

## When to Use

Use this skill when:

- A task needs framework-specific runtime behavior guidance
- Observability/caching semantics differ by runtime mode
- Security header placement requires framework-specific clarification

## Quick Start

```markdown
/provider-nextjs-astro-runtime surface="nextjs-app-router" mode="ssr"
```

## Core Workflow

1. **Surface identification** - Determine framework/runtime mode
2. **Policy mapping** - Map framework specifics to canonical Octon policy
3. **Risk checks** - Call out runtime-specific risk and verification points
4. **Output** - Save adapter guidance summary

## Parameters

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts framework surface, runtime mode, and observability scope.

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Primary output is execution evidence in `/.octon/state/evidence/runs/skills/provider-nextjs-astro-runtime/`.

## Boundaries

- Keep all advice subordinate to canonical methodology and governance contracts
- Avoid presenting framework-specific behavior as mandatory governance doctrine
- Do not claim runtime guarantees without cited local evidence

## When to Escalate

- Runtime mode is ambiguous (SSR/SSG/edge/serverless) and impacts policy
- Framework behavior conflicts with local contract expectations
- Required implementation details are unavailable in repository context

## References

- [Behavior phases](references/phases.md)
- [Decision logic](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [Validation](references/validation.md)
- [Safety](references/safety.md)
- [Glossary](references/glossary.md)
