# Child Packet Index

All child packets are required, active, sibling architecture proposal packets. Parent evidence coordinates only and never satisfies child receipts.

Dependent child packets use the contract-valid `verification` dependency gate: downstream implementation waits for dependency implementation, conformance, drift verification, and required evidence while child acceptance, implementation, closeout, and archive remain owned by each child lifecycle.

| Order | Child | Phase | Focus | Dependencies |
| --- | --- | --- | --- | --- |
| 1 | `token-efficiency-token-measurement-ledger` | `phase-0` | measurement | none |
| 2 | `token-efficiency-evidence-index-raw-log-summaries` | `phase-1` | evidence | `token-efficiency-token-measurement-ledger` |
| 3 | `token-efficiency-planner-state-program-context-capsule` | `phase-1` | planner-state | `token-efficiency-token-measurement-ledger` |
| 4 | `token-efficiency-blocker-ledger-recovery-deltas` | `phase-3` | recovery | `token-efficiency-evidence-index-raw-log-summaries`, `token-efficiency-planner-state-program-context-capsule` |
| 5 | `token-efficiency-validator-manifests-generated-freshness` | `phase-3` | validation-freshness | `token-efficiency-evidence-index-raw-log-summaries`, `token-efficiency-planner-state-program-context-capsule` |
| 6 | `token-efficiency-prompt-pack-instruction-capsules` | `phase-2` | prompt-runtime | `token-efficiency-token-measurement-ledger` |
| 7 | `token-efficiency-lifecycle-context-pack-integration` | `phase-2` | context-runtime | `token-efficiency-prompt-pack-instruction-capsules`, `token-efficiency-token-measurement-ledger` |
| 8 | `token-efficiency-proposal-artifact-index-spine` | `phase-2` | proposal-index | `token-efficiency-token-measurement-ledger`, `token-efficiency-lifecycle-context-pack-integration` |
| 9 | `token-efficiency-repo-authority-write-scope-index` | `phase-5` | repo-graph | `token-efficiency-proposal-artifact-index-spine` |
| 10 | `token-efficiency-model-routing-action-slice-budgets` | `phase-4` | routing-loop | `token-efficiency-token-measurement-ledger`, `token-efficiency-planner-state-program-context-capsule`, `token-efficiency-blocker-ledger-recovery-deltas`, `token-efficiency-validator-manifests-generated-freshness` |
| 11 | `token-efficiency-structured-receipts-concise-publication` | `phase-3` | receipts-output | `token-efficiency-evidence-index-raw-log-summaries`, `token-efficiency-blocker-ledger-recovery-deltas`, `token-efficiency-validator-manifests-generated-freshness` |
| 12 | `token-efficiency-semantic-cache-context-reuse` | `phase-5` | mature-scale | `token-efficiency-lifecycle-context-pack-integration`, `token-efficiency-proposal-artifact-index-spine`, `token-efficiency-repo-authority-write-scope-index`, `token-efficiency-model-routing-action-slice-budgets` |
