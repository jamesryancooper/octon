Below is a repo-first blueprint that reproduces the *core mechanics* of **ChatGPT Projects** (shared context + scoped instructions + “memory”) and **custom GPTs** (reusable specialists with distinct behavior), but implemented inside a `scratchpad/` directory and optimized for **Cursor** workflows (rules + @mentions + Agent).

---

## 1) Conceptual mapping (ChatGPT → repo)

ChatGPT Projects are “smart workspaces” that bundle **chats + files + instructions + project memory**. ([OpenAI Help Center][1])
Custom GPTs are “specialist configurations,” and OpenAI’s @mentions let you switch specialists *without losing the conversation context*. ([OpenAI Help Center][2])

In your repo, mirror that with two first-class primitives:

### A. `ProjectHub` (Projects analogue)

A folder that owns:

- **Project instructions** (what “good” looks like in this project)
- **Project memory** (decisions, assumptions, glossary, running summary)
- **Project knowledge/artifacts** (docs, links, datasets, specs)
- **Session logs** (what happened in each interaction)

### B. `Assistant` (custom GPT analogue)

A version-controlled “assistant spec” that defines:

- persona + rules + workflow
- expected inputs/outputs (schemas/templates)
- allowed tools / constraints (even if only “human-enforced” initially)

In Cursor, you’ll bring these into the active context via **rules** and **@mentions** (Cursor supports mentions for context selection including Docs). ([Cursor][3])

---

## 2) Directory architecture inside `scratchpad/`

Here’s a clean “productionizable” layout:

```txt
scratchpad/
  README.md                       # how to use the scratchpad system

  assistants/                     # reusable specialists (custom GPT analog)
    registry.yaml                 # human+tool readable index
    reviewer/
      assistant.md                # the core spec (system-like prompt + workflow)
      examples.md                 # few-shot examples
      checklists.md               # quality gates
      outputs/                    # reusable templates (PR review format, etc.)
    researcher/
      assistant.md
      sources.md
    architect/
      assistant.md
      patterns.md

  projects/                       # workspaces (Projects analog)
    <project_slug>/
      PROJECT.md                  # “project instructions” (scope, goals, constraints)
      MEMORY.md                   # running state summary (1-2 pages max)
      DECISIONS.md                # ADR-style log
      GLOSSARY.md                 # canonical definitions
      CONTEXT/                    # “uploaded files” analog
        docs/                     # specs, RFCs, PDFs converted to md, etc.
        links.md                  # curated URL list + notes
        data/                     # small datasets; large data referenced externally
      SESSIONS/                   # conversation/session logs (append-only)
        2026-01-06.md
      OUTPUTS/                    # deliverables produced for this project
        diagrams/
        drafts/
      TASKS.md                    # backlog / next actions

  runtime/                        # generated, non-source-of-truth
    index/                        # optional embeddings / search index / cache
    tmp/
```

### Why this works

- “Projects keep everything together” → `projects/<slug>/` bundles *instructions + files + session history + memory* ([OpenAI Help Center][1])
- “Project-only memory” → your `MEMORY.md` + `DECISIONS.md` become the *single source of truth* for continuity and context boundaries ([OpenAI Help Center][1])
- “Switch GPTs while keeping context” → you keep the project context constant and swap *assistant specs* in/out via mentions ([OpenAI Help Center][2])

---

## 3) Assistant spec format (what to put in `assistant.md`)

Keep each assistant’s “contract” stable and scannable. Suggested structure:

```md
# Assistant: reviewer

## Mission
One sentence.

## Operating rules (non-negotiables)
- …

## Workflow
1) …
2) …

## Output format
### Summary
### Findings (severity-tagged)
### Suggested patches
### Follow-ups

## Boundaries / tool constraints
- Never …
- Prefer …

## When to escalate to another assistant
- If X, call `architect`
```

Then add:

- `examples.md` for canonical demonstrations
- `checklists.md` for repeatable quality gates

This mirrors how custom GPTs package “skills/styles/instructions” into a reusable specialist. ([OpenAI Help Center][2])

---

## 4) Project hub format (what to put in `PROJECT.md` + memory files)

### `PROJECT.md` (instructions / operating context)

Model it after ChatGPT Project Instructions (they’re scoped and override global instructions in-project). ([OpenAI Help Center][1])
Include:

- goals / non-goals
- stack + constraints
- definitions of done
- “how we work” (review rules, testing, release flow)
- reference pointers (where specs live)

### `MEMORY.md` (your “project-only memory”)

Keep it short and current:

- current status
- key constraints
- open questions
- next actions
- “do not forget” items

### `DECISIONS.md` (ADR log)

Append-only:

- date
- decision
- rationale
- alternatives considered
- consequences

### `SESSIONS/YYYY-MM-DD.md`

A lightweight log:

- what you asked
- what changed
- links to PRs/commits
- updated memory snippets (or a note: “memory updated”)

---

## 5) Cursor integration layer (make this feel native)

Cursor gives you **persistent instructions** via project rules and/or `AGENTS.md`. Cursor explicitly supports project rules and notes `AGENTS.md` as a simpler alternative. ([Cursor][4])
Cursor also has an Agent that can run commands and edit code. ([Cursor][5])
And it supports @mentions for bringing context (files/docs/snippets) into the chat. ([Cursor][3])

### A. Put a “router” rule in `.cursor/rules/`

Create one high-level rule that teaches Cursor how your scratchpad works.

Example intent (in plain English):

- If the user is working inside `projects/<slug>/`, always load `PROJECT.md` + `MEMORY.md`.
- If the user mentions an assistant, treat that assistant spec as the active “system prompt” for the next response.
- If there’s conflict, project constraints win, then assistant constraints, then general preferences.

Cursor’s official docs emphasize rules as persistent instructions and that `.cursor/rules` is the modern location for these rules. ([Cursor][4])

### B. Use `AGENTS.md` for the simplest version

If you don’t want rule metadata complexity, place an `AGENTS.md` at repo root (and optionally inside `scratchpad/projects/<slug>/` for local overrides). Cursor supports `AGENTS.md` in root and subdirectories. ([Cursor][4])

### C. “@mention = load context” convention

Adopt a muscle-memory convention:

- Start every thread by mentioning:

  - `@scratchpad/projects/<slug>/PROJECT.md`
  - `@scratchpad/projects/<slug>/MEMORY.md`
- When you want a specialist:

  - `@scratchpad/assistants/reviewer/assistant.md`

That mimics OpenAI’s @mentions behavior: you keep the same conversation context, but “route” the next turn through a different specialist. ([OpenAI Help Center][2])

---

## 6) Orchestration logic (how a “turn” should work)

Treat every interaction as a predictable pipeline:

1. **Select ProjectHub**

   - ensure `PROJECT.md` + `MEMORY.md` are in context

2. **Select Assistant** (optional)

   - mention the assistant spec you want active

3. **Do the work**

   - produce output into `OUTPUTS/` (or directly change code)

4. **Commit memory**

   - update `MEMORY.md` (current state)
   - append to `DECISIONS.md` if a choice was made
   - append session summary to `SESSIONS/`

Cursor Agent can help automate the “update memory + write session log” steps since it can edit files and run commands. ([Cursor][5])

---

## 7) Optional “nice-to-have” components (if you want parity+)

### A. Local retrieval index (Projects “files + recall” on steroids)

Add a small script that:

- indexes `projects/**/CONTEXT/**` + `DECISIONS.md` + `MEMORY.md`
- creates an embeddings index under `runtime/index/`
- supports a command like: `scratchpad recall {{project}} "query"`

This gives you “ask the project” recall without having to manually @mention a dozen files.

### B. Assistant tests (keep assistants from drifting)

Under each assistant:

- `tests/` with “input → expected shape of output”
- a “golden prompt” regression file

### C. Collaboration/permissions analogue

ChatGPT Projects have chat vs edit roles in shared projects. ([OpenAI Help Center][1])
In git, mimic that with:

- CODEOWNERS on `PROJECT.md`, `MEMORY.md`, `DECISIONS.md`
- PR-required changes for memory/instructions
- optional “read-only” mirroring via docs site / repo permissions

---

## 8) Minimum viable version (if you want to start today)

If you do nothing else, do **just this**:

1. Create:

- `scratchpad/assistants/<name>/assistant.md`
- `scratchpad/projects/<slug>/PROJECT.md`
- `scratchpad/projects/<slug>/MEMORY.md`

2. Add a root `AGENTS.md` that explains:

- how to load project context
- how to activate an assistant by @mentioning its `assistant.md`

This is fully aligned with Cursor’s supported instruction surfaces (rules and/or `AGENTS.md`). ([Cursor][4])

---

If you tell me what assistants you want first (e.g., “reviewer”, “architect”, “researcher”, “writer”), I can draft the initial `assistant.md` templates and a starter `AGENTS.md` + `.cursor/rules/` router rule text that matches your preferred style and rigor.

[1]: https://help.openai.com/en/articles/10169521-using-projects-in-chatgpt "Projects in ChatGPT | OpenAI Help Center"
[2]: https://help.openai.com/en/articles/8908924-what-is-the-mentions-feature-for-gpts "What is the @mentions feature for GPTs? | OpenAI Help Center"
[3]: https://cursor.com/docs/context/mentions?utm_source=chatgpt.com "@ Mentions - Cursor Docs"
[4]: https://cursor.com/docs/context/rules?utm_source=chatgpt.com "Rules | Cursor Docs"
[5]: https://cursor.com/docs/agent/overview?utm_source=chatgpt.com "Overview | Cursor Docs"
