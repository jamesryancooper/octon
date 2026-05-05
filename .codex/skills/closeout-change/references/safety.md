---
title: Closeout Change Safety
---

# Safety

- Fail closed when route selection is ambiguous.
- Fail closed when the target lifecycle outcome is ambiguous and the next step
  would mutate hosted `main`, delete a branch, or overclaim completion.
- Preserve unrelated working tree changes.
- Do not stage files outside the intended Change scope.
- Do not bypass required validation, review, approval, evidence, or rollback
  requirements.
- Do not use GitHub state as authority.
- Do not report a checkpoint, patch, or branch-local commit as landed.
- Do not report a pushed-only no-PR branch as hosted landing.
- Do not report `published-branch`, `branch-local-complete`, `published`, or
  `ready` as completed closeout.
- Do not downgrade a target outcome of `landed` or `cleaned` to
  `published-branch` without recording landing evaluation evidence and a
  precise blocker.
- Do not attempt hosted no-PR landing when the provider ruleset requires PR;
  report a blocker instead.
- Do not silently convert a blocked `branch-no-pr` hosted landing into
  `branch-pr`.
- Do not report hosted no-PR landing unless exact source SHA checks passed and
  `origin/main` equals the recorded landed ref after the fast-forward push.
- Do not report a draft, open, or ready PR as full closeout.
- Do not claim cleanup unless local branch, remote branch when present, and
  worktree cleanup evidence exists or a deferred-cleanup record is written.
- Do not claim cleaned closeout when final local `main`, `origin/main`, and the
  recorded landed ref alignment cannot be proven.
- Do not retain proposal-local runtime dependencies.
