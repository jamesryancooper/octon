---
title: Safety Reference
description: Safety policies and constraints for the deploy-status skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Bash(vercel *) WebFetch Write(../../output/reports/*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# Safety Reference

## Tool Policy

- Deny-by-default
- Allowed tools are defined in SKILL.md `allowed-tools`
- Permitted command scope: `vercel *` only

## Hard Constraints

- Never trigger a new deployment as part of status checks
- Never modify source files, config, or deployment settings
- Never print credentials, tokens, or environment secrets
- Never run destructive Vercel commands (remove, alias delete, project delete)

## Data Handling

- Treat deployment metadata as operationally sensitive
- Log status summary and non-sensitive evidence only
- Redact any accidental secret-like values before writing logs

## Escalation Triggers

- CLI unavailable or authentication invalid
- Project target cannot be resolved
- Status evidence is inconsistent across sources
- Permission-denied responses from Vercel APIs or CLI
