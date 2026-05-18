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
   first. Use its classification and remove only helper-classified cleanup
   candidates.
3. Never delete protected, referenced, ambiguous, manual-review, user-owned, or
   active implementation artifacts.
4. Do not include active implementation files in cleanup commits unless they are
   explicitly part of that closeout set.
5. Partition unrelated cleanup, progress, and evidence work into separate
   coherent `branch-no-pr` branches with focused Conventional Commits.
6. Push, land, clean up branches, and sync local main only when branch contents
   are safe to publish.
7. If raw `.octon/state/**` control/evidence records or internal run logs are
   not safe to publish, do not widen disclosure or retry by workaround. Instead,
   create a push-safe disposition receipt recording counts, classification,
   retained rationale, local-only recovery branch or commit refs, and remaining
   blockers.
8. Rerun
   `.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh`
   for the proposal program target before finishing.

## Required Receipt

Write `support/lifecycle-residue-cleanup.md` with:

- `verdict`
- `cleaned_at`
- `cleanup_candidates`
- `manual_review_count`
- `worktree_hygiene_verdict`
- `remaining_blocker_class`
- `residue_fingerprint`

The receipt must also name remaining manual-review classes and rationale, state
whether local main is synced with origin/main, and confirm active
implementation work remains intact.

## Stop Conditions

Finish only when cleanup candidates are zero, all safe closeout sets are landed
or explicitly preserved with a receipt, remaining manual-review residue is
named by class and rationale, local main is synced when publishable work was
landed, and the post-cleanup hygiene classifier result is recorded.
