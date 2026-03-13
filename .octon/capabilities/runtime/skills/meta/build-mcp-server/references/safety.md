---
title: Safety Reference
description: Safety policies and constraints for the build-mcp-server skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Edit Write(../../../**) Bash(npm) Bash(npx) Bash(mkdir) Bash(cp) Bash(node) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# Safety Reference

## Security Boundaries

### Credential Handling

- **Never** hardcode API keys, tokens, or secrets in source code
- **Always** use environment variables via `.env`
- **Always** create `.env.example` with placeholder values (never real credentials)
- **Always** add `.env` to `.gitignore`

### Tool Permissions

- Read-only tools should be the default
- Write/mutate tools must be clearly labeled in descriptions
- Destructive tools (delete, drop) should require confirmation input
- All tools must validate inputs before passing to underlying APIs

### Error Safety

- Never expose stack traces to agents
- Never include credentials in error messages
- Return structured error objects with actionable messages
- Log detailed errors server-side, return summaries to clients

## Behavioral Boundaries

- Do not auto-connect the server to Claude or other agents
- Do not install the server globally
- Do not modify existing MCP configurations
- Document all security considerations in the README

## Rate Limiting

- Document the underlying API's rate limits
- Recommend appropriate usage patterns
- Consider adding client-side throttling for high-frequency tools
