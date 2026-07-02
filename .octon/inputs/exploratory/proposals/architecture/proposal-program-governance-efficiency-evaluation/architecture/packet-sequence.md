# Packet Sequence

The program runs sequentially so later surfaces depend on stable report and scoring contracts.

| Order | Child | Gate |
| --- | --- | --- |
| 1 | `proposal-governance-efficiency-report-contract` | Define the advisory report schema and vocabulary first. |
| 2 | `proposal-governance-efficiency-evidence-collector` | Collect retained evidence only after the report needs are clear. |
| 3 | `proposal-governance-efficiency-scoring-and-classification` | Score controls after the collector and report fields are stable. |
| 4 | `proposal-governance-efficiency-operator-surface` | Add operator access after core read-only behavior is defined. |
| 5 | `proposal-governance-efficiency-validation-and-documentation` | Add regression coverage and docs after the accepted surface set is known. |

No sequence step authorizes a child lifecycle transition by itself. Each child must pass its own review, implementation, validation, closeout, archive, cleanup, and terminal proof gates.
