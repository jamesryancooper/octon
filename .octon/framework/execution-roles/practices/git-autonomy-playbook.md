---
title: Git Autonomy Playbook
description: Worktree-native operator playbook for Octon's Git and GitHub workflow.
---

# Git Autonomy Playbook

This playbook describes Octon's durable Git/GitHub workflow for any
worktree-capable Git environment. The local helper scripts below are
recommended projections of that workflow, not prerequisites and not the sole
definition of readiness or mergeability.

The machine-readable workflow contract lives at
`.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`.
Treat that contract as the durable source of truth for operating model,
closeout contexts, remediation policy, helper semantics, and validation
scenarios.

For agent-driven autonomous closeout from a branch worktree, use the
`/closeout-pr` skill. It owns the full loop from task-scoped file review
through commit, draft PR, check remediation, review-thread remediation, ready
gate, and merge or explicit blocker.

This playbook covers the helper lane:

- `.octon/framework/execution-roles/_ops/scripts/git/git-wt-new.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-open.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-autonomy-hooks-install.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-autonomy-hooks-uninstall.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh`
- `.octon/framework/execution-roles/_ops/scripts/github/sync-github-labels.sh`

Use this with [GitHub Autonomy Runbook](./github-autonomy-runbook.md) for
token, permissions, and control-plane drift operations.

---

## Core Model

Octon's default work unit is a Change; branch worktrees are selected only for branch-no-pr or branch-pr routes.

- **Primary `main` worktree or clone**
  - Keep this clean.
  - Use it for `fetch`, `pull --ff-only`, repo-wide inspection, conflict
    investigation, and creating new branch worktrees.
  - Never open a PR from `main`.
- **Branch worktree**
  - One task or PR per worktree.
  - Do implementation, testing, review remediation, and PR iteration here.
  - Keep the same branch and same PR for the life of the task.
- **Shared invariants**
  - Do not stack unrelated tasks in one worktree.
  - Do not branch-hop inside a worktree for unrelated work.
  - Do not treat helper-script output as proof that a PR is complete.

---

## Preconditions

- Git supports linked worktrees or an equivalent worktree-capable interface.
- A clean primary `main` worktree or clone exists and is treated as the
  integration anchor.
- New work starts in a branch worktree, not on `main`.
- `gh auth status` is healthy for the target account when using GitHub helper
  commands.
- Branch naming and commit conventions remain governed by:
  - `.octon/framework/execution-roles/practices/standards/commit-pr-standards.json`
- Repository autonomy variables and secrets are configured for the autonomous
  lane:
  - `AUTONOMY_AUTO_MERGE_ENABLED=true`
  - `AUTONOMY_PAT` repository Actions secret
  - `AI_GATE_ENFORCE` mode matches desired rollout phase
  - `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` set before strict AI-gate mode

---

## Closeout Model

`Branch closeout` is the context-sensitive handoff from current implementation
state to the correct next Git/PR action. Depending on state, closeout may mean:

- branch the work off `main` into a feature worktree
- stage, commit, validate, receipt, and open a draft PR only for branch-pr
- mark a draft PR ready and request squash auto-merge
- mark a draft PR ready for human review with auto-merge off
- report blockers and continue implementation with no closeout mutation

`git-pr-ship.sh` is a helper for requesting the ready or merge-lane
transition. It reports status by default and uses explicit request flags for
ready or auto-merge transitions. It does not prove readiness. GitHub required
checks, review policy, and reviewer or maintainer confirmation remain the
final merge gate. In solo-maintainer repositories, reviewer-thread cleanup may
use the documented solo-maintainer exception after fix, commit, push, reply,
green required checks, and maintainer override evidence.

---

## Script Quick Reference

### 1. Create a branch worktree

```bash
.octon/framework/execution-roles/_ops/scripts/git/git-wt-new.sh \
  --type fix \
  --slug phase-e-local-autonomy-scripts
```

Behavior:

- Validates branch format against repository branch policy contract.
- Runs clean-state preflight (prune/sync/closed-branch cleanup) by default.
- Creates a new linked worktree in a sibling folder.
- Creates the branch from `main` (or `--base` override).
- Establishes branch-route isolation for one branch-routed Change.

### 2. Commit, validate, receipt, and publish when branch-pr

```bash
.octon/framework/execution-roles/_ops/scripts/git/git-pr-open.sh \
  --title "fix(github): tighten autonomy script defaults" \
  --summary "Adds safer defaults for local autonomy helper scripts." \
  --stage-all \
  --no-issue "operator-tooling"
```

Behavior:

- Commits staged changes, or stages everything when `--stage-all` is set.
- Pushes the current branch to `origin`.
- Builds the PR body from `.github/PULL_REQUEST_TEMPLATE.md`.
- Ensures issue-link policy with either `Closes #...` or `No-Issue: ...`.
- Opens a draft PR from the current branch. Later PR updates happen by pushing
  more commits to the same branch.

### 3. Report status or request a transition

Status-only helper:

```bash
.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh
```

Autonomous-lane helper:

```bash
.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh \
  --request-ready \
  --request-automerge
```

Manual-lane helper:

```bash
.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh --request-ready
```

Behavior:

- No-argument mode reports current PR status, lane hints, and blockers.
- `--request-ready` requests the ready-for-review transition when the PR is
  still draft.
- `--request-automerge` requests squash auto-merge on GitHub.
- `--wait` waits for closure and runs local cleanup when an auto-merge request
  was made.
- Requests a workflow transition, but does not decide whether the PR is truly
  complete or mergeable.

### 3A. Agent-driven autonomous closeout

Use `/closeout-pr` when the work has reached a credible completion point and
the process should continue autonomously until merge or a real external
blocker.

Core loop:

1. start from the current branch worktree
2. review tracked, unstaged, and untracked changes
3. stage the intended files only
4. commit, push, and create or update the draft PR
5. poll checks and unresolved conversations
6. if a check fails, inspect the run, apply the smallest credible fix,
   validate locally, commit, push, and recheck
7. if unresolved conversations remain, address them with
   `fix + commit + push + reply`
8. move out of draft only when checks are green, conversations are cleared,
   author action items are closed, and the lane is correct
9. request squash auto-merge for the autonomous lane, or keep the PR ready in
   the manual lane only when a concrete blocker requires authorized human
   action

### 4. Enforce local cleanup state on demand

```bash
.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh
```

Behavior:

- Deletes local branches whose latest PR is already closed or merged.
- Deletes matching origin branches when no open PR references the branch.
- Checks out and fast-forwards `main` to `origin/main`.
- Supports `--watch-pr <number>` to wait for closure, then clean branch state.
- Prunes safe linked worktree directories for closed branches automatically
  when possible.
- If the current worktree or a dirty or in-use linked worktree cannot be
  removed automatically, prints the exact manual `git worktree remove <path>`
  follow-up step.

### 5. Install non-blocking local cleanup hooks

```bash
.octon/framework/execution-roles/_ops/scripts/git/git-autonomy-hooks-install.sh
```

Behavior:

- Installs managed `post-merge` and `post-checkout` hooks.
- Triggers `.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh --no-sync-main`
  in the background.
- Uses lock and throttle controls to avoid duplicate runs.
- Skips safely when the working tree is dirty.

Uninstall:

```bash
.octon/framework/execution-roles/_ops/scripts/git/git-autonomy-hooks-uninstall.sh
```

### 6. Sync required GitHub labels

```bash
.octon/framework/execution-roles/_ops/scripts/github/sync-github-labels.sh
```

Behavior:

- Creates or updates triage and policy labels idempotently.
- Keeps color and description aligned with workflow expectations.

---

## Contextual Closeout Gate

Ask about closeout only at a credible completion point or when the operator
explicitly asks to finish, ship, or closeout. Do not ask after every
file-changing turn.

### Completion signals

- The current implementation slice is complete enough to hand off.
- Targeted validation for the current scope has run or the remaining gap is
  explicitly understood.
- No unresolved author action items remain for the current revision.
- The branch, worktree, and PR state are known.

### Suppress closeout prompts when

- active implementation is still continuing
- an open PR has red required checks
- unresolved author action items remain
- a ready PR is waiting on reviewer or maintainer confirmation of
  reviewer-owned threads, or on the documented solo-maintainer exception
  evidence needed to resolve them

### Standard prompt set

- **Primary `main` worktree**
  - "This work is on the main worktree, and Octon does not open PRs from
    `main`. Should I branch it into a feature worktree and prepare a draft
    PR?"
- **Branch worktree, no PR yet**
  - "This branch worktree looks ready for PR closeout. Should I stage,
    commit, validate, record a Change receipt, and open a draft PR only if
    branch-pr is selected?"
- **Branch worktree, existing draft PR, autonomous lane**
  - "This draft PR looks ready for Octon's autonomous merge lane. Should I
    mark it ready and request squash auto-merge?"
- **Branch worktree, existing draft PR, manual lane**
  - "This draft PR looks ready for the manual lane. Should I mark it ready for
    human review and keep auto-merge off?"
- **Blocked state**
  - No closeout prompt. Report blockers instead.

### Ready PR status responses

If the PR is already ready, report status instead of asking another closeout
question:

- already ready and waiting on required checks or GitHub auto-merge
- already ready and waiting on reviewer or maintainer confirmation, or on
  solo-maintainer exception evidence
- already ready in the manual lane and waiting on human review or merge

---

## Managing Multiple Active Worktrees

Use this workflow when you have several live worktrees in parallel and want to
land them through PRs without creating merge churn.

### Core Rule

Keep exactly one integration worktree on `main`, and treat every other
worktree as branch-only.

- Use the main worktree only for `git fetch`, `git pull --ff-only`,
  validation, and conflict inspection.
- Do not develop directly on `main`.
- In every new worktree, create or keep a real branch before doing additional
  work.

### Recommended Sequence

1. In each worktree, create or confirm a branch.

```bash
git checkout -b feat/<slug>
```

2. Check scope before opening anything:

```bash
git status --short
git diff --stat
```

3. Commit and push each branch worktree.
4. Open each PR as draft first.
5. Mark only merge-ready, non-overlapping PRs as ready.
6. Merge one overlapping PR at a time.
7. After each merge, refresh the `main` worktree first:

```bash
git fetch origin
git checkout main
git pull --ff-only
```

8. Rebase every remaining branch onto updated `main`.
9. Re-run validation in each rebased worktree.
10. Move the next PR to ready only after the rebase is clean.

### Queue Discipline

Keep a small operator queue for all active worktrees:

| Worktree | Branch | PR | Depends On | Status |
|---|---|---|---|---|
| `/path/to/worktree-a` | `feat/foo` | `#123` | `none` | `draft` |
| `/path/to/worktree-b` | `fix/bar` | `#124` | `#123` | `waiting-rebase` |

Minimum fields:

- worktree path
- branch name
- PR number or URL
- dependency order
- current status such as `draft`, `ready`, `merged`, or `waiting-rebase`

### When Parallel PRs Are Safe

It is safe to open multiple draft PRs in parallel when they are truly
independent.

Examples:

- distinct subsystems
- disjoint file sets
- no shared generated surfaces
- no shared control-plane files

### When To Serialize

Serialize merges when worktrees touch any of these:

- the same files
- the same subsystem or domain boundary
- generated or effective outputs
- shared control-plane files such as `instance/**`, `.github/**`, or
  governance surfaces

In those cases:

1. Merge the foundational or lower-risk PR first.
2. Rebase the dependent worktree branch.
3. Re-run validation.
4. Merge the next PR only after the rebase is green.

### Anti-Patterns

- Do not merge a worktree branch into local `main` first and then create a PR.
- Do not keep long-lived detached HEAD worktrees.
- Do not leave several overlapping PRs in ready-to-merge state at once.
- Do not merge `main` into feature branches; rebase them instead.
- Do not delete a worktree by hand when it still has an open PR; use normal
  closeout and cleanup flow first.

### Closeout Cadence

The safest rhythm is:

1. worktree branch
2. draft PR
3. merge one PR
4. refresh `main`
5. rebase remaining worktrees
6. validate
7. merge the next PR

This keeps merge conflicts local, review state legible, and branch cleanup
predictable.

---

## Lane Guidance

### Autonomous lane

1. Create a branch worktree with `git-wt-new.sh`.
2. Implement the change and run the current validation slice.
3. Open a draft PR with `git-pr-open.sh`.
4. Address review with `fix + commit + push + reply`.
5. Move to ready only when the work is complete, no unresolved author action
   items remain, and the PR is eligible for autonomous handling.
6. Use `git-pr-ship.sh --request-ready --request-automerge` to request ready
   plus squash auto-merge.
7. Let required checks and GitHub branch rules decide final merge safety.
8. Let cleanup enforcement converge local branch state and prune safe linked
   worktree directories, then handle any printed manual follow-up step.

For high-impact work, autonomous handling becomes elevated autonomy rather
than a manual default. Before requesting ready or auto-merge, explicitly
self-review the diff, policy impact, evidence, and rollback path. After the
merge request, watch until GitHub merges, fetch `origin/main`, prove the merged
result is present, and record final closeout evidence.

### Manual lane

Keep the PR in the manual lane only when the branch or change has a concrete
unresolved blocker that requires human judgment, credentials, authority, or
policy acceptance, including:

- `exp/*` branches
- live rulesets require an approval authority the agent cannot provide
- required checks fail for a reason the agent cannot safely fix
- review threads require product, security, legal, or architectural judgment
- live rulesets, secrets, permissions, credentials, or external service
  configuration would change outside approved scope
- rollback is unclear or unsafe
- required evidence, mergeability, or post-merge `origin/main` state cannot be
  proven
- policies conflict or authority is ambiguous

Do not escalate merely because the PR is high-impact. Escalation reports must
state the exact blocker, evidence gathered, attempted remediation, and smallest
human decision needed.

Manual-lane flow:

1. Keep the same branch worktree and same PR.
2. Open the PR as draft first and keep scope tight.
3. Use `git-pr-ship.sh --request-ready` only if you want helper-assisted
   ready-state transition. It does not substitute for human review or prove
   readiness.
4. Address review with new commits and replies, leaving reviewer-owned threads
   for reviewer or maintainer confirmation unless the documented
   solo-maintainer exception applies.
5. After merge or closure, converge `main`, allow cleanup to prune safe linked
   worktrees, and complete any printed manual follow-up step if needed.

---

## Safety and Exceptions

- Do not bypass required checks or branch rules via local scripts.
- Keep `main` clean; direct-main is allowed only for low-risk solo Changes with validation, receipt, and rollback.
- If a PR has red required checks or unresolved author action items, keep
  working instead of invoking closeout.
- Cleanup hooks are non-blocking and must not interrupt local work.
- Hooks intentionally skip execution when the working tree is dirty.
- If autonomy behavior regresses:
  1. Set `AUTONOMY_AUTO_MERGE_ENABLED=false`
  2. Keep triage and policy checks active
  3. Follow rollback guidance in
     [GitHub Autonomy Runbook](./github-autonomy-runbook.md)
