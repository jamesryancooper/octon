# Query — Hybrid Retrieval & Answering

- **Purpose:** Answer questions by routing across dense/keyword/graph stores, fusing/reranking results, and citing sources per Harmony contracts.
- **Responsibilities:** selecting retrieval strategies, applying filters/windowing, fusing + reranking hits, assembling answer JSON, packaging evidence packs with citations.
- **Integrates with:** Index (stores), Doc/Dev/Stack/UI (callers), Agent (runs), Eval (ground‑truth checks), Cache (snapshots).
- **I/O:** reads `indexes/**` (dense.vec, keyword.json, `links.jsonl`); retrieves at chunk granularity and returns `answer.json` with chunk‑level `citations` (`path:line` or `doc#chunk_id`) and an `evidence/` pack (excerpts).
- **Wins:** Grounded, cited answers; machine‑actionable evidence that downstream services can trust.
- **Harmony alignment:** advances interoperability and grounded outputs via consistent answer/evidence contracts and citations; exposes governance hooks so answers are evaluable by Eval.
- **Implementation Choices (opinionated):**
  - RAGatouille: hybrid retrieval + lightweight rerank (ColBERT‑style) to fuse dense/keyword results for grounded answers.
  - rank-bm25: deterministic BM25 scoring to handle sparse and exact‑match queries.
  - networkx: neighborhood expansion and path scoring over the `links.jsonl` graph.
- **Common Qs:** *Rebuild indexes?* Requests Index to refresh; does not build itself. *Missing sources?* Expands hops on link graph, then re‑ranks.

---

## Minimal Interfaces (copy/paste scaffolds)

### Query (ask)

```json
{
  "query": "Where is FooService instantiated and what's new in v2?",
  "filters": {"lang": ["ts"], "tag": ["system:api"]},
  "strategy": {"use": ["keyword","dense","graph"], "fuse": "rrf", "top_k": 12}
}
```

---

## Chunk‑First Retrieval & Evidence

- Retrieves candidates as chunks (not whole documents) from hybrid stores; fuses and reranks at chunk granularity.
- Evidence packs cite chunk IDs and include minimal excerpts bounded by token limits; callers can expand to full documents if needed.
- Index preserves `chunk_id` in artifacts; Query propagates those into citations and evidence JSON.

## Rerankers & LTR (optional)

- Out‑of‑the‑box rerankers: lightweight ColBERT‑style scoring is built‑in; add an optional cross‑encoder for higher precision on the top‑k.
- LTR (learning‑to‑rank): later, plug models trained from Eval signals (clicks, labels) to refine fused candidates.

Minimal config stub — cross‑encoder reranker

```json
{
  "query": "How do we deprecate FooService?",
  "strategy": { "use": ["dense","keyword","graph"], "fuse": "rrf", "top_k": 50 },
  "rerankers": [
    {
      "type": "cross_encoder",
      "model": "cross-encoder/ms-marco-MiniLM-L-6-v2",
      "apply_to": "fused",
      "top_k": 50,
      "keep_k": 15,
      "batch_size": 32,
      "normalize": true
    }
  ]
}
```

LTR placeholder (concept)

```json
{
  "rerankers": [
    {
      "type": "ltr",
      "model": "file:models/ltr/latest.bin",
      "features": ["bm25","dense","graph_hops","recency_days"],
      "keep_k": 20
    }
  ]
}
```

---

## Advanced Index Families: Query integration

These options let Query leverage new Index modes and artifacts with minimal changes to your existing `strategy` and adapters.

### Hierarchical summary‑tree retrieval (RAPTOR‑style)

- Probes higher‑level summaries for global/thematic recall, then descends to supporting leaf chunks; fuses multi‑level evidence.

Config sketch

```json
{
  "query": "Summarize Foo design decisions with sources",
  "strategy": {
    "route": "hierarchical",
    "hierarchical": { "probe_summaries": true, "descend": { "k_per_parent": 3 } },
    "fuse": "rrf",
    "top_k": 50
  }
}
```

### KG + community summaries (GraphRAG‑style global route)

- Reads community summaries to draft partial answers for global questions, combines with local chunk retrieval for citations.

Config sketch

```json
{
  "query": "What themes explain the Foo→Bar migration?",
  "strategy": {
    "route": "kg_global",
    "kg": { "use": ["community_summaries","entities"], "top_k": 40 },
    "fuse": "weighted",
    "weights": { "kg": 0.6, "keyword": 0.25, "dense": 0.15 }
  }
}
```

### Learned sparse retrieval (SPLADE/uniCOIL)

- Adds a sparse‑neural scorer that fuses with dense via RRF/weighted; improves candidate quality at BM25‑like latency.

Config sketch

```json
{
  "query": "Which ADR defines rollout gates?",
  "strategy": { "use": ["sparse_learned","dense"], "fuse": "rrf", "top_k": 50 }
}
```

### Faster late‑interaction backends (PLAID / SPLATE)

- Swap the ColBERT engine to reduce latency without changing artifacts; SPLATE offers a sparse late‑interaction variant.

Config sketch

```json
{
  "query": "What changed between Foo v1 and v2?",
  "retriever": { "type": "colbert", "engine": "plaid", "k": 200 },
  "strategy": { "use": ["colbert"], "top_k": 50 }
}
```

### Unified dense+sparse ANN (single hybrid index)

- Replaces separate dense/keyword routes with one unified ANN query; keep your reranker as is.

Config sketch (experimental)

```json
{
  "query": "Find design notes on feature flags",
  "strategy": { "use": ["unified"], "top_k": 50, "unified": { "backend": "graph_ann" } }
}
```

### Memory‑augmented pre‑retrieval (MemoRAG‑style)

- A lightweight LLM drafts global “clues” to steer retrieval, then normal fusion/rerank proceeds; cache clues for frequent templates.

Config sketch

```json
{
  "query": "How do we roll out FeatureFlagX?",
  "memory": { "enabled": true, "clue_model": "gpt-4o-mini", "max_clues": 3, "cache": { "ttl_hours": 168 } },
  "strategy": { "use": ["keyword","dense","graph"], "fuse": "rrf", "top_k": 30 }
}
```

Router hint
- Set `router.mode: "auto"` to route long/global questions to `hierarchical`/`kg_global`, otherwise fall back to your flat/hybrid route.

## Pilot Plan & Gates

Objective
- Quantify gains from new routes/engines (hierarchical, kg_global, learned sparse, PLAID/SPLATE, memory, unified ANN) in answer accuracy, citation correctness, recall@k, latency, and cost.

Dataset slice
- Use the same 5–10% snapshot as Index pilots. Split eval into global/long vs local/pointed queries.

A/B routes (besides baseline hybrid)
- `route: hierarchical` vs flat hybrid.
- `route: kg_global` vs flat hybrid on global questions.
- `use: ["sparse_learned","dense"]` vs `use: ["keyword","dense"]`.
- `retriever.type: colbert` with `engine: plaid|splate` vs vanilla ColBERT.
- `memory.enabled: true` vs disabled on ambiguous/underspecified queries.
- `use: ["unified"]` (experimental) vs split dense+keyword routes.

Toggle examples

```json
// Baseline flat hybrid
{ "strategy": { "use": ["keyword","dense","graph"], "fuse": "rrf", "top_k": 30 } }
```

```json
// Hierarchical route
{ "strategy": { "route": "hierarchical", "hierarchical": { "probe_summaries": true }, "fuse": "rrf", "top_k": 50 } }
```

```json
// KG global
{ "strategy": { "route": "kg_global", "kg": { "use": ["community_summaries","entities"], "top_k": 40 }, "fuse": "weighted", "weights": { "kg": 0.6, "keyword": 0.25, "dense": 0.15 } } }
```

```json
// Learned sparse fusion
{ "strategy": { "use": ["sparse_learned","dense"], "fuse": "rrf", "top_k": 50 } }
```

Acceptance gates (suggested)
- Hierarchical: +5–10 pts Recall@20 on long/global queries; +3–5% absolute answer accuracy; ≤10% latency increase.
- KG: +10% absolute answer accuracy on global questions; equal or better citation correctness.
- Learned sparse: ≥ baseline Recall@20/MRR at BM25‑like latency (±10%).
- PLAID/SPLATE: ≤1% MRR delta vs vanilla; −2× to −10× latency.
- Memory: improved evidence recall on ambiguous queries; minimal token cost via caching.
- Unified ANN: no >2% recall/MRR regression; document ops simplification.

Ops & observability
- Log route, knobs, corpus hash, and latency/token usage to Observe. Use Eval to compute Recall@k/MRR/answer accuracy.

## Ephemeral Index Adapters (in‑memory, off‑disk)

Use these when you want small‑to‑mid corpora retrieval without writing persistent index artifacts. Adapters build in RAM at runtime and are discarded when the process exits. Index remains the source of truth for reproducible, on‑disk snapshots; Query's adapters are runtime conveniences.

- Size guidance (practical on a MacBook M3)
  - Small: ≤100k vectors (384–512D) or ≤10k docs / ≤100k chunks
  - Mid: 100k–2M vectors or 10k–200k docs / 100k–2M chunks
  - Rule of thumb: 384D float32 ≈ 1.5 KB/vector; 512D ≈ 2.0 KB/vector; plan RAM for indexes + caches.

- Recommended backends (open‑source, self‑hosted)
  - Dense vectors: FAISS (Flat or IVF) in RAM; hnswlib for HNSW in RAM; Annoy for quick prototypes.
  - Keyword/sparse: SQLite FTS5 in `:memory:`; Tantivy (Rust) with memory directory for higher throughput.
  - Graph: networkx adjacency built from `links.jsonl` or quick source scans.

### Config shape

Add an `adapters` block to your Query request alongside `strategy`.

```json
{
  "query": "How do feature flags roll out?",
  "strategy": {"use": ["dense","keyword","graph"], "fuse": "rrf", "top_k": 12},
  "adapters": {
    "dense": { "backend": "faiss", "index": "flat", "persist": false },
    "keyword": { "backend": "sqlite_fts5", "persist": false },
    "graph": { "backend": "networkx", "source": "indexes/<snapshot>/links.jsonl" }
  }
}
```

Notes

- If `source` points to Index artifacts, adapters warm from disk but do not write new artifacts.
- If you omit `source`, adapters can scan normalized inputs or raw files (slower, but zero setup).
- Query should log corpus hash + adapter params to Observe for reproducibility.

### ANN Runtime Knobs

- FAISS IVF: `nprobe` controls recall/latency at query time.
- HNSW (hnswlib): `efSearch` controls recall/latency at query time.
- Expose via `adapters.dense` or `strategy`: Query passes through to the backend without mutating persisted indexes.

Example

```json
{
  "strategy": { "use": ["dense","keyword"], "top_k": 30 },
  "adapters": {
    "dense": { "backend": "faiss", "index": "ivf", "nprobe": 32 },
    "keyword": { "backend": "sqlite_fts5" }
  }
}
```

### Dense adapter options

- FAISS (Flat)
  - Config: `{ "backend": "faiss", "index": "flat", "metric": "l2|ip" }`
  - Best for small corpora; simple and fast to build; memory ~ vectors × dim × 4B.

- FAISS (IVF)
  - Config: `{ "backend": "faiss", "index": "ivf", "nlist": 4096, "nprobe": 16 }`
  - Good for mid corpora when Flat is too slow; slight recall tradeoff, tunable with `nprobe`.

- hnswlib (HNSW)
  - Config: `{ "backend": "hnswlib", "M": 32, "efConstruction": 200, "efSearch": 64 }`
  - Excellent recall/latency for 100k–2M vectors; memory efficient; actively maintained.

### Keyword adapter options

- SQLite FTS5 in memory
  - Config: `{ "backend": "sqlite_fts5", "pragma": {"cache_size": -16000} }`
  - Creates `:memory:` DB, tokenizes and indexes text; BM25‑like scoring; zero disk I/O.

- Tantivy (Rust)
  - Config: `{ "backend": "tantivy", "directory": "memory", "langs": ["en"] }`
  - Lucene‑like performance in memory; requires Rust/FFI integration.

### Graph adapter options

- networkx adjacency
  - Config: `{ "backend": "networkx", "source": "links.jsonl", "max_hops": 2 }`
  - Loads edges to RAM and supports bounded BFS expansion for candidate generation.

### Example: small corpus, fully in‑memory

```json
{
  "query": "Which ADR defines our rollout gates?",
  "strategy": {"use": ["keyword","graph"], "fuse": "weighted", "weights": {"keyword": 0.8, "graph": 0.2}, "top_k": 10},
  "adapters": {
    "keyword": { "backend": "sqlite_fts5" },
    "graph": { "backend": "networkx", "source": "indexes/latest/links.jsonl", "max_hops": 2 }
  }
}
```

### Example: mid corpus, dense + keyword in RAM

```json
{
  "query": "Where is FeatureFlagX evaluated and who calls it?",
  "strategy": {"use": ["dense","keyword","graph"], "fuse": "rrf", "top_k": 25},
  "adapters": {
    "dense": { "backend": "hnswlib", "M": 32, "efConstruction": 200, "efSearch": 64 },
    "keyword": { "backend": "sqlite_fts5" },
    "graph": { "backend": "networkx", "source": "indexes/abc123/links.jsonl", "max_hops": 2 }
  }
}
```

### Platform notes (macOS M3)

- Install PyTorch with Metal (MPS) to accelerate embedding; FAISS CPU works well, hnswlib uses CPU.
- SQLite is native; FTS5 is built‑in. Tantivy requires Rust; prefer SQLite for simplicity.
- Keep an eye on RAM headroom; for 512D with 1M vectors, expect ~2 GB for raw vectors (plus overhead).

### When to prefer Index instead

- Compliance/audit needs, CI preview builds, reproducible evals, or when you need persistent artifacts for sharing and rollbacks.
- Very large corpora where you benefit from ANN structures saved to disk and loaded memory‑mapped.

---

## Database Adapters (serving backends)

Query can retrieve from databases instead of (or alongside) on‑disk artifacts. This fits a "publish → serve" pattern where Index remains the source of truth and a DB provides filters/joins and shared access. For small→mid corpora, a unified PostgreSQL stack keeps ops simple and fast.

Recommended combo

- PostgreSQL + pgvector for dense vectors
- PostgreSQL FTS (`tsvector` + GIN) and `pg_trgm` for keyword/trigram search
- A simple `doc_edges` table for graph expansion
- Optional: ParadeDB to enhance BM25/semantic search within PostgreSQL

Adapter config shape

```json
{
  "query": "How do we roll out FeatureFlagX?",
  "strategy": {"use": ["dense","keyword","graph"], "fuse": "rrf", "top_k": 20},
  "adapters": {
    "dense":   { "backend": "pgvector",     "dsn": "env:PG_DSN", "table": "doc_vectors", "dim": 384, "metric": "l2" },
    "keyword": { "backend": "postgres_fts",  "dsn": "env:PG_DSN", "table": "docs", "lang": "english" },
    "graph":   { "backend": "postgres_edges","dsn": "env:PG_DSN", "table": "doc_edges", "max_hops": 2 }
  }
}
```

Usage notes

- DSN: read from environment (e.g., `PG_DSN=postgres://user:pass@localhost:5432/knowledge`). Do not hardcode.
- Mixed sources: you can use DB for `dense`, and local `keyword.json` / `links.jsonl` for others; Query fuses scores regardless of source.
- Citations: store `uri` and metadata in `docs` so Query can cite `path:line` after retrieving content for evidence packs.

PostgreSQL schemas (see Index "Publishing to Databases" for full DDL)

- docs: `id TEXT PRIMARY KEY, uri TEXT, meta JSONB, text TEXT, ts tsvector GENERATED ...`
- doc_vectors: `id TEXT PRIMARY KEY, doc_id TEXT REFERENCES docs(id), embedding vector(384)` + HNSW/IVF index as needed
- doc_edges: `(src TEXT, dst TEXT, rel TEXT, weight DOUBLE PRECISION, PRIMARY KEY (src,dst,rel))`

Examples

```json
// Dense via pgvector; keyword via local keyword.json; graph via postgres edges
{
  "query": "Where is rollout policy defined and referenced?",
  "strategy": {"use": ["dense","keyword","graph"], "fuse": "weighted", "weights": {"dense": 0.5, "keyword": 0.35, "graph": 0.15}},
  "adapters": {
    "dense":   { "backend": "pgvector", "dsn": "env:PG_DSN", "table": "doc_vectors", "dim": 384 },
    "keyword": { "backend": "local_keyword", "path": "indexes/latest/keyword.json" },
    "graph":   { "backend": "postgres_edges", "dsn": "env:PG_DSN", "table": "doc_edges", "max_hops": 2 }
  }
}
```

```json
// Fully in Postgres (add ParadeDB if you prefer its search interface)
{
  "query": "Summarize our deployment SLOs with sources",
  "strategy": {"use": ["keyword","dense"], "fuse": "rrf", "top_k": 15},
  "adapters": {
    "dense":   { "backend": "pgvector",    "dsn": "env:PG_DSN", "table": "doc_vectors", "metric": "l2" },
    "keyword": { "backend": "postgres_fts","dsn": "env:PG_DSN", "table": "docs", "lang": "english" }
  }
}
```

Performance & tuning

- pgvector: choose HNSW for low‑latency reads, or IVF for balance; set `dim` to your embedding dimension.
- FTS: ensure `tsvector` GIN index; add `pg_trgm` GIN indexes for fuzzy matching if needed.
- Graph: ensure indexes on `doc_edges(src)` and `doc_edges(dst)`; bound BFS via `max_hops`.

Security & ops

- Keep DSNs in secrets (Vault) and prefer least‑privilege DB roles.
- Log adapter parameters and corpus IDs to Observe for reproducibility.

### ParadeDB adapter (optional)

ParadeDB enhances PostgreSQL with search capabilities (e.g., BM25/semantic modules). You can point Query's keyword adapter to a ParadeDB‑backed search index if you prefer its interface and ranking.

Adapter example

```json
{
  "query": "Find ADRs about rollout gates",
  "strategy": {"use": ["keyword","dense"], "fuse": "rrf", "top_k": 15},
  "adapters": {
    "dense":   { "backend": "pgvector", "dsn": "env:PG_DSN", "table": "doc_vectors", "dim": 384 },
    "keyword": { "backend": "paradedb_search", "dsn": "env:PG_DSN", "index": "docs_search", "lang": "english" }
  }
}
```

Notes

- ParadeDB setup and index creation vary by version; consult ParadeDB’s documentation for the exact index DDL and query API.
- You can mix ParadeDB for keyword and pgvector for dense; Query fuses scores as usual.

---

## Recency & Freshness (query‑time)

- Never mutates indexes; applies optional recency filters/boosts over metadata (e.g., `ts`, `observed_ts`).
- Useful for living docs and release notes where recent changes matter.

Minimal config

```json
{
  "filters": { "min_ts": 1710000000 },
  "recency": { "boost": { "half_life_days": 30, "field": "ts" } }
}
```

## Multilingual Strategy Defaults

- If Ingest labeled chunks with `lang`, Query can adjust fusion weights per locale and prefer multilingual embeddings.
- Example: increase sparse weight for morphologically rich languages; rely more on dense for English.

Config sketch

```json
{
  "strategy": {
    "use": ["dense","keyword"],
    "fuse": "weighted",
    "weights": {
      "default": { "dense": 0.6, "keyword": 0.4 },
      "per_locale": {
        "en": { "dense": 0.65, "keyword": 0.35 },
        "de": { "dense": 0.5,  "keyword": 0.5  },
        "ja": { "dense": 0.7,  "keyword": 0.3  }
      }
    }
  }
}
```
