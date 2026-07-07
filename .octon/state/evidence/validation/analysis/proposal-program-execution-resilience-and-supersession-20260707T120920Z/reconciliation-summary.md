# Proposal Program Execution Resilience And Supersession Reconciliation

emitted_at: 2026-07-07T12:09:20Z

## Purpose

This program coordinates four child packets that harden proposal-program execution so it can recover from stuck loops, prove write ownership before mutation, rescue polluted runs without losing child-owned evidence, and hand off worktree residue through non-mutating closeout-worktree evidence.

The parent remains coordination-only. This reconciliation does not satisfy child receipts, close children, archive proposals, authorize cleanup, or replace child-owned implementation/conformance/closeout evidence.

## Current Disposition

Program disposition: not terminal.

Reason: the previously identified runtime gaps are now repaired and validated, but child lifecycle state is still `in-review` for all four children and child-owned terminal receipts were not found in retained evidence/control/continuity roots. The parent remains non-terminal until each child is closed through its own lifecycle route.

## Child Reconciliation

| Child | Manifest status | Landed/proven behavior | Remaining child-owned work | Disposition |
| --- | --- | --- | --- | --- |
| `proposal-program-loop-breaker` | `in-review` | Runtime contains blocker ledger/progress fingerprinting and cleanup residue fingerprint behavior. `cargo test -p octon_kernel residue_cleanup_` passed, including unchanged and changed fingerprint cases. Residue fingerprint shell test passed. | Create/retain child-owned implementation, conformance, drift, and closeout receipts; reconcile status through the child lifecycle route. | Proof-ready, not terminal. |
| `proposal-program-ownership-baseline-and-leases` | `in-review` | Runtime records start worktree baseline, explicit dirty-start lease inputs, leased/foreign path counts, child-authority flags, and route-scoped write lease receipts with include/exclude paths for parent and child dispatch. `cargo test -p octon_kernel program_worktree_baseline_` and `cargo test -p octon_kernel route_write_lease` passed. | Create/retain child-owned implementation, conformance, drift, and closeout receipts; reconcile status through the child lifecycle route. | Implemented/proof-ready, not terminal. |
| `proposal-program-supersession-rescue-path` | `in-review` | Registry metadata supports `supersession_evidence`, replacement child ids, successor constraints, and parent-summary non-authority fields. Runtime now emits `octon-program-polluted-run-freeze-v1` before further mutation when a selected child route has a prior start without completion; the freeze carries event/checkpoint/blocker digests, child receipt refs or explicit missing-ref blockers, deliverable partitioning, non-authority flags, clean successor-run requirements, and normal Change closeout routing. `cargo test -p octon_kernel unfinished_selected_child_route_start_blocks_redispatch` passed. | Create/retain child-owned implementation, conformance, drift, and closeout receipts; reconcile status through the child lifecycle route. | Implemented/proof-ready, not terminal. |
| `closeout-worktree-autonomous-partition-evidence` | `in-review` | Closeout-worktree report validation includes `closeout-worktree-report-v1`, proposal-program handoff authorization, authorized path exact matching, foreign fingerprint binding, parent-summary non-authority, and forbidden mutating actions. `test-closeout-worktree-wrapper.sh` passed with 63/0. | Create/retain child-owned implementation, conformance, drift, and closeout receipts; reconcile status through the child lifecycle route. | Proof-ready, not terminal. |

## Fixed During This Reconciliation

- Repaired the delivery evidence-index test fixture so it includes the required `retained_state_report` table. The production generator and validators already failed closed correctly; the fixture was stale against the current receipt contract.
- Added route-scoped write lease receipts (`octon-program-route-write-lease-v1`) to parent and child route dispatch. Parent route leases include the parent target/run roots and explicitly exclude child-owned targets/run roots; child route leases bind existing authority-zone write-scope digests and exclude parent/sibling surfaces. The lease ref/digest is passed into nested lifecycle route inputs and is marked dispatch-preflight-only.
- Added polluted-run freeze evidence (`octon-program-polluted-run-freeze-v1`) to the child-route completion-not-observed guard. Freeze evidence is emitted before the run is marked blocked, is explicitly non-authorizing, carries child receipt refs or missing-ref blockers, partitions deliverable versus excluded paths, and records clean successor-run/normal Change closeout requirements.
- Refreshed `.octon/generated/proposals/registry.yml` via `generate-proposal-registry.sh --write`, then proved projection freshness with `--check`.

## Terminal Plan

1. Run child-owned closeout reconciliation for `proposal-program-loop-breaker`.
   - Retain implementation/conformance/drift/closeout evidence under the child route.
   - Move status only through the child lifecycle route after child-owned receipts validate.

2. Run child-owned closeout reconciliation for `proposal-program-ownership-baseline-and-leases`.
   - Use the new route-write-lease implementation and tests as implementation proof.
   - Retain child implementation/conformance/drift/closeout receipts without letting parent evidence substitute.

3. Run child-owned closeout reconciliation for `proposal-program-supersession-rescue-path`.
   - Use the new polluted-run freeze implementation and interrupted-route regression as implementation proof.
   - Retain child implementation/conformance/drift/closeout receipts without treating freeze evidence as delivery or closeout authority.

4. Run child-owned closeout reconciliation for `closeout-worktree-autonomous-partition-evidence`.
   - Use the existing closeout-worktree validator/test coverage as implementation proof.
   - Retain child closeout receipts without letting parent summary or partition reports replace child evidence.

5. Refresh generated registry through the canonical generator after any lifecycle/status edits.

6. Close the parent program only after all four children are terminal and the parent validators, registry check, delivery validators, evidence-index validator, lifecycle contracts, and worktree hygiene proofs pass.

## Fail-Closed Notes

- Parent evidence may summarize current posture, but it cannot close a child or satisfy a child receipt.
- The program must not claim terminal state until all child statuses/receipts are terminal. Route-write-lease and polluted-run freeze behavior is now implemented/proven, but that proof does not close any child by itself.
- Generated registry freshness is currently repaired, but it must be rechecked after any child status edits.
