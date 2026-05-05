---
name: closeout-change
description: >
  Route-neutral Change closeout. Resolves Change identity, selects direct-main,
  branch-only, PR-backed, or stage-only/escalated route from the canonical
  default work unit policy, records lifecycle outcome and Change receipt
  requirements, and delegates to PR-specific closeout only when branch-pr is
  selected.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-05-01"
  updated: "2026-05-05"
skill_sets: [executor, collaborator, guardian, integrator]
capabilities: [external-dependent, stateful, safety-bounded, self-validating]
allowed-tools: Read Glob Grep Edit Bash(git status *) Bash(git diff *) Bash(git add *) Bash(git commit *) Bash(git push *) Bash(git rev-parse *) Bash(git branch *) Bash(git fetch *) Bash(git checkout *) Bash(git merge *) Bash(git ls-files *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-commit.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-push.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-land.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-required-checks-at-ref.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh *) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Closeout Change

Route-neutral closeout for Octon's default work unit: the Change.

## When to Use

Use this skill when a Change has reached a credible completion or checkpoint
point and the next output route has not already been selected.

Use `closeout-pr` only after this skill or another canonical authority has
selected `branch-pr`, or when the task starts from an existing PR context.

## Core Workflow

1. **Resolve Change** — Identify the Change intent, scope, touched paths, and
   existing branch or PR context.
2. **Select Route** — Load
   `.octon/framework/product/contracts/default-work-unit.yml` and select exactly
   one route: `direct-main`, `branch-no-pr`, `branch-pr`, or
   `stage-only-escalate`. For solo work, consider `direct-main` first when all
   direct-main predicates are satisfied and no branch or PR predicate applies.
3. **Resolve Target Outcome** — Resolve the requested lifecycle target before
   mutation: preservation, branch-local completion, pushed-branch handoff,
   hosted landing, cleaned closeout, PR publication, PR readiness, PR landing,
   blocker recording, or denial.
4. **Select Outcome** — Resolve actual lifecycle outcome separately from route
   and target:
   `preserved`, `branch-local-complete`, `published-branch`, `published`,
   `ready`, `landed`, `cleaned`, `blocked`, `escalated`, or `denied`.
5. **Validate Evidence** — Check the route-required validation, review or
   waiver, durable history, receipt, and rollback evidence.
6. **Act Or Preserve** — Complete the route-specific next step or preserve state
   and report blockers.
7. **Record Receipt** — Produce or update a Change receipt shaped by
   `.octon/framework/product/contracts/change-receipt-v1.schema.json`.
8. **Post-Landing Cleanup And Sync** — When `branch-no-pr` or `branch-pr` work
   has landed in `origin/main`, verify containment, complete safe branch
   cleanup or record a deferred-cleanup blocker, fetch origin, sync local
   `main` to `origin/main`, and verify local `main`, `origin/main`, and the
   recorded landed ref are aligned. For `direct-main`, fetch and sync local
   `main` after the push and post-push checks.
9. **Delegate PR** — Invoke `closeout-pr` only when the selected route is
   `branch-pr`.

## Boundaries

- Do not open a PR unless route selection returns `branch-pr`.
- Do not create a branch merely because a Change exists.
- Do not choose `branch-no-pr` solely because the provider can support
  route-neutral hosted landing; provider support is a hosted landing
  precondition, not a route-selection reason by itself.
- Do not treat a route as the requested lifecycle outcome. When the operator
  says `branch-no-pr` without stating handoff, landing, or cleanup intent, ask
  whether to stop at `published-branch`, attempt hosted no-PR landing, or
  attempt cleaned closeout before mutating hosted refs.
- If the target outcome is `landed` or `cleaned` and evidence only supports
  `published-branch`, record `published-branch` as a continued handoff with
  landing evaluation evidence and `not_landed_reason`; do not call it completed
  closeout.
- Do not claim direct-main completion without a commit, local validation
  evidence, Change receipt, rollback handle, push to `origin/main`, and proof
  that `origin/main` contains the landed ref plus post-push fetch/sync proof
  that local `main`, `origin/main`, and the landed ref align, unless the
  operator explicitly asks for local-only closeout or a concrete push blocker
  is reported.
- Do not claim `branch-no-pr` as `landed` without branch commit evidence, main
  integration evidence, landed ref, rollback handle, and cleanup disposition.
- When the operator asks for closeout and the selected route is `branch-no-pr`,
  push the source branch to origin for branch-publication closeout or complete
  hosted no-PR landing for `landed`. Without an origin push, report a local
  checkpoint, local-only result, or blocker instead of full closeout.
- For hosted `branch-no-pr` landing, run hosted no-PR landing preflight before
  mutation and require provider ruleset evidence, a pushed source branch, exact
  source SHA required checks, fast-forward-only update evidence, and proof that
  `origin/main` equals `landed_ref` after the push.
- After landed `branch-no-pr` or `branch-pr` work is merged, fast-forwarded, or
  otherwise verified as contained in `origin/main`, clean up obsolete local and
  remote source branches that are safe to delete. Never delete protected
  branches, active work branches, unmerged branches, open-PR branches, or
  branches whose evidence and rollback posture are not retained.
- If branch cleanup cannot be completed safely, keep the branch, record the
  exact blocker, and set cleanup disposition to deferred or blocked instead of
  claiming cleaned/full closeout.
- If the target outcome is `cleaned` and cleanup or local-main sync cannot be
  proven, record `not_cleaned_reason` and report continued, blocked, or
  escalated closeout instead of completed closeout.
- After cleanup is completed or explicitly deferred, fetch from origin, sync
  local `main` to `origin/main`, and verify local `main`, `origin/main`, and
  the recorded `landed_ref` are aligned before declaring closeout complete.
- If the provider ruleset requires PR for `main`, report a blocker for
  `branch-no-pr` hosted landing. Do not silently convert `branch-no-pr` to
  `branch-pr`; PR mutation requires selected route `branch-pr` or explicit
  operator reroute.
- Do not claim `branch-pr` as full closeout when the PR is only draft, open, or
  ready; full PR-backed closeout requires merge evidence or a precise external
  blocker.
- Do not treat stage-only evidence as completed durable history.
- Do not use proposal-local packet paths as runtime or policy dependencies.

## References

- [Phases](references/phases.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [I/O contract](references/io-contract.md)
- [Safety](references/safety.md)
- [Validation](references/validation.md)
- [Dependencies](references/dependencies.md)
