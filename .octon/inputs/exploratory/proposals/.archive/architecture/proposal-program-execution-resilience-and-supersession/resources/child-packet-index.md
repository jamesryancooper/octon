# Child Packet Index

| Child | Priority | Phase | Dependencies | Purpose |
| --- | --- | --- | --- | --- |
| `proposal-program-loop-breaker` | P0 | phase-1 | none | Stop repeated routes when blocker evidence is unchanged and prioritize real drift repair before cleanup. |
| `proposal-program-ownership-baseline-and-leases` | P0 | phase-2 | `proposal-program-loop-breaker` | Establish start baseline, route write leases, isolated worktree gate, and owned/foreign classification. |
| `proposal-program-supersession-rescue-path` | P1 | phase-3 | `proposal-program-ownership-baseline-and-leases` | Freeze polluted runs, carry child-owned receipts forward, and create clean successor or Change closeout paths. |
| `closeout-worktree-autonomous-partition-evidence` | P1 | phase-4 | `proposal-program-supersession-rescue-path` | Return non-mutating partition reports from `closeout-worktree` when ownership is provable. |
