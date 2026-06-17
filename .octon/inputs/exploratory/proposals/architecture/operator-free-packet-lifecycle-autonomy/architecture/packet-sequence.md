# Packet Sequence

| Priority | Order | Child | Depends On | Gate | Rationale |
| --- | ---: | --- | --- | --- | --- |
| P0 | 1 | `blocked-delivery-receipt-semantics` | none | receipt schema review | Allows truthful blocked delivery receipts to validate structurally before wrapper orchestration depends on them. |
| P0 | 2 | `packet-delivery-wrapper-orchestration-autonomy` | `blocked-delivery-receipt-semantics` | delivery workflow review | Makes `/proposal-packet-delivery` the outer route-owned orchestrator with explicit pre-archive and archived-state behavior. |
| P0 | 3 | `branch-no-pr-closeout-state-machine-autonomy` | `packet-delivery-wrapper-orchestration-autonomy` | closeout route review | Lets `closeout-change` progress from published branch to landed, synced, cleaned, and branch-deleted in one route. |
| P1 | 4 | `generated-freshness-scope-detection` | `packet-delivery-wrapper-orchestration-autonomy` | freshness scope review | Detects generator-input changes and routes generated/read-model authorization before closeout. |
| P1 | 5 | `packet-worktree-partitioning-automation` | `branch-no-pr-closeout-state-machine-autonomy` | hygiene route review | Makes publishable evidence, cleanup-safe residue, protected retained evidence, and manual-review paths first-class buckets. |
| P1 | 6 | `terminal-evidence-sink-autonomy` | `branch-no-pr-closeout-state-machine-autonomy`, `packet-worktree-partitioning-automation` | terminal proof review | Emits post-landing proof without source-branch commits or landed-ref mutation. |
| P1 | 7 | `git-mutation-sandbox-preflight` | `branch-no-pr-closeout-state-machine-autonomy` | git helper review | Improves diagnostics for fetch, checkout, landing, sync, and cleanup operations that require elevated git mutation permissions. |

The first three children should be implemented first because they define the
truth model and route sequence for the rest of the autonomy improvements.
