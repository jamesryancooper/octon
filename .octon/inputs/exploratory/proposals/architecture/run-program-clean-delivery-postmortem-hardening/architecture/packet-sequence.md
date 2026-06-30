# Packet Sequence

1. `run-program-clean-delivery-architecture-review-freshness`
   - Fix stale review receipt recurrence before other delivery claims depend
     on parent review evidence.
2. `run-program-clean-delivery-delivery-receipt-completion`
   - Require concrete delivery receipts and indexes before clean-delivery
     claims.
3. `run-program-clean-delivery-change-closeout-reconciliation`
   - Reconcile manual or later Git completion with Change closeout evidence.
4. `run-program-clean-delivery-cleanup-disposition`
   - Close cleanup disposition semantics that otherwise block or overclaim
     terminal hygiene.
5. `run-program-clean-delivery-validator-hardening`
   - Add negative controls and disclosure-tier execution to the aggregate
     validator chain.
6. `run-program-clean-delivery-test-hermeticity`
   - Make tests hermetic so validators do not introduce tracked generated
     residue.

Each child must complete its own review, implementation, verification,
closeout, and archive gates. The parent may only cite child evidence by path
and digest after child routes produce it.
