refresh_id: proposal-program-execution-resilience-current-code-refresh-20260706
refreshed_at: 2026-07-06T00:00:00Z
refresh_scope: parent-local-current-code-map
target_program: proposal-program-execution-resilience-and-supersession
verdict: partly-landed-with-real-gaps
child_authority_preserved: yes
parent_status: in-review
runtime_mutation_performed: no
generated_output_refreshed: no

# Current Code Refresh

## Boundary

This refresh compares the parent program goals against current repository code,
validators, and proposal-local state. It is parent-local coordination evidence
only.

It does not close, accept, archive, supersede, or implement any child packet.
Child manifests, promotion targets, receipts, validation verdicts, archive
metadata, and terminal outcomes remain child-owned. Generated proposal registry
entries remain derived-only.

## Summary

The program goals remain applicable, but the original four-child plan is no
longer a clean not-started implementation plan. Current code already contains
substantial loop-control, worktree-baseline, child-receipt-boundary, and
closeout-worktree handoff behavior.

The useful next action is not to run the old staged plan unchanged. The useful
next action is to reconcile the proposal lineage with current implementation:
mark already-landed behavior, identify validator-covered behavior, and route
remaining gaps through child-owned revision, closeout, or supersession paths.

## Goal Status Map

| Goal | Current status | Current code evidence | Validator coverage | Real gap |
| --- | --- | --- | --- | --- |
| Loop breaker: stop repeated recovery or cleanup when blocker evidence is unchanged. | Largely landed. The runtime has blocker ledgers, recovery progress fingerprints, route evidence fingerprints, recovery budgets, and unchanged cleanup fingerprint tests. | `lifecycle_program.rs` defines `BLOCKER_LEDGER_FILE`, `RECOVERY_DELTA_SUMMARY_FILE`, recovery budget snapshots, `ProgramBlockerLedger`, `ProgramRecoveryProgressFingerprint`, `parent_route_blocker_fingerprint`, `apply_recovery_progress_blockers`, and `apply_recovery_budget_blockers`. | Runtime tests include unchanged and changed cleanup fingerprint behavior, including `residue_cleanup_unchanged_fingerprint_is_not_redispatched` and `residue_cleanup_changed_fingerprint_allows_new_attempt`. Residue fingerprint behavior is also covered by `test-proposal-lifecycle-residue-fingerprint.sh`. | Child proposal status still says `in-review`; it has not been reconciled as landed, superseded, or still-open through child-owned lifecycle evidence. |
| Ownership baseline and leases: prove owned, leased, and foreign surfaces before mutation. | Partly landed. The runtime records a program worktree baseline and supports explicit dirty-start lease inputs with run-owned, leased, and foreign path partitioning. | `lifecycle_program.rs` defines `PROGRAM_WORKTREE_BASELINE_FILE`, `INPUT_WORKTREE_BASELINE_LEASE`, `INPUT_WORKTREE_BASELINE_LEASE_PATHS`, `ensure_program_worktree_baseline`, and `write_program_worktree_baseline_receipt`. The receipt records status fingerprint, isolation verdict, run-owned paths, leased paths, foreign paths, and non-authorizing child-boundary notices. | Runtime tests include `program_worktree_baseline_blocks_fresh_dirty_unleased_git_run` and `program_worktree_baseline_records_run_owned_leased_and_foreign_paths`. | The landed surface is a start-of-run baseline and dirty-start lease model. A full audit is still needed to prove every mutating proposal-program route has route-scoped write-lease enforcement, not just baseline gating. |
| Supersession rescue: freeze polluted runs, preserve child receipts, and move deliverables to a clean successor or normal Change closeout. | Partly landed. Registry-level supersession and replacement fields exist, child receipts remain child-owned, and delivery evidence records child receipt refs without parent substitution. | `lifecycle_program.rs` supports `supersession_evidence`, `replacement_child_id`, `successor_constraints`, direct child receipt refs, delivery handoff evidence, and `parent_summary_satisfies_child_receipts: false`. | Contract and validator coverage checks child receipt ownership and parent-summary non-substitution through lifecycle contract tests, readiness projection checks, delivery profile validation, delivery evidence index validation, and postmortem validation. | I did not find an explicit polluted-run freeze receipt/state or a complete clean successor-run creation path under that name. If this behavior now exists under another route, the child packet needs a child-owned evidence update. If not, this remains the main implementation gap. |
| Autonomous partition evidence: let `closeout-worktree` return non-mutating reports without authorizing cleanup or terminal claims. | Largely landed. `closeout-worktree` now defines proposal-program child and parent handoff authorizations for non-mutating reports. | `closeout-worktree/SKILL.md`, `references/io-contract.md`, and `references/validation.md` require `closeout-worktree-report-v1`, optional `lifecycle-interaction-return-v1`, proposal-program handoff authorization, parent handoff authorization, foreign fingerprints, exact path sets, child authority preservation, and forbidden mutation actions. | `validate-closeout-worktree-wrapper.sh` validates proposal-program handoff and parent handoff fields, exact authorized paths, digests, non-mutating disposition, and false forbidden actions. Tests cover closeout-worktree reports and partition-clean terminal closeout fixtures. | Remaining work is lineage reconciliation: the child packet should be revised or closed through its own route to reflect that the current durable implementation now appears to cover the original target. |

## Validator-Covered Surfaces

- `validate-closeout-worktree-wrapper.sh` validates non-mutating
  proposal-program handoff and parent handoff report structure, digest
  matching, exact authorized path sets, child-authority preservation, and
  forbidden mutation actions.
- `test-closeout-worktree-wrapper.sh` and
  `test-validate-proposal-packet-terminal-closeout.sh` exercise handoff,
  partition-clean, non-mutating, and no-cleaned-claim behavior.
- `test-pack-shape.sh` checks that proposal-program verification accepts
  validated parent closeout-worktree handoff and that program closeout keeps
  the handoff non-authorizing.
- `test-proposal-lifecycle-residue-fingerprint.sh` proves cleanup candidate
  path changes alter residue fingerprints while retained manual-review residue
  does not create cleanup fingerprint churn.
- `test-validate-lifecycle-contracts.sh` covers proposal-program child
  receipt ownership, parent-summary non-substitution, recovery policy shape,
  and supersession/replacement schema fields.
- `lifecycle_program.rs` unit tests cover repeated cleanup fingerprint
  behavior, worktree baseline blocking, worktree baseline partitioning,
  handoff unblocking, parent handoff stability, and child receipt boundaries.

## Remaining Real Gaps

1. Reconcile proposal lifecycle state. The parent and all four children still
   appear as `in-review` proposal lineage even though current code covers
   substantial parts of the original plan. This requires child-owned revision,
   closeout, archive, or supersession handling; the parent cannot do it for the
   children.
2. Prove or add polluted-run freeze semantics. Current code has supersession
   fields and child receipt carry-forward boundaries, but this refresh did not
   find a distinct polluted-run freeze receipt/state or clean successor-run
   creation path matching the original PR 3 goal.
3. Audit route-scoped write leases. The baseline and dirty-start lease model is
   present, but a route-by-route proof is still needed before claiming all
   mutating proposal-program routes are lease-gated.
4. Retain closeout-grade evidence before closing the parent. Generated proposal
   registry entries and proposal-local summaries are not retained runtime
   evidence. Parent closeout still needs the owning lifecycle receipts and
   validation evidence required by the child packets.
5. Refresh generated proposal registry only through the canonical generator if
   any later child-owned lifecycle revision changes statuses, archive
   disposition, or proposal registry shape.

## Recommendation

Keep the goals, but revise the implementation posture:

- treat loop breaker as likely implemented but needing child-owned lifecycle
  reconciliation;
- treat ownership baseline as partly implemented and requiring route-lease
  coverage proof;
- treat supersession rescue as partly implemented with polluted-run freeze as
  the main remaining design/implementation gap;
- treat closeout-worktree partition evidence as likely implemented, with
  remaining work focused on child-owned closeout evidence.
