---
title: Safety Reference
description: Safety policies and constraints for the deploy skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Bash(vercel *) Bash(npm pack*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# Safety Reference

Safety policies and behavioral constraints for the vercel-deploy skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.octon/capabilities/runtime/skills/registry.yml`

## Tool Policy

### Mode

Deny-by-default

Allowed tools are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

This skill requires:

- Read access to project files (package.json, vercel.json, .vercel/)
- Glob for file discovery
- Bash access restricted to `vercel *` and `npm pack*` commands only
- Write access to execution log directory

This skill explicitly does **NOT** have:

- Edit access (no source file modifications)
- Write access to source files or configuration
- Unrestricted Bash access
- WebFetch access
- Task access (no sub-agent delegation)

## Bash Scope

### Allowed Commands

| Pattern | Purpose |
|---------|---------|
| `vercel --version` | Check CLI availability |
| `vercel --prod` | Production deployment |
| `vercel` (no flags) | Preview deployment |
| `vercel link` | Link project (informational — user should run) |
| `npm pack *` | Package project for deployment |

### Explicitly Forbidden Commands

| Command | Reason |
|---------|--------|
| `vercel env *` | May expose secrets |
| `vercel secrets *` | May expose secrets |
| `vercel rm *` | Destructive — removes deployments |
| `vercel alias rm *` | Destructive — removes aliases |
| Any command not matching `vercel *` or `npm pack*` | Outside scope |

## Credential Safety

- **Never** log, store, or display authentication tokens
- **Never** log environment variable values
- **Never** include `.env` file contents in logs or output
- **Never** run `vercel env pull` or similar commands that expose secrets
- If deployment output contains tokens or secrets, redact before logging

## File Policy

### Read Scope

- `package.json` — framework detection, build script
- `vercel.json` — deployment configuration
- `.vercel/project.json` — project linking status
- `tsconfig.json` — TypeScript configuration check

### Write Scope

- `.octon/capabilities/runtime/skills/_ops/state/logs/vercel-deploy/` — Execution logs only

### Source Code Modifications

None. This skill never modifies source files, configuration files, or any file outside the log directory.

## Behavioral Boundaries

- Never modify source files or project configuration
- Never store or log credentials
- Never run commands outside the allowed Bash scope
- Never force-delete deployments
- Never override existing production deployments without explicit user request
- Default to preview deployment if environment parameter is ambiguous
- Always report deployment URL to user
- Always log execution results

## Escalation Triggers

| Trigger | Action |
|---------|--------|
| CLI not installed | Report, instruct user to install |
| Not authenticated | Report, instruct user to login |
| Project not linked | Report, instruct user to link |
| Build fails | Report errors, do not retry |
| Deploy fails | Report error details |
| Permission denied | Report, suggest checking access |
