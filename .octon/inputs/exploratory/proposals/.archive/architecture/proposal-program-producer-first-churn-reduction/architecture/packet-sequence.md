# Packet Sequence

The program runs sequentially so shared idempotency and metrics are defined
before producer-specific compaction work.

| Order | Child | Gate |
| --- | --- | --- |
| 1 | `proposal-churn-common-generator-idempotency-metrics` | Establish common no-op write and churn measurement contract. |
| 2 | `proposal-churn-run-health-read-model-compaction` | Reduce the largest tracked generated fanout after common metrics exist. |
| 3 | `proposal-churn-effective-publication-idempotency` | Stabilize runtime-facing generated/effective publication before payload compaction. |
| 4 | `proposal-churn-extension-payload-compaction` | Compact extension copied payloads after effective publication invariants are clear. |
| 5 | `proposal-churn-filesystem-snapshot-retention` | Add snapshot identity and retention under capability producer ownership. |
| 6 | `proposal-churn-proposal-artifact-compaction` | Reduce proposal registry and artifact churn with changed-packet-only generation. |
| 7 | `proposal-churn-receipt-fanout-compaction` | Compact timestamped validation/publication receipts after publication invariants are stable. |
| 8 | `proposal-churn-host-projection-idempotency` | Make host projection fanout idempotent while preserving non-authority projection parity. |
| 9 | `proposal-churn-tmp-engine-cache-hygiene` | Bound local scratch and engine cache residue through owning cleanup routes. |
| 10 | `proposal-churn-retained-run-evidence-efficiency` | Optional adjacent retained evidence/control/continuity efficiency work. |

No sequence step authorizes implementation or a child lifecycle transition by
itself. Each child must pass its own review, implementation, validation,
closeout, archive, cleanup, and terminal proof gates.
