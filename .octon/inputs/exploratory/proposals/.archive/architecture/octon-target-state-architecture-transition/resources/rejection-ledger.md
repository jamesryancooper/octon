# Rejection Ledger

| Rejected option | Why rejected |
|---|---|
| Architectural re-foundation | Core class-root, authority, mission/run, support, and evidence architecture is strong and should be preserved. |
| New top-level control plane | Would violate `.octon/` super-root and create rival authority. |
| Making generated maps authoritative | Violates generated/read-model discipline. |
| Removing all compatibility projections immediately | Could break current validators/runtime tooling; retirement must be staged. |
| Broad live support expansion | Stage-only/non-live adapters must remain outside live claims until proof-backed. |
| Treating proposal packet as durable source | Proposal standard explicitly says proposals are temporary and non-canonical. |
| Cosmetic doc-only fix | Does not prove side-effect coverage, proof completeness, or runtime modularity. |
| Big-bang runtime rewrite | Unnecessary and risky; use staged modular refactor behind stable CLI semantics. |
