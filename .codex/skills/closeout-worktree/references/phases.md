---
title: Closeout Worktree Phases
---

# Phases

1. Load the default work unit policy, Change Closeout State Machine,
   Git/worktree autonomy contract, `closeout-change`, and `closeout-pr`.
2. Capture worktree inventory for branch, HEAD, `main`, `origin/main`, staged,
   unstaged, untracked, ignored, branch, and remote state.
3. Run `.octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh`
   in read-only mode and retain the classifier output or summary reference.
   For proposal lifecycle residue, consume
   `.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh`
   partitions as read-only routing evidence:
   `publishable_changes`, `publishable_closeout_evidence`,
   `cleanup_safe_local_residue`, `protected_retained_evidence`,
   `protected_active_control_state`, and
   `manual_review_foreign_ambiguous_unsafe_or_user_owned`.
4. Partition residue into candidate Change scopes. Each candidate must have a
   coherent intent, path set, ownership posture, likely route, target lifecycle
   outcome, validation floor, and rollback or discard posture. For a generic
   worktree closeout request, default candidate target outcomes to `cleaned`
   unless a narrower target is explicit. When these facts are unambiguous,
   partition autonomously instead of asking the operator to choose the first
   candidate.
5. Mark every observed item as one of: selected candidate, later candidate,
   retained evidence, generated projection, host projection, local ignored
   residue, blocked, ambiguous, or foreign/user-owned.
6. Select exactly one candidate for the next singular closeout. Multiple
   candidates alone is not a blocker. Stop before delegation only when the
   selected candidate itself has a candidate-keyed blocker, or when several
   candidates are equally plausible for the same residue and cannot be safely
   separated.
7. Invoke or hand off to `closeout-change` for the selected candidate using
   explicit include and exclude path boundaries.
8. Delegate eligible local Octon run/artifact residue to
   `repo-hygiene-cleanup`; route generated run-health projections to the
   run-health generator; delegate temporary proposal fixture candidates to
   `fixture-retention-closeout`; retain or block any detached worktree residue
   until Git worktree cleanup proof is available. Do not delete any of these
   classes directly from the wrapper. Classifier partitions do not authorize
   deletion, branch cleanup, archive, promotion, publication, closeout, or a
   `cleaned` claim.
9. Re-run inventory and residue classification after the singular closeout
   completes, blocks, or escalates.
10. Repeat candidate selection when the next candidate is coherent and safely
   separable. Re-inventory and re-classify after every `closeout-change` run
   before selecting that next candidate. If generic worktree closeout targets
   `cleaned` and only unambiguous closeout evidence residue remains under
   retained evidence roots, route that residue as the next singular
   `closeout-change` candidate.
11. Write a wrapper report that records closed Changes, retained candidates,
    blockers, escalations, validation evidence, `worktree_terminal_state`, and
    the next route condition.
12. When a wrapper report summarizes branch-no-pr terminal proof, cite the
    delegated `closeout-change` receipt and retained sink evidence only after
    that receipt proves landing evidence, final sync proof, cleanup
    authorization, cleanup disposition, rollback posture, and validation proof.
    The wrapper must keep `landed_ref` distinct from the proof sink or receipt
    path and must not perform or imply any terminal-proof ref mutation.
13. When a delegated `closeout-change` run records permission diagnostics for a
    blocked git mutation, summarize them only as delegated routing evidence.
    The summary must preserve operation class, current and target refs when
    known, expected authorization gate, likely blocker, and owning rerun route;
    the wrapper must not perform or authorize the retry, cleanup, landing,
    branch deletion, final sync, closeout, or `cleaned` claim.

Detection alone is not deletion authority. This wrapper must partition residue into singular Change closeouts and coordinate those closeouts; it does not authorize cleanup outside singular Change closeout.
