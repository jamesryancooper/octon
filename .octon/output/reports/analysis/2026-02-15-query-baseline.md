# Query Baseline Report (Phase 3)

- Date: 2026-02-15
- Service: 'octon.service.query'
- Dataset: '/Users/jamesryancooper/Projects/octon/.octon/capabilities/services/retrieval/query/fixtures/eval-baseline.jsonl'
- Snapshot root: '/tmp/octon-query-indexes'
- Cases: 4

## Metrics

| Metric | Value |
|---|---:|
| Citation completeness (ask cases) | 1.0000 |
| Citation locator validity | 1.0000 |
| Recall@20 | 1.0000 |
| MRR | 1.0000 |
| Answer phrase accuracy (ask cases) | 1.0000 |
| Latency p95 (ms) | 245 |

## Case Results

| Case | Command | Status | Rank (expected chunk) | Candidates | Citations | Total ms |
|---|---|---|---:|---:|---:|---:|
| `eval-retrieve-rollout-gates` | `retrieve` | `success` | `1` | `4` | `4` | `224` |
| `eval-ask-rollout-definition` | `ask` | `success` | `1` | `4` | `4` | `245` |
| `eval-explain-weighted` | `explain` | `partial` | `1` | `4` | `4` | `194` |
| `eval-retrieve-ownership-no-graph` | `retrieve` | `partial` | `1` | `4` | `4` | `183` |

## Notes

- Semantic signal latency is agent-bound and scales with candidate set size and model inference behavior.
- Deterministic stages: keyword, graph, fusion, citation.
- Run records emitted to '.octon/capabilities/services/_ops/state/runs/query/' include span evidence:
  - 'service.query.ask'
  - 'service.query.retrieve'
  - 'service.query.explain'
