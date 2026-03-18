# Ingest — Normalization & Enrichment

- **Purpose:** Normalize internal/external sources into consistent, provenance‑rich chunks for indexing, adding an AI‑aligned ingestion pipeline to Octon.
- **Responsibilities:** parsing multi‑format inputs, token‑aware chunking, deduplicating by content hash, labeling provenance/semantics, enforcing redaction via Guard.
- **Octon alignment:** Advances Interoperability and Provenance with consistent metadata contracts and deterministic chunking; exposes Guard hooks and defers policy/eval gates downstream.
- **Integrates with:** Search (external sources), Plan/Agent (orchestration), Index (consumes chunks), Dataset (corpora), Guard (redaction).
- **I/O:** reads `sources/**` snapshots and repos/docs/APIs/binaries; writes `ingest/*.jsonl` normalized chunks with metadata (`source`,`uri`,`ts`,`hash`,`tokens`,`labels`).
- **Wins:** Uniform, reproducible chunks that improve retrieval quality and speed index builds.
- **Implementation Choices (opinionated):**
  - unstructured: multi‑format (HTML/Office/PDF) parsing for robust text normalization.
  - Marker: high‑fidelity PDF→Markdown/text extraction that preserves structure for better chunking.
  - tiktoken: token‑aware chunking sized to target model windows.
- **Common Qs:**
  - *Binary formats?* Use Marker/unstructured for extraction; keep source URI and content hash.
  - *Determinism?* Hash raw bytes and chunk boundaries; re‑runs yield identical IDs.
  - *Redaction?* Enforce Guard patterns before writing `ingest/*.jsonl`.

## Chunk‑First Contract (Deterministic)

- Produces token‑aware, deterministic chunks with stable IDs so downstream services can retrieve at chunk granularity.
- Each record includes: `chunk_id`, `doc_id`, `uri`, `offset` (byte or token start), `len_tokens`, `hash` (sha256 of normalized text), `ts` (ingest time), `lang` (BCP‑47), `labels`, `source`.
- Boundaries are stable across runs for unchanged source bytes; IDs derive from `frontmatter.id` when present, else `uri+hash`.
- Provenance: retain `source` URI and any parent/section anchors to enable path:line/page citations later.

Example chunk shape (JSONL line)

```json
{
  "chunk_id": "doc:abc#c:00042",
  "doc_id": "doc:abc",
  "uri": "octon/feature-flags.md",
  "offset": 420,
  "len_tokens": 180,
  "hash": "sha256:...",
  "ts": 1720000000,
  "lang": "en",
  "labels": ["adr","owner:platform"],
  "text": "…normalized excerpt…"
}
```

## Dedup & Near‑Duplicate Detection

- Exact dedup: drop identical raw bytes by `sha256(raw_bytes)` before parsing.
- Near‑dup: optionally filter highly similar chunks across sources (copy/paste drift, scraped mirrors) using MinHash or SimHash.
- Redaction happens before hashing to avoid leaking secrets into digests.

Minimal config stub (MinHash and SimHash)

```json
{
  "ingest": {
    "chunking": { "max_tokens": 320, "overlap": 32, "deterministic": true },
    "ids": { "prefer": "frontmatter.id", "fallback": "uri+sha256(text)" },
    "dedup": {
      "exact": { "by": "sha256(raw_bytes)" },
      "near_dup": {
        "method": "minhash",
        "ngrams": 5,
        "num_perm": 128,
        "threshold": 0.85,
        "index": { "type": "lsh", "bands": 32 }
      }
    },
    "near_dup_alt": {
      "method": "simhash",
      "bits": 64,
      "hamming": 3
    },
    "redaction": { "guard_profile": "default" }
  }
}
```

Operational notes

- Apply near‑dup at the chunk level to keep unique evidence granularity for Query.
- Keep a small quarantine log (`ingest/near_dup.jsonl`) for review instead of silent drops when tuning thresholds.

## Freshness & Provenance

- Record `observed_ts` (source mtime or HTTP `Last-Modified`) and `ingested_ts` per chunk.
- Attach `source_eTag`/`content_length` when available to speed no‑op re‑ingests.
- Redact PII/keys via Guard before hashing and storage; store redaction version in metadata.

## Multilingual Segmentation (Defaults)

- Language detection on normalized text; label chunks with `lang`.
- Locale‑aware tokenization/segmentation: preserve CJK and script‑specific boundaries; avoid stemming for CJK.
- Recommended defaults
  - en: stopwords=en, stemmer=porter
  - de: stopwords=de, stemmer=snowball_de
  - es: stopwords=es, stemmer=snowball_es
  - fr: stopwords=fr, stemmer=snowball_fr
  - ja/zh: no stemming; use unigram/bigram tokenization at index time

Config sketch

```json
{
  "ingest": {
    "lang": { "detect": true, "label_field": "lang", "detector": "fasttext" },
    "segment": { "locale_aware": true }
  }
}
```

## Checklist (owner of record)

- Deterministic, token‑aware chunking with stable IDs and provenance.
- Exact + near‑duplicate filtering prior to Index.
- Language detection and locale labels at source.
- Redaction before hashing and storage.

---

## Advanced Builders (optional)

These extend Ingest for newer indexing families that improve RAG on long/global queries and high‑recall scenarios. Each builder writes artifacts alongside your normal `ingest/*.jsonl` chunks so Index and Query can consume them without changing base contracts.

### Hierarchical summary‑tree (RAPTOR‑style)

- Build a bottom‑up tree by clustering leaf chunks → LLM‑summarizing clusters → re‑embedding summaries until a multi‑level tree forms.
- Persist parent/child edges and store summary nodes as first‑class retrievable artifacts.
- Notes: Adds LLM cost; summaries are typically ~25–30% of child size, often reducing overall store size via compression.

Config sketch

```json
{
  "ingest": {
    "hierarchical": {
      "levels": 2,
      "cluster": { "method": "kmeans", "k": 8, "min_leaf": 6 },
      "summarize": { "model": "gpt-4o-mini", "max_tokens": 256 },
      "reembed": { "model": "sentence-transformers/all-MiniLM-L6-v2" },
      "persist": {
        "edges": "ingest/tree_edges.jsonl",
        "summaries": "ingest/summaries.jsonl"
      }
    }
  }
}
```

Artifacts
- `ingest/tree_edges.jsonl` lines: `{ parent_id, child_id, level }`
- `ingest/summaries.jsonl` lines: `{ node_id, level, text, embedding?, meta }`

### Knowledge graph + community summaries (GraphRAG)

- Extract entities/relations to build a KG, run community detection, then precompute community summaries as retrievable nodes.
- Store the KG and summaries for Query's global/insight routes.

Config sketch

```json
{
  "ingest": {
    "kg": {
      "ner": { "model": "en_core_web_sm", "types": ["PERSON","ORG","PRODUCT"] },
      "relations": { "llm": "gpt-4o-mini" },
      "community": { "algo": "louvain", "min_size": 8 },
      "summaries": { "llm": "gpt-4o-mini", "max_tokens": 256 },
      "persist": {
        "entities": "ingest/entities.jsonl",
        "edges": "ingest/kg_edges.jsonl",
        "communities": "ingest/communities.jsonl",
        "community_summaries": "ingest/community_summaries.jsonl"
      }
    }
  }
}
```

Artifacts
- `ingest/entities.jsonl` lines: `{ entity_id, name, type, mentions[] }`
- `ingest/kg_edges.jsonl` lines: `{ src_entity, dst_entity, rel, weight }`
- `ingest/communities.jsonl` lines: `{ community_id, members[] }`
- `ingest/community_summaries.jsonl` lines: `{ community_id, text, meta }`

### Learned sparse retrieval (SPLADE/uniCOIL family)

- Train/emit learned sparse postings (term → impact weights). Optionally run doc expansion (doc2query‑T5) before/during training.
- Export to a Lucene/ES‑compatible postings layout if you want CPU‑friendly serving.

Config sketch

```json
{
  "ingest": {
    "sparse_learned": {
      "model": "splade_v2",
      "doc_expansion": { "enabled": true, "model": "doc2query-t5-small" },
      "export": { "format": "lucene_postings", "path": "ingest/sparse_postings/" },
      "persist": { "impacts": "ingest/sparse_impacts.jsonl" }
    }
  }
}
```

Artifacts
- `ingest/sparse_impacts.jsonl` lines: `{ doc_id|chunk_id, terms: string[], weights: number[] }`
- `ingest/sparse_postings/` optional inverted files for direct serving

### Faster late‑interaction backends (PLAID / SPLATE)

- PLAID: no ingest changes—keep emitting ColBERT token embeddings; PLAID changes index/search engine later.
- SPLATE: additionally persist the adapter mapping token embeddings into a sparse vocab.

Config hint

```json
{
  "ingest": {
    "colbert": { "emit_token_embeddings": true },
    "late_interaction": { "splate_adapter_path": "ingest/splate_adapter.bin" }
  }
}
```

### Unified dense+sparse ANN (single hybrid index)

- Ingest changes are minimal; ensure dense and sparse signals are normalized and metadata records their scales so Index can co‑index safely.
- Record per‑signal stats (means/variances) to help downstream calibration.

### Memory‑augmented “global clues” (MemoRAG)

- Build a compact global memory (long‑range summaries or key‑fact traces) offline; store as a small auxiliary index.

Config sketch

```json
{
  "ingest": {
    "memory": {
      "builder": "memorag",
      "llm": "gpt-4o-mini",
      "schedule": "weekly",
      "persist": { "memories": "ingest/memory.jsonl" }
    }
  }
}
```

Artifacts
- `ingest/memory.jsonl` lines: `{ memory_id, text, scope: "global|theme", meta }`

Cross‑cutting notes
- Cache LLM outputs (summaries, community summaries) and rebuild incrementally to control cost.
- Keep all advanced artifacts deterministic where possible (stable IDs, hashes) so they can be referenced in Query citations.

## Pilot Plan (A/B)

Goal
- Validate build cost, artifact health, and downstream retrieval/answer gains for RAPTOR (hierarchical), GraphRAG (kg), learned sparse, PLAID/SPLATE, unified ANN prep, and memory.

Scope (slice first)
- 5–10% of corpus or 1–2 representative domains/repos; fix the snapshot hash to keep comparisons stable.

Build variants
- Baseline: existing pipeline only
  - No `hierarchical`, no `kg`, no `sparse_learned`, no `memory` extras.
- RAPTOR tree: enable `ingest.hierarchical` as configured above.
- GraphRAG: enable `ingest.kg` (entities + relations + community summaries).
- Learned sparse: enable `ingest.sparse_learned` (with optional `doc_expansion`).
- PLAID/SPLATE: no ingest change for PLAID; for SPLATE, persist adapter (`late_interaction.splate_adapter_path`).
- Memory: enable `ingest.memory` builder.

Config delta (pilot toggles)

```json
{
  "ingest": {
    "hierarchical": { "enabled": true, "levels": 2 },
    "kg": { "enabled": true },
    "sparse_learned": { "enabled": true, "model": "splade_v2" },
    "memory": { "enabled": true }
  }
}
```

Checks & guardrails
- Cost: set a token budget per 1k chunks for summarization/communities; cache LLM outputs.
- Health: verify artifact counts and referential integrity (every parent has children; entities referenced by edges exist).
- Size: record sizes of `summaries.jsonl`, `community_summaries.jsonl`, and `sparse_impacts.jsonl` vs baseline.

Success signals (hand off to Index/Query/Eval)
- Build completes within budget; artifacts pass integrity checks.
- Downstream (measured in Query/Eval): Recall@20, MRR, answer accuracy/citation correctness improve on the pilot slice.
