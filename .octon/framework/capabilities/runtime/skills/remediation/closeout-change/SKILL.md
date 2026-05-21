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

Use `closeout-worktree` when the operator asks to close out a dirty worktree or
multiple local change sets. `closeout-worktree` must decompose the work into
singular `closeout-change` runs rather than replacing the Change default work
unit.

Use `closeout-pr` only after this skill or another canonical authority has
selected `branch-pr`, or when the task starts from an existing PR context.

## Core Workflow

Execute the Change Closeout State Machine phase loop from
`.octon/framework/product/contracts/change-closeout-state-machine.yml`.

1. **Read In And Bind Constraints** — Load the default work unit policy, state
   machine, Change receipt schema, Git/worktree contract, and current
   repository state.
2. **Inventory** — Capture branch, HEAD, `main`, `origin/main`, staged,
   unstaged, untracked, ignored, branch, remote, and worktree state.
3. **Classify Residue** — Classify staged, unstaged, untracked, ignored,
   generated, host-projection, evidence, release, input-surface, and branch
   residue. Detection alone is not deletion authority.
4. **Resolve Route And Target Outcome** — Resolve Target Outcome after selecting exactly one route from
   `.octon/framework/product/contracts/default-work-unit.yml`; resolve the
   target lifecycle outcome separately from the route. When the operator asks to
   close out the Change without naming a narrower target, set
   `target_lifecycle_outcome: cleaned`.
   Select Outcome by recording the actual lifecycle outcome only after the
   route-specific evidence is available.
5. **Safe Cleanup** — Remove only evidence-backed residue. Escalate on
   ambiguous ownership, user-owned work, protected branches, active branches,
   unmerged branches, open-PR branches, or missing rollback posture.
6. **Prepare Change Set** — Keep only the coherent accepted Change in the
   staged scope or branch.
7. **Validate** — Run the selected validation floor and route-specific checks.
8. **Hosted No-PR Checks And Landing** — For selected `branch-no-pr` hosted
   landing, require preflight, pushed source branch, exact source-SHA checks,
   fast-forward/update proof, `origin/main == landed_ref`, rollback handle, and
   final local sync.
9. **PR-Backed Delegation** — Invoke `closeout-pr` only when selected route is
   `branch-pr`.
10. **Branch Cleanup** — For landed branch routes, prove `origin/main`
    containment, no-open-PR status, rollback/discard posture, and local/remote
    cleanup status.
11. **Receipt And Evidence** — Produce or update a Change receipt shaped by
    `.octon/framework/product/contracts/change-receipt-v1.schema.json`.
    Completed or cleaned claims require `stateful_closeout` evidence.
12. **Final Verification** — Verify clean or documented retained residue and
    final local `main`, `origin/main`, and landed-ref alignment when claimed.
13. **Final Report** — Report the actual lifecycle outcome, blockers,
    validation, receipt, cleanup, rollback handle, and final sync.

## Boundaries

- Do not open a PR unless route selection returns `branch-pr`.
- Do not create a branch merely because a Change exists.
- Do not choose `branch-no-pr` solely because the provider can support
  route-neutral hosted landing; provider support is a hosted landing
  precondition, not a route-selection reason by itself.
- Do not treat a route as the requested lifecycle outcome. When the operator
  asks to close out a Change without explicitly requesting a narrower target
  such as `published-branch`, `branch-local-complete`, `landed`, `preserved`,
  or `blocked`, and without explicitly requesting the `stage-only-escalate`
  route, default `target_lifecycle_outcome` to `cleaned` before mutating hosted
  refs.
- If the target outcome is `landed` or `cleaned` and evidence only supports
  `published-branch`, record `published-branch` as a continued handoff with
  landing evaluation evidence and `not_landed_reason`; do not call it completed
  closeout.
- If the default or explicit target outcome is `cleaned` and evidence only
  supports a lower actual outcome, record the lower route-compatible
  `lifecycle_outcome`, `closeout_outcome: continued`, `blocked`, or `escalated`,
  and the exact `not_landed_reason`, `not_cleaned_reason`, blocker, or
  next-route condition.
- `branch-local-complete` and `published-branch` are continuation or handoff
  outcomes only. They must report `closeout_outcome: continued`, `blocked`, or
  escalated/denied as appropriate, never completed.
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
- Post-Landing Cleanup And Sync: after landed `branch-no-pr` or `branch-pr` work is merged, fast-forwarded, or
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
- Branch-based `landed` or `cleaned` full closeout requires receipt evidence
  that the source branch changes are integrated into `origin/main`; a
  post-landing fetch occurred; local `main` was updated to match
  `origin/main`; the recorded `landed_ref` is contained in both local `main`
  and `origin/main`; and branch cleanup is completed or explicitly deferred
  with blocker evidence.
- After cleanup is completed or explicitly deferred, fetch from origin, sync
  local `main` to `origin/main`, verify local `main`, `origin/main`, and the
  recorded `landed_ref` are aligned, and record containment evidence before
  declaring branch-based closeout complete.
- If the provider ruleset requires PR for `main`, report a blocker for
  `branch-no-pr` hosted landing. Do not silently convert `branch-no-pr` to
  `branch-pr`; PR mutation requires selected route `branch-pr` or explicit
  operator reroute.
- Do not claim `branch-pr` as full closeout when the PR is only draft, open, or
  ready; full PR-backed closeout requires merge evidence or a precise external
  blocker.
- Do not treat stage-only evidence as completed durable history.
- Do not claim completed or cleaned closeout without `stateful_closeout`
  receipt evidence from the Change Closeout State Machine.
- Do not use proposal-local packet paths as runtime or policy dependencies.

## References

- [Phases](references/phases.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [I/O contract](references/io-contract.md)
- [Safety](references/safety.md)
- [Validation](references/validation.md)
- [Dependencies](references/dependencies.md)
