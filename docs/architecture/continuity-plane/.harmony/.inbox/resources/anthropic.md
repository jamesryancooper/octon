# Anthropic

Here are the most “stealable” Anthropic ideas for upgrading Harmony’s Continuity Plane (file-based continuity artifacts + HCP compiler + HCG index), organized by what they enable and how they map to your substrate.

## 1) Treat “continuity” as a harness behavior, not a prompt trick

**What Anthropic does**

* Pushes agents into an explicit **incremental loop** (one feature / one unit of work at a time), and requires leaving the workspace in a **clean, recoverable state** each iteration. ([Anthropic][1])
* Uses **structured state files (often JSON)** for things like test status / feature status because models are less likely to “creative-write” or overwrite structure vs freeform docs. ([Anthropic][1])
* Bakes in **“get bearings”** routines: check working directory, read git logs + progress files, pick next unfinished item. ([Anthropic][1])

**How to borrow in HCP**

* Make your `.uacf/` artifacts the canonical “bearings” interface (backlog → plan → progress → handoff) and enforce **structured fields** for status/acceptance/evidence (JSON/YAML) while keeping narrative progress append-only (Markdown).
* Put the “bearings checklist” into the **compiler contract** (a required artifact schema + lint rules), not just a best-practice doc.

## 2) “Multi-context window workflows” as a first-class protocol

**What Anthropic recommends**

* Use a **different first-window prompt** to set up durable scaffolding (tests, setup scripts), then later windows iterate against a todo list / structured state. ([Claude][2])
* Prefer **starting fresh** sometimes over compaction because strong models can rediscover state from the filesystem quickly—*if* you tell them exactly what to read first (progress, tests, git logs). ([Claude][2])
* Explicitly instruct agents not to “wrap up early” as the context limit approaches; instead **save state to memory** and continue. ([Claude][2])

**How to borrow in HCP**

* Codify two startup modes in your session templates:

  1. **Fresh-window rehydrate**: read `.uacf/handoff.md`, `.uacf/plan.md`, `.uacf/backlog.*`, newest progress entries.
  2. **Compacted carryover** (optional): only if the harness supports safe summarization and you want continuity inside the transcript.
* Add a CI rule: every “session end” must produce a **handoff brief** plus updated structured state (status + evidence).

## 3) Context engineering = “progressive disclosure” + filesystem semantics

**What Anthropic emphasizes**

* Agents should avoid loading everything into context; instead use tools (or shell primitives) to **query, slice, and retrieve just-in-time**—mirroring how humans use external indexes rather than memorizing corpora. ([Anthropic][3])
* File/folder names and structure act as **behavioral metadata** that guides the agent toward the right information. ([Anthropic][3])

**How to borrow in HCP**

* Treat repo layout + naming conventions as part of your “context API.” Concretely:

  * Standardize surfaces: `public/`, `internal/`, `agent/` (or metadata-first with folder defaults) and teach agents to infer trust + intended use from location.
  * Have HCP emit a **“context pack manifest”** (a small, high-signal index) the agent can consult first, then drill down as needed.

## 4) Memory as a tool: dedicated directory + strict protocol + backend flexibility

**What Anthropic ships (memory tool)**

* A **file-based memory directory** that persists across conversations; Claude automatically checks it first; agents can create/update/delete files there. ([Claude][4])
* The tool is **client-side**: you control storage (files, database, cloud storage, encryption, etc.). ([Claude][4])
* Strong operational guidance: always view memory first; assume interruption; keep it organized; security controls like path traversal protection, size limits, expiration. ([Claude][4])

**How to borrow in HCP**

* Your `.uacf/` folder is already conceptually similar. The key upgrades to “Anthropic-grade” are:

  * **Hard protocol**: “view memory first,” “assume interruption,” “record decisions + evidence immediately.”
  * **Tool boundary**: restrict writes to approved memory roots (e.g., `.uacf/` + `agent/` surface), and enforce PII/secret stripping rules.
  * **Backend split**: keep authoritative memory in git files, but allow an optional **server-backed mirror** when you need concurrency, access control, or high-frequency events (see #6 below).

## 5) Context management: automatic clearing + preserve-to-memory at thresholds

**What Anthropic adds**

* **Context editing** clears stale tool results and/or old “thinking” blocks as context grows—server-side strategies plus SDK compaction options. ([Claude][5])
* When paired with memory, the agent gets a warning and can **summarize key info into memory** before old tool results are cleared. ([Claude][4])

**How to borrow in HCP**

* Implement a harness-level “context pressure” hook:

  * On pressure: auto-trigger a “write handoff / progress / decision delta” routine into `.uacf/`.
  * Allow aggressive transcript trimming because your real continuity lives in artifacts + HCG.

## 6) Subagents + isolated contexts as a scalability primitive

**What Anthropic suggests in the Agent SDK**

* Subagents help in two ways: **parallelization** and **context isolation** (subagents return only relevant findings to the orchestrator). ([Anthropic][6])

**How to borrow in HCP**

* Treat “specialist agents” as producing **typed outputs** into the Content Plane (e.g., `research_findings.yaml`, `test_report.json`, `decision_proposal.md`) that the orchestrator compiles/indexes.
* In other words: subagents shouldn’t spray chat text; they should emit artifacts your compiler can validate.

## 7) Tool scale without context bloat: on-demand tool discovery + examples

**What Anthropic introduced (advanced tool use)**

* **Tool Search Tool**: don’t stuff 50K–100K tokens of tool definitions into the prompt; discover tools on demand. ([Anthropic][7])
* **Programmatic Tool Calling**: shift orchestration logic into code where appropriate to reduce context pollution and enable loops/conditionals cleanly. ([Anthropic][7])
* **Tool Use Examples**: schemas aren’t enough—attach concise examples to reduce parameter mistakes. ([Anthropic][7])

**How to borrow in HCP**

* Extend HCP to compile a **Tool Catalog** (schemas + examples + safety policies) into HCG.
* Give agents a “tool search” capability against HCG, loading only the few tools relevant to the current step.
* Store examples as versioned, reviewable artifacts (so tool behavior is teachable and auditable).

## 8) File-based “project configuration” as an agent surface

**What Anthropic exposes**

* The Agent SDK supports filesystem-based configuration like **project memory and instructions** (e.g., `CLAUDE.md` / `.claude/CLAUDE.md`) plus “skills” and custom command surfaces. ([Claude][8])

**How to borrow in HCP**

* Standardize a Harmony equivalent:

  * `HARMONY.md` (project constraints + invariants)
  * `.uacf/` (continuity)
  * `.hcp/` (compiler config, schemas, render targets)
* Compile these into a single “agent-facing context pack” output every build.

## Practical “next upgrades” for Harmony (high leverage, low risk)

1. Enforce **structured state** + append-only logs (compiler-validated). ([Claude][2])
2. Add a **context pressure → persist-to-artifacts** hook (your version of memory+context editing). ([Claude][4])
3. Add **tool catalog + tool search** to avoid context bloat and make tool use teachable (schemas + examples). ([Anthropic][7])
4. Add **subagent output contracts**: subagents must write typed artifacts, not just prose. ([Anthropic][6])

* [The Verge](https://www.theverge.com/news/804124/anthropic-claude-ai-memory-upgrade-all-subscribers?utm_source=chatgpt.com)
* [The Verge](https://www.theverge.com/news/776827/anthropic-claude-ai-memory-upgrade-team-enterprise?utm_source=chatgpt.com)
* [Tom's Guide](https://www.tomsguide.com/ai/claude-just-unlocked-memory-that-syncs-with-chatgpt-heres-how-it-works?utm_source=chatgpt.com)

[1]: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents "Effective harnesses for long-running agents \ Anthropic"
[2]: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices "Prompting best practices - Claude Docs"
[3]: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents "Effective context engineering for AI agents \ Anthropic"
[4]: https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool "Memory tool - Claude Docs"
[5]: https://platform.claude.com/docs/en/build-with-claude/context-editing "Context editing - Claude Docs"
[6]: https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk "Building agents with the Claude Agent SDK \ Anthropic"
[7]: https://www.anthropic.com/engineering/advanced-tool-use "Introducing advanced tool use on the Claude Developer Platform \ Anthropic"
[8]: https://platform.claude.com/docs/en/agent-sdk/overview "Agent SDK overview - Claude Docs"
