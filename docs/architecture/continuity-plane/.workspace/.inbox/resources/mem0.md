# Mem0

Mem0 is *very* relevant to what you’re building—but it’s “memory as a runtime service,” whereas your Harmony Content Plane (HCP) approach is “memory as versioned artifacts compiled into a queryable graph.”

## What Mem0 is (in terms that map to your framework)

Mem0 positions itself as a **memory layer for agents/apps** with explicit operations to **add, search, update, and delete** memories. ([Mem0][1])

A key part of its design is a **layered taxonomy of memory**:

* **Conversation memory** (in-flight, current turn)
* **Session memory** (short-lived, scoped to a task/session)
* **User memory** (long-lived personalization)
* **Organizational memory** (shared context across agents/teams) ([Mem0][2])

Under the hood, Mem0 is typically backed by a **vector store** (semantic retrieval), with optional reranking/filters in the search pipeline. ([Mem0][1])
It can also optionally add **graph memory**, where it extracts entities/relationships and stores edges in a graph backend (Neo4j/Memgraph/Neptune/Kuzu, etc.) to support multi-hop recall. ([Mem0][3])

## What’s closest to your “file-based handoff artifacts” approach: OpenMemory (MCP)

Mem0 also ships **OpenMemory MCP Server**, which is explicitly about **cross-tool continuity**: a *local-first* memory server your MCP-compatible tools can connect to, so “context handoff across tools” doesn’t require repeating instructions. ([Mem0][4])

It exposes standardized MCP tools like:

* `add_memories`, `search_memory`, `list_memories`, `delete_all_memories` ([Mem0][4])

So conceptually it matches your operational loop:

> *end-of-session → persist; start-of-session → rehydrate*
> …but with an API + retrieval pipeline instead of git-tracked artifacts.

## Where Mem0 fits inside HCP (and where it doesn’t)

### The cleanest mental model

* **HCP / .uacf artifacts = canonical, auditable, institutional memory**

  * versioned (git), reviewable (PRs), deterministic compilation into HCG (SQLite/JSON/graph)
  * great for decisions, plans, runbooks, “why,” and anything that must be *inspectable + governable*
* **Mem0 = runtime, write-heavy, retrieval-optimized memory**

  * great for personalization, high-churn session notes, “stuff the agent should remember but humans don’t want to curate line-by-line”

### How the orthogonal “memory surfaces” map

* **Personal / user memory** → Mem0 “user memory” layer (keyed by `user_id`) ([Mem0][2])
* **Task/session memory** → Mem0 “session memory” (`session_id`) or HCP session-scoped handoff briefs (depending on whether you want it queryable by SQL/graph vs semantically retrievable by vector search) ([Mem0][2])
* **System/organizational memory** → either:

  * **HCP-first** (preferred as source of truth), *optionally mirrored into Mem0 org memory for fast semantic recall*, or
  * Mem0 “organizational memory” with strong governance to avoid drift ([Mem0][2])

## Do you need Postgres, or is SQLite enough?

**SQLite (your HCP implementation) is excellent for**:

* deterministic, build-time indexing of artifacts/content into a **queryable snapshot**
* read-heavy access patterns (agent rehydration, “blast radius” queries, dependency graph traversals)
* governance workflows (git/PR)

**A server DB (Postgres/pgvector, etc.) becomes attractive when you need**:

* **high-frequency writes** (many small memory events per minute)
* **concurrency** (many agents/users writing simultaneously)
* **vector similarity search at scale** with filtering/retention policies

Mem0 explicitly supports **pgvector on Postgres** as a vector store option (create the Postgres `vector` extension; configure provider `"pgvector"`). ([Mem0][5])
And OpenMemory’s installer script shows it can be configured to run with different stores (defaulting to Qdrant, but including `pgvector`, `chroma`, `redis`, etc.). ([GitHub][6])

So the practical answer is:

* **Institutional memory + continuity artifacts** → keep in **HCP + SQLite index** (canonical, governed).
* **Personalization + high-churn runtime memory** → Mem0 backed by **Postgres/pgvector (or another vector DB)**.

## A hybrid integration pattern that usually works best

**“HCP is source of truth; Mem0 is a recall accelerator.”**

1. **Write-back promotion (recommended)**

   * During a run: agent can store lots of raw/cheap memories in Mem0 (session/user)
   * End of run: agent promotes *curated* outcomes into `.uacf/` artifacts (decisions, plan updates, handoff brief), which HCP compiles and indexes.

2. **HCP ↔ Mem0 linking via stable IDs**

   * When writing to Mem0, include metadata like `hcp_ref: "ref:uacf:handoff@2025-12-16"` so retrieval can deep-link back to the canonical artifact.

3. **Deletion/compliance strategy**

   * Mem0 supports targeted deletion (including filter-based deletes) for cleanup/erasure workflows. ([Mem0][7])
   * HCP uses git history + explicit lifecycle rules (append-only logs, ADRs), which is good for auditability but requires separate handling for privacy/PII policies.

## One more “similar to your approach” datapoint

There are already MCP memory servers explicitly “using mem0 principles” backed by **Postgres + pgvector** (i.e., service-based memory that tools can query), which is basically the Mem0-style complement to your file-based continuity artifacts. ([GitHub][8])

---

If you want, I can propose a concrete **HCP ↔ Mem0 interface contract** (IDs, metadata schema, retention rules, and a “promotion rubric” for what *must* land in `.uacf/` vs what can remain ephemeral in Mem0).

[1]: https://docs.mem0.ai/core-concepts/memory-operations/search "Search Memory - Mem0"
[2]: https://docs.mem0.ai/core-concepts/memory-types "Memory Types - Mem0"
[3]: https://docs.mem0.ai/open-source/features/graph-memory "Graph Memory - Mem0"
[4]: https://docs.mem0.ai/openmemory/overview "Overview - Mem0"
[5]: https://docs.mem0.ai/components/vectordbs/dbs/pgvector "Pgvector - Mem0"
[6]: https://raw.githubusercontent.com/mem0ai/mem0/main/openmemory/run.sh "raw.githubusercontent.com"
[7]: https://docs.mem0.ai/core-concepts/memory-operations/delete "Delete Memory - Mem0"
[8]: https://github.com/sdimitrov/mcp-memory "GitHub - sdimitrov/mcp-memory: MCP Memory Server with PostgreSQL and pgvector for long-term memory capabilities"

Here are the highest-leverage ideas from **Mem0** you can borrow to strengthen your **Continuity Plane / Harmony Content Plane (HCP)**, mapped to how you’d implement them in a **flat-file-first, compiler-built** system.

## 1) Treat “memory” as a lifecycle pipeline, not a bucket

Mem0’s core move is a **two-phase incremental pipeline**:

* **Extract** candidate memories from the newest interaction using (a) a rolling conversation summary + (b) a recency window of recent messages.
* **Update** the memory store by comparing each candidate to similar existing memories and choosing an operation: **ADD / UPDATE / DELETE / NOOP**. ([ar5iv][1])

**What to borrow for HCP**

* Add a compiler step: `hcp memory extract` → `hcp memory reconcile`.
* Make “memory writes” **idempotent**: the default action is *NOOP* unless there’s strong evidence to add/update/delete.
* Prefer **“invalidate/tombstone”** over hard deletes for auditability + temporal reasoning (Mem0’s graph variant explicitly discusses marking relationships invalid rather than removing them in some cases). ([ar5iv][1])

## 2) Use dual context for extraction: “summary + recency”

Mem0 explicitly uses a **conversation summary** plus **N recent messages** to extract better memories, and refreshes the summary asynchronously so extraction stays context-aware without slowing the main loop. ([ar5iv][1])

**What to borrow for HCP**

* Your `.uacf/handoff.md` is already a “rehydration pack.” Add an explicit **rolling summary artifact** (or formalize `handoff.md` as the rolling summary).
* Extraction prompt always includes:

  * `handoff.md` (global summary)
  * last *K* entries of `progress.md` (recency window)
  * the newest session delta (what just happened)

This reduces “memory drift” and prevents a single session from rewriting the world model.

## 3) Partition memory aggressively to prevent “memory leaks”

Mem0 shows how bad it gets when unrelated memories bleed across users/agents/apps, and proposes scoping memory with identifiers like **user_id, agent_id, app_id, run_id** + filter logic at query time. ([Mem0][2])

**What to borrow for HCP**
Represent scoping as *first-class metadata* on every memory object (and on every continuity artifact entry). Concretely:

* **Subject scope** (who/what the memory is about): user / org / project / agent / run
* **Execution scope** (where it was produced): repo / branch / environment / harness
* **Surface** (who may see it): public / internal / agent-facing (your existing tri-surface concept)
* **Purpose**: preference / fact / plan / decision / procedure / evaluation evidence

Then require all “memory retrieval” to specify a scope filter, so “chef agent” doesn’t see “travel agent” hotel prefs unless explicitly allowed. ([Mem0][2])

## 4) Add explicit ingestion controls (don’t store garbage)

Mem0’s cookbooks focus on preventing “memory pollution” via:

* **custom instructions** (“what to store / what to ignore”),
* **confidence thresholds** (only persist high-confidence facts),
* **updates** (revise rather than duplicate),
* and **sensitive/PII filtering rules**. ([Mem0][3])

**What to borrow for HCP**
Create a repo-local policy file like:

* `.uacf/policy/memory_ingestion.yaml`

  * disallowed classes (PII, secrets)
  * required evidence for certain memory types (e.g., “system truth must link to a source artifact / test / decision”)
  * minimum confidence by category (medical/legal/etc. higher)
  * “speculation markers” that default to NOOP unless confirmed

And enforce it as a **compiler lint gate** (fail build or quarantine memories when violated).

## 5) Prevent memory bloat with expiration + retention tiers

Mem0 defaults to “memories persist forever,” but explicitly recommends **expiration_date** for short-term context and separating temporary vs permanent retention to avoid retrieval quality collapse. ([Mem0][4])

**What to borrow for HCP**
Introduce retention semantics in file-based memory objects:

* **Permanent**: durable prefs, stable facts, policies, ADRs
* **Run-scoped / session-scoped**: ephemeral context (expires)
* **Stale-but-auditable**: keep in archive/tombstone, excluded from agent context by default

The compiler can:

* exclude expired memories from “agent context export,”
* keep them in the index for audit/history,
* optionally “promote” frequently-used temporary memories to permanent if repeatedly retrieved/confirmed.

## 6) Tagging / categorization as a retrieval accelerator

Mem0 supports **project-level categories** that get auto-assigned to future memories so retrieval can filter down quickly (e.g., billing vs password reset vs plan changes). ([Mem0][5])

**What to borrow for HCP**

* Add `category` / `tags` fields to memory objects.
* Let the compiler auto-tag via deterministic rules first (folder paths, schema types, known ref types), then optionally an LLM tagger.
* Make “agent-facing export” prefer *category-filtered* packs (e.g., “only decisions + next actions + constraints + open risks”).

## 7) Support both vector retrieval and graph memory where it matters

Mem0’s docs describe default **vector store** behavior, plus **graph memory** that extracts entities + relationships (works_with, member_of, reports_to, etc.) to answer multi-hop questions that vectors alone struggle with. ([Mem0][6])

**What to borrow for HCP**
You already compile a **dependency graph** for content. Extend HCG with a **Memory Graph**:

* store some memories as **triples** (subject–predicate–object) in addition to raw text
* connect memory nodes to canonical content entities via your `ref:<type>:<id>` mechanism
* let retrieval choose:

  * vector similarity for “what’s relevant?”
  * graph traversal for “how are these connected?” (multi-hop)

This fits HCP well because graph edges are naturally **compile-time resolvable**.

## 8) Interoperability: expose memory as a standard tool interface (MCP)

Mem0’s OpenMemory product is basically “portable memory” for MCP-compatible clients, exposing standard ops like `add_memories`, `search_memory`, `list_memories`, `delete_all_memories`, and emphasizing **local-first storage** + a unified UI. ([Mem0][7])

**What to borrow for HCP**
Even if HCP remains “compiler not product,” you can add an **optional adapter layer**:

* **HCP Memory MCP Server (optional)**: exposes the same tool surface, but its backend is your `.uacf/` + compiled index.
* This enables cross-tool continuity (Cursor ↔ Claude Desktop ↔ other harnesses) without forcing a CMS-like runtime.

## How this fits your file-first HCP model (and where a server DB might actually be needed)

### SQLite (HCP’s current model) is great when:

* memory is **repo/workspace scoped**,
* you can accept **compile-time indexing** (or incremental rebuild),
* the primary workload is **read-heavy**: “rehydrate me at session start,” “build context pack.”

That matches your current artifact loop.

### A server DB (Postgres / hosted vector DB) becomes useful when:

* you need **high-frequency writes** without committing to git,
* you need **multi-user concurrency** across many agents/teams,
* you want **cross-repo / cross-workspace** personal memory,
* you want OpenMemory-like **always-on retrieval** without rebuild cycles. ([Mem0][7])

A clean hybrid (very Mem0-ish) is:

* **Canonical / institutional memory** stays file-first in git (HCP source of truth).
* **Runtime personal/session memory** can live in an optional local/server store (MCP), with **promotion** into git-backed artifacts when it becomes durable policy/decision/fact.

## Concrete “borrow list” to implement next in HCP

1. Add a **typed memory object schema** (with scope, surface, retention, confidence, provenance).
2. Implement **extract → reconcile** with **ADD/UPDATE/DELETE/NOOP** semantics. ([ar5iv][1])
3. Add **ingestion policy + confidence gating + PII rules** as compiler lints. ([Mem0][3])
4. Add **expiration_date** + retention tiers to prevent bloat. ([Mem0][4])
5. Add **scope filters** (user/agent/app/run) to stop memory leaks. ([Mem0][2])
6. Add optional **graph-form memory** for multi-hop continuity questions. ([Mem0][6])
7. Optionally expose memory via **MCP tool ops** for cross-harness continuity. ([Mem0][7])

If you want, I can turn this into a **draft HCP Memory spec** (schemas + folder layout + compiler stages + retrieval/export contracts) that plugs directly into your `.uacf/` artifact model.

[1]: https://ar5iv.org/pdf/2504.19413 "[2504.19413] Mem0: Building Production-Ready AI Agents with Scalable Long-Term Memory"
[2]: https://docs.mem0.ai/cookbooks/essentials/entity-partitioning-playbook "Partition Memories by Entity - Mem0"
[3]: https://docs.mem0.ai/cookbooks/essentials/controlling-memory-ingestion "Control Memory Ingestion - Mem0"
[4]: https://docs.mem0.ai/cookbooks/essentials/memory-expiration-short-and-long-term "Set Memory Expiration - Mem0"
[5]: https://docs.mem0.ai/cookbooks/essentials/tagging-and-organizing-memories "Tag and Organize Memories - Mem0"
[6]: https://docs.mem0.ai/cookbooks/essentials/choosing-memory-architecture-vector-vs-graph "Choose Vector vs Graph Memory - Mem0"
[7]: https://docs.mem0.ai/openmemory/overview "Overview - Mem0"
