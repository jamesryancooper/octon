# Campaign Promotion Documentation Receipt

## Profile Selection Receipt

- `change_profile`: `atomic`
- `release_state`: `pre-1.0`
- `rationale`:
  - The repository already had an evidence-backed `no-go` decision for
    `campaigns`, but it lived mainly in a phase receipt rather than a standing
    live practice doc.
  - This change promotes that guidance into the orchestration practices surface
    without changing runtime behavior.
- `profile_facts`:
  - `downtime_tolerance`: not applicable
  - `external_consumer_coordination`: none required
  - `data_migration_backfill`: none
  - `rollback_mechanism`: git revert
  - `blast_radius`: documentation and future decision hygiene only
  - `compliance_constraints`: keep `campaigns` optional and aggregation-only

## Implementation Plan

1. Create a standing orchestration practice doc that explains when `campaigns`
   should stay deferred and when to reopen the decision.
2. Link that doc from orchestration practices and the implementation agreement.
3. Update the old Phase 9 receipt so future readers are routed to the live
   standing guide.

## Impact Map (code, tests, docs, contracts)

- `code`:
  - none
- `tests`:
  - none
- `docs`:
  - `/.octon/orchestration/practices/campaign-promotion-criteria.md`
  - `/.octon/orchestration/practices/README.md`
  - `/.octon/orchestration/practices/orchestration-domain-implementation-agreement.md`
  - `/.octon/output/plans/2026-03-10-orchestration-domain-phase9-completion-receipt.md`
- `contracts`:
  - none; this is a live-practice clarification layered on top of existing
    package contracts

## Compliance Receipt

- `campaigns` remain deferred by default.
- Future promotion must remain evidence-backed.
- The standing guidance now lives in the orchestration practices surface rather
  than only in a historical phase receipt.

## Exceptions/Escalations

- No exception requested.
