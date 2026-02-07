# Letta

Yes — there are several Letta ideas you can borrow **directly**, even if you keep HCP’s **git-flat-file canonical artifacts** as the source of truth.

## 1) “Memory blocks” as first-class, labeled context units

Letta treats *core memory* as a set of **pinned, structured, labeled blocks** (e.g., “human”, “persona”, “planning”) that are **always visible** in the context window and can be updated over time. ([Letta Docs][1])
**How to borrow in HCP:** your `.uacf/memory/blocks/*` becomes the canonical equivalent, and your context-pack compiler always includes the relevant blocks (role-scoped) at the top of every pack.

## 2) “Compile the context window” as an explicit pipeline step

Letta describes building each LLM request by “compiling” a context window from persistent state (blocks) + other memory. ([letta.com][2])
**How to borrow in HCP:** formalize your “session start” as a deterministic **context compilation pipeline** (select → order → budget → redact → export), not an ad-hoc “read a few files.”

## 3) Hard separation: **core (in-context)** vs **out-of-context** memory tiers

Letta’s docs explicitly frame two tiers: **in-context/core** (instructions + blocks + recent history) and **out-of-context** (evicted history + archival store). ([Letta Docs][3])
**How to borrow in HCP:** keep `.uacf/` artifacts + “blocks/facts/procedures” as *core*, while pushing large histories and raw traces into *out-of-context* stores (even if that store is still file-based, e.g., NDJSON + summaries).

## 4) “Agent-immutable” long-term memory for governance

Letta’s **archival memory** is explicitly designed to be **agent-immutable** (agents can insert/search; developers can manage edits/deletes via SDK), which prevents silent rewriting and drift. ([Letta Docs][4])
**How to borrow in HCP:** mirror this with:

- append-only event logs
- immutable accepted decisions
- “facts” editable only via a **proposal → accept** workflow (your `.uacf/memory/proposals/*` pattern)

## 5) Built-in memory tools (standard operations, not bespoke prompts)

Letta provides default “base tools” for memory management and access to conversation history + archival storage. ([Letta Docs][5])
**How to borrow in HCP:** standardize a small set of *memory ops* your agents always use:

- `search_hcg(query)` (facts/episodes/procedures)
- `append_event(ndjson)` + `write_session_summary()`
- `propose_memory_update(patch)` (writes proposal artifacts)
  This reduces variability and improves reliability.

## 6) Multi-agent “shared blocks” as a coordination primitive

Letta supports attaching the same memory block to multiple agents and also provides guidance for **multi-agent shared memory** (e.g., workers write outputs to blocks that a supervisor reads). ([Letta Docs][6])
**How to borrow in HCP:** define explicit shared artifacts (e.g., `.uacf/memory/blocks/org-broadcast.*`, `.uacf/handoff.md`, `.uacf/plan.md`) and declare which roles can write to which blocks (read-only vs read-write).

## 7) “Filesystem-only memory can be enough” (validate your current direction)

Letta’s benchmarking writeup argues that with good agent design, **simple filesystem tools** can perform strongly on retrieval-oriented benchmarks, and more complex tools can be added later via integrations. ([letta.com][7])
**How to borrow in HCP:** treat your current file-based system as the baseline that can scale surprisingly far, while keeping an escape hatch (runtime MemoryService / vector search) for high-churn, user-scoped, or huge corpora.

## 8) Make memory debuggable: visibility into what the agent “saw”

Letta’s ADE is explicitly about making context windows and memory state **visible and manageable** for debugging. ([letta.com][8])
**How to borrow in HCP:** build an “Agent Pack Inspector” (even a CLI report) that shows:

- which blocks/facts/episodes were included
- token budget usage by section
- redactions applied
- diffs vs previous pack
  This is huge for diagnosing continuity failures.

## 9) Treat model selection + memory as an eval surface

Letta created a **leaderboard focused on agentic memory management** because model choice behaves differently in stateful-agent scenarios. ([letta.com][9])
**How to borrow in HCP:** add a small regression suite: “rehydration success,” “contradiction handling,” “proposal quality,” “context rot resistance,” etc., so changes to prompts/pack logic don’t silently degrade continuity.

---

### The “best-fit” Letta borrow for Harmony, in one sentence

Adopt Letta’s **memory blocks + context compilation + immutable archival governance + observability** patterns, but implement them as **typed, validated HCP artifacts + deterministic exports**, keeping any server DB only for **high-churn recall/personalization** where you truly need it. ([letta.com][2])

[1]: https://docs.letta.com/guides/ade/core-memory?utm_source=chatgpt.com "Core memory | Letta Docs"
[2]: https://www.letta.com/blog/memory-blocks?utm_source=chatgpt.com "Memory Blocks: The Key to Agentic Context Management - Letta"
[3]: https://docs.letta.com/guides/agents/architectures/memgpt?utm_source=chatgpt.com "Agent memory & architecture | Letta Docs"
[4]: https://docs.letta.com/guides/agents/archival-memory?utm_source=chatgpt.com "Archival memory | Letta Docs"
[5]: https://docs.letta.com/guides/agents/base-tools?utm_source=chatgpt.com "Base tools | Letta Docs"
[6]: https://docs.letta.com/guides/agents/multi-agent-shared-memory?utm_source=chatgpt.com "Multi-agent shared memory | Letta Docs"
[7]: https://www.letta.com/blog/benchmarking-ai-agent-memory?utm_source=chatgpt.com "Benchmarking AI Agent Memory: Is a Filesystem All You Need? - Letta"
[8]: https://www.letta.com/blog/introducing-the-agent-development-environment?utm_source=chatgpt.com "Introducing the Agent Development Environment - Letta"
[9]: https://www.letta.com/blog/letta-leaderboard?utm_source=chatgpt.com "Letta Leaderboard: Benchmarking LLMs on Agentic Memory"

