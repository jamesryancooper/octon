Below is an architectural blueprint that maps **ChatGPT Projects → your `.workspace` harness** and **Custom GPTs → your “assistants”**, and makes it work consistently in **Cursor, Claude Code, and Codex** by using:

1. **repo-native source-of-truth files** in `.workspace/`
2. **tool-specific “adapters”** (Cursor Rules, `CLAUDE.md`, `AGENTS.md`)
3. an optional **MCP server** for hard, reliable routing (all three support MCP) ([Cursor][1])

---

## 1) Conceptual mapping

### “Project” (ChatGPT) → `.workspace/` (your localized harness)

A ChatGPT Project is basically: **scoped instructions + shared context + durable memory + continuity across chats**.

Your `.workspace` already *is* that. So the key is to formalize:

- **Project instructions** = `START.md`, `scope.md`, `conventions.md`, `catalog.md`
- **Project memory** = `context/*` + `progress/*` (your existing structure)
- **Project boundary enforcement** = your dot-prefixed rules + allowlists

### “Custom GPT” → “assistant”

A Custom GPT is: **packaged behavior** (instructions, tool affordances, reusable patterns). In-repo, that becomes **an assistant definition + optional context bundle + optional tools**.

---

## 2) Canonical on-disk design (source of truth)

Add one new top-level folder inside each `.workspace`:

```text
.workspace/
├── assistants/
│   ├── registry.yml
│   ├── refactor/
│   │   ├── assistant.md
│   │   ├── context.include   # optional globs or file list
│   │   └── tools.yml         # optional tool allowlist
│   ├── reviewer/
│   │   └── assistant.md
│   └── ...
├── context/
├── progress/
└── ...
```

### Assistant contract (tool-agnostic)

Each `assistant.md` is the **single source of truth** for:

- identity: `name`, `description`, “when to use”
- operating rules: priorities, constraints, definition-of-done behavior
- IO contract: “what it returns” (patch, checklist, ADR summary, etc.)
- guardrails: “never read `.humans/` / `.archive/`; only read `.scratchpad/` when user points to a file”, etc. (matches your autonomy rules)

### Registry

`assistants/registry.yml` maps:

- `@mention` name → folder
- default assistant for the workspace
- optional aliases (`@rev` → reviewer)

---

## 3) The “@mention” router spec (works everywhere)

Define one consistent semantic rule across tools:

**Rule A — turn-level selection**

- If a user message starts with `@assistant_name`, route the entire turn to that assistant.

**Rule B — inline delegation**

- If `@assistant_name` appears mid-message, treat it as a subtask and return a *sectioned* response (e.g., “Main”, “@reviewer says”, etc.).

**Rule C — locality & overrides**

- Nearest `.workspace/assistants/registry.yml` wins.
- Allow parent `.workspace` to supply defaults, child `.workspace` to override.

You can enforce this in two ways:

- **Soft routing (instruction-only):** each tool’s instruction file tells the model to follow Rules A–C.
- **Hard routing (MCP tool):** a tool call actually resolves the assistant + assembles context deterministically.

You’ll want both: soft routing for convenience, MCP for reliability.

---

## 4) Tool adapters (so this “just works” in Cursor + Claude Code + Codex)

### A) Cursor (rules + MCP)

Cursor’s project rules live in `.cursor/rules/` and are scoped via path patterns / relevance. ([Cursor][2])
Cursor also supports MCP servers. ([Cursor][1])

**Adapter design**

- Keep your existing `.cursor/rules/workspace/RULE.md`.
- Add a generated rule: `.cursor/rules/assistants/RULE.md` that:

  - lists available assistants (from registry)
  - defines the @mention router behavior
  - instructs the agent: “When you see @name, load `.workspace/assistants/name/assistant.md` and comply”

**Optional “one rule per assistant”**

- Generate `.cursor/rules/assistant-refactor/RULE.md` etc.
  This makes Cursor’s native `@…` ergonomics feel like ChatGPT’s GPT mention UX.

### B) Claude Code (project memory + slash commands + MCP)

Claude Code:

- loads project memory from `./CLAUDE.md` or `./.claude/CLAUDE.md`, and modular rules from `./.claude/rules/*.md`. ([Claude Code][3])
- supports importing additional files via `@path/to/file` syntax in `CLAUDE.md`. ([Claude Code][3])
- supports project slash commands in `.claude/commands/…` with precedence rules. ([Claude Code][4])
- supports MCP. ([Claude Code][5])

**Adapter design**

- Generate a `CLAUDE.md` at the repo root (or at each workspace root) that imports the harness:

  - `See @path/to/.workspace/START.md …`
  - `Assistant router rules…`
  - `Assistant list…`

- Generate `.claude/commands/assistant.md` implementing a reliable fallback:

  - `/assistant refactor <task…>` → uses the assistant router spec + loads assistant.md
  - (Claude Code supports arguments like `$ARGUMENTS`.) ([Claude Code][4])

### C) Codex (AGENTS.md + directory-walk discovery + MCP)

Codex reads `AGENTS.override.md` then `AGENTS.md` in each directory from repo root down to the current working directory, concatenating them so nearer files override earlier guidance. ([OpenAI Developers][6])
Codex has `/init` to scaffold `AGENTS.md`. ([OpenAI Developers][7])
Codex supports MCP. ([OpenAI Developers][8])

**Adapter design**

- Generate `AGENTS.md` (global behavior + router spec + “how to find `.workspace`”).
- When a directory contains a `.workspace/`, also generate an `AGENTS.override.md` in that same directory that:

  - imports that workspace’s `START/scope/conventions/catalog`
  - lists that workspace’s assistants
  - defines local overrides + boundaries

This matches Codex’s native “walk down the tree” mental model almost perfectly. ([OpenAI Developers][6])

---

## 5) MCP layer (the seamless / deterministic part)

Because Cursor, Claude Code, and Codex all support MCP, the cleanest “shared substrate” is an MCP server you own. ([Cursor][1])

### Workspace MCP server responsibilities

Implement a local MCP server (e.g., `workspace-mcp`) that exposes tools like:

- `workspace.discover(cwd)` → nearest `.workspace` root
- `workspace.pack_context(workspace_root, token_budget)` → returns a curated context bundle (START/scope/conventions + memory digest + requested files), respecting your ignore rules
- `assistants.list(workspace_root)` → names + descriptions
- `assistants.run(workspace_root, assistant_name, user_task, files?)`

  - resolves `@assistant`
  - loads `assistant.md`
  - assembles context with the packer
  - returns a structured response
- `memory.append_log(workspace_root, entry)` → appends to `progress/log.md`
- `memory.update_tasks(workspace_root, patch)` → updates `tasks.json`
- `memory.promote(from, to)` → implements your “promote-from-scratch” workflow safely

### Why MCP matters here

It gives you **Projects-like continuity + GPT-like modularity** without relying on each editor’s own “prompt magic” to behave the same.

---

## 6) Memory model (replicating “project-only memory”)

Treat your `.workspace/progress/` + `.workspace/context/` as the authoritative state:

- **Append-only log:** `progress/log.md`
- **Structured tasks:** `progress/tasks.json`
- **Entity state:** `progress/entities.json`
- **Distilled memory digest:** `context/decisions.md` / `context/lessons.md` (+ optionally a compact `context/memory.md` that’s optimized for token budgets)

Then make the adapters/MCP server enforce:

- only these files are “memory”
- `.scratchpad/` and `.inbox/` are **human-directed access only**
- `.humans/` and `.archive/` are **never-access**

That reproduces the “project-only memory boundary” at the repo level.

---

## 7) One practical workflow (how it feels day-to-day)

1. You open any file anywhere.
2. The tool (Cursor/Claude/Codex) picks up the nearest `.workspace` via:

   - rules discovery (Cursor), or
   - `CLAUDE.md` + imports (Claude Code), or
   - `AGENTS.md` directory walk (Codex). ([Cursor][2])
3. You type:

   - `@refactor make this service boundary explicit…`
4. Router selects the assistant, context packer pulls the right harness + memory + relevant files, assistant responds.
5. Session end: MCP tool updates `progress/log.md` and `tasks.json`.

---

## 8) What I’d implement first (minimum viable, high leverage)

1. **`assistants/` + registry + 2–3 assistants** (refactor, reviewer, docs)
2. **Codex adapter:** `AGENTS.md` + per-workspace `AGENTS.override.md` (because Codex’s discovery model already matches your locality philosophy). ([OpenAI Developers][6])
3. **Claude adapter:** generate `CLAUDE.md` that imports the workspace harness via `@…` imports + add a `/assistant` slash command. ([Claude Code][3])
4. **Cursor adapter:** one assistants router rule + optional one-rule-per-assistant for ergonomic `@assistant` usage. ([Cursor][2])
5. **MCP server** once the above is working, to make routing deterministic across all three tools. ([Cursor][1])

---

If you want, I can turn this into a concrete “scaffold spec” (exact files + templates for `assistant.md`, `registry.yml`, `AGENTS.md`, `AGENTS.override.md`, `CLAUDE.md`, and the Cursor rule), written so you can drop it into your repo and immediately start adding assistants.

[1]: https://cursor.com/docs/context/mcp?utm_source=chatgpt.com "Model Context Protocol (MCP) | Cursor Docs"
[2]: https://cursor.com/docs/context/rules?utm_source=chatgpt.com "Rules | Cursor Docs"
[3]: https://code.claude.com/docs/en/memory "Manage Claude's memory - Claude Code Docs"
[4]: https://code.claude.com/docs/en/slash-commands "Slash commands - Claude Code Docs"
[5]: https://code.claude.com/docs/en/mcp "Connect Claude Code to tools via MCP - Claude Code Docs"
[6]: https://developers.openai.com/codex/guides/agents-md?utm_source=chatgpt.com "Custom instructions with AGENTS.md - developers.openai.com"
[7]: https://developers.openai.com/codex/cli/slash-commands?utm_source=chatgpt.com "Slash commands in Codex CLI - developers.openai.com"
[8]: https://developers.openai.com/codex/mcp?utm_source=chatgpt.com "Model Context Protocol"
