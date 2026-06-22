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
  hosted no-PR landing as a `branch-pr` predicate. Record
  `branch_pr_predicate` and matching `branch_pr_predicate_evidence` for initial
  `branch-pr` selection, or record route transition authority before changing
  routes.
- Do not infer `branch-pr` from branch isolation, high-impact scope,
  protected-surface scope, or provider caution alone.
- Do not report hosted no-PR landing unless exact source SHA checks passed and
  `origin/main` equals the recorded landed ref after the fast-forward push.
- Do not mutate hosted `origin/main` for no-PR landing unless a retained
  `branch-landing-authorization-v1` receipt validates against the current
  source ref and target pre-ref. This authorization is required evidence, not a
  bypass of platform, sandbox, or host safety controls.
- Do not report branch-based full closeout unless source-branch integration
  into `origin/main`, post-landing fetch, local `main` sync to `origin/main`,
  and landed-ref containment in both refs are recorded.
- Do not emit or accept terminal current-state proof as a source-branch commit
  requirement after landing, or as a mutation of `origin/main`, local `main`,
  the landed ref, or the source branch.
- Do not claim terminal success or `cleaned` unless terminal proof is emitted
  after landing evidence, final sync proof, cleanup authorization, cleanup
  disposition, rollback posture, and validation proof exist, with
  `landed_ref` distinct from the proof sink or receipt path.
- Do not delete or prune local or remote source branch refs unless a retained
  `branch-cleanup-authorization-v1` receipt validates against the current
  source branch, landed ref, local `main`, `origin/main`, no-open-PR proof, and
  rollback/discard posture.
- Do not retry or reinterpret a failed permission-sensitive git mutation
  without retained diagnostics that name the operation class, current and
  target refs when known, expected authorization gate, likely sandbox, host,
  provider, remote, or ref-write blocker, and owning rerun route.
- Do not treat git mutation diagnostics as authority to fetch, checkout,
  commit, push, land, sync, clean up, delete or prune branches, publish, close
  out, or claim `cleaned`.
- Do not report a draft, open, or ready PR as full closeout.
- Do not claim cleaned closeout unless local branch, remote branch when present,
  and worktree cleanup evidence proves cleanup completed. Deferred cleanup must
  downgrade the actual outcome and record `not_cleaned_reason` plus
  `cleanup_stop_reason`.
- Do not claim cleaned closeout when final local `main`, `origin/main`, and the
  recorded landed ref alignment cannot be proven.
- Do not retain proposal-local runtime dependencies.
