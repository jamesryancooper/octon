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
release automation, protected or high-impact governance handling, or when the
operator explicitly requests a PR.

Branches are isolation mechanisms. They are selected when a Change needs
isolation from `main`, pause/resume safety, multiple commits, handoff,
elevated-risk validation, protected-surface review, or when repository policy
requires branch-based handling.

Direct-main is allowed only for low-risk solo Changes on a clean current
`main` when local validation, durable history, rollback, and Change receipt
requirements are satisfied and no policy, repository protection, collaboration
need, or operator instruction requires a branch or PR.

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
channel the Change needs. Lifecycle outcome is recorded separately and answers
how far through closeout the Change actually progressed.

- `direct-main`: low-risk solo Change, locally validated, landed directly on
  current clean `main`, with a Change receipt and rollback handle.
- `branch-no-pr`: isolated Change that needs a branch or worktree but does not
  need PR-backed review or publication. This route can preserve state, complete
  locally on the branch, push the branch for backup or handoff, fast-forward
  land on hosted `main` without a PR when provider rules allow route-neutral
  updates, and clean up only when the receipt records evidence for that
  lifecycle outcome.
- `branch-pr`: PR-backed Change selected for hosted review, external signoff,
  unresolved review discussion, PR-required provider rules, publication, release
  automation, collaboration, protected or high-impact governance handling,
  existing PR context, or explicit operator request.
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
- `landed`: the branch Change is fast-forward integrated into hosted `main`
  without a PR, with provider ruleset evidence, exact source SHA validation,
  source branch push evidence, rollback handle, and post-push proof that
  `origin/main` equals the recorded landed ref.
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
  verified to contain the merged result.
- `cleaned`: local branch, remote branch, and worktree cleanup are complete or
  explicitly deferred with evidence.

A checkpoint, patch, or branch-local commit must never be reported as landed.
A draft or open PR must never be reported as full closeout. Landing requires a
target branch reference, landed ref, integration method, validation evidence,
rollback handle, and cleanup disposition.

## Durable History

Every completed Change requires durable history:

- Change identity and selected route.
- Intent and scope.
- Touched paths or diff reference.
- Validation evidence at the selected floor.
- Review evidence or explicit waiver when required.
- Durable history reference: commit, patch, checkpoint, branch, or PR.
- Lifecycle outcome, integration status, publication status, and cleanup status.
- Rollback handle.
- Closeout outcome and remaining blockers.

PR-backed Changes may project this information into PR bodies and checks, but
the PR is not the authority source. No-PR Changes must retain equivalent local
validation, review or waiver, receipt, and rollback evidence.

## Gate Semantics

Validation and review gates attach to the Change.

GitHub checks, review threads, PR templates, and auto-merge workflows are valid
gate projections for PR-backed Changes. Route-neutral required checks may also
gate hosted no-PR landing, but the check evidence must attach to the exact
source SHA that is fast-forward pushed to `main`.

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
- Do not claim `branch-no-pr` as hosted landed unless `origin/main` equals the
  recorded landed ref after the fast-forward push.
- Do not open a PR unless `branch-pr` is selected.
- Do not use proposal-local files as runtime or policy dependencies.
- Keep GitHub and host adapters projection-only. They may mirror status, but
  they do not mint authority.
