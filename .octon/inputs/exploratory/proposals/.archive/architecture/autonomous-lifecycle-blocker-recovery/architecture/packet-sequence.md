# Packet Sequence

Status: draft parent-program sequence.

The program uses `gated-parallel` coordination. It is not `program-atomic`;
child write scopes and route gates remain child-owned.

## phase-0

- `autonomous-blocker-taxonomy`: define recovery classes, examples, and
  escalation criteria. Dependencies: none.
- `token-efficiency-preservation`: define compact evidence, retry summaries,
  and diagnostic constraints. Dependencies: none.

## phase-1

- `validator-affordances`: define validator diagnostics and recovery hints.
  Dependencies: `autonomous-blocker-taxonomy`,
  `token-efficiency-preservation`.
- `cleanup-routing`: define repo-hygiene cleanup delegation and receipt-backed
  cleanup boundaries. Dependencies: `autonomous-blocker-taxonomy`,
  `token-efficiency-preservation`.

## phase-2

- `evidence-and-receipt-hardening`: define child-owned receipt preservation,
  replayable checkpoint references, compact event summaries, and parent summary
  safeguards. Dependencies: `autonomous-blocker-taxonomy`,
  `validator-affordances`, `token-efficiency-preservation`.

## phase-3

- `runner-recovery-behavior`: define autonomous runner repair, retry, refresh,
  resume, and stop behavior. Dependencies: `autonomous-blocker-taxonomy`,
  `validator-affordances`, `cleanup-routing`,
  `evidence-and-receipt-hardening`, `token-efficiency-preservation`.

## phase-4

- `escalation-policy-update`: define updated escalation policy and examples.
  Dependencies: `autonomous-blocker-taxonomy`,
  `runner-recovery-behavior`, `evidence-and-receipt-hardening`.

Later lifecycle execution must revalidate parent review, child reviews,
implementation-grade completeness receipts, and child readiness before
generating or using the parent orchestration prompt.
