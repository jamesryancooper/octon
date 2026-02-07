# LangChain

Yep—LangChain/LangGraph have a bunch of **clean, composable abstractions** you can borrow to make your Continuity Plane (HCP/HCG + `.uacf/`) more robust, especially for **multi-session + multi-agent** work.

## 1) Adopt LangGraph’s split: “short-term state” vs “long-term store”

LangGraph draws a sharp line between:

- **Short-term memory = thread-scoped state** (the “working set” for a single conversation/run), persisted via **checkpoints** so the thread can be resumed. ([LangChain Docs][1])
- **Long-term memory = a store** (cross-thread, cross-session), organized by **namespaces** and retrievable anytime. ([LangChain Docs][1])

**How to borrow for HCP**

- Treat your existing `.uacf/handshake + progress + decisions` as *canonical long-term*, but also introduce an explicit **short-term “run state”** artifact model (more below).
- Add a **Store abstraction** to your compiler/runtime that can hold “memories” as JSON docs keyed by `(namespace, key)` and compiled into HCG. (This maps directly to LangGraph’s `store.put(namespace, key, value)` mental model.) ([LangChain Docs][1])

## 2) Bring checkpointer semantics into the Continuity Plane

LangGraph’s persistence model is extremely Continuity-friendly:

- It checkpoints **graph state every super-step**, keyed by a **thread_id**, enabling **resume**, **state history**, **replay/time travel**, and **fault tolerance** (including “pending writes” so you don’t re-run successful steps after a failure). ([LangChain Docs][2])
- It also supports **encryption at the persistence layer** via encrypted serializers. ([LangChain Docs][2])

**How to borrow for HCP**

- Add a `.uacf/checkpoints/` (or `.uacf/runs/<run_id>/checkpoints/`) folder containing:

  - `state.json` snapshots (or per-channel files)
  - `writes.log` (pending writes / applied writes)
  - metadata (step number, timestamps, tool calls, provenance)
- Make checkpointing **automatic at each “agent step”** (tool call, test run, file write batch), not only at session end.
- Add “time travel” primitives: *replay from checkpoint*, *fork run from checkpoint*, *diff checkpoints*.

This dovetails with your “content compiler” idea: checkpoints are raw, and HCP compiles them into queryable HCG tables (runs, steps, artifacts, decisions, outputs).

## 3) Use namespaces as the spine for your “memory surfaces”

LangGraph’s long-term store is explicitly hierarchical: **namespace = folder-like grouping**, key = filename-like identifier; namespaces often include user/org IDs and other labels, and you can search with filters. ([LangChain Docs][1])

**How to borrow for HCP**
Make “surface” and “scope” first-class **namespace dimensions** in your HCG index, e.g.:

`(org_id, project_id, surface, principal, memory_type, scope)`

Examples:

- Public institutional facts: `(acme, harmony, public, system, semantic, canon)`
- Internal runbook knowledge: `(acme, harmony, internal, system, semantic, canon)`
- Agent-facing continuity artifacts: `(acme, harmony, agent, system, episodic, runs)`
- Personal preferences: `(acme, harmony, agent, user:123, profile, preferences)`

This gives you **orthogonal composition** (public/internal/agent-facing × personal/system × semantic/episodic/procedural), without needing separate storage systems for every axis.

## 4) Add “memory shaping” tools: trim, delete, summarize

LangGraph is blunt about reality: long histories break context windows and degrade model quality, so it bakes in a toolkit:

- **Trim messages**
- **Delete messages**
- **Summarize earlier history and replace it with a summary**
- plus custom filtering strategies ([LangChain Docs][3])

**How to borrow for HCP**

- Standardize a **Context Budget Policy** in `.uacf/`:

  - “keep last N turns + pinned facts + running summary”
  - “never drop tool-call/result pairs”
- Treat `handoff.md` as the *summary artifact*, but make it **incrementally maintained** (like LangGraph’s `summary` key alongside `messages`). ([LangChain Docs][3])

## 5) Support both semantic “profiles” and “collections”

LangChain’s memory conceptual guide calls out two pragmatic representations for semantic memory:

- **Profile**: a single continuously-updated JSON doc (good for preferences, constraints, stable facts)
- **Collection**: many small memory docs (often higher recall, but needs consolidation/deletion discipline) ([LangChain Docs][1])

**How to borrow for HCP**

- Implement both as first-class typed blocks in HCP:

  - `profiles/<principal>.json` (strict schema, patch updates)
  - `collections/<topic>/*.json` (append-friendly, later consolidation)
- Compile both into SQLite tables + optional embedding indexes (mirroring LangGraph store’s ability to choose which fields get embedded). ([LangChain Docs][2])

## 6) Make “procedural memory” an explicit artifact: prompts evolve via reflection

LangChain frames **procedural memory** for agents as a combo of code + prompt + weights, and notes it’s common to update prompts via **reflection/meta-prompting**, even storing/updating the prompt inside the memory store. ([LangChain Docs][1])

**How to borrow for HCP**

- Treat your agent’s “operating manual” as **versioned procedural memory**:

  - `.uacf/procedures/system_prompt.md`
  - `.uacf/procedures/tool_policies.yaml`
  - `.uacf/procedures/workflow.md`
- Add a structured “reflection” flow: feedback → propose patch → require approval tier → persist new procedure.

## 7) Hot-path vs background memory writing (and why it matters)

LangChain distinguishes:

- **Hot path**: write memories during the main run (immediate availability, but adds latency and complexity)
- **Background**: extract memories asynchronously after (no latency, but you must choose when to trigger) ([LangChain Docs][1])

**How to borrow for HCP**
This fits your compiler philosophy perfectly:

- Hot-path writes = **minimal, essential continuity** (plan/progress/decision deltas)
- Background writes = **“memory distillation jobs”** that turn logs/checkpoints into:

  - updated profiles
  - consolidated collections
  - improved handoff briefs
  - extracted reusable examples (episodic memory)

## 8) Storage implications: where SQLite fits, where Postgres helps

LangGraph explicitly supports:

- **SQLite checkpointers** as great for local/experimentation
- **Postgres checkpointers** as ideal for production persistence ([LangChain Docs][2])

**A good mapping for your Continuity Plane**

- **HCP SQLite (compiled, deterministic index)** is perfect for:

  - canonical artifacts (`decisions`, `plans`, `runbooks`)
  - queryability, blast-radius analysis, reproducible builds
- **Postgres (server DB)** becomes attractive when you need:

  - high write concurrency (many agents/users writing checkpoints)
  - runtime “thread state” shared across machines/services
  - low-latency resume/time-travel APIs

A hybrid is very natural: *Postgres holds live checkpoint/state*, and HCP compiles **promoted** continuity artifacts + summarized run outputs into the canonical SQLite/HCG snapshot.

---

## Concrete “imports” I’d implement in HCP, inspired by LangChain

1. **Thread model**: adopt `thread_id` + optional `user_id` as universal keys across all continuity operations. ([LangChain Docs][2])
2. **Checkpointer interface** (file-backed first, DB-backed optional): `.put`, `.get`, `.list`, plus “pending writes”. ([LangChain Docs][2])
3. **Store interface**: namespace/key JSON memories, compiled into HCG; add optional semantic search and content filters. ([LangChain Docs][1])
4. **Context shaping policies**: trim/delete/summarize as standardized transformations. ([LangChain Docs][3])
5. **Procedural memory artifacts**: reflection-driven prompt/procedure updates. ([LangChain Docs][1])

If you want, I can turn this into a **Harmony Continuity Plane “Memory & Persistence” spec page** (schemas + folder layout + compilation outputs + what stays file-first vs when you’d add a Postgres checkpointer).

[1]: https://docs.langchain.com/oss/python/concepts/memory "Memory overview - Docs by LangChain"
[2]: https://docs.langchain.com/oss/python/langgraph/persistence "Persistence - Docs by LangChain"
[3]: https://docs.langchain.com/oss/javascript/langgraph/add-memory "Memory - Docs by LangChain"

What concepts, architectural approaches, or other ideas can we borrow from LangChain to help improve our Continuity Plane?
