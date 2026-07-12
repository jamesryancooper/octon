# Compatibility and Retirement Plan

> Non-authoritative. How the migration bridges old and new, and how it retires
> superseded surfaces without breaking a running solo install.

## Compatibility bridges

| Bridge | Purpose | Lifetime |
|---|---|---|
| NDJSON run-journal as **derived export** of the SQLite store | Existing tooling/skills that read journals keep working while the store becomes authoritative | Indefinite (journal stays as a read view) |
| `DelegationProof` retained as **evidence annotation** | Preserves the executor's valuable governance checks (contract/evidence-gate/context-binding/HumanBoundaryRequired) while authority moves to the grant | Indefinite (demoted, not deleted) |
| Legacy YAML state as **read-only projection** during PP-03 | Zero-downtime cutover of the transaction boundary | Until PP-03 exit; then read-view only |
| PR route as **fallback** for branch-no-PR | Any verifier/broker unavailability escalates rather than fails the operator | Permanent (PR is the escalation target) |
| `route-write-lease` files as **derived projection** of transactional reservations | Downstream readers unaffected while authority moves into the store | Until readers migrate; then optional |
| Retention "Class A/B/C" alias kept for one release after rename | Avoids breaking references while the FD-002 crosswalk lands | One release window |

## Retirement schedule (superseded surfaces)

| Surface | Retire when | Replacement | Safe-delete gate |
|---|---|---|---|
| Managed git hooks (`git-autonomy-hooks-install.sh`) | PP-05 sanitized adapter proven | Explicit gated cleanup command | Git-extension-point negative suite passes |
| Autonomous direct-main route | PP-06 branch-no-PR default proven | branch-no-PR + PR escalation | Route-order validator forbids autonomous direct-main |
| Ambient credentials at spawn | PP-04 broker proven | Broker-held credentials | Child-env-scrubbed negative test passes |
| File state as transaction boundary | PP-03 store proven | SQLite/WAL | Kill-point/concurrency tests pass |
| Candidate-editable required checks | PP-06 out-of-tree verifier proven | Out-of-tree verifier | Candidate-diff-cannot-alter-verdict test passes |
| Overstated "signed/complete-mediation" claims | PP-00 (immediately) | Honest wording or real signing | Support-claim-proof-map clean |
| `AUTONOMY_PAT` broad merge authority | PP-06 (scope App or base-ref eligibility) | Scoped App or trusted-state eligibility | J-07 acceptance test passes |
| Federation / Trust-Compact in solo vertical | PP-12 (gate off) / later (remove) | Off-by-default feature | Solo dogfood passes with feature off |

## Support-claim transition (paired with `support-claim-review.md`)

1. **PP-00, before any privileged work**: reword every FD-014/doc/schema use of
   "sign/signed/signature/attestation/complete-mediation/tamper-proof/non-repudiation"
   to the honest "hash-chained + git-anchored" (unless option A signing is chosen),
   rename the capability-layer `signature` field, and downgrade complete-mediation
   language to "bounded local evidence for kernel-mediated effects only".
2. **Per packet**: no packet may publish a support claim stronger than the test it
   just passed. The `support-claim-proof-map.yml` (Phase 3) is the gate.
3. **Before production trust claims (PP-12)**: every remaining claim maps to a
   passing acceptance test; TCB physical writers enumerated; key rotation/backup
   recovery proven if signing was adopted.

## Backward-compatibility guarantees

- A solo operator on the current install must be able to run PP-00..PP-03 with **no
  loss of existing missions or evidence** (store cutover is additive; journals
  preserved).
- No retirement deletes evidence; retired mechanisms are demoted to read-only or
  feature-flagged before deletion, and deletion is gated on the replacement's
  acceptance test.
