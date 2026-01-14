Below is a practical blueprint to recreate the *core* mechanics of **ChatGPT Projects** (scoped workspace + shared context/memory) and **Custom GPTs** (reusable assistant definitions) *inside your repo*, while fitting nicely into **Claude Code** and **Cursor** workflows.

---

## 0) The mental model to copy

A clean way to “port” the ChatGPT concepts into a codebase is to adopt the same primitives used by modern assistant runtimes:

- **Assistant (Custom GPT analog)** = `{instructions + tools + model + optional knowledge}`
- **Project** = `{shared instructions + shared knowledge + shared memory + threads}`
- **Thread** = conversation state (messages, summaries, artifacts)
- **Run** = “execute assistant on thread”, including multi-step tool use

This maps almost 1:1 to OpenAI’s Assistants API primitives (**Assistants / Threads / Runs**) described in their docs/cookbook. ([OpenAI Cookbook][1])

---

## 1) Target functionality to reproduce

### A) “Projects” (repo-scoped workspace)

What you want in-repo:

- **Shared project instructions** (coding standards, architecture constraints)
- **Project memory** (facts/decisions + summaries) with scope boundaries
- **Project knowledge base** (indexed docs, ADRs, specs, READMEs, tickets)
- **Multiple threads** (separate tasks, all living under the same project)

### B) “Custom GPTs” → “Assistants”

What you want in-repo:

- A library of named assistants (“reviewer”, “architect”, “release-manager”…)
- Each has:

  - system prompt / style
  - tool permissions
  - optional knowledge sources
  - model choice (cheap vs strong)

Claude Code explicitly supports **custom subagents** with their own prompts/tools/context window. ([Claude Code][2])
And it supports **project-level** subagent files under `.claude/agents/` that can be committed to the repo. ([Claude Code][3])

---

## 2) Repo layout (single source of truth)

Use a neutral, editor-agnostic “AI workspace” folder, then generate editor-specific configs from it.

### Proposed structure

```
repo/
  .ai/
    project.yaml
    assistants/
      architect.yaml
      reviewer.yaml
      debugger.yaml
      prompts/
        architect.md
        reviewer.md
    knowledge/
      adr/
      specs/
      playbooks/
    memory/
      decisions.md
      facts.jsonl
      thread_summaries/
    threads/
      2026-01-07_refactor-auth.jsonl
      2026-01-06_release-1.8.0.jsonl
    indexes/
      kb.vector.sqlite   # or chroma/qdrant/pgvector etc.
  .claude/
    agents/              # generated from .ai/assistants/*
      reviewer.md
      architect.md
  .mcp.json              # MCP servers shared for the project (optional)
```

Why this works:

- `.ai/` is your **Project**.
- `.ai/assistants/*` are your **Custom GPTs**.
- `.ai/threads/*` mirrors “multiple chats in a project”.
- `.ai/memory/*` is project memory with explicit scoping rules.

---

## 3) Core services (the “assistant runtime” you build)

Think in 5 components. You can implement them as a **local CLI + daemon**, or just a CLI that spins up ephemeral processes.

### 3.1 Assistant Registry

Loads assistant definitions (YAML/JSON) and resolves:

- prompt template
- allowed tools
- model/provider
- retrieval sources

### 3.2 Project Context Manager

Builds the “project context packet” for each run:

- static: `project.yaml`, coding rules, architecture notes
- dynamic: git diff, referenced files, recent thread summary
- retrieved: top-K chunks from KB index

> Cursor has been moving toward the agent *self-gathering context* (rather than you manually attaching lots of @items). Your runtime should do the same: auto-collect, but keep it inspectable and overrideable. ([Cursor][4])

### 3.3 Knowledge Base (indexer + retriever)

Pipeline:

1. watch filesystem / git changes
2. chunk documents/code (per your rules)
3. embed + store in a vector index
4. retrieval with filters (path tags, recency, “project only”, etc.)

Store options:

- simplest: SQLite + vector extension / local embedding server
- team-scale: pgvector / qdrant

### 3.4 Memory Store (project-scoped)

Implement **two layers**:

- **“Facts/Decisions”**: explicit writes only (human or `/remember`)
- **“Thread summaries”**: auto-generated compaction after N turns

Claude Code hooks show a good pattern: enforce deterministic behaviors *outside prompting* (e.g., block writes to protected paths, auto-format after edits). ([Claude Code][5])

### 3.5 Execution Engine (Runs)

A “Run” does:

- assemble context packet
- call model provider (Anthropic/OpenAI/etc.)
- handle tool calls (and approvals)
- write artifacts (patches, notes, summaries)
- append to thread log

This is exactly the “run on a thread” idea in assistant platforms. ([OpenAI Cookbook][1])

---

## 4) Tools & integrations: use MCP as your “Actions layer”

You said you want @mention-style calling of assistants. The *cleanest* cross-editor way is:

- **Expose your repo assistants as an MCP server** (your runtime becomes a tool provider).
- Then Cursor / Claude Code can call your tools through MCP (or your scripts can).

MCP is JSON-RPC based and defines transports like **stdio** and **HTTP/streaming**. ([Model Context Protocol][6])

### Recommended MCP surface area

Expose tools like:

- `assistants.list()`
- `assistants.run({ name, thread_id, input, mode })`
- `project.context_preview({ thread_id })`
- `memory.write({ scope, key, value })`
- `kb.search({ query, filters })`
- `repo.apply_patch({ diff })`
- `repo.run_tests({ command })`

### Security controls (don’t skip this)

Claude Code’s MCP docs explicitly warn to trust servers and be careful with prompt injection, and supports allow/deny controls at enterprise level. ([Claude Code][7])
Even if you’re solo, implement:

- tool allowlists per assistant
- path allowlists for file edits
- command allowlists for shell
- “approval required” gates for dangerous tools

---

## 5) How this plugs into Claude Code (very directly)

Claude Code gives you most of this “for free”:

### 5.1 Assistants live in `.claude/agents/`

Claude Code supports:

- **User subagents**: `~/.claude/agents/`
- **Project subagents**: `.claude/agents/` (share with team) ([Claude Code][3])

So your repo can generate `.claude/agents/reviewer.md` from `.ai/assistants/reviewer.yaml`.

### 5.2 Invocation patterns

- You can start a session with a specific agent via `--agent`. ([Claude Code][8])
- You can define subagents dynamically via `--agents` JSON. ([Claude Code][8])
- Subagents have their **own context window**, tool permissions, and are delegated/used for matching tasks. ([Claude Code][2])

### 5.3 Shared tools via `.mcp.json`

Claude Code supports **project-scoped MCP server config** in `.mcp.json` and explains scope/precedence. ([Claude Code][7])
So you can commit your MCP toolchain (your own assistant server + git/jira/db servers) for the whole team.

---

## 6) How this plugs into Cursor (pragmatic approach)

Cursor can:

- reference context via @mentions (files/folders/docs), and is evolving how that works ([Cursor][4])
- use MCP tools in its agentic workflows (commonly via Composer). ([Cursor Directory][9])

So the Cursor-friendly plan is:

- run your **MCP “assistant-runtime” server**
- Cursor agent can call it as a tool (“run @reviewer on this diff” becomes “call assistants.run(…)”)
- keep `.ai/` as the single source of truth

(Exact Cursor UI mechanics change quickly, so treating your runtime as a tool keeps you insulated from UI churn.)

---

## 7) A concrete “minimum viable” implementation plan

### Step 1 — Define your formats

- `.ai/project.yaml`: project rules, allowed MCP servers, KB roots, memory policy
- `.ai/assistants/*.yaml`: name, description, model, prompt file, tool allowlist
- `.ai/assistants/prompts/*.md`: the actual system prompts

### Step 2 — Build the runtime (CLI first)

Commands:

- `ai assistant run reviewer --thread auth-refactor --input "..."`
- `ai thread new ...`
- `ai kb index`
- `ai memory remember ...`

Use SQLite for threads + memory to start.

### Step 3 — Add MCP server wrapper

- Implement MCP stdio transport (so Cursor/Claude Code can launch it as a local server).
- Tools: `assistants.list`, `assistants.run`, `kb.search`, etc.

### Step 4 — Generate editor-native configs

- Generator script: `.ai/tools/sync_editors`

  - writes `.claude/agents/*.md` from `.ai/assistants/*` ([Claude Code][3])
  - writes `.mcp.json` from `.ai/project.yaml` for shared MCP servers ([Claude Code][7])

### Step 5 — Governance (hooks & policies)

- Add Claude Code hooks to enforce invariants (formatting, deny paths, audit logs). ([Claude Code][5])
- Mirror the same rules in your own runtime if you’ll use it outside Claude.

---

## 8) Key design choice: “assistants as config” vs “assistants as code”

You’ll get the closest to “Custom GPTs” by making assistants *mostly configuration*:

- prompt template
- tool allowlist
- model selection
- retrieval sources

…and keep “custom logic” in:

- MCP tools (deterministic code)
- hooks/policies
- retrieval/indexing pipeline

That division keeps the system stable even as models and IDE behaviors change.

---

If you want, I can also provide:

- a ready-to-commit **starter folder** (`.ai/` + sample assistants + generator script spec), or
- a recommended tech stack for the runtime (TypeScript vs Python) based on how you prefer to ship MCP servers.

[1]: https://cookbook.openai.com/examples/assistants_api_overview_python "Assistants API Overview (Python SDK)"
[2]: https://code.claude.com/docs/en/sub-agents "Subagents - Claude Code Docs"
[3]: https://code.claude.com/docs/en/settings "Claude Code settings - Claude Code Docs"
[4]: https://cursor.com/docs/context/mentions?utm_source=chatgpt.com "@ Mentions - Cursor Docs"
[5]: https://code.claude.com/docs/en/hooks-guide "Get started with Claude Code hooks - Claude Code Docs"
[6]: https://modelcontextprotocol.io/specification/2025-06-18/basic/transports?utm_source=chatgpt.com "Transports - Model Context Protocol"
[7]: https://code.claude.com/docs/en/mcp "Connect Claude Code to tools via MCP - Claude Code Docs"
[8]: https://code.claude.com/docs/en/cli-reference "CLI reference - Claude Code Docs"
[9]: https://cursor.directory/mcp/mcp-installer "MCP Installer - MCP Server | Cursor Directory"
