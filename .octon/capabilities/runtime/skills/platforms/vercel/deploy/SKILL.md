---
name: vercel-deploy
description: >
  Deploy the current project to Vercel using the Vercel CLI. Handles
  pre-flight verification, build checks, deployment execution, and
  status reporting. Supports both production and preview deployments.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-02-09"
  updated: "2026-02-09"
skill_sets: [executor]
capabilities: [external-dependent, external-output]
allowed-tools: Read Glob Bash(vercel *) Bash(npm pack*) Write(_ops/state/logs/*)
---

# Vercel Deploy

Package and deploy the current project to Vercel using the CLI.

## When to Use

Use this skill when:

- You need to deploy a project to Vercel
- You want to create a preview deployment for testing
- You need to push to production
- You want to verify deployment status after changes

## Quick Start

```
/vercel-deploy
```

Or for a preview deployment:

```
/vercel-deploy environment="preview"
```

## Core Workflow

1. **Pre-flight** — Check `vercel` CLI availability, verify project is linked (`vercel link`), read `vercel.json` if present for configuration
2. **Build Verification** — If `package.json` has a `build` script, note build configuration. Check for obvious issues (missing dependencies, TypeScript errors in config)
3. **Deploy** — Execute `vercel --prod` (production) or `vercel` (preview). Capture deployment URL from output
4. **Report** — Log deployment URL, project name, environment, and status. Report results to user

## Parameters

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts optional parameters for deployment environment (production or preview) and project directory.

## Output Location

Output paths are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `_ops/state/logs/vercel-deploy/` — Execution logs with deployment URLs and status

The deployment URL is reported directly to the user (not written to a file).

## Boundaries

- **Bash scope:** Only `vercel *` and `npm pack*` commands — no arbitrary shell access
- Never store or log credentials, tokens, or API keys
- Never modify source files
- Never run `vercel env` commands that could expose secrets
- Never force-delete or override existing deployments
- Default to preview deployment if environment is ambiguous

## When to Escalate

- `vercel` CLI is not installed — instruct user to run `npm i -g vercel`
- Project is not linked — instruct user to run `vercel link`
- Authentication expired — instruct user to run `vercel login`
- Build fails — report build errors, do not attempt to fix
- Deployment fails — report error details from CLI output

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase instructions
- [Safety policies](references/safety.md) — Bash scope restrictions, credential handling
