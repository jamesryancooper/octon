# Invariants

1. Files are canonical source-of-truth.
2. Snapshot IDs are deterministic for identical input trees.
3. Snapshot artifacts are immutable after creation.
4. Snapshot publication is atomic; incomplete builds are never marked ready.
5. Snapshot builds enforce writer lock semantics to prevent concurrent publishers.
6. Snapshot retention GC preserves active/new snapshots while enforcing configured budgets.
7. Snapshot operations enforce bounded file/byte/time limits and fail closed on limit exceedance.
8. Provider-specific terms are disallowed in core filesystem-snapshot files.
