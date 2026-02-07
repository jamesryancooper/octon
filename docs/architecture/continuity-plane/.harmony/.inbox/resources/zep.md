# Zep

Yep — **Zep is very much “in the same family” as your approach**, but it sits at a different layer of the stack.

## What Zep is (and why it’s relevant to your file-based continuity memory)

Zep positions itself as a **context engineering platform** that **assembles the right context automatically** from *chat history + business data + events*, and returns that assembled context to the agent via an API. ([Zep Documentation][1])

Concretely, Zep:

- **Persists and recalls chat histories**
- **Generates summaries and other “artifacts” from those histories**
- **Embeds messages/summaries for search**
- Does this **asynchronously**, and **persists to a database** so it can scale ([GitHub][2])

That’s conceptually extremely close to your model (“turn ephemeral context into persistent memory”), except:

- Your canonical artifacts live as **files in git** and get compiled into a **queryable content graph (SQLite + JSON + dependency graph)**.
- Zep’s canonical store is a **runtime memory service** backed by a **database** and optimized for **fast retrieval + dynamic updates**. ([GitHub][2])

## Graphiti: Zep’s open-source “engine” that maps well to agent memory

Zep’s open-source project **Graphiti** is explicitly a **temporal / temporally-aware knowledge graph framework** for agents, built for **incremental updates (no batch recomputation)** and **hybrid retrieval**. ([GitHub][3])

A few key things that are particularly aligned with your “continuity” objectives:

- **Temporal validity + change handling** (“facts change, old ones invalidated; history preserved”) — i.e., memory that evolves rather than “static RAG.” ([Zep][4])
- A first-class idea of **episodes** (adding text/JSON episodes into memory). ([Zep Documentation][5])
- An **MCP server** so IDE agents (Claude Desktop/Cursor/etc.) can query the knowledge graph as “memory.” ([Zep Documentation][5])
- Graphiti is described as powering Zep’s commercial context engineering platform. ([GitHub][3])

## How similar is it to “file-based artifacts” like handoffs/progress/decisions

**Similar in spirit:**

- Your process: *session → summarize → write durable artifacts → next session reads artifacts*
- Zep/Graphiti: *interaction/event → extract facts/entities/relationships → store durably → retrieve the right slices later* ([Zep][4])

**Different in shape:**

- Your artifacts are **human-auditable, reviewable, version-controlled** (institutional memory + continuity trails).
- Zep is optimized for **runtime personalization + fast relevance selection** (agent context assembly), and it stores memory in a **database** rather than “repo files as source of truth.” ([Zep][4])

## The “DB question”: does Zep imply Postgres/Neo4j-style infrastructure

Zep (as a service) is explicitly **database-backed** for durability and scale. ([GitHub][2])

Graphiti is flexible about storage backends. In their docs, they expose configuration guides for multiple graph databases, including **Neo4j, FalkorDB, AWS Neptune, and Kuzu DB**. ([Zep Documentation][5])
That’s a strong hint that:

- Some deployments are naturally **server-backed** (Neo4j/Neptune),
- while others can be more **local/embedded-friendly** (Kuzu is typically embedded/on-disk).

## A clean way to integrate Zep-style memory with your Harmony Content Plane

If you want the best of both worlds, the clean separation usually looks like:

- **HCP / HCG (git + compiler + SQLite index)** = *canonical, reviewable continuity artifacts + institutional memory + publishable surfaces.*
- **Zep/Graphiti (runtime DB + temporal KG)** = *high-churn, personalized, event-driven memory + fast retrieval/context assembly.*

Then you add a controlled “bridge”:

- **Export** curated snapshots from Zep/Graphiti into your `.uacf/` artifacts (e.g., “user summary”, “current constraints”, “recent decisions”) at session end for auditability.
- **Ingest** selected HCP entities (policies, specs, product truths) into Graphiti as “episodes” so runtime memory stays grounded in canonical content.

If you want, I can propose a concrete “bridge contract” (what gets synced, when, and how to avoid canon conflicts) that fits your **public/internal/agent-facing** surfaces and your **static vs dynamic** memory dimensions.

[1]: https://help.getzep.com/overview "Welcome to Zep! | Zep Documentation"
[2]: https://github.com/getzep/zep-python "GitHub - getzep/zep-python: Build Agents That Recall What Matters.  Systematically engineer relevant context from chat history & business data. (Python Client)"
[3]: https://github.com/getzep/graphiti "GitHub - getzep/graphiti: Build Real-Time Knowledge Graphs for AI Agents"
[4]: https://www.getzep.com/ "Context Engineering & Agent Memory Platform for AI Agents - Zep"
[5]: https://help.getzep.com/graphiti "Welcome to Graphiti! | Zep Documentation"

Zep has a bunch of “memory-as-infrastructure” ideas you can borrow without turning Harmony into a server-first product. The trick is to lift the *concepts* (temporal graph, episodic ingestion, context assembly contracts) and implement them inside your **file-first compiler + queryable HCG** model.

## 1) Borrow Zep’s “context assembly” abstraction (not just retrieval)

Zep frames the problem as: **(1) add context → (2) maintain a temporal knowledge model → (3) retrieve & assemble a pre-formatted context block**. ([GitHub][1])

**How to apply to HCP**

- Make “context assembly” a **first-class compiler/output** alongside “render to web/email”.
- Treat agent startup as: `seed → assemble → export` rather than “read a few files”.

## 2) Ship a default “Context Block” format + templating

Zep’s “Context Block” is an **optimized, automatically assembled string** designed to be pasted straight into prompts. It also offers **custom templates** and an “advanced” mode with full control. ([Zep Documentation][2])

**How to apply to HCP**

- Add `hcp context get` that emits a **Harmony Context Block** with fixed sections (like: *Project Brief, Current Plan, Recent Decisions, Relevant Facts, Procedures*).
- Add **template packs** per role/harness (e.g., *Coder*, *Ops*, *PM*, *Research*) mirroring Zep’s “custom context templates” idea. ([Zep Documentation][2])

## 3) Hybrid retrieval: semantic + full-text + graph traversal

Zep explicitly combines **semantic search + full-text search + breadth-first search** to assemble the Context Block. ([Zep Documentation][2])
Graphiti likewise emphasizes **hybrid retrieval (embeddings + BM25 + graph traversal)**. ([GitHub][3])

**How to apply to HCP**

- In HCG/SQLite: use **FTS5** (full-text) + graph adjacency (dependency graph) and optionally a vector index (local or external).
- Treat *refs* as graph edges: BFS outward from seed nodes (active backlog item, latest handoff, touched entities) to collect relevant memory.

## 4) Avoid LLM calls in the retrieval path

Zep deprecated a “summarized context” mode because it couldn’t hit low-latency requirements; it now returns **structured facts + a user summary** optimized for performance. ([Zep Documentation][2])
Graphiti also highlights achieving fast retrieval by **avoiding LLM calls during retrieval**. ([Graph Database & Analytics][4])

**How to apply to HCP**

- Do compaction/summarization **offline** (build-time or session-end), not at “agent start” time.
- Your current “write handoff at end” pattern is perfect—just formalize it into compiler outputs (summaries, facts, indexes).

## 5) Temporal memory model: track change, invalidate—not overwrite

Zep/Graphiti emphasize that new interactions should **update or invalidate outdated facts while retaining history** (so agents can reason over evolving state). ([Zep][5])
Graphiti’s docs call out **temporal awareness** and point-in-time queries. ([Zep Documentation][6])

**How to apply to HCP**

- Add **bi-temporal fields** to memory edges/claims:

  - `t_observed` (when it was true in the world)
  - `t_ingested` (when you learned it)
  - `t_valid_from`, `t_valid_to` (validity interval)
- Replace “edit the fact in place” with: **new claim supersedes old claim**, old claim becomes invalid but queryable.

## 6) Episodic ingestion as the backbone of continuity

Graphiti’s docs describe ingesting data as **discrete episodes** to preserve provenance and enable incremental extraction. ([Zep Documentation][6])
Zep’s Memory API adds session-specific messages, and Zep builds a **user-level knowledge graph** from them. ([Zep Documentation][7])

**How to apply to HCP**

- Treat each session end as an **Episode bundle**:

  - raw events (append-only)
  - a session summary
  - extracted candidates (facts/relations) with provenance pointers
- Your existing handoff/progress/decisions become “episodes” feeding a continuously updated HCG.

## 7) Two-layer API: opinionated default + power-user graph API

Zep explicitly offers a **high-level Memory API** and a **lower-level Graph API** for customization. ([Zep Documentation][7])

**How to apply to HCP**

- Provide:

  - **Simple**: “give me a context block for this task”
  - **Advanced**: “run this query + render with this template”
- This maps nicely to your “compiler not product” boundary: the “advanced” layer can just be SQL + render templates over SQLite outputs.

## 8) Custom ontology / entity types (schema-driven precision)

Zep markets “custom graph entities” and explicitly encourages defining domain-specific entities using familiar schema tooling (Zod/Pydantic). ([Zep][5])

**How to apply to HCP**

- Expand your schema registry so memory objects can declare:

  - entity types (`Customer`, `Incident`, `Feature`, `Policy`, `Decision`)
  - relation types (`depends_on`, `supersedes`, `blocked_by`, `applies_to`)
- Compiler validates them and materializes join tables for fast query + BFS.

## 9) Unified graph from heterogeneous sources (files + business data + events)

Zep’s core claim is assembling relationship-aware context from **chat history, business data, documents, and app events**. ([GitHub][1])

**How to apply to HCP**

- Keep **files canonical**, but allow “imports” as deterministic inputs:

  - nightly exported event logs
  - CRM snapshots
  - incident timelines
- Compile them into HCG as additional typed entities/edges (still deterministic).

## 10) Explainability & debugging for context (“why did the agent see this?”)

Graphiti’s README contrasts Zep’s managed platform as having **graph visualization + debug logs + API logs**. ([GitHub][3])

**How to apply to HCP**

- Add a compiler output: `context_explain.json` listing:

  - which seed triggered inclusion
  - traversal path / query that selected it
  - provenance (episode IDs, refs)
    This is huge for trust, regressions, and “context rot” debugging.

---

# What can stay SQLite/file-first vs what pushes you toward Postgres

**Stays comfortably in HCP (git + compiler + SQLite):**

- Context Block + templates
- Hybrid retrieval via FTS5 + graph traversal over your dependency graph
- Episodic ingestion from `.uacf/` artifacts
- Temporal validity + invalidation (modeled in tables)
- Custom ontology types (schemas → tables)
- Explainability outputs (“why included” traces)

**Starts to justify a server DB (Postgres/Neo4j/etc.):**

- Very high-churn, per-user memory at scale (many concurrent writes)
- Strong deletion/retention guarantees per user/tenant (GDPR-like workloads)
- Sub-200ms online retrieval under load across huge graphs
- Continuous ingestion from many live sources with streaming updates

A practical hybrid (very Zep-aligned) is: **HCP remains canonical + auditable**, and a runtime memory service (optional) produces *proposals/episodes* that get compiled back into canonical artifacts—so you never lose your “content is code” benefits while still enabling Zep-style dynamism. ([Zep Documentation][7])

[6]: https://help.getzep.com/graphiti/getting-started/overview "Overview | Zep Documentation"
[7]: https://help.getzep.com/v2/memory "Memory | Zep Documentation"
