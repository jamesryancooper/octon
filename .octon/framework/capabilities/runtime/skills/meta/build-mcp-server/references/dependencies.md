---
title: Dependencies Reference
description: External dependencies for build-mcp-server.
---

# Dependencies Reference

## Required External Tools

| Tool | Purpose | Verification |
|---|---|---|
| `node` | Runtime for generated MCP server projects | `node --version` |
| `npm` | Package management and scripts | `npm --version` |
| `npx` | Ad hoc MCP tooling and inspector execution | `npx --version` |

## Optional Dependencies

| Dependency | Purpose | When Needed |
|---|---|---|
| Network access to target API/service | End-to-end validation of generated tool handlers | If validating live integrations |

## Fallback Behavior

- If required tooling is unavailable, stop and report missing prerequisites.
- If live target service is unavailable, complete local scaffold and mark live verification as pending.
