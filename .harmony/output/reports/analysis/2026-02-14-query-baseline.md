# Query Baseline Report (Phase 3)

- Date: 2026-02-14
- Service: 'harmony.service.query'
- Dataset: '/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/retrieval/query/fixtures/eval-baseline.jsonl'
- Snapshot root: '/tmp/harmony-query-indexes'
- Cases: 4

## Metrics

| Metric | Value |
|---|---:|
| Citation completeness (ask cases) | 1.0000 |
| Citation locator validity | 1.0000 |
| Recall@20 | 1.0000 |
| MRR | 1.0000 |
| Answer phrase accuracy (ask cases) | 1.0000 |
| Latency p95 (ms) | 256 |

## Case Results

| Case | Command | Status | Rank (expected chunk) | Candidates | Citations | Total ms |
|---|---|---|---:|---:|---:|---:|
| `eval-retrieve-rollout-gates` | `retrieve` | `success` | `1` | `4` | `4` | `207` |
| `eval-ask-rollout-definition` | `ask` | `success` | `1` | `4` | `4` | `256` |
| `eval-explain-weighted` | `explain` | `partial` | `1` | `4` | `4` | `181` |
| `eval-retrieve-ownership-no-graph` | `retrieve` | `partial` | `1` | `4` | `4` | `168` |

## Notes

- Semantic signal latency is agent-bound and scales with candidate set size and model inference behavior.
- Deterministic stages: keyword, graph, fusion, citation.
- Run records emitted to '.harmony/capabilities/services/_ops/state/runs/query/' include span evidence:
  - 'service.query.ask'
  - 'service.query.retrieve'
  - 'service.query.explain'
