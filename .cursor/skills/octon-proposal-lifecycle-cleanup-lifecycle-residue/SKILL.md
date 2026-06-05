---
name: octon-proposal-lifecycle-cleanup-lifecycle-residue
description: Run the cleanup-lifecycle-residue bundle.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-05-18"
  updated: "2026-05-18"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Bash(git status) Bash(git diff) Bash(git fetch *) Bash(git checkout -b *) Bash(git add *) Bash(git commit *) Bash(git push *) Bash(git merge *) Bash(.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh *) Bash(.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh *) Bash(.octon/framework/assurance/runtime/_ops/scripts/proposal-lifecycle-residue-fingerprint.sh *) Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Program - Cleanup Lifecycle Residue

This route is the dedicated cleanup authority for residual worktree artifacts
left by a proposal program lifecycle run. It is separate from
`closeout-packet` and `closeout-program`; do not treat those closeout routes as
cleanup routes.

## Required Procedure

1. Inspect the dirty worktree and the lifecycle target.
2. Run `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
   first as classification evidence only. When the lifecycle `run_id` or
   `program_run_id` is available, pass it as `--active-run-id <run-id>` so
   current-run control and evidence artifacts are protected from cleanup. Do
   not invoke the helper with `--confirm`, `--authorize`, or `--authorization`
   from this route.
3. Delegate eligible local run-state cleanup candidates to
   `repo-hygiene-cleanup`. Actual deletion requires that route's classify-first
   flow plus explicit confirmation or a validating
   `repo-hygiene-cleanup-authorization-v1` receipt. Record the delegated
   cleanup evidence ref, authorization ref when present, cleanup outcome, and
   next-route condition.
4. Classify every changed or untracked path as active implementation work,
   valid lifecycle/proposal progress, cleanup-safe local residue, protected or
   referenced evidence, or ambiguous/manual-review residue.
5. Preserve protected, referenced, ambiguous, manual-review, user-owned, and
   active implementation artifacts.
6. Partition safe publishable cleanup, progress, and evidence sets into
   coherent `branch-no-pr` branches with focused Conventional Commits.
7. Push, land, clean up branches, and sync local main only when branch content
   is safe to publish.
8. If raw `.octon/state/**` control/evidence records or internal run logs are
   not safe to publish, do not widen disclosure or work around policy. Write a
   push-safe disposition receipt instead.
9. Rerun
   `.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh`
   for the relevant proposal program target before finishing.
10. Compute the lifecycle residue freshness digest with
   `.octon/framework/assurance/runtime/_ops/scripts/proposal-lifecycle-residue-fingerprint.sh --target <program_packet_path> --lifecycle proposal-program`
   and record that exact output in `residue_fingerprint`. Do not substitute
   the cleanup helper's `classification_digest`; it is a separate helper
   diagnostic, not the lifecycle receipt freshness digest.

## Receipt

Write `support/lifecycle-residue-cleanup.md` with at least:

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

Place these fields in the opening YAML receipt block. If cleanup candidates are
zero, active implementation work is intact, the proposal worktree classifier
reports `worktree_hygiene_verdict: pass`, and
`worktree_hygiene_foreign_path_count: 0`, retained protected or helper
manual-review state is local evidence and not a human approval pause. Record
`implementation_blocking: false`, `closeout_blocking: false`,
`archive_blocking: false`, `implementation_hygiene_verdict: pass`,
`publication_hygiene_verdict: pass`, and `remaining_blocker_class: none`.

The `residue_fingerprint` field must equal the current output of
`proposal-lifecycle-residue-fingerprint.sh` for the bound program target and
proposal-program lifecycle. Keep the cleanup helper's `classification_digest`
under a separate helper field when useful.

The receipt must record retained rationale, local-only recovery refs when raw
private artifacts are retained locally, and any remaining blocker class.
