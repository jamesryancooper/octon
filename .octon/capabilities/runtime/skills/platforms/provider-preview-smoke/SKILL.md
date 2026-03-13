---
name: provider-preview-smoke
description: >
  Provider-specific preview smoke adapter for collecting URL-level smoke
  evidence, readiness outcomes, and remediation hints while remaining aligned
  to Octon tiered CI/CD gate contracts.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-03-05"
  updated: "2026-03-05"
skill_sets: [executor, specialist, guardian]
capabilities: [external-dependent, external-output]
allowed-tools: Read Glob Grep Bash(curl *) Write(_ops/state/logs/*) Write(../../output/reports/*)
---

# Provider Preview Smoke

Run provider-specific preview smoke checks as an optional adapter layer and emit gate-friendly evidence.

## When to Use

Use this skill when:

- Preview URL smoke evidence is required for T2/T3 gates
- A provider-specific preview environment needs health verification
- A release review needs quick readiness classification for a preview target

## Quick Start

```markdown
/provider-preview-smoke url="https://preview.example.com" profile="t2"
```

## Core Workflow

1. **Pre-flight** - Validate URL target and expected smoke profile
2. **Smoke execution** - Perform lightweight HTTP readiness checks
3. **Classification** - Determine pass/degraded/fail with evidence
4. **Output** - Save smoke report and run log

## Parameters

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts preview URL, smoke profile, and retry controls.

## Output Location

Output paths are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

Primary outputs are smoke reports and execution logs.

## Boundaries

- Provider smoke checks are informational adapters, not canonical governance rules
- Never execute destructive operations against preview targets
- Do not record sensitive headers, cookies, or tokens in reports

## When to Escalate

- Preview URL is unreachable or DNS/network resolution fails repeatedly
- Smoke result conflicts with CI/provider status evidence
- Required smoke profile is undefined for the requested tier

## References

- [Behavior phases](references/phases.md)
- [Decision logic](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [Validation](references/validation.md)
- [Safety](references/safety.md)
- [Glossary](references/glossary.md)
