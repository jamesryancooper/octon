# Current-State Gap Map

## Summary

| Concept | Current Octon evidence | Coverage status | Gap type(s) | Operational risk if left as-is | Final disposition |
|---|---|---|---|---|---|
| Worktree-capable operator model | `git-wt-new.sh`, `git-pr-open.sh`, `git-autonomy-playbook.md`, `git-github-autonomy-workflow-v1.md` | partially_covered | environment_overfit; prose_drift | medium — the repo has the right primitives, but the durable story still leans too heavily on one operator environment | adapt |
| Contextual closeout gate | `/.octon/instance/ingress/manifest.yml`, `/.octon/instance/ingress/AGENTS.md` | under_covered | scalar_contract; missing_context_model | high — the current fixed prompt does not encode worktree or PR state | adapt |
| Review remediation semantics | `pull-request-standards.md`, `github-control-plane-contract.json`, remediation skill, PR template | partially_covered | contradictory_wording; reviewer_resolution_conflict | high — merge-blocking thread resolution can be misunderstood as author-side self-resolution | adapt |
| Helper-script readiness and cleanup semantics | `git-pr-ship.sh`, `git-pr-cleanup.sh`, workflow docs | partially_covered | helper_vs_policy_mismatch; incomplete_housekeeping | medium — the current helper can be overread as proof of readiness, and worktree directory cleanup is not first-class | adapt |

## Detailed gaps

### 1. Worktree-capable operator model

**What exists now**

- `git-wt-new.sh` already creates branch worktrees from `main`.
- `git-pr-open.sh` already rejects `main` and defaults to draft PR creation.
- `git-autonomy-playbook.md` already distinguishes `main` from branch
  worktrees.

**Why that is not yet enough**

- The durable story still includes an environment-specific operating model that
  does not generalize cleanly.
- The repo needs one abstract definition that works whether the operator uses
  Codex App, a plain terminal, or another worktree-capable Git environment.

### 2. Contextual closeout gate

**What exists now**

- Ingress manifest exposes `branch_closeout_prompt`.
- Ingress `AGENTS.md` says to ask the same question after every file-changing
  turn.

**Why that is not yet enough**

- A single scalar prompt cannot distinguish:
  - `main` versus branch worktree
  - no PR versus draft PR versus ready PR
  - autonomous lane versus manual lane
  - blocked versus actually ready

### 3. Review remediation semantics

**What exists now**

- `pull-request-standards.md` says unresolved review conversations block merge.
- The remediation skill says not to resolve other people's comments.
- `github-control-plane-contract.json` requires review-thread resolution.

**Why that is not yet enough**

- The current PR template still implies that the author can satisfy the review
  state by resolving every conversation.
- The durable model needs a stronger distinction between:
  - author-side duties: fix, commit, reply
  - reviewer or maintainer duties: resolve reviewer-owned threads

### 4. Helper-script readiness and cleanup semantics

**What exists now**

- `git-pr-ship.sh` marks draft PRs ready and requests auto-merge by default.
- `git-pr-cleanup.sh` already handles branch and ref convergence.

**Why that is not yet enough**

- The helper default is eager enough that operators can mistake it for a
  readiness oracle.
- Cleanup is strong on refs but weaker on linked-worktree directory
  housekeeping.

## Explicit no-change findings

These surfaces already express the right core posture and do not need semantic
replacement for this packet to land:

- `git-pr-open.sh` rejecting `main`
- `git-wt-new.sh` creating branch worktrees
- `github-control-plane-contract.json` keeping GitHub checks and
  review-thread resolution as the final merge gate
- `commit-pr-standards.json` enforcing trunk commit and PR-title grammar
