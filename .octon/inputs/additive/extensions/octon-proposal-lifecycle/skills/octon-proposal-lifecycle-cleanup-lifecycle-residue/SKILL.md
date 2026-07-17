---
name: octon-proposal-lifecycle-cleanup-lifecycle-residue
description: Classify and preserve lifecycle residue without cleanup effects during RP-00.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-05-05"
  updated: "2026-07-14"
skill_sets: [guardian, specialist]
capabilities: [safety-bounded, self-validating]
allowed-tools: Read Glob Grep Bash(git status) Bash(git diff) Bash(.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh *) Bash(.octon/framework/assurance/runtime/_ops/scripts/proposal-lifecycle-residue-fingerprint.sh *) Write(/.octon/state/evidence/runs/skills/*)
---

# Program - Classify And Preserve Lifecycle Residue

RP-00 converts this route to non-mutating classification and preservation.
It is not cleanup authority.

1. Inventory and classify the scoped worktree read-only.
2. Preserve protected, referenced, ambiguous, manual-review, user-owned, active
   implementation artifacts, control state, evidence, refs, branches,
   worktrees, rollback handles, and unrelated work.
3. Record a digest-bound classification and later owner; do not delegate to
   `repo-hygiene-cleanup`, Change closeout, or a Git/GitHub route.
4. Emit `RP00_CONTAINMENT_PUBLICATION_DISABLED`,
   `cleanup_deletion_performed: false`, `repo_hygiene_cleanup_performed: false`,
   and `cleaned_claim: false` for any cleanup request.

Do not invoke cleanup-local-run-artifacts.sh, delete/reset/stage/commit/push,
publish, archive, land, sync, prune, remove worktrees, or mutate refs. A
compatibility `support/lifecycle-residue-cleanup.md` receipt may record
`cleaned_at`, `cleanup_candidates`, `manual_review_count`,
`worktree_hygiene_verdict`, `remaining_blocker_class`, and
`residue_fingerprint`, but it is classification evidence only and cannot claim
cleanup success. RP-08 is the later cleanup owner.
