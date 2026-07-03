# Child Packet Index

| Child | Priority | Phase | Required | Purpose |
| --- | --- | --- | --- | --- |
| `proposal-churn-common-generator-idempotency-metrics` | P0 | phase-1 | yes | Establish common no-op write rules and churn metrics for generator entrypoints. |
| `proposal-churn-run-health-read-model-compaction` | P0 | phase-2 | yes | Reduce run-health read-model fanout while preserving operator freshness and traceability. |
| `proposal-churn-effective-publication-idempotency` | P0 | phase-3 | yes | Make runtime-facing effective publishers digest-aware without weakening locks, receipts, or resolver checks. |
| `proposal-churn-extension-payload-compaction` | P0 | phase-4 | yes | Reduce copied extension payload fanout through digest reuse and changed-extension-only publication. |
| `proposal-churn-filesystem-snapshot-retention` | P1 | phase-5 | yes | Add stable identity and producer-owned retention to capability filesystem snapshots. |
| `proposal-churn-proposal-artifact-compaction` | P1 | phase-6 | yes | Make proposal registry and artifact generation archive-aware and changed-packet-only. |
| `proposal-churn-receipt-fanout-compaction` | P1 | phase-7 | yes | Compact repeated timestamped validation/publication receipts while retaining full proof retrieval. |
| `proposal-churn-host-projection-idempotency` | P1 | phase-8 | yes | Make `.claude`, `.codex`, and `.cursor` projection publishing idempotent and non-authoritative. |
| `proposal-churn-tmp-engine-cache-hygiene` | P1 | phase-9 | yes | Bound `.octon/generated/.tmp` and engine build/cache residue with explicit cleanup authority. |
| `proposal-churn-retained-run-evidence-efficiency` | P2 | phase-10 | no, deferred | Optional adjacent retained evidence/control/continuity indexing and retention efficiency. |

All child packets are sibling proposal packets under
`.octon/inputs/exploratory/proposals/architecture/`. No child packet is nested
under this parent.

## External Dependencies

These existing packets are referenced as dependencies, not duplicated as
children:

- `run-program-clean-delivery-test-hermeticity`
- `run-program-clean-delivery-cleanup-disposition`
- `proposal-program-loop-breaker`
- `closeout-worktree-autonomous-partition-evidence`
