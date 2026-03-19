---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .octon/framework/capabilities/runtime/skills/registry.yml
#   - Output paths: .octon/framework/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Edit Write(../../../**) Bash(npm) Bash(npx) Bash(mkdir) Bash(cp) Bash(node) Write(/.octon/state/evidence/runs/skills/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `name` | text | Yes | — | Server name (kebab-case, used for directory and package.json) |
| `tools` | text | No | — | Comma-separated list of tool names to scaffold |
| `service` | text | No | — | Description of the service to expose (alternative to `tools`) |
| `language` | text | No | `typescript` | Implementation language: `typescript` or `python` |
| `output_dir` | folder | No | `.` | Directory where the MCP server project will be created |

## Output Structure

### Primary Output: MCP Server Project

Created at `{output_dir}/{name}/` with full project structure.

### Execution Log

Written to `.octon/state/evidence/runs/skills/build-mcp-server/{{run_id}}.md`.

### Log Index

Written to `.octon/state/evidence/runs/skills/build-mcp-server/index.yml`.

## Dependencies

This skill requires:

- **Read** — Read existing code for context
- **Glob** — Find relevant files
- **Grep** — Search for existing patterns
- **Edit** — Modify generated files during implementation
- **Write** — Create new project files
- **Bash** — Run npm install, TypeScript compilation, validation
- **Write(/.octon/state/evidence/runs/skills/*)** — Write execution logs
