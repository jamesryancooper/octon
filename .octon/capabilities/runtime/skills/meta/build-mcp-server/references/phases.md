---
behavior:
  phases:
    - name: "Analyze"
      steps:
        - "Identify the target service or API to expose"
        - "List the operations that should be available as tools"
        - "Determine authentication requirements (API keys, OAuth, none)"
        - "Identify required environment variables"
        - "Check for existing MCP servers for the same service (avoid duplication)"
        - "Record: service name, N tools planned, auth type, env vars needed"
    - name: "Design"
      steps:
        - "Define tool schemas with JSON Schema-typed inputs"
        - "Write clear, agent-friendly tool descriptions"
        - "Define expected output shapes for each tool"
        - "Identify which tools are read-only vs write/mutate"
        - "Group tools by resource type (e.g., issues: list, get, create)"
        - "Record: tool definitions with input schemas and descriptions"
    - name: "Scaffold"
      steps:
        - "Create project directory with standard structure"
        - "Generate package.json with MCP SDK dependency"
        - "Generate tsconfig.json for TypeScript"
        - "Create src/ directory with index.ts entry point"
        - "Create src/tools/ directory for tool implementations"
        - "Create .env.example with required variables"
        - "Record: files created, directory structure"
    - name: "Implement"
      steps:
        - "Implement server entry point with MCP SDK setup"
        - "Implement tool registry (src/tools/index.ts)"
        - "Implement each tool handler with input validation"
        - "Add structured error handling (never expose stack traces)"
        - "Add rate limiting documentation and considerations"
        - "Record: tools implemented, validation coverage"
    - name: "Validate"
      steps:
        - "Verify TypeScript compiles without errors"
        - "Verify server starts and responds to MCP handshake"
        - "Verify each tool is listed in the tools/list response"
        - "Test at least one tool with a sample input"
        - "Verify error handling returns structured errors"
        - "Record: validation results per check"
    - name: "Document"
      steps:
        - "Generate README.md with setup instructions"
        - "Include: tool reference table (name, description, inputs)"
        - "Include: configuration section (env vars, auth setup)"
        - "Include: usage examples for Claude Desktop and Claude Code"
        - "Include: security considerations"
        - "Write execution log"
        - "Update log index"
  goals:
    - "Produce a working MCP server that passes the MCP inspector"
    - "All tools have typed inputs with descriptions"
    - "Error handling returns structured messages, never stack traces"
    - "README enables setup without reading source code"
    - "Security boundaries are explicit (least privilege, no hardcoded secrets)"
---

# Behavior Reference

Detailed phase-by-phase behavior for the build-mcp-server skill.

## Phase 1: Analyze

Understand the target service and plan the tool set.

### Analysis Protocol

1. **Identify the service:**
   - What API or system will the MCP server expose?
   - Is there an OpenAPI spec, SDK, or documentation?

2. **Plan tools:**
   - List each operation as a potential tool
   - Name tools with verb-noun pattern: `list-issues`, `create-comment`, `get-user`
   - Prefer specific tools over generic ones (`search-users` vs `query-database`)

3. **Determine auth:**
   - API key in header? → env var `{SERVICE}_API_KEY`
   - OAuth? → Document the flow, recommend existing auth patterns
   - No auth? → Document that no credentials are needed

### Tool Count Guidelines

| Tools | Recommendation |
|-------|---------------|
| 1-5 | Single focused server |
| 6-15 | Single server with tool grouping |
| 16+ | Split into multiple focused servers |

---

## Phase 2: Design

Define tool schemas for agent consumption.

### Tool Schema Template

```typescript
{
  name: "list-issues",
  description: "List issues in a GitHub repository, optionally filtered by state and labels",
  inputSchema: {
    type: "object",
    properties: {
      owner: { type: "string", description: "Repository owner" },
      repo: { type: "string", description: "Repository name" },
      state: { type: "string", enum: ["open", "closed", "all"], description: "Filter by state" },
      labels: { type: "array", items: { type: "string" }, description: "Filter by labels" }
    },
    required: ["owner", "repo"]
  }
}
```

### Description Guidelines

- Start with a verb: "List", "Create", "Get", "Search", "Update", "Delete"
- Include what the tool returns
- Mention important constraints or limits
- Keep under 200 characters

---

## Phase 3: Scaffold

Generate the project structure.

### Standard Structure

```
{server-name}/
├── package.json
├── tsconfig.json
├── .env.example
├── src/
│   ├── index.ts           # Server entry point
│   ├── tools/
│   │   ├── index.ts        # Tool registry
│   │   └── {resource}.ts   # Tool implementations by resource
│   └── utils/
│       ├── validation.ts   # Input validation
│       └── errors.ts       # Error formatting
└── README.md
```

---

## Phase 4: Implement

Build the server and tool handlers.

### Entry Point Pattern

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { registerTools } from "./tools/index.js";

const server = new McpServer({
  name: "{server-name}",
  version: "1.0.0",
});

registerTools(server);

const transport = new StdioServerTransport();
await server.connect(transport);
```

### Tool Handler Pattern

```typescript
server.tool("list-issues", "List issues in a repository", {
  owner: z.string(),
  repo: z.string(),
  state: z.enum(["open", "closed", "all"]).optional().default("open"),
}, async ({ owner, repo, state }) => {
  // Implementation with error handling
  try {
    const issues = await fetchIssues(owner, repo, state);
    return { content: [{ type: "text", text: JSON.stringify(issues, null, 2) }] };
  } catch (error) {
    return { content: [{ type: "text", text: `Error: ${error.message}` }], isError: true };
  }
});
```

---

## Phase 5: Validate

Verify the server works correctly.

### Validation Checklist

1. `npx tsc --noEmit` passes
2. Server starts without errors
3. `tools/list` returns all defined tools
4. At least one tool responds to a valid request
5. Invalid input returns a structured error (not a crash)

---

## Phase 6: Document

Generate user-facing documentation.

### README Template

```markdown
# {Server Name} MCP Server

{One-line description}

## Setup

1. Clone this directory
2. `npm install`
3. Copy `.env.example` to `.env` and fill in values
4. `npm run build`

## Configuration

| Variable | Required | Description |
|----------|----------|-------------|
| `{SERVICE}_API_KEY` | Yes | API key for {service} |

## Tools

| Tool | Description |
|------|-------------|
| `list-issues` | List issues in a repository |

## Usage

### Claude Desktop

Add to `claude_desktop_config.json`:

\`\`\`json
{
  "mcpServers": {
    "{server-name}": {
      "command": "node",
      "args": ["path/to/build/index.js"],
      "env": { "{SERVICE}_API_KEY": "your-key" }
    }
  }
}
\`\`\`
```
