# Cache — Memoization & Artifacts

- **Purpose:** Speed up repeated steps and share artifacts across plans/runs.
- **Responsibilities:** content-addressable storage, TTLs, invalidation hooks, partial result reuse.
- **Integrates with:** Agent (memo), Query/Index (snapshots), Observe (indexes to traces).
- **I/O:** cached blobs, pointers, cache keys.
- **Wins:** Faster iterations and cheaper runs.
