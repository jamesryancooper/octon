---
name: build-mcp-server
description: >
  Scaffold, implement, and validate a Model Context Protocol (MCP) server
  that exposes tools for AI agent consumption. Follows the MCP specification
  to produce a working server with typed tool definitions, input validation,
  error handling, and security boundaries. Treats tool integrations as
  engineered products, not ad-hoc scripts.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-02-09"
  updated: "2026-02-10"
skill_sets: [executor]
capabilities: [external-dependent, self-validating]
# Write scopes are explicit: workspace writes plus skill log output. Bash scoped to npm/npx/mkdir/cp/node.
allowed-tools: Read Glob Grep Edit Write(../../../**) Bash(npm) Bash(npx) Bash(mkdir) Bash(cp) Bash(node) Write(_ops/state/logs/*)
---

# Build MCP Server

Scaffold, implement, and validate a Model Context Protocol server.

## When to Use

Use this skill when:

- You need to expose an API, database, or service as MCP tools for AI agents
- You want to build a reliable integration between Claude/other agents and external systems
- You need to create tool definitions with proper input validation and error handling
- You want to follow MCP best practices for security and reliability

## Quick Start

```
/build-mcp-server name="project-api" tools="list-items,create-item,get-item"
```

Or with a service description:

```
/build-mcp-server name="github-issues" service="GitHub Issues API"
```

## Core Workflow

1. **Analyze** — Understand the target service/API and identify tools to expose
2. **Design** — Define tool schemas with input/output types and descriptions
3. **Scaffold** — Generate MCP server project structure
4. **Implement** — Build tool handlers with validation, error handling, and security
5. **Validate** — Test the server with the MCP inspector and real tool calls
6. **Document** — Generate README with setup instructions and tool reference

### MCP Server Anatomy

```
my-mcp-server/
├── package.json          # Dependencies and scripts
├── tsconfig.json         # TypeScript configuration
├── src/
│   ├── index.ts          # Server entry point
│   ├── tools/            # Tool definitions and handlers
│   │   ├── index.ts      # Tool registry
│   │   └── {tool}.ts     # Individual tool implementations
│   └── utils/            # Shared utilities
│       ├── validation.ts # Input validation helpers
│       └── errors.ts     # Error formatting
├── README.md             # Setup and usage documentation
└── .env.example          # Required environment variables
```

### Tool Design Principles

| Principle | Application |
|-----------|------------|
| Single responsibility | Each tool does one thing well |
| Descriptive naming | Tool names clearly indicate the action (verb-noun) |
| Typed inputs | All inputs have JSON Schema types and descriptions |
| Graceful errors | Errors return structured messages, never stack traces |
| Least privilege | Request only the permissions each tool needs |
| Idempotency | Prefer idempotent operations where possible |

## Parameters

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts a server name and either a list of tools or a service description, plus optional parameters for language and transport.

## Output Location

The MCP server is created in the project directory specified by the user. Execution logs are written to `_ops/state/logs/build-mcp-server/`.

## Boundaries

- Never hardcode credentials — use environment variables and `.env.example`
- Never expose destructive operations without explicit confirmation tools
- Always validate inputs before passing to underlying APIs
- Always include rate limiting considerations in tool documentation
- Do not auto-connect the server to Claude or other agents — document how to configure
- Follow the MCP specification for transport, tool schemas, and error formats

## When to Escalate

- Target API requires OAuth flows — document the auth setup, recommend existing MCP auth patterns
- Service has complex pagination — recommend cursor-based pagination tools
- More than 15 tools needed — recommend splitting into multiple focused servers
- Server needs to handle webhooks or push notifications — flag as beyond basic MCP scope

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) — Inputs, outputs, server structure
- [Safety policies](references/safety.md) — Security boundaries, credential handling
- [Validation](references/validation.md) — Acceptance criteria for working MCP servers
- [Examples](references/examples.md) — MCP server examples for common integrations
