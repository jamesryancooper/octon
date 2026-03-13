---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .octon/capabilities/runtime/skills/registry.yml
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Edit Bash(gh) Bash(npm) Bash(npx) Write(../../output/reports/*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

Extended input/output documentation for the triage-ci-failure skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.octon/capabilities/runtime/skills/registry.yml`
> - Output paths: `.octon/capabilities/runtime/skills/registry.yml`

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `pr` | text | No* | — | PR number or URL with failing CI |
| `branch` | text | No* | — | Branch name with failing CI |
| `job` | text | No | — | Target a specific job name |
| `step` | text | No | — | Target a specific step name |

*One of `pr` or `branch` is required.

## Output Structure

### Primary Output: Triage Report

Written to `.octon/output/reports/analysis/YYYY-MM-DD-ci-triage.md`.

### Execution Log

Written to `.octon/capabilities/runtime/skills/_ops/state/logs/triage-ci-failure/{{run_id}}.md`.

### Log Index

Written to `.octon/capabilities/runtime/skills/_ops/state/logs/triage-ci-failure/index.yml`.

## Dependencies

This skill requires:

- **Read** — Read source files for understanding context
- **Glob** — Find files referenced in error output
- **Grep** — Search for related code patterns
- **Edit** — Apply fixes to source files
- **Bash(gh)** — GitHub CLI for fetching CI logs
- **Bash(npm/npx)** — Run local verification checks
- **Write(../../output/reports/*)** — Write triage report
- **Write(_ops/state/logs/*)** — Write execution logs

## External Dependencies

- `gh` CLI must be installed and authenticated
- Node.js/npm for local verification (if project uses Node)
- Repository must use GitHub Actions (or compatible CI)
