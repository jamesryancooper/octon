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
allowed-tools: Read Glob Grep Edit Bash(git status *) Bash(git diff *) Bash(git add *) Bash(git commit *) Bash(git push *) Bash(git rev-parse *) Bash(git branch *) Bash(git fetch *) Bash(git checkout *) Bash(git merge *) Bash(git ls-files *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-commit.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-push.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-land.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-required-checks-at-ref.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-cleanup.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh *) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
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
   If direct-main is not eligible and the Change needs branch isolation, select
   `branch-no-pr` unless a concrete PR predicate is independently proven. Never
   infer `branch-pr` from branch isolation, high-impact scope,
   protected-surface scope, provider caution, blocked direct-main landing, or
   blocked hosted no-PR landing alone.
   Select Outcome by recording the actual lifecycle outcome only after the
   route-specific evidence is available.
   Route transition is separate from route selection: if the route changes
   after initial selection, record `initial_route`,
   `route_transition_reason`, `route_transition_authority`,
   `route_transition_authority_ref`, and
   `route_transition_evidence_refs` before taking route-specific actions.
5. **Safe Cleanup** — Remove only evidence-backed residue. Escalate on
   ambiguous ownership, user-owned work, protected branches, active branches,
   unmerged branches, open-PR branches, or missing rollback posture.
6. **Prepare Change Set** — Keep only the coherent accepted Change in the
   staged scope or branch. When a delegated worktree candidate has explicit
   include/exclude boundaries, branch isolation is required, and no candidate
   branch exists, create or select a task branch without asking for another
   partition decision; stage only the include paths and preserve every excluded,
   ambiguous, ignored, user-owned, generated-authority, input, control, or
   evidence path outside the candidate boundary.
7. **Validate** — Run the selected validation floor and route-specific checks.
8. **Hosted No-PR Checks And Landing** — For selected `branch-no-pr` hosted
   landing, require preflight, pushed source branch, exact source-SHA checks,
   governed landing authorization, fast-forward/update proof,
   `origin/main == landed_ref`, rollback handle, and final local sync.
9. **PR-Backed Delegation** — Invoke `closeout-pr` only when selected route is
   `branch-pr` and the receipt records matching
   `branch_pr_predicate_evidence`.
10. **Branch Cleanup** — For landed branch routes, prove `origin/main`
    containment, no-open-PR status, rollback/discard posture, governed cleanup
    authorization, and local/remote cleanup status.
11. **Receipt And Evidence** — Produce or update a Change receipt shaped by
    `.octon/framework/product/contracts/change-receipt-v1.schema.json`.
    Completed or cleaned claims require `stateful_closeout` evidence. Hosted or
    shared closeout claims also require publishable evidence receipt refs under
    `.octon/state/evidence/runs/skills/**`; local-private raw logs under
    `.octon/state/evidence/local/**` may be cited only by digest-backed local
    evidence refs inside a publishable receipt and do not satisfy the closeout
    claim by themselves.
12. **Final Verification** — Verify clean or documented retained residue and
    final local `main`, `origin/main`, and landed-ref alignment when claimed.
13. **Final Report** — Report the actual lifecycle outcome, blockers,
    validation, receipt, cleanup, rollback handle, and final sync.

## Routine Autonomy

For a generic closeout request, assume `target_lifecycle_outcome: cleaned`.
Do not pause to ask whether to partition an unambiguous dirty worktree
candidate, create the required branch, push the source branch, run hosted
no-PR preflight, emit landing authorization, land, emit cleanup authorization,
clean safe source refs, sync local `main`, or write the receipt when the
selected route, validation floor, rollback posture, policy, and helper
authorization checks all pass.

Ask only when there is real ambiguity or unsafe action: overlapping candidate
boundaries, unclear ownership, protected or active branches, unmerged or
open-PR branches, missing validation, missing rollback posture, provider rules
requiring PR, stale or denied authorization, runtime/sandbox/provider/host
approval denial, or cleanup outside a governed route.

## Boundaries

- Do not open a PR unless route selection returns `branch-pr`.
- Do not select `branch-pr` unless a concrete PR predicate is recorded with
  matching `branch_pr_predicate_evidence`; high-impact or protected scope alone
  is not a predicate.
- Do not create a branch merely because a Change exists.
- Do not choose `branch-no-pr` solely because the provider can support
  route-neutral hosted landing; provider support is a hosted landing
  precondition, not a route-selection reason by itself.
- Do not ask the operator to confirm routine `cleaned` progression after
  `branch-no-pr` has been selected and all route-specific preconditions,
  validation, rollback, landing authorization, cleanup authorization, and final
  sync proof are satisfied. Continue until `cleaned` is proven or a precise
  blocker requires downgrade.
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
  mutation, emit or reference a `branch-landing-authorization-v1` receipt, and
  require the mutating helper to validate that authorization before it can
  update `origin/main`. The authorization must bind provider ruleset evidence,
  a pushed source branch, exact source SHA required checks or explicit
  empty-check policy, the current target pre-ref, rollback/discard posture, and
  no-PR eligibility. It does not bypass platform, sandbox, or host safety
  controls.
- Post-Landing Cleanup And Sync: after landed `branch-no-pr` or `branch-pr` work is merged, fast-forwarded, or
  otherwise verified as contained in `origin/main`, clean up obsolete local and
  remote source branches only after emitting or referencing a validating
  `branch-cleanup-authorization-v1` receipt. Never delete protected branches,
  active work branches, unmerged branches, open-PR branches, or branches whose
  evidence and rollback posture are not retained.
- Branch cleanup authorization must prove the source branch changes are
  integrated into `origin/main`, local `main` is synchronized to `origin/main`,
  the recorded `landed_ref` is contained in both refs, the source branch is not
  protected, no open PR exists, rollback/discard posture is retained, cleanup
  policy allows the mutation, and host/platform safety controls are not
  bypassed.
- If branch cleanup authorization is missing, malformed, stale, denied, or
  mismatched, do not delete or prune refs. Report `landed`, `deferred`, or
  `blocked` with blocker evidence instead of `cleaned`.
- If branch cleanup cannot be completed safely, keep the branch, record the
  exact blocker, and set cleanup disposition to deferred or blocked instead of
  claiming cleaned/full closeout.
- `cleaned` is route-bound: it proves only the selected Change route cleanup,
  branch cleanup, retained residue, and sync requirements that this singular
  closeout owns. It does not assert global worktree hygiene. Unrelated or
  global local artifact residue must be routed through `closeout-worktree` or
  `repo-hygiene-cleanup`, and unresolved repo-hygiene cleanup candidates block
  a full-worktree cleanliness claim.
- Closeout evidence generated after route cleanup and landing is outside the
  already-landed Change route. When a wrapper-level Git-clean terminal state is
  required, that evidence must be retained, blocked, or routed as a separate
  singular Change rather than folded into the completed route receipt.
- Eligible local Octon run/artifact residue is not branch cleanup. Route it to
  `repo-hygiene-cleanup` and its validating
  `repo-hygiene-cleanup-authorization-v1` receipt flow; generated run-health
  projections remain generator-owned and stale detached Git worktrees require
  explicit Git worktree cleanup proof.
- If the target outcome is `cleaned` and cleanup or local-main sync cannot be
  proven, record `not_cleaned_reason` and `cleanup_stop_reason`, then report a
  lower actual outcome such as `landed`, `deferred`, or `blocked` instead of
  completed cleaned closeout.
- If a target of `landed` or `cleaned` stops before `origin/main` mutation,
  record `landing_stop_reason` with `not_landed_reason`. Use
  `runtime_approval_denied` only when Octon governance authorization exists and
  validates but the runtime, sandbox, provider, or host approval boundary still
  refuses the mutation.
- Branch-based `landed` or `cleaned` full closeout requires receipt evidence
  that the source branch changes are integrated into `origin/main`; a
  post-landing fetch occurred; local `main` was updated to match
  `origin/main`; the recorded `landed_ref` is contained in both local `main`
  and `origin/main`; and branch cleanup is completed with governed cleanup
  authorization when claiming `cleaned`.
- After cleanup is completed, fetch from origin, sync local `main` to
  `origin/main`, verify local `main`, `origin/main`, and the recorded
  `landed_ref` are aligned, and record containment evidence before declaring
  branch-based cleaned closeout complete. Deferred cleanup is a lower actual
  outcome, not `cleaned`.
- If the provider ruleset requires PR for `main`, report a blocker for
  `branch-no-pr` hosted landing. Do not silently convert `branch-no-pr` to
  `branch-pr`; PR mutation requires selected route `branch-pr` with
  `branch_pr_predicate` and `branch_pr_predicate_evidence`, or explicit
  operator/policy reroute recorded through route transition authority.
- A blocked direct-main push, GH013, required checks, or blocked hosted
  no-PR landing is not itself a `branch-pr` predicate.
- Do not claim `branch-pr` as full closeout when the PR is only draft, open, or
  ready; full PR-backed closeout requires merge evidence or a precise external
  blocker.
- Do not treat stage-only evidence as completed durable history.
- Do not claim completed or cleaned closeout without `stateful_closeout`
  receipt evidence from the Change Closeout State Machine.
- Do not claim hosted/shared closeout, including hosted `branch-no-pr`
  `cleaned`, from raw repo-hygiene logs or local-private evidence. Require
  publishable evidence receipt refs and keep raw local helper output outside
  hosted/shared closeout payloads.
- Do not use proposal-local packet paths as runtime or policy dependencies.
- A `lifecycle-interaction-request-v1` may provide scoped advisory context for
  why Change Closeout was requested, but it is not landing, cleanup, hosted,
  rollback, scope, validation, or closeout authority. Continue to require the
  Change receipt, landing authorization, cleanup authorization, hosted checks,
  rollback posture, exact SHA evidence, final sync, and target-owned gates
  before claiming any lifecycle outcome.

## References

- [Phases](references/phases.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [I/O contract](references/io-contract.md)
- [Safety](references/safety.md)
- [Validation](references/validation.md)
- [Dependencies](references/dependencies.md)
