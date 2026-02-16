# Invariants

1. Files are canonical source-of-truth.
2. Snapshot IDs are deterministic for identical input trees.
3. Snapshot artifacts are immutable after creation.
4. Graph operations require valid snapshot artifacts.
5. Discovery operations return bounded, explicit frontier expansions.
6. Graph entities returned to callers are resolvable to file path or source locator.
7. Provider-specific terms are disallowed in core filesystem-graph files.
8. Runtime metrics are emitted per operation with latency and status fields.
9. Per-operation latency and error budgets are enforced by CI SLO gates.
10. Automated SLO tuning can tighten budgets from CI history but must not loosen them.
