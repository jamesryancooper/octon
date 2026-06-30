# Source Lineage

This program is grounded in the postmortem of the
`run-program-to-clean-delivery` proposal program run.

## Controlling Evidence

- Parent proposal program:
  `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery`
- Latest parent lifecycle evidence:
  `.octon/state/evidence/runs/workflows/20260630T023600Z-run-program-clean-delivery-post-change-closeout-replan`
- Parent Change receipt:
  `.octon/state/evidence/runs/skills/closeout-change/20260630T023314Z-run-program-clean-delivery-parent-lifecycle-change/change-receipt.json`
- Parent closeout-worktree lifecycle residue handoff:
  `.octon/state/evidence/validation/analysis/2026-06-30-closeout-worktree-run-program-to-clean-delivery-parent-lifecycle-residue-handoff.yml`
- Parent closeout-worktree nonterminal broader hygiene report:
  `.octon/state/evidence/validation/analysis/2026-06-30-closeout-worktree-run-program-to-clean-delivery-parent-closeout-program-hygiene.yml`

## Issue Coverage

- Stale parent pre-integration architecture review evidence.
- Parent lifecycle completion being easy to confuse with clean delivery.
- Missing concrete Proposal Program Delivery receipt and evidence index for
  the clean-delivery run.
- Branch-local Change receipt not reconciled after later merge, sync, and
  branch cleanup actions.
- Cleanup and worktree disposition ambiguity around preserved residue,
  protected run-state residue, local metadata, and deletion authority.
- Aggregate clean-delivery validator coverage gaps.
- Non-hermetic validator test behavior that can dirty tracked generated read
  models.

Chat history is source narrative only. Repository receipts, validators, and
current files remain the authoritative factual basis.
