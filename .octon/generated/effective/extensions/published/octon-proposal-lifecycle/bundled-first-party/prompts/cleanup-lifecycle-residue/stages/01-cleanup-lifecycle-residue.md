# Stage: Cleanup Lifecycle Residue

Act as the lifecycle residue cleanup agent for the bound proposal program
target. This route is separate from normal `closeout-packet` and
`closeout-program` semantics; do not widen closeout authority.

## Inputs

- `program_packet_path`: proposal program target.
- `run_id`: optional lifecycle run id that produced the residue.
- `blocked_child_id`: optional child whose closeout/archive preflight was
  blocked.
- `blocked_route_id`: optional child route blocked by worktree hygiene.

## Procedure

1. Inspect the dirty worktree and classify every changed or untracked path as:
   active implementation work, valid lifecycle/proposal progress,
   cleanup-safe local residue, protected or referenced evidence, or
   ambiguous/manual-review residue.
2. Run `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
   first as classification evidence only. When `run_id` or `program_run_id` is
   available, pass it as `--active-run-id <run-id>` so current-run control and
   evidence artifacts are protected from cleanup. Do not invoke the helper with
   `--confirm`, `--authorize`, or `--authorization` from this route.
3. Delegate eligible local run-state cleanup candidates to
   `repo-hygiene-cleanup`. Actual deletion requires that route's classify-first
   flow plus explicit confirmation or a validating
   `repo-hygiene-cleanup-authorization-v1` receipt. Record the delegated
   cleanup evidence ref, authorization ref when present, cleanup outcome, and
   next-route condition.
4. Never delete protected, referenced, ambiguous, manual-review, user-owned, or
   active implementation artifacts.
5. Do not include active implementation files in cleanup commits unless they are
   explicitly part of that closeout set.
6. Partition unrelated cleanup, progress, and evidence work into separate
   coherent `branch-no-pr` branches with focused Conventional Commits.
7. Push, land, clean up branches, and sync local main only when branch contents
   are safe to publish.
8. If raw `.octon/state/**` control/evidence records or internal run logs are
   not safe to publish, do not widen disclosure or retry by workaround. Instead,
   create a push-safe disposition receipt recording counts, classification,
   retained rationale, local-only recovery branch or commit refs, and remaining
   blockers.
9. Rerun
   `.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh`
   for the proposal program target before finishing.
10. Compute the lifecycle residue freshness digest with
   `.octon/framework/assurance/runtime/_ops/scripts/proposal-lifecycle-residue-fingerprint.sh --target <program_packet_path> --lifecycle proposal-program`
   and record that exact output in `residue_fingerprint`. Do not substitute
   the cleanup helper's `classification_digest`; that helper digest may be
   retained separately as helper evidence, but it is not the lifecycle receipt
   freshness digest.

## Required Receipt

Write `support/lifecycle-residue-cleanup.md` with:

- `verdict`
- `cleaned_at`
- `cleanup_candidates`
- `active_implementation_work_intact`
- `implementation_blocking`
- `closeout_blocking`
- `archive_blocking`
- `implementation_hygiene_verdict`
- `publication_hygiene_verdict`
- `manual_review_count`
- `worktree_hygiene_verdict`
- `remaining_blocker_class`
- `residue_fingerprint`

Place every required field in the opening YAML receipt block; completion
observers read top-level YAML fields from that block.
The `residue_fingerprint` field must equal the current output of
`proposal-lifecycle-residue-fingerprint.sh` for the bound program target and
proposal-program lifecycle. The cleanup helper's `classification_digest` is a
different diagnostic and must not be copied into `residue_fingerprint`.

The receipt must also name remaining manual-review classes and rationale, state
whether local main is synced with origin/main, and confirm active
implementation work remains intact.

Use phase-specific blocking semantics. If cleanup candidates are zero, active
implementation work is intact, the post-cleanup proposal worktree classifier
reports `worktree_hygiene_verdict: pass`, and
`worktree_hygiene_foreign_path_count: 0`, retained protected or helper
manual-review state is not a human blocker. Record the cleanup as retained but
passing:

```yaml
verdict: pass-retained
cleanup_candidates: 0
active_implementation_work_intact: yes
implementation_blocking: false
closeout_blocking: false
archive_blocking: false
implementation_hygiene_verdict: pass
publication_hygiene_verdict: pass
remaining_blocker_class: none
```

If cleanup candidates are zero and active implementation work is intact, but
the proposal worktree classifier reports blocked hygiene, nonzero foreign
paths, or unresolved ambiguous ownership outside the lifecycle target scope,
record the cleanup as implementation-safe and publication-blocking unless a
validated parent closeout-worktree handoff covers the current residue:

```yaml
verdict: blocked-retained
cleanup_candidates: 0
active_implementation_work_intact: yes
implementation_blocking: false
closeout_blocking: true
archive_blocking: true
implementation_hygiene_verdict: pass
publication_hygiene_verdict: blocked
remaining_blocker_class: worktree-hygiene-blocked
```

If a parent `lifecycle-interaction-return-v1` validates, its cited
`closeout-worktree-report-v1` validates, and the report is bound to the current
classifier digest or foreign fingerprint, residue fingerprint, cleanup receipt
context, non-mutating disposition, and retained path set with
`preserve-and-exclude-from-lifecycle-closeout-blocking`, record:

```yaml
worktree_hygiene_verdict: resolved-by-validated-parent-closeout-worktree-return
closeout_blocking: false
archive_blocking: false
remaining_blocker_class: none
cleanup_deletion_performed: false
repo_hygiene_cleanup_performed: false
cleaned_claim: false
archive_authorized: false
```

This handoff clears only the parent lifecycle closeout/archive-readiness
hygiene blocker. It does not authorize deletion, cleanup, archive relocation,
Git mutation, publication, promotion, cleaned claims, or child-owned evidence.

Do not collapse these fields into `worktree_hygiene_verdict`. The legacy
worktree hygiene verdict remains compatibility evidence; the phase-specific
fields decide whether child implementation, closeout, and archive may proceed.
Retained helper manual-review counts alone do not require human intervention
when the proposal worktree classifier has already classified the live worktree
as owned or in scope for the bound program run.

## Stop Conditions

Finish only when cleanup candidates are zero, all safe closeout sets are landed
or explicitly preserved with a receipt, remaining manual-review residue is
named by class and rationale, local main is synced when publishable work was
landed, and the post-cleanup hygiene classifier result is recorded.
