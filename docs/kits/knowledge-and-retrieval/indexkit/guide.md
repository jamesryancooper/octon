# IndexKit — Indexing For Retrieval

IndexKit creates deterministic indexes—both on-disk and in databases—that power Harmony's document-centric and hybrid retrieval flows. It leans on strict, mode-specific contracts so downstream kits can trust artifact shape, metadata, and behavior.

## Quick Snapshot

- **Modes:** `document` (document‑centric) • `hybrid` (dense + keyword + link graph) • `hierarchical` (summary‑tree, RAPTOR‑style) • `kg` (entity KG + community summaries) • `colbert` (late‑interaction) • `code` (AST/symbol/xref/callgraph) • `structured` (tables/KB)
- **Hybrid signals:** `dense`, `keyword`, `graph`, `vision`, `entities`, `sparse_learned` (select any subset via `signals: [...]`)
- **Also‑emit option:** Hybrid can optionally also emit the `document` artifact to avoid double builds
- **Artifacts:** Reproducible JSON/JSONL indexes, FAISS stores, BM25 weights, link manifests
- **Optional publish:** Upsert artifacts to serving DBs (e.g., PostgreSQL + pgvector + FTS/trigrams + edges) for query‑time filters/joins
- **Inputs:** Normalized chunks from IngestKit with stable IDs and metadata
- **Outputs:** Audit-ready index directories designed for QueryKit, PlanKit/AgentKit, and Harmony CI flows

## Core Responsibilities

- Ingest normalized document chunks from internal and external sources
- Parse, preserve, and unify metadata (including stable IDs and provenance)
- Extract and preprocess text for sparse, dense, and structural signals
- Compute global statistics (BM25, TF/IDF) and embeddings
- Build and update document-centric, hybrid, and link-oriented indexes
- Maintain compatibility with open RAG/ColBERT schemas
- Emit reproducible, inspectable, space-efficient artifacts
- Support previews, metadata lookup, and incremental updates

## Ecosystem Integrations

- **QueryKit:** consumes IndexKit stores for retrieval
- **PlanKit / AgentKit:** orchestrate index build pipelines
- **IngestKit:** supplies normalized Markdown and non-Markdown content
- **DatasetKit:** provides corpora definitions
- **DiagramKit:** renders hybrid link-graph views

## Operating Modes

### `document` — Document-Centric Retrieval

- **What it does**
  - Merge normalized chunks per document
  - Compute global term statistics and per-document sparse weights
  - Preserve stable IDs and metadata
  - Emit RAGatouille-compatible JSON indexes with short previews
- **I/O**
  - Reads `ingest/**` normalized records (with doc IDs and metadata)
  - Writes `.index/index.json` containing global stats, per-doc sparse vectors, metadata, and previews; when `snapshot: true`, also writes `.index/snapshot/manifest.json`
- **Wins**
  - Tiny, CPU-only artifact suitable for small-footprint deployments
  - Enables document-level retrieval with stable IDs
  - Acts as a drop-in upgrade path to late-interaction embeddings
- **Opinionated implementation choices**
  - RAGatouille-compatible schema (ColBERT-aligned contracts)
  - `numpy` / `scipy` for sparse weights
  - JSON/JSONL artifacts for portability
  - `python-frontmatter` for YAML ID parsing
  - `markdown-it-py` for consistent Markdown-to-text extraction

### `hybrid` — Dense + Keyword + Link-Graph Retrieval

- **What it does**
  - Compute sentence embeddings
  - Run BM25 scoring
  - Construct link graphs from references and paths
  - Capture immutable snapshots
  - Support incremental shard rebuilds and health checks
- **Signals**
  - Enable any combination of `dense`, `keyword`, `graph`, `vision`, `entities`, and `sparse_learned` via `signals: [ ... ]`.
  - Graph‑only builds (e.g., `signals: ["graph"]`) are supported for lightweight, structure‑first workflows.
- **Also emit document (optional)**
  - Set `also_emit: { document: true }` to additionally write the document‑centric `document` artifact
    (`.index/index.json`) during the same hybrid build. This avoids running two separate builds
    when both artifacts are desired.
- **I/O**
  - Reads `ingest/**` normalized records
  - Writes `indexes/**` artifacts such as `dense.faiss`, `keyword.json`, `links.jsonl`, and `snapshot/manifest.json`
  - When `also_emit.document: true`, additionally writes `.index/index.json` (and `.index/snapshot/manifest.json` when snapshots are enabled)
- **Wins**
  - High-recall retrieval across dense, sparse, and structural signals
  - Reproducible, inspectable artifacts with incremental updates
- **Opinionated implementation choices**
  - FAISS for dense vector search
  - `sentence-transformers` for embeddings
  - `rank-bm25` for keyword/BM25 scoring
  - `networkx` for link-graph construction and traversal
- **Chunk‑first contract**
  - Preserve stable `chunk_id` from IngestKit in all hybrid artifacts to support chunk‑granularity retrieval and citations in QueryKit.
  - Document‑level metadata is retained separately for rollups, but primary retrieval units are chunks.

### `hierarchical` — Summary‑Tree Retrieval (RAPTOR‑style)

- **What it does**
  - Indexes both leaf chunks and multi‑level summary nodes built bottom‑up (cluster → summarize → re‑embed).
  - Persists explicit parent/child edges to enable top‑down probing then descent to supporting leaves at query time.
- **I/O**
  - Reads `ingest/**` chunks plus `ingest/tree_edges.jsonl` and `ingest/summaries.jsonl` when provided by IngestKit.
  - Writes `hierarchical/**`: `tree_edges.jsonl`, `summaries.jsonl`, optional `summary_vectors.faiss`, and `snapshot/manifest.json`.
- **Wins**
  - Substantial gains on long‑context/global questions by retrieving from summaries and leaves together.
- **Opinionated implementation choices**
  - K‑means/HDBSCAN for clustering; `sentence-transformers` for summary embeddings; JSONL artifacts for transparency.

### `kg` — Knowledge Graph + Community Summaries

- **What it does**
  - Indexes an entity/relationship KG and precomputed community summaries as retrievable nodes for global/insight queries.
- **I/O**
  - Reads `ingest/entities.jsonl`, `ingest/kg_edges.jsonl`, `ingest/communities.jsonl`, `ingest/community_summaries.jsonl`.
  - Writes `kg/**`: `entities.jsonl`, `edges.jsonl`, `communities.jsonl`, `community_summaries.jsonl`, `snapshot/manifest.json`.
- **Wins**
  - Targets “global sensemaking” questions; complements local chunk retrieval with graph‑level evidence.
- **Opinionated implementation choices**
  - Simple JSONL schemas for entities/edges; community detection metadata persisted for debuggability.

### `colbert` — Late‑Interaction (MaxSim) Retrieval

- **What it does**
  - Builds token‑level embeddings and late‑interaction (MaxSim) indexes compatible with ColBERT/RAGatouille.
  - Preserves mappings between documents, chunks, and token vectors; supports shard layouts.
- **I/O**
  - Reads `ingest/**` normalized chunks.
  - Writes `colbert/**` artifacts (RAGatouille/ColBERT layout) with model/tokenizer metadata and shard manifests.
- **Wins**
  - Higher‑fidelity matching for nuanced queries; strong rerank without heavyweight cross‑encoders.
- **Opinionated implementation choices**
  - RAGatouille/ColBERTv2 layout; tokenizer metadata captured for reproducibility; CPU/MPS acceptable for small corpora.
- **Engines**
  - `engine`: `"vanilla" | "plaid" | "splate"` — PLAID keeps ColBERT quality with lower latency via centroid interaction/pruning; SPLATE provides a sparse late‑interaction variant (may require an ingest‑time adapter).

### `code` — Language‑Aware Code Indexing

- **What it does**
  - Parses code with language‑aware engines to extract symbols, definitions, references, and call graphs.
  - Emits artifacts for code search and impact analysis (symbols/xrefs/callgraph), plus optional per‑file previews.
- **I/O**
  - Reads normalized code records from IngestKit or scans a repo directly (language filters).
  - Writes `code/**`: `symbols.jsonl`, `xref.jsonl`, `callgraph.jsonl`, and `files.jsonl` (optional previews).
- **Wins**
  - Precise, navigable code retrieval and evidence for refactors/migrations; grounds DevKit/CodeModKit plans.
- **Opinionated implementation choices**
  - Tree‑sitter where possible; deterministic JSONL artifacts; simple schema per language with shared core fields.

### `structured` — Tables / Knowledge Base

- **What it does**
  - Indexes structured data (tables/CSVs/SQLite) with schema graphs and optional column embeddings; provides FTS.
- **I/O**
  - Reads tabular sources from IngestKit (CSV/Parquet/SQL dumps).
  - Writes `structured/**`: `tables.jsonl`, `schema.graph.json`, `fts.sqlite` (FTS5), optional `columns.faiss`.
- **Wins**
  - High‑signal retrieval for facts/metrics; joins and key/foreign‑key awareness; complements text search.
- **Opinionated implementation choices**
  - SQLite/FTS5 for local search; DuckDB acceptable; column embeddings optional; provenance preserved per row/table.

## Hybrid Signals

IndexKit’s hybrid mode builds one or more retrieval signals and fuses them in QueryKit. Enable signals with
`signals: ["dense", "keyword", "graph", "vision", "entities", "sparse_learned"]` and tune fusion via `fuse`.

Serving note: If you publish to a database (e.g., PostgreSQL + pgvector + FTS/trigrams + edges), QueryKit can retrieve
directly from the DB instead of local artifacts. See [QueryKit](../querykit/guide.md) (Database Adapters).

- Dense
  - Purpose: semantic search over embeddings.
  - Artifacts: `dense.faiss`, `dense.meta.json` (`model`, `dim`, `index_type`).
  - Config: `embedding_model`, `faiss.index_type|nlist|nprobe`.
  - Validation: vector/doc cardinality match, dim matches `dense.meta.json`.

- Keyword
  - Purpose: exact‑match and sparse scoring via BM25.
  - Artifacts: `keyword.json` (`idf`, `doc_len`, `avg_doc_len`, `stopwords`).
  - Config: `keyword.k1`, `keyword.b`, `keyword.stopwords`.
  - Validation: stat drift checks (avg doc len, idf coverage), stopword handling.

- Graph
  - Purpose: structure‑aware expansion and reranking via link relationships between documents.
  - Artifacts: `links.jsonl` with one edge per line: `{ src, dst, weight, edge, anchor }`.
  - Inputs: references extracted from normalized content (frontmatter links, Markdown links, directory adjacency);
    paths are normalized to stable IDs.
  - Config: `graph.max_hops` (neighborhood expansion bound), `graph.weight` map for edge classes
    (e.g., `{ internal: 1.0, external: 0.5 }`).
  - Validation: broken/missing targets, self‑loops, duplicate edges (collapsed with weight sum), path normalization.
  - Retrieval: QueryKit expands neighborhoods up to `max_hops`, then fuses candidates with dense/keyword according
    to `fuse` (e.g., `rrf` or weighted).

- Vision
  - Purpose: multimodal retrieval over images/pages/figures to augment text evidence.
  - Artifacts: `vision.faiss` (image/page embeddings), `page_map.jsonl` (doc→pages→bboxes), optional `ocr.jsonl`.
  - Inputs: images, PDFs, or page snapshots normalized via IngestKit (includes document URI linkage).
  - Config: `vision.embedding_model` (e.g., `clip-base`), `vision.page_limit`, `vision.ocr: { engine: "tesseract", lang: ["en"] }`.
  - Validation: vector/page count parity, bbox coordinate sanity, OCR language/encoding checks.
  - Retrieval: fuse visual hits with text signals; optionally constrain to pages cited in `page_map.jsonl`.

- Entities
  - Purpose: lightweight entity and relation extraction to improve recall/precision for names, IDs, and typed facts.
  - Artifacts: `entities.jsonl` (per‑doc entities with spans/types), `triples.jsonl` (subject‑predicate‑object with provenance).
  - Inputs: text from IngestKit; optional dictionaries for ID resolution.
  - Config: `entities.model` (spaCy/transformer), `entities.types` allowlist, `entities.linkers` for ID mapping.
  - Validation: span bounds, type coverage, linker precision thresholds; provenance fields required.
  - Retrieval: boost or filter candidates by entity/type; fuse as an additional score component.

## Why Teams Choose IndexKit

- **Unified API:** One interface covers document-centric, dense, keyword, and graph-based retrieval.
- **Stable, Portable Artifacts:** Indexes are well-specified, auditable, and easy to version or transfer.
- **Reproducible Builds:** Deterministic pipelines guarantee repeatable outputs for identical inputs.
- **Auditability & Transparency:** Rich metadata, per-document stats, and manifest snapshots support inspection and troubleshooting.
- **Interoperability:** Strict contracts simplify integration with external tools and downstream replacements.
- **Incremental Indexing:** Update, extend, or repair indexes without full rebuilds.
- **Open RAG Alignment:** Designed around ColBERT/RAGatouille compatibility and open reference tooling.
- **Extensibility:** Modular architecture welcomes new signals such as graphs, entities, or custom embeddings.

## Harmony Alignment

IndexKit reinforces the Harmony methodology, as detailed in [harmony-lean-ai-accelerated-methodology.md](../../harmony/methodology/README.md):

- **Spec-first, Contract-driven:** Schemas and artifact formats emphasize contract fidelity and drift detection.
- **Auditability & Transparency:** Versionable artifacts and manifests meet Harmony's SRE, compliance, and ASVS guardrails.
- **Modular, Flow-first CI/CD:** Deterministic builds enable tiny PRs, previews, and fast rollbacks in trunk-based flows.
- **Security & Reliability:** SBOM-ready artifacts, license scanning, and secret-free code align with Harmony's security posture (NIST SSDF, ASVS).
- **Open RAG & Hexagonal Boundaries:** Compatibility with ColBERT/RAGatouille keeps boundaries clear for plug-in or downstream substitution.
- **Observability Ready:** Per-index and per-document metadata slot into Harmony observability and error budget workflows.

**TL;DR:** IndexKit is a “drop-in” Harmony knowledge indexer that keeps RAG pipelines fast, safe, and auditable.

## Common Questions

- **Which mode should I start with?** Use `document` for small, fast, document-level retrieval; choose `hybrid` when you need higher recall, multi-signal search, or graph-aware traversal.
- **How do we switch to true ColBERT embeddings?** Swap in RAGatouille embeddings—the schema already matches.
- **Can it handle non-Markdown inputs?** Yes. Delegate normalization to IngestKit; IndexKit indexes the normalized output.
- **How are stable IDs enforced?** Prefer an `id` field in frontmatter; fall back to `path + content hash` for deterministic IDs.
- **How does document-centric RAG work here?** `document` mode emits a per-document store that QueryKit ranks and hands off to an LLM.

## Minimal Interfaces

- **IndexKit**
  - `build_document()`
  - `build_hybrid()`
  - `build_hierarchical()`
  - `build_kg()`
- **QueryKit**
  - `query()`

```json
{
  "mode": "document",
  "source": "ingest/",
  "output": { "file": ".index/index.json" },
  "snapshot": true
}
```

```json
{
  "mode": "hybrid",
  "source": "ingest/",
  "signals": ["dense", "keyword", "graph", "sparse_learned"],
  "output": { "dir": "indexes/" },
  "also_emit": { "document": true },
  "snapshot": true
}
```

```json
{
  "mode": "colbert",
  "source": "ingest/",
  "colbert": { "model": "colbertv2", "shards": 1, "engine": "plaid" },
  "output": { "dir": "colbert/" },
  "snapshot": true
}
```

```json
{
  "mode": "hierarchical",
  "source": "ingest/",
  "hierarchical": { "use": ["leaf","summary"], "fuse": "rrf", "top_k": 50 },
  "output": { "dir": "hierarchical/" },
  "snapshot": true
}
```

```json
{
  "mode": "kg",
  "source": "ingest/",
  "kg": { "use": ["community_summaries","entities"], "top_k": 50 },
  "output": { "dir": "kg/" },
  "snapshot": true
}
```

```json
{
  "mode": "code",
  "source": "ingest/",
  "languages": ["ts","js","py"],
  "output": { "dir": "code/" },
  "snapshot": true
}
```

```json
{
  "mode": "structured",
  "source": "ingest/",
  "structured": { "fts": true, "column_embeddings": false },
  "output": { "dir": "structured/" },
  "snapshot": true
}
```

## Contracts & Schemas

- **Input contract (from IngestKit)**
  - Required: `uri` (path or URL), `source` (namespace), `ts` (build timestamp), `hash` (content hash), `tokens` (int), `text` (string)
  - Recommended: `id` (stable string). If absent, IndexKit derives a deterministic ID (e.g., `uri + content hash`). IngestKit typically sets `id` from frontmatter when present. See [IngestKit](../ingestkit/guide.md).
  - Optional: `labels` (map or array), `lang` (BCP‑47), `parent_id` (for hierarchies)
- **Document output (`.index/index.json`)**
  - Top‑level: `schema_version` (semver), `mode` ("document"), `build` (`ts`,`source_hash`), `stats` (`doc_count`,`avg_doc_len`)
  - `docs[]`: `{ id, uri, meta, preview, sparse }` where `sparse = { terms: string[], weights: number[] }`
  - Example:

    ```json
    {
      "schema_version": "1.0.0",
      "mode": "document",
      "build": { "ts": 1720000000, "source_hash": "sha256:..." },
      "stats": { "doc_count": 123, "avg_doc_len": 218.4 },
      "docs": [
        {
          "id": "doc:abc123",
          "uri": "harmony/intro.md",
          "meta": { "title": "Intro" },
          "preview": "Short excerpt…",
          "sparse": { "terms": ["harmony","index"], "weights": [1.42, 0.67] }
        }
      ]
    }
    ```

- **Hybrid outputs (`indexes/**`)**
  - `dense.faiss` (FAISS index), `dense.meta.json` (`model`,`dim`,`index_type`)
  - `keyword.json` (`idf`, `doc_len`, `avg_doc_len`, `stopwords`)
  - `links.jsonl` (per line: `{ src, dst, weight, edge, anchor }`)
  - `snapshot/manifest.json` (`id`, `ts`, `artifacts[]` with checksums)
  - If `also_emit.document: true`, `.index/index.json` is co‑emitted using the document schema below.
  - Optional (per enabled signal): `vision.faiss`, `page_map.jsonl`, optional `ocr.jsonl`; `entities.jsonl`, `triples.jsonl`; `sparse_impacts.jsonl` and/or `sparse_postings/` when `sparse_learned` is enabled.

- **Hierarchical outputs (`hierarchical/**`)**
  - `tree_edges.jsonl`, `summaries.jsonl`, optional `summary_vectors.faiss`, `snapshot/manifest.json`.

- **KG outputs (`kg/**`)**
  - `entities.jsonl`, `edges.jsonl`, `communities.jsonl`, `community_summaries.jsonl`, `snapshot/manifest.json`.

- **ColBERT outputs (`colbert/**`)**
  - ColBERT shard/index layout (RAGatouille compatible), `meta.json` (`model`,`tokenizer`,`dim`), shard manifests

- **Code outputs (`code/**`)**
  - `symbols.jsonl` (symbol table entries), `xref.jsonl` (definition ↔ reference), `callgraph.jsonl` (directed edges), optional `files.jsonl` (previews)

- **Structured outputs (`structured/**`)**
  - `tables.jsonl` (table rows/summary), `schema.graph.json` (entities/relations), `fts.sqlite` (FTS5 index), optional `columns.faiss`
- **Versioning**
  - Include `schema_version`; bump major on breaking changes; maintain down‑conversion notes when feasible.

## Artifacts & Layout

```plaintext
# document
.index/
  index.json
  snapshot/
    manifest.json
```

```plaintext
# hybrid (per snapshot)
indexes/<snapshot-id>/
  dense.faiss
  dense.meta.json
  keyword.json
  links.jsonl
  vision.faiss            # when vision signal is enabled
  page_map.jsonl          # when vision signal is enabled
  ocr.jsonl               # when OCR is enabled
  entities.jsonl          # when entities signal is enabled
  triples.jsonl           # when entities signal is enabled
  snapshot/
    manifest.json
```

If `also_emit.document: true` is set during a hybrid build, the document artifact is also written:

```plaintext
.index/
  index.json
  snapshot/
    manifest.json
```

- Typical sizes depend on corpus/model; document stays small (JSON tens of MB for ~10k docs). Hybrid grows with embedding dim and doc count.

## Publishing to Databases (Optional)

IndexKit is the source of truth for reproducible, on‑disk snapshots. When you need serving features (filters/joins, shared access), add a publish step that upserts artifacts into a database. For small→mid corpora, a unified PostgreSQL stack works well:

- Vectors: pgvector extension (HNSW/IVFFlat or L2/IP distance on a `vector` column)
- Keyword: PostgreSQL FTS (`tsvector`) + GIN, plus `pg_trgm` for trigram fuzzy matching
- Graph: simple `edges` table with indexes on `src` and `dst`
- Optional: ParadeDB for richer search capabilities built on PostgreSQL (BM25/semantic modules); see ParadeDB docs for setup

Example publish config (conceptual)

```json
{
  "mode": "hybrid",
  "source": "ingest/",
  "signals": ["dense","keyword","graph"],
  "output": { "dir": "indexes/" },
  "publish": {
    "postgres": {
      "dsn": "postgres://user:pass@localhost:5432/knowledge",
      "tables": {
        "docs": "docs",
        "vectors": "doc_vectors",
        "fts": "docs",
        "edges": "doc_edges"
      },
      "upsert": true
    }
  }
}
```

Minimal schema (DDL)

```sql
-- extensions
CREATE EXTENSION IF NOT EXISTS vector;       -- pgvector
CREATE EXTENSION IF NOT EXISTS pg_trgm;      -- trigram search

-- documents (metadata + FTS)
CREATE TABLE IF NOT EXISTS docs (
  id TEXT PRIMARY KEY,
  uri TEXT NOT NULL,
  meta JSONB,
  text TEXT,
  ts tsvector GENERATED ALWAYS AS (to_tsvector('english', coalesce(text,''))) STORED
);
CREATE INDEX IF NOT EXISTS idx_docs_ts ON docs USING GIN (ts);
CREATE INDEX IF NOT EXISTS idx_docs_uri ON docs(uri);

-- vectors (one per doc or per chunk)
CREATE TABLE IF NOT EXISTS doc_vectors (
  id TEXT PRIMARY KEY,
  doc_id TEXT NOT NULL REFERENCES docs(id) ON DELETE CASCADE,
  embedding vector(384)
);
-- add HNSW/IVF indexes if desired (pgvector 0.5+)
-- CREATE INDEX IF NOT EXISTS idx_doc_vectors_hnsw ON doc_vectors USING hnsw (embedding vector_l2_ops);

-- graph edges
CREATE TABLE IF NOT EXISTS doc_edges (
  src TEXT NOT NULL REFERENCES docs(id) ON DELETE CASCADE,
  dst TEXT NOT NULL REFERENCES docs(id) ON DELETE CASCADE,
  rel TEXT DEFAULT 'links',
  weight DOUBLE PRECISION DEFAULT 1.0,
  PRIMARY KEY (src, dst, rel)
);
CREATE INDEX IF NOT EXISTS idx_edges_src ON doc_edges(src);
CREATE INDEX IF NOT EXISTS idx_edges_dst ON doc_edges(dst);
```

Notes

- ParadeDB: If you adopt ParadeDB, use its search extensions to index `docs.text` and run BM25/semantic queries within PostgreSQL. Keep IndexKit snapshots as your audit baseline.
- Upserts: include `ON CONFLICT ... DO UPDATE` in your publish scripts to keep DBs in sync with snapshots.
- Provenance: store `uri` and relevant metadata in `docs.meta` for grounding and citations.
- Security: keep DSNs in secrets (VaultKit); avoid committing credentials.

### How to run (example)

- Prereqs: install `psycopg2` (or `psycopg2-binary`) in your environment; create the tables/extensions shown above.
- Run the publish script to upsert docs (from `.index/index.json`) and edges (from `links.jsonl`) into PostgreSQL.

```bash
# Set DSN via env and publish the latest snapshot
export PG_DSN="postgres://user:pass@localhost:5432/knowledge"
python scripts/publish_postgres.py \
  --snapshot indexes/latest \
  --docs-json .index/index.json \
  --tables docs=docs vectors=doc_vectors edges=doc_edges
```

- Vectors: upsert after your embedding job (per doc or chunk) using the same `doc_vectors` table.
- ParadeDB: if using ParadeDB for search, publish docs as above, then build ParadeDB indexes per its documentation.

### Verify (psql)

Run a few quick checks to confirm data landed and indexes work.

```bash
# Ensure required extensions are installed
psql "$PG_DSN" -c "SELECT extname FROM pg_extension WHERE extname IN ('vector','pg_trgm');"

# Counts
psql "$PG_DSN" -c "SELECT COUNT(*) AS doc_count FROM docs;"
psql "$PG_DSN" -c "SELECT COUNT(*) AS edge_count FROM doc_edges;"

# Sample rows
psql "$PG_DSN" -c "SELECT id, uri FROM docs ORDER BY id LIMIT 5;"
psql "$PG_DSN" -c "SELECT src, dst, rel, weight FROM doc_edges ORDER BY src LIMIT 10;"

# Smoke‑test FTS (adjust query terms as needed)
psql "$PG_DSN" -c "SELECT id, ts_rank_cd(ts, plainto_tsquery('english','feature flag')) AS rank FROM docs WHERE ts @@ plainto_tsquery('english','feature flag') ORDER BY rank DESC LIMIT 5;"

# Optional: test vector search if embeddings are loaded (replace [...] with a real vector literal)
# For L2 distance:
# psql "$PG_DSN" -c "SELECT d.id, v.embedding <-> ARRAY[0.01,0.02, ... ]::vector AS l2 FROM doc_vectors v JOIN docs d ON d.id=v.doc_id ORDER BY l2 ASC LIMIT 5;"
```

## Configuration & Tuning

- **Shared**: `mode`, `source`, `output`, `snapshot`, `min_tokens` (default 15), `preview_tokens` (default 80)
- **Document**
  - `bm25`: `{ k1: 1.2, b: 0.75 }` (defaults shown)
  - `stopwords`: language code or explicit list
  - `idf_smoothing`: boolean
  - Note: In `hybrid` mode, BM25 parameters live under `keyword.k1`/`keyword.b`; in `document` mode they live under `bm25`.
- **Hybrid**
  - `embedding_model`: e.g., `sentence-transformers/all-MiniLM-L6-v2`
  - `faiss`: `{ index_type: "FlatL2" | "IVFFlat" | "IVF-PQ" | "HNSW", nlist, nprobe, pq: { m, nbits }, hnsw: { M, efConstruction } }`
  - `keyword`: `{ k1, b, stopwords }`
  - `graph`: `{ max_hops: 2, weight: { internal: 1.0, external: 0.5 } }`
  - `fuse`: `{ strategy: "rrf" | "weighted", weights: { dense: 0.5, keyword: 0.4, graph: 0.1 } }`
  - `signals`: `["dense","keyword","graph","vision","entities","sparse_learned"]` (choose any subset; omit to use defaults)
  - `also_emit`: `{ document: true }` to co‑emit `.index/index.json` alongside the hybrid snapshot
  - `vision`: `{ embedding_model: "clip-base", page_limit: 5, ocr: { engine: "tesseract", lang: ["en"] } }`
  - `entities`: `{ model: "en_core_web_sm", types: ["ORG","PERSON"], linkers: { } }`
  - `unified_index` (experimental): `{ enabled: true, backend: "graph_ann", calibrate: { dense_scale: 1.0, sparse_scale: 0.7 } }`
- **ColBERT**
  - `colbert`: `{ model: "colbertv2", tokenizer: "bert-base-uncased", shards: 1, engine: "vanilla|plaid|splate" }`
  - `faiss`: `{ index_type: "IVFFlat", nlist, nprobe }` (if using ANN wrappers)
- **Hierarchical**
- `hierarchical`: `{ use: ["leaf","summary"], fuse: "rrf|weighted", top_k: 50 }`
- **KG**
- `kg`: `{ use: ["community_summaries","entities"], top_k: 50 }`
- **Code**
  - `languages`: e.g., `["ts","js","py","go"]`
  - `parsers`: per‑language engine selection (e.g., tree‑sitter)
  - `code`: `{ include_tests: false, follow_generated: false }`
- **Structured**
  - `structured`: `{ fts: true, column_embeddings: false, sample_rows: 1000 }`
  - `duckdb`: optional DuckDB settings if preferred over SQLite

## Incremental & Maintenance

- **Incremental builds**: detect changed chunks via `hash`; rebuild affected docs/shards only; preserve unchanged artifacts.
- **Renames/moves**: stable `id` from frontmatter keeps identity; path changes update `uri` without duplicating docs.
- **Pruning**: remove artifacts for docs missing from current `ingest/**` when `prune: true`.
- **Repairs**: verify FAISS/vector counts vs. docs; recompute missing stats; regenerate manifest.

## Performance & Footprint

- For CPU‑only defaults: prefer `all-MiniLM-L6-v2` and `FlatL2` for small corpora; move to `IVFFlat` as data grows.
- Memory scales with embedding dim × doc chunks; tune chunking in IngestKit and `min_tokens` here.
- BM25 `k1`/`b` tuning impacts sparse recall; start with defaults and adjust using EvalKit metrics.

## Quality & Validation

- Built‑in checks: missing/duplicate IDs, zero‑length docs, token spikes, BM25 stat drift, FAISS/dense cardinality mismatch, broken links.
- Outputs a concise report (JSON) and non‑zero exit on failure when checks are enforced in CI.
- Eval hooks: consume IndexKit artifacts in EvalKit to track Recall@k/MRR before and after changes.

Additional checks by mode/signal

- ColBERT: tokenizer/model dim parity; shard integrity; MaxSim spot checks on a validation sample.
- Code: parser error rates by language; orphan symbols; xref/callgraph closure consistency; file path stability.
- Structured: FTS coverage; schema graph validity (FKs/PKs); column embedding count parity; sample row provenance.
- Vision: page_map consistency (bbox ranges), vector count vs. pages; OCR language coverage and encoding.
- Entities: span bounds and type coverage; linker precision thresholds and provenance.

## Pilot Plan & Gates

Objective

- A/B new modes/signals against your baseline to quantify retrieval/answer gains, latency, and footprint.

Dataset slice

- Fix a snapshot of ~5–10% of the corpus; ensure the eval set includes long/global and local/pointed questions.

Variants to build (besides baseline)

- `hierarchical`: add summary‑tree artifacts; query multi‑level (probe summaries → descend to leaves).
- `kg`: add entity KG + community summaries; enable a global question route.
- `hybrid + sparse_learned`: add learned sparse postings alongside BM25/dense.
- `colbert` with `engine: "plaid"` (and optionally `"splate"`).
- `hybrid` with `unified_index.enabled: true` (experimental).

Minimal config deltas

```json
// Hybrid with learned sparse
{
  "mode": "hybrid",
  "source": "ingest/",
  "signals": ["dense","keyword","graph","sparse_learned"],
  "output": { "dir": "indexes/" },
  "snapshot": true
}
```

```json
// ColBERT with PLAID engine
{
  "mode": "colbert",
  "source": "ingest/",
  "colbert": { "model": "colbertv2", "shards": 1, "engine": "plaid" },
  "output": { "dir": "colbert/" },
  "snapshot": true
}
```

Acceptance gates (suggested)

- Hierarchical: +5–10 pts Recall@20 on long/global; +3–5% absolute answer accuracy; ≤10% serve‑latency drift.
- KG: +10% absolute answer accuracy on global/insight queries; citation correctness ≥ baseline.
- Learned sparse: ≥ baseline Recall@20/MRR at BM25‑like latency (±10%); CPU‑friendly serving path validated.
- PLAID/SPLATE: within ±1% MRR and −2× to −10× latency vs vanilla ColBERT; index size within ±10%.
- Unified hybrid (experimental): no regression >2% on Recall@20/MRR; document risks if serving complexity drops materially.

Observability

- Log `schema_version`, build `ts`, corpus hash, mode/signal knobs, and artifact sizes to ObservaKit for traceability.

## Link Graph Details

- **Edge sources**: Markdown links, frontmatter references, directory adjacency, and cross‑doc anchors.
- **Edge fields**: `{ src, dst, edge: "md|ref|path", weight, anchor }`; normalize paths; collapse duplicates by summing weights.
- **Use in retrieval**: QueryKit expands neighborhoods up to `max_hops`, then re‑ranks fused candidates.

## Examples

- Graph‑only (lightweight structure build)

```json
{
  "mode": "hybrid",
  "source": "ingest/",
  "signals": ["graph"],
  "graph": { "max_hops": 2 },
  "output": { "dir": "indexes/" },
  "snapshot": true
}
```

- Full hybrid + co‑emit document (avoid double build)

```json
{
  "mode": "hybrid",
  "source": "ingest/",
  "signals": ["dense", "keyword", "graph"],
  "embedding_model": "sentence-transformers/all-MiniLM-L6-v2",
  "faiss": { "index_type": "FlatL2" },
  "keyword": { "k1": 1.2, "b": 0.75 },
  "graph": { "max_hops": 2 },
  "fuse": { "strategy": "rrf" },
  "also_emit": { "document": true },
  "output": { "dir": "indexes/" },
  "snapshot": true
}
```

- Hybrid with vision + entities

```json
{
  "mode": "hybrid",
  "source": "ingest/",
  "signals": ["dense", "keyword", "graph", "vision", "entities"],
  "embedding_model": "sentence-transformers/all-MiniLM-L6-v2",
  "vision": { "embedding_model": "clip-base", "ocr": { "engine": "tesseract", "lang": ["en"] } },
  "entities": { "model": "en_core_web_sm", "types": ["ORG","PERSON"] },
  "fuse": { "strategy": "weighted", "weights": { "dense": 0.45, "keyword": 0.35, "graph": 0.1, "vision": 0.05, "entities": 0.05 } },
  "output": { "dir": "indexes/" },
  "snapshot": true
}
```

## Language & Content Handling

- Stopwords/stemming by `lang`; if absent, default to `en`. IngestKit may set `lang` during normalization.
- Preserve code blocks for preview but exclude from BM25 unless tagged (e.g., `labels: ["code:index"]`).
- Non‑text (images/PDFs) become text via IngestKit extractors; retain `uri` and provenance.

## Security & Compliance

- GuardKit performs redaction before indexing; IndexKit never writes secrets into artifacts.
- Artifacts are SBOM‑ready; record third‑party models/libs in the manifest for license scanning.
- Snapshots are immutable; prefer new snapshots over in‑place mutation for auditability.

## ANN Presets & Autosizing

- Opinionated, persistent ANN presets for dense vectors; saved into snapshot manifests for reproducibility.
- Presets (FAISS IndexFactory strings under the hood)
  - `hnsw:fast-read` → `HNSW32,Flat` (great recall/latency; higher RAM). Tunables: `hnsw.M`, `hnsw.efConstruction`.
  - `ivf:balanced` → `IVF{nlist},Flat` (lower RAM than Flat; good for mid‑size). Tunables: `nlist`, `nprobe`.
  - `ivf-pq:compact` → `IVF{nlist},PQ{m}x{nbits}` (best memory efficiency; small recall tradeoff). Tunables: `nlist`, `pq.m`, `pq.nbits`.
- Autosizing
  - `nlist` default ≈ `sqrt(N)` (rounded to power‑of‑two buckets). Override via config.
  - `pq.m` defaults to `dim/6` (rounded to multiple of 8); `pq.nbits` defaults to 8.
  - All choices and corpus size are recorded in `dense.meta.json`.

Minimal config (presets)

```json
{
  "mode": "hybrid",
  "source": "ingest/",
  "embedding_model": "sentence-transformers/all-MiniLM-L6-v2",
  "faiss": {
    "preset": "ivf-pq:compact",
    "autosize": true,
    "metric": "l2",
    "ivf": { "nlist": null, "nprobe": 16 },
    "pq":  { "m": null,  "nbits": 8 },
    "hnsw": { "M": 32, "efConstruction": 200 }
  },
  "output": { "dir": "indexes/" },
  "snapshot": true
}
```

Notes

- QueryKit exposes runtime knobs like `nprobe` or `efSearch`; IndexKit presets target build‑time memory/latency trade‑offs.
- For small corpora, use QueryKit’s in‑memory adapters; IndexKit remains source of truth when you need persistence.

## Freshness & Lifecycle

- Snapshot rotation: write immutable `indexes/<snapshot-id>/…` and update `indexes/latest` symlink.
- TTL/expiry policies: mark snapshots `expires_at` in `snapshot/manifest.json`; CI can prune beyond retention windows.
- Incremental rebuilds: shard‑aware updates for partial corpus changes; per‑artifact checksums in manifest to skip unchanged work.

## Per‑Locale Indexing Defaults

- Sparse analyzers per language (stopwords/stemmers).
- Embedding model selection per locale; prefer multilingual models when mixed corpora.

Recommended defaults (illustrative)

- en: stopwords=en, stemmer=porter; embedding=`sentence-transformers/all-MiniLM-L6-v2`
- es: stopwords=es, stemmer=snowball_es; embedding=`sentence-transformers/distiluse-base-multilingual-cased-v2`
- de: stopwords=de, stemmer=snowball_de; embedding=`sentence-transformers/distiluse-base-multilingual-cased-v2`
- fr: stopwords=fr, stemmer=snowball_fr; embedding=`sentence-transformers/distiluse-base-multilingual-cased-v2`
- ja/zh: no stemming; unigram/bigram tokenization; embedding=`sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2`

Config sketch

```json
{
  "hybrid": {
    "keyword": { "stopwords": { "default": "en", "per_locale": { "es": "es", "de": "de" } } },
    "embedding_model": { "default": "sentence-transformers/all-MiniLM-L6-v2", "per_locale": { "es": "distiluse-base-multilingual-cased-v2" } }
  }
}
```

## Quickstart

```python
# Python API (conceptual)
from indexkit import build_document, build_hybrid

build_document(
  source="ingest/",
  output={"file": ".index/index.json"},
  snapshot=True,
  preview_tokens=80,
)

build_hybrid(
  source="ingest/",
  output={"dir": "indexes/"},
  signals=["dense","keyword","graph"],
  embedding_model="sentence-transformers/all-MiniLM-L6-v2",
  snapshot=True,
)
```

```json
{
  "mode": "document",
  "source": "ingest/",
  "bm25": { "k1": 1.2, "b": 0.75 },
  "output": { "file": ".index/index.json" },
  "snapshot": true
}
```

```json
{
  "mode": "hybrid",
  "source": "ingest/",
  "signals": ["dense", "keyword", "graph"],
  "embedding_model": "sentence-transformers/all-MiniLM-L6-v2",
  "output": { "dir": "indexes/" },
  "snapshot": true
}
```

## Troubleshooting

- Missing stable IDs: ensure `frontmatter.id` or deterministic `path+hash`; duplicates fail validation.
- Model not found: verify local availability of `sentence-transformers` model or configure an offline cache path.
- FAISS dim mismatch: confirm `dense.meta.json.dim` matches embedding model output.
- Empty `links.jsonl`: enable link extraction in IngestKit or add references; verify path normalization.
- Memory pressure on build: reduce chunk size in IngestKit, lower embedding dim/model, or switch FAISS to `IVFFlat`.
