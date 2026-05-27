---
title: Closeout Change Safety
---

# Safety

- Fail closed when route selection is ambiguous.
- Resolve a generic closeout request to `target_lifecycle_outcome: cleaned`;
  fail closed only when the operator's requested narrower target conflicts with
  the selected route or required proof.
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
  precise blocker plus `landing_stop_reason`.
- Do not attempt hosted no-PR landing when the provider ruleset requires PR;
  report a blocker instead.
- Do not silently convert a blocked `branch-no-pr` hosted landing into
  `branch-pr`.
- Do not treat a blocked direct-main push, GH013, required checks, or blocked
  hosted no-PR landing as a `branch-pr` predicate. Record `branch_pr_predicate`
  for initial `branch-pr` selection, or record route transition authority
  before changing routes.
- Do not report hosted no-PR landing unless exact source SHA checks passed and
  `origin/main` equals the recorded landed ref after the fast-forward push.
- Do not mutate hosted `origin/main` for no-PR landing unless a retained
  `branch-landing-authorization-v1` receipt validates against the current
  source ref and target pre-ref. This authorization is required evidence, not a
  bypass of platform, sandbox, or host safety controls.
- Do not report branch-based full closeout unless source-branch integration
  into `origin/main`, post-landing fetch, local `main` sync to `origin/main`,
  and landed-ref containment in both refs are recorded.
- Do not delete or prune local or remote source branch refs unless a retained
  `branch-cleanup-authorization-v1` receipt validates against the current
  source branch, landed ref, local `main`, `origin/main`, no-open-PR proof, and
  rollback/discard posture.
- Do not report a draft, open, or ready PR as full closeout.
- Do not claim cleaned closeout unless local branch, remote branch when present,
  and worktree cleanup evidence proves cleanup completed. Deferred cleanup must
  downgrade the actual outcome and record `not_cleaned_reason` plus
  `cleanup_stop_reason`.
- Do not claim cleaned closeout when final local `main`, `origin/main`, and the
  recorded landed ref alignment cannot be proven.
- Do not retain proposal-local runtime dependencies.
