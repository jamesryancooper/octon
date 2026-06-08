# Packet Sequence

Status: accepted parent-program sequence.

The program uses `gated-parallel` coordination. The phase plan is not a lifecycle `change_profile`; every packet remains under the active `atomic` pre-1.0 profile unless a future authorized route records a valid transitional exception.

Dependency gating is lifecycle-based, not proposal-status-based. Dependent children use the `verification` gate so downstream implementation work waits for dependency implementation, conformance, drift verification, retained evidence, rollback posture, and relevant receipts while closeout and archive continue through their own declared routes.

## phase-0

- `token-efficiency-token-measurement-ledger`: measurement. Dependencies: none.

## phase-1

- `token-efficiency-evidence-index-raw-log-summaries`: evidence. Dependencies: `token-efficiency-token-measurement-ledger`.
- `token-efficiency-planner-state-program-context-capsule`: planner-state. Dependencies: `token-efficiency-token-measurement-ledger`.

## phase-2

- `token-efficiency-prompt-pack-instruction-capsules`: prompt-runtime. Dependencies: `token-efficiency-token-measurement-ledger`.
- `token-efficiency-lifecycle-context-pack-integration`: context-runtime. Dependencies: `token-efficiency-prompt-pack-instruction-capsules`, `token-efficiency-token-measurement-ledger`.
- `token-efficiency-proposal-artifact-index-spine`: proposal-index. Dependencies: `token-efficiency-token-measurement-ledger`, `token-efficiency-lifecycle-context-pack-integration`.

## phase-3

- `token-efficiency-blocker-ledger-recovery-deltas`: recovery. Dependencies: `token-efficiency-evidence-index-raw-log-summaries`, `token-efficiency-planner-state-program-context-capsule`.
- `token-efficiency-validator-manifests-generated-freshness`: validation-freshness. Dependencies: `token-efficiency-evidence-index-raw-log-summaries`, `token-efficiency-planner-state-program-context-capsule`.
- `token-efficiency-structured-receipts-concise-publication`: receipts-output. Dependencies: `token-efficiency-evidence-index-raw-log-summaries`, `token-efficiency-blocker-ledger-recovery-deltas`, `token-efficiency-validator-manifests-generated-freshness`.

## phase-4

- `token-efficiency-model-routing-action-slice-budgets`: routing-loop. Dependencies: `token-efficiency-token-measurement-ledger`, `token-efficiency-planner-state-program-context-capsule`, `token-efficiency-blocker-ledger-recovery-deltas`, `token-efficiency-validator-manifests-generated-freshness`.

## phase-5

- `token-efficiency-repo-authority-write-scope-index`: repo-graph. Dependencies: `token-efficiency-proposal-artifact-index-spine`.
- `token-efficiency-semantic-cache-context-reuse`: mature-scale. Dependencies: `token-efficiency-lifecycle-context-pack-integration`, `token-efficiency-proposal-artifact-index-spine`, `token-efficiency-repo-authority-write-scope-index`, `token-efficiency-model-routing-action-slice-budgets`.

Later lifecycle execution must revalidate all child reviews, implementation-grade completeness receipts, strict review gates, implementation prompts, and child readiness before using the parent implementation prompt.
