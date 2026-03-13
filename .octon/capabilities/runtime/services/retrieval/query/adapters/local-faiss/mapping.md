# local-faiss Mapping

## Scope

Maps canonical Query service semantics to FAISS adapter semantics. This
contract is declarative only; runtime implementation lives externally.

## Mapping Table

| Canonical Semantic | Adapter Mapping | Notes |
|---|---|---|
| `strategy.use=keyword` | lexical pre-filter before vector lookup | Adapter may compose local lexical filtering with FAISS candidate sets. |
| `strategy.use=semantic` | embedding similarity search | Canonical semantic score is mapped to provider distance/similarity output. |
| `strategy.top_k` | FAISS `k` | Direct cardinality mapping. |
| `candidates[].chunk_id` | vector metadata `chunk_id` | Chunk identifiers must remain canonical for citation assembly. |
| `citations[].locator` | metadata locator pass-through | Locator format remains canonical chunk locator. |

## Boundary

- Provider-specific terms remain confined to `adapters/local-faiss/`.
- Core Query schemas and runtime stay provider-agnostic.
