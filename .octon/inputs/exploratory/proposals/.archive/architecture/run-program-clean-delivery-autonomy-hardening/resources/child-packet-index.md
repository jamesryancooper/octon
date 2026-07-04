# Child Packet Index

| Sequence | Child | Priority | Findings | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `run-program-clean-delivery-compact-blocker-remediation` | P1 | PM-001 | Add compact blocker-remediation mode and artifact budgets. |
| 2 | `run-program-clean-delivery-autonomous-hygiene-continuation` | P1 | PM-002 | Continue after recoverable hygiene blockers using route-owned preserve/exclude receipts. |
| 3 | `run-program-clean-delivery-stale-branch-retirement` | P1 | PM-003, PM-007 | Retire stale local branches and distinguish branch roles. |
| 4 | `run-program-clean-delivery-run-health-localization` | P1 | PM-004 | Keep run-health projections diagnostic unless promoted. |
| 5 | `run-program-clean-delivery-no-dispatch-deduplication` | P2 | PM-005 | Deduplicate max-step and no-dispatch artifact churn. |
| 6 | `run-program-clean-delivery-retained-state-reporting` | P2 | PM-007 | Make final reports explicit about delivered, retained, deleted, and manual-review state. |
| 7 | `run-program-clean-delivery-authorized-hosted-landing` | P2 | PM-006 | Consume valid hosted no-PR landing receipts without chat approval stops after execution-lane checks. |

All child packets are sibling packets. The parent may not satisfy child-owned
review, implementation, validation, closeout, archive, delivery, or cleanup
authority.
