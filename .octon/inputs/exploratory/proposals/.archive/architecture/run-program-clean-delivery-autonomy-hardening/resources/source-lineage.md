# Source Lineage

This program distills the clean-delivery postmortem audit findings and the
operator steering decisions that followed them.

## Postmortem Findings

- PM-001: blocker handling generated too much residue.
- PM-002: recoverable blockers were classified as human-required too often.
- PM-003: similar branch names made delivery status confusing.
- PM-004: generated run-health projections dominated tracked residue.
- PM-005: max-step resumptions produced repeated compact artifacts without
  forward action.
- PM-006: hosted landing had sufficient Octon authorization but still required
  execution-environment approval.
- PM-007: final reporting overclaimed branch cleanup scope.

## Operator Steering Decisions

- Stale local branches with no unique commits should be retired automatically
  under governed evidence when safe.
- Artifact budgets should use repeated fingerprints, file count, and total
  bytes, transitioning to compact blocker-remediation mode instead of pausing.
- Hosted no-PR landing should consume a current authorization receipt
  non-interactively when all receipt, ref, ruleset, check, rollback, and sync
  facts validate.
- Run-health projections should be diagnostic read models by default and
  durable evidence only when explicitly promoted by route-owned receipt.
- Human review is reserved for unclassifiable, unpreservable, destructive,
  external, protected, or conflicting cases.

## Prior Proposal Lineage

- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-postmortem-hardening`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-cleanup-disposition`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-change-closeout-reconciliation`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-delivery-receipt-completion`
- Local retained-state localization receipts from the post-branch-retirement
  cleanup pass.
