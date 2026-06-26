# Source Of Truth Map

| Topic | Source Of Truth | Notes |
| --- | --- | --- |
| Proposal identity and lifecycle posture | `proposal.yml` | Authoritative for this packet only. |
| Architecture decision | `architecture/target-architecture.md` | Defines desired durable behavior. |
| Required implementation sequence | `architecture/implementation-plan.md` | Must be reconciled during implementation. |
| Done gates | `architecture/acceptance-criteria.md` | Acceptance criteria take precedence over README prose. |
| Observed postmortem inputs | `resources/postmortem-findings.md` and `resources/source-lineage.md` | Evidence and prompt lineage, not durable runtime authority. |
| Proposal-local readiness | `support/implementation-grade-completeness-review.md` | Allows implementation planning to proceed after review. |
| Durable runtime authority after implementation | Promotion targets listed in `proposal.yml` | Proposal-local artifacts must not be cited as runtime authority. |

Generated projections, chat history, local terminal evidence, and proposal summaries are non-authoritative unless their owning validators and receipts bind them to the relevant durable route.
