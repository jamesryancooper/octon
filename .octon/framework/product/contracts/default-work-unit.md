---
title: Change-First Default Work Unit
description: Canonical product contract for Octon's default work unit and Git/GitHub route selection.
status: active
---

# Change-First Default Work Unit

## Contract

Octon's default work unit is a Change.

A Change is the durable unit of intent, execution, evidence, validation,
review, rollback, and closeout. The compiled internal runtime bundle for a
Change is a Change Package. A Run Contract remains the authority for a material
run; neither a Change nor a Change Package authorizes material execution by
itself.

Pull Requests are optional publication and review outputs. They are selected
when a Change needs hosted review, external signoff, unresolved review
discussion, PR-required provider rules, collaboration, preview publication,
release automation, protected or high-impact work whose governing evidence
requires hosted review or remote validation, or when the operator explicitly
requests a PR.

Branches are isolation mechanisms. They are selected when a Change needs
isolation from `main`, pause/resume safety, multiple commits, handoff,
elevated-risk validation, protected-surface review, or when repository policy
requires branch-based handling.

When the operator asks for closeout, `direct-main` and `branch-no-pr` closeout
include an origin push by default. For `direct-main`, push `main` and verify
`origin/main` contains the recorded landed ref, then fetch and sync local
`main` to `origin/main` before declaring closeout complete. For `branch-no-pr`,
push the source branch for branch-publication closeout or complete the hosted
no-PR landing path when `landed` is claimed. After any `branch-no-pr` or
`branch-pr` work lands in `origin/main`, closeout also includes safe branch
cleanup or an explicit deferred-cleanup blocker, followed by a fetch, local
`main` sync, and proof that local `main`, `origin/main`, and the recorded
landed ref are aligned. Skipping the push or cleanup is allowed only for an
explicit local-only operator instruction or a concrete blocker, and the receipt
must not claim full hosted closeout.

For solo work, select the fastest safe route. Consider `direct-main` first
when the Change is low-risk, the operator is on clean current `main`, local
validation is sufficient, rollback is straightforward from the resulting
commit, durable history and Change receipt evidence can be recorded, and no
policy, repository protection, collaboration need, branch-isolation need, or
operator instruction requires a branch or PR.

Provider route-neutral capability is not itself a reason to choose
`branch-no-pr`. It is a hosted landing precondition after `branch-no-pr` is
selected for branch isolation and hosted no-PR landing is intended.

Change Package is the active internal execution-bundle name for pre-1.0 and
later target-state surfaces. No active compatibility alias, shim, parallel
schema, or duplicate compiler path is part of the target state.

## Routes

Maintainer quickstart:
`.octon/framework/execution-roles/practices/change-lifecycle-routing-quickstart.md`
provides the operator route matrix, live-vs-target ruleset table, and receipt
examples that make this contract executable for day-to-day closeout. This file
and `.octon/framework/product/contracts/default-work-unit.yml` remain the
authoritative policy.

Route selection starts from Change identity and chooses the execution or review
channel the Change needs. Target lifecycle outcome records what the operator or
agent is trying to achieve. Lifecycle outcome is recorded separately and
answers how far through closeout the Change actually progressed.

When the operator asks for `branch-no-pr` closeout and does not name a target
outcome, the agent must clarify whether the request is for pushed-branch
handoff, hosted no-PR landing, or cleaned closeout. If the target is `landed`
or `cleaned` but the actual result is only `published-branch`, the receipt must
record landing evaluation evidence, `closeout_outcome: continued`, and a
precise `not_landed_reason`. If the target is `cleaned` but cleanup cannot be
completed or explicitly deferred, the receipt must also record
`not_cleaned_reason`.

- `direct-main`: low-risk solo Change, locally validated, landed directly on
  current clean `main`, pushed to `origin`, with a Change receipt and rollback
  handle. If the push is blocked or the operator explicitly requests local-only
  handling, report closeout as incomplete or local-only; do not present it as
  full closeout.
- `branch-no-pr`: isolated Change that needs a branch or worktree but does not
  need PR-backed review or publication. This route can preserve state, complete
  locally on the branch, push the branch for backup or handoff, fast-forward
  land on hosted `main` without a PR when provider rules allow route-neutral
  updates, and clean up only when the receipt records evidence for that
  lifecycle outcome.
- `branch-pr`: PR-backed Change selected for hosted review, external signoff,
  unresolved review discussion, PR-required provider rules, publication, release
  automation, collaboration, protected or high-impact work whose governing
  evidence requires hosted review or remote validation, existing PR context, or
  explicit operator request.
- `stage-only-escalate`: blocked Change that preserves state and records the
  missing decision, validation, rollback, authorization, review, or ownership
  condition.

When route inputs conflict, the safer or more constrained route wins. Ambiguous
risk, ownership, validation, rollback, freshness, or authority routes fail
closed to `stage-only-escalate` unless a higher authority denies the action.

## Lifecycle Outcomes

Routes do not by themselves prove landing, publication, or cleanup. Every Change
receipt must separately record lifecycle outcome and status fields.

Branch-no-PR outcomes:

- `preserved`: patch, checkpoint, or branch state is recoverable; it is not
  committed, landed, or published unless additional evidence says so.
- `branch-local-complete`: intended scope is committed on the branch; it is not
  landed on `main`.
- `published-branch`: the branch is pushed for backup or handoff; no PR exists.
  This is a continued handoff outcome, not completed closeout. It can satisfy a
  handoff-only target, but it cannot satisfy a target outcome of `landed` or
  `cleaned` without a recorded blocker.
- `landed`: the branch Change is fast-forward integrated into hosted `main`
  without a PR, with provider ruleset evidence, exact source SHA validation,
  source branch push evidence, rollback handle, and post-push proof that
  `origin/main` equals the recorded landed ref. Full closeout after landing
  requires cleanup completion or an explicit deferred-cleanup blocker plus
  local `main` synchronized to `origin/main`.
- `cleaned`: local branch, remote branch when present, and worktree cleanup are
  complete or explicitly deferred with evidence.

PR-backed outcomes:

- `preserved`: branch state is recoverable but no usable PR exists yet.
- `published`: the branch is pushed and a PR exists.
- `ready`: required hosted checks and review gates are satisfied or blocked by
  a precise external condition. Autonomous draft completion may mark an open
  draft PR ready only when it is in the autonomous `branch-pr` lane, all
  required checks are green, `AI Review Gate / decision` is green when
  required, PR quality, branch naming, clean-state, and autonomy checks are
  green, no unresolved author-action review threads, blocking labels,
  requested changes, merge conflicts, or stale head state remain, and required
  Change receipt or PR closeout evidence is present. High-impact PRs also
  require explicit self-review of diff, policy impact, evidence, and rollback
  path, but high-impact classification alone is not a manual-lane outcome.
- `landed`: the PR is merged into `main` and `origin/main` is fetched and
  verified to contain the merged result. Full closeout after landing requires
  cleanup completion or an explicit deferred-cleanup blocker plus local `main`
  synchronized to `origin/main`.
- `cleaned`: local branch, remote branch, and worktree cleanup are complete or
  explicitly deferred with evidence.

A checkpoint, patch, or branch-local commit must never be reported as landed.
A draft or open PR must never be reported as full closeout. Landing requires a
target branch reference, landed ref, integration method, validation evidence,
rollback handle, and cleanup disposition.

For no-PR closeout, local landing alone is not enough when the operator asks to
close out the Change. `direct-main` closeout must push to `origin/main` and
verify the hosted branch contains the landed ref, then fetch and sync local
`main` to `origin/main`. `branch-no-pr` closeout must push the source branch to
origin or complete hosted no-PR landing; otherwise it is a local checkpoint or
blocker, not full closeout.

## Post-Landing Cleanup And Sync

When `branch-no-pr` or `branch-pr` work has landed in `origin/main`, branch
cleanup is part of Change closeout. After the source branch, PR branch, or
merge ref is verified as contained in `origin/main`:

1. Verify `origin/main` contains the landed commit or merge ref.
2. Verify required post-landing checks and closeout evidence are complete.
3. Delete only obsolete local and remote source branches that are safe to
   delete.
4. Do not delete protected branches, active work branches, unmerged branches,
   open-PR branches, or branches whose evidence and rollback posture are not
   retained.
5. If cleanup cannot be completed safely, record the precise blocker and
   cleanup disposition in the Change receipt.
6. After cleanup is complete or explicitly deferred, fetch from origin and sync
   local `main` to `origin/main`.
7. Verify local `main`, `origin/main`, and the recorded landed ref are aligned
   before declaring closeout complete.

For `direct-main`, there is no source-branch cleanup requirement, but closeout
still performs the post-push fetch and verifies local `main`, `origin/main`,
and the recorded landed ref are aligned after post-push checks complete.

## Durable History

Every completed Change requires durable history:

- Change identity and selected route.
- Target lifecycle outcome and final lifecycle outcome.
- Intent and scope.
- Touched paths or diff reference.
- Validation evidence at the selected floor.
- Review evidence or explicit waiver when required.
- Durable history reference: commit, patch, checkpoint, branch, or PR.
- Lifecycle outcome, integration status, publication status, and cleanup status.
- Rollback handle.
- Closeout outcome and remaining blockers.

When a receipt targets `landed` or `cleaned` but records a lower actual
outcome, durable history must include landing evaluation evidence plus
`not_landed_reason` or `not_cleaned_reason` as appropriate. A receipt that only
records a pushed source branch is a handoff receipt and must not be reported as
completed closeout.

PR-backed Changes may project this information into PR bodies and checks, but
the PR is not the authority source. No-PR Changes must retain equivalent local
validation, review or waiver, receipt, and rollback evidence.

## Gate Semantics

Validation and review gates attach to the Change.

GitHub checks, review threads, PR templates, and auto-merge workflows are valid
gate projections for PR-backed Changes. Route-neutral required checks may also
gate hosted no-PR landing, but the check evidence must attach to the exact
source SHA that is fast-forward pushed to `main`.

For `direct-main`, hosted protected-main checks do not convert the Change into
`branch-pr`. The route still starts from clean current `main`, local validation,
Change receipt evidence, and a rollback handle. If the receipt claims
`hosted-main-updated` or hosted protected-main checks were required for the
direct update, route-neutral check evidence must attach to the exact
`landed_ref`; PR metadata and PR-only checks are not required.

Local validation output, local review evidence, AI review evidence, explicit
waiver, and rollback evidence are valid gate projections for no-PR Changes when
the governing validation floor allows local proof. A no-PR branch checkpoint,
branch-local commit, or pushed-only branch is not hosted landing evidence.

If a provider ruleset currently requires a pull request for `main`, hosted
`branch-no-pr` landing is unavailable and the route must fail closed with a
blocker unless the operator explicitly selects a PR-backed route. Do not
silently convert `branch-no-pr` to `branch-pr`.

The target GitHub ruleset is route-neutral protected `main`: required status
checks, linear history, non-fast-forward protection, and deletion protection
remain universal, while universal PR-required merging is removed. Universal
checks must be runnable against the exact source SHA used for hosted no-PR
landing. PR-specific checks such as PR template quality and AI review gate
decisions remain behind `branch-pr` and must not be required for no-PR hosted
landing.

The route-neutral hosted check set is `route_neutral_closeout_validation`,
`branch_naming_validation`, `route_aware_autonomy_validation`, and
`exact_source_sha_validation`.

## Boundary Rules

- Do not treat a PR, branch, GitHub workflow, or Change Package as the product
  default work unit.
- Do not bypass required validation, evidence, review, approval, or rollback
  obligations by selecting a no-PR route.
- Do not claim a stage-only Change as landed or complete.
- Do not claim `published-branch`, `branch-local-complete`, `published`, or
  `ready` as completed closeout.
- Do not downgrade a target outcome of `landed` or `cleaned` without recording
  landing evaluation evidence and a precise blocker.
- Do not claim `branch-no-pr` as hosted landed unless `origin/main` equals the
  recorded landed ref after the fast-forward push.
- Do not claim full `branch-no-pr` or `branch-pr` closeout after landing while
  branch cleanup is still pending; cleanup must be completed or explicitly
  deferred with blocker evidence.
- Do not delete protected branches, active work branches, unmerged branches,
  open-PR branches, or branches whose evidence and rollback posture are not
  retained.
- Do not declare closeout complete until local `main`, `origin/main`, and the
  recorded landed ref are aligned after the final fetch/sync step.
- Do not open a PR unless `branch-pr` is selected.
- Do not choose `branch-no-pr` solely because the provider can support
  route-neutral hosted landing; direct-main remains the faster safe route for
  eligible low-risk solo Changes.
- Do not use proposal-local files as runtime or policy dependencies.
- Keep GitHub and host adapters projection-only. They may mirror status, but
  they do not mint authority.
