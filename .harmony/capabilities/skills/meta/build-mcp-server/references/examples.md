---
title: Examples Reference
description: MCP server examples for the build-mcp-server skill.
---

# Examples Reference

## Example 1: GitHub Issues Server

**Invocation:**
```
/build-mcp-server name="github-issues" tools="list-issues,get-issue,create-issue,add-comment"
```

**Result:**
- 4 tools defined with typed inputs
- Auth via `GITHUB_TOKEN` env var
- README with Claude Desktop configuration

## Example 2: Database Query Server

**Invocation:**
```
/build-mcp-server name="project-db" service="PostgreSQL database for the project"
```

**Result:**
- Tools: `query` (read-only SQL), `list-tables`, `describe-table`
- No write tools by default (read-only safety)
- Auth via `DATABASE_URL` env var

## Example 3: Internal API Server

**Invocation:**
```
/build-mcp-server name="billing-api" service="Internal billing microservice"
```

**Result:**
- Tools derived from API endpoints
- Auth via `BILLING_API_KEY` env var
- Rate limiting documented from API specs
