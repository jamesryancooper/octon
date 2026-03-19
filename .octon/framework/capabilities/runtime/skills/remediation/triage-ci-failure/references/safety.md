---
title: Safety Reference
description: Safety policies and constraints for the triage-ci-failure skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Output paths: .octon/framework/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Edit Bash(gh) Bash(npm) Bash(npx) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# Safety Reference

Safety policies and behavioral constraints for the triage-ci-failure skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.octon/framework/capabilities/runtime/skills/registry.yml`

## Tool Policy

### Mode

Deny-by-default

This skill requires:

- Read access to source files and CI logs
- Glob/Grep for finding related code
- Edit access to apply fixes
- Bash access scoped to `gh`, `npm`, `npx` commands
- Write access to report and log directories

This skill explicitly does **NOT** have:

- Permission to modify CI workflow YAML files (`.github/workflows/`)
- Permission to disable linting rules globally
- Permission to skip or delete tests
- Permission to force-push

## CI Config Protection

- **Never modify** `.github/workflows/` files without explicit user approval
- **Never disable** CI checks, even temporarily
- **Never add** `--no-verify` or equivalent flags
- **Never skip** failing tests — fix them or explain why the test expectation should change

## Git Safety

- Create new commits for fixes (never amend)
- Never force-push
- Run local verification before pushing

## Fix Boundaries

### What the Skill Fixes

- Test failures caused by code changes
- Build errors (import, type, syntax)
- Lint violations
- Dependency resolution conflicts

### What the Skill Does NOT Fix

- Infrastructure failures (OOM, network, rate limits) — report only
- Pre-existing failures unrelated to the current PR — flag and report
- Flaky tests — flag as flaky, do not suppress
- CI configuration issues — report and suggest fix, do not apply

## Escalation Triggers

| Trigger | Action |
| ------- | ------ |
| INFRA category failure | Report, do not attempt fix |
| Pre-existing failure | Flag, note it predates this PR |
| >3 independent failure categories | Recommend separate triage passes |
| Fix requires CI config change | Report suggested change, do not apply |
