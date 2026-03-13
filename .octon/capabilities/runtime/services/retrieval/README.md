# Retrieval

Organize and query your knowledge base.

## Services

- [Search](./search/guide.md) — Harvests external web/API sources into snapshots with provenance.
- [Ingest](./ingest/guide.md) — Normalizes multi-format sources into token-aware, deterministic chunks with stable IDs.
- [Index](./index/guide.md) — Builds deterministic indexes (dense, keyword, graph, hierarchical, ColBERT, code, structured modes).
- [Query](./query/guide.md) — Hybrid retrieval with dense/keyword/graph fusion, reranking, chunk-level citations and evidence packs.
- [Parse](./parse/README.md) — Converts PDFs to Markdown (Docling-powered), deterministic and local-first.

## Index and RAG Best Practices

The Index service aligns well with current RAG-indexing best practices. It's contract-first and deterministic, supports hybrid (dense+BM25+graph) signals, emits reproducible snapshots, preserves chunk-level IDs end-to-end, and can publish to serving databases — all table-stakes in modern RAG stacks.

Here's how it maps to "best practice" checkpoints:

- Determinism & provenance. Builds immutable, audit-ready snapshots with manifests; emphasizes strict, mode-specific contracts so downstream tools can trust artifact shape and metadata.
- Chunk-first, stable IDs. Ingest produces deterministic chunks with stable `chunk_id`/`doc_id`, and Query retrieves/reranks at chunk granularity—so citations/evidence stay tight.
- Hybrid indexing. Indexes dense vectors, BM25 stats, and a link graph; supports fusing scores (RRF/weighted) at query time.
- Late-interaction/ColBERT readiness. Contracts and outputs are ColBERT/RAGatouille-compatible, giving you a clean upgrade path.
- Quality gates in CI. Built-in validation detects ID issues, stat drift, FAISS/embedding mismatches, and more; hooks into the Eval service for Recall@k/MRR tracking.
- Incremental builds & lifecycle. Rebuilds only affected shards, rotates immutable `indexes/<snapshot>` with a `latest` pointer, and supports TTL/expiry.
- Scalability knobs. Presets for FAISS/HNSW with autosizing; records choices for reproducibility.
- Multimodal & entities when useful. Optional "vision" and "entities" signals integrate as additional retrieval evidence.
- Publish-to-DB (serve path). Optional, but aligned with the common "build snapshots → upsert to Postgres (pgvector + FTS + edges)" pattern.

Nuances (where the work lives):

- Reranking/recency live at query-time. Cross-encoder reranking, LTR, and optional recency boosting are part of the Query service, not Index (correct separation of concerns).
- Input hygiene matters. Near-duplicate filtering and redaction happen in the Ingest service before indexing; keep those on to avoid noisy vectors or leaked secrets.

## Bottom Line

If you run the canonical workflow — Ingest (deterministic chunks + dedup/redaction) → Index (`hybrid` with optional `also_emit.document`) → Query (hybrid retrieval + rerank + citations) — you're aligned with current RAG best practices for small-to-mid corpora, with a clean path to ColBERT and DB-backed serving when needed.
