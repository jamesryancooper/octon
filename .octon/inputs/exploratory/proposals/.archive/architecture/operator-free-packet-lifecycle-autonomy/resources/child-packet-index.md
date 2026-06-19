# Child Packet Index

| Priority | Child | Path | Purpose |
| --- | --- | --- | --- |
| P0 | `blocked-delivery-receipt-semantics` | `.octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics` | Make truthful blocked aggregate receipts validate structurally while keeping success outcomes strict. |
| P0 | `packet-delivery-wrapper-orchestration-autonomy` | `.octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy` | Make `/proposal-packet-delivery` the outer route-owned orchestrator with explicit pre-archive and archived-state routing. |
| P0 | `branch-no-pr-closeout-state-machine-autonomy` | `.octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy` | Let `closeout-change` own published, landed, synced, cleaned, and branch-deleted states. |
| P1 | `generated-freshness-scope-detection` | `.octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection` | Auto-detect generator-input changes and route generated/read-model freshness authorization before closeout. |
| P1 | `packet-worktree-partitioning-automation` | `.octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation` | Make worktree closeout buckets first-class and cleanup-safe. |
| P1 | `terminal-evidence-sink-autonomy` | `.octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy` | Emit post-landing proof without creating new source-branch commits or mutating the landed ref. |
| P1 | `git-mutation-sandbox-preflight` | `.octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight` | Improve diagnostics for sandbox-sensitive git mutation helpers. |

Children are planned sibling packets. This parent program does not create the
child packet directories.
