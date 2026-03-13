# Query Route Evaluation Report (Phase 4)

- Date: 2026-02-14
- Service: 'octon.service.query'
- Dataset: '/Users/jamesryancooper/Projects/octon/.octon/capabilities/services/retrieval/query/fixtures/eval-routes.jsonl'
- Snapshot root: '/tmp/octon-query-indexes'
- Cases: 2

## Aggregate A/B Metrics

| Metric | Flat | Route |
|---|---:|---:|
| Recall@20 | 0.0000 | 1.0000 |
| MRR | 0.0000 | 1.0000 |
| Latency p95 (ms) | 196 | 262 |

## Aggregate Route Correctness Metrics

| Metric | Value |
|---|---:|
| Route applied rate | 1.0000 |
| Citation completeness | 1.0000 |
| Citation locator validity | 1.0000 |

## Route-Specific Gates

| Route | Cases | Flat Recall@20 | Route Recall@20 | Flat MRR | Route MRR | Applied Rate | Citation Completeness | Locator Validity | Gate |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| `graph_global` | `1` | `0.0000` | `1.0000` | `0.0000` | `1.0000` | `1.0000` | `1.0000` | `1.0000` | `pass` |
| `hierarchical` | `1` | `0.0000` | `1.0000` | `0.0000` | `1.0000` | `1.0000` | `1.0000` | `1.0000` | `pass` |

## Overall Gate

- Overall result: **pass**
- Route-level pass criteria:
  - Route applied rate = 1.0000
  - Citation completeness = 1.0000
  - Citation locator validity >= 0.9900
  - Recall non-regression vs flat
  - MRR non-regression vs flat

## Case Results

| Case | Route | Flat rank | Route rank | Flat status | Route status | Route applied | Flat ms | Route ms |
|---|---|---:|---:|---|---|---:|---:|---:|
| `route-hierarchical-001` | `hierarchical` | `0` | `1` | `success` | `success` | `1` | `196` | `262` |
| `route-graph-global-001` | `graph_global` | `0` | `1` | `success` | `success` | `1` | `163` | `208` |
