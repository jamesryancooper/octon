---
name: deploy-status
description: >
  Check Vercel deployment status for a linked project and report readiness.
  Uses the Vercel CLI plus optional URL verification to surface external
  deployment outputs (URL and state) without modifying source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-02-10"
  updated: "2026-02-10"
skill_sets: [executor]
capabilities: [external-dependent, external-output]
allowed-tools: Read Glob Bash(vercel *) WebFetch Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Deploy Status

Check deployment status and readiness for a Vercel project.

## When to Use

Use this skill when:

- You need current deployment status before a release handoff
- A deploy succeeded but health/readiness is uncertain
- You want a structured readiness report with follow-up actions
- You need deployment URL and status metadata surfaced to the user

## Quick Start

```markdown
/deploy-status project="my-app" environment="production"
```

Or inspect a specific deployment:

```markdown
/deploy-status deployment="https://my-app.vercel.app"
```

## Core Workflow

1. **Pre-flight** - Validate Vercel CLI availability, linked project context, and target parameters.
2. **Status Collection** - Query deployment status from Vercel CLI output for the selected target.
3. **Verification** - Optionally probe deployment URL reachability and capture response signals.
4. **Report** - Produce a readiness report and execution log, then return external output metadata.

## Parameters

Parameters are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts optional project/deployment targets plus environment and URL-check controls.

## Output Location

Output paths are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

- `.harmony/output/reports/analysis/` - Deployment readiness report
- `.harmony/capabilities/runtime/skills/_ops/state/logs/deploy-status/` - Execution logs and run index

External outputs (deployment URL and status state) are documented in `references/external-outputs.md`.

## Boundaries

- Bash scope is restricted to `vercel *` commands
- Never modify source files, build configs, or deployment settings
- Never expose tokens, secrets, or environment variable values
- Use read-only status checks; do not trigger new deploys

## When to Escalate

- Vercel CLI is unavailable or authentication is invalid
- Project linkage is missing and target cannot be resolved
- Status signals are contradictory (CLI success but URL unreachable)
- Required deployment context is ambiguous after one clarification attempt

## References

- [Behavior phases](references/phases.md)
- [Decision logic](references/decisions.md)
- [Checkpoint model](references/checkpoints.md)
- [External dependencies](references/dependencies.md)
- [External outputs](references/external-outputs.md)
- [Safety policies](references/safety.md)
