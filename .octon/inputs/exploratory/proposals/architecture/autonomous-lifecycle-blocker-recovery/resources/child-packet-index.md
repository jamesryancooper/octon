# Child Packet Index

The parent program coordinates these canonical sibling child packets. It does
not nest children and does not satisfy child-owned lifecycle receipts.

| Child | Phase | Group | Required | Scope |
|---|---:|---|---:|---|
| `autonomous-blocker-taxonomy` | phase-0 | classification | yes | Recovery classes, examples, and escalation criteria. |
| `token-efficiency-preservation` | phase-0 | efficiency | yes | Compact receipts, bounded summaries, targeted diagnostics, and no-regression token constraints. |
| `validator-affordances` | phase-1 | validators | yes | Machine-readable validator diagnostics, stale evidence causes, and repair hints. |
| `cleanup-routing` | phase-1 | cleanup | yes | Receipt-backed repo-hygiene cleanup delegation for local run-state residue. |
| `evidence-and-receipt-hardening` | phase-2 | evidence | yes | Child-owned receipts, replayable checkpoint references, compact event summaries, and parent-summary safeguards. |
| `runner-recovery-behavior` | phase-3 | runner | yes | Autonomous repair, retry, refresh, rerun, resume, and hard-stop behavior. |
| `escalation-policy-update` | phase-4 | policy | yes | Updated escalation policy and examples limiting operator escalation to hard blockers. |

All children are active proposal packets under
`.octon/inputs/exploratory/proposals/architecture/`.
