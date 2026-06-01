# Implementation Plan

## Packet-Local Revision Work

1. Bind the parent postmortem findings to current repository evidence.
2. Classify every terminal-routing requirement as fixed, partially fixed,
   open, or outside this child packet's mutation authority.
3. Map each open or partial gap to a downstream child owner, target file set,
   required change, no-op rationale where applicable, and validation floor.
4. Preserve proposal-local and parent/child authority boundaries in the source
   map, file-change map, rollback plan, cutover checklist, operator disclosure,
   risk register, evidence plan, and implementation-grade receipt.

## Downstream Implementation Sequence

1. `proposal-program-runner-workflow-retry-ids` owns workflow run id retry and
   replay-safe resume hardening before any retry-sensitive archive or promote
   route is rerun.
2. `proposal-program-runner-change-handoff-checkpoints` owns non-authorizing
   Change and worktree handoff checkpoints without moving closeout or cleanup
   authority into the runner.
3. `proposal-program-runner-aggregate-terminal-blockers` owns parent
   controller blocker ledger improvements while preserving child-owned
   receipts.
4. `proposal-program-runner-promotion-evidence-binding` owns selected-child
   promotion evidence binding before workflow-owned promotion dispatch.
5. `proposal-program-runner-publication-freshness-preflight` owns generated
   freshness classification and canonical recovery routing.
6. `proposal-program-runner-parent-review-churn` owns parent review digest
   boundary hardening for volatile run-control and route-created evidence.
7. `proposal-program-runner-archive-observation-recovery` owns archive
   terminal observation hardening and blocked archive evidence.
8. `proposal-program-runner-terminal-routing-tests` owns regression coverage
   across all terminal-routing gaps.

## Handoff Rule

Each downstream child must start from `architecture/current-state-gap-map.md`
and may narrow, supersede, or prove a no-op only with fresh live repository
evidence. Parent program coordination cannot satisfy child review,
implementation, conformance, drift, closeout, or archive receipts.
