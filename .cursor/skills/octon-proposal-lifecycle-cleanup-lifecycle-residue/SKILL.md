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
allowed-tools: Read Glob Grep Bash(git status) Bash(git diff) Bash(git fetch *) Bash(git checkout -b *) Bash(git add *) Bash(git commit *) Bash(git push *) Bash(git merge *) Bash(.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh *) Bash(.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh *) Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Octon Proposal Lifecycle: Cleanup Lifecycle Residue

This route is the dedicated cleanup authority for residual worktree artifacts
left by a proposal program lifecycle run. It is separate from
`closeout-packet` and `closeout-program`; do not treat those closeout routes as
cleanup routes.

## Required Procedure

1. Inspect the dirty worktree and the lifecycle target.
2. Run `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
   first. Remove only helper-classified cleanup candidates.
3. Classify every changed or untracked path as active implementation work,
   valid lifecycle/proposal progress, cleanup-safe local residue, protected or
   referenced evidence, or ambiguous/manual-review residue.
4. Preserve protected, referenced, ambiguous, manual-review, user-owned, and
   active implementation artifacts.
5. Partition safe publishable cleanup, progress, and evidence sets into
   coherent `branch-no-pr` branches with focused Conventional Commits.
6. Push, land, clean up branches, and sync local main only when branch content
   is safe to publish.
7. If raw `.octon/state/**` control/evidence records or internal run logs are
   not safe to publish, do not widen disclosure or work around policy. Write a
   push-safe disposition receipt instead.
8. Rerun
   `.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh`
   for the relevant proposal program target before finishing.

## Receipt

Write `support/lifecycle-residue-cleanup.md` with at least:

- `verdict`
- `cleaned_at`
- `cleanup_candidates`
- `manual_review_count`
- `worktree_hygiene_verdict`
- `remaining_blocker_class`
- `residue_fingerprint`

The receipt must record retained rationale, local-only recovery refs when raw
private artifacts are retained locally, and any remaining blocker class.
