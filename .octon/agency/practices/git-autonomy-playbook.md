---
title: Git Autonomy Playbook
description: Local operator playbook for autonomy-first Git and GitHub workflow execution.
---

# Git Autonomy Playbook

This playbook covers the local script lane for autonomy-first Git/GitHub flow:

- `.octon/agency/_ops/scripts/git/git-wt-new.sh`
- `.octon/agency/_ops/scripts/git/git-pr-open.sh`
- `.octon/agency/_ops/scripts/git/git-pr-ship.sh`
- `.octon/agency/_ops/scripts/git/git-autonomy-hooks-install.sh`
- `.octon/agency/_ops/scripts/git/git-autonomy-hooks-uninstall.sh`
- `.octon/agency/_ops/scripts/git/git-pr-cleanup.sh`
- `.octon/agency/_ops/scripts/github/sync-github-labels.sh`

Use this with [GitHub Autonomy Runbook](./github-autonomy-runbook.md) for token,
permissions, and control-plane drift operations.

---

## Preconditions

- `gh auth status` is healthy for the target account.
- Branch naming and commit conventions remain governed by:
  - `.octon/agency/practices/standards/commit-pr-standards.json`
- Repository autonomy variables/secrets are configured:
  - `AUTONOMY_AUTO_MERGE_ENABLED=true`
  - `AUTONOMY_PAT` repository Actions secret
  - `AI_GATE_ENFORCE` mode matches desired rollout phase
  - `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` set before strict AI-gate mode

---

## Script Quick Reference

`Branch closeout` means the full lifecycle: stage/commit, push, PR open/update,
ready/auto-merge request (policy permitting), wait/poll to completion, and
cleanup.

### 1) Create a branch + worktree

```bash
.octon/agency/_ops/scripts/git/git-wt-new.sh \
  --type fix \
  --slug phase-e-local-autonomy-scripts
```

Behavior:

- Validates branch format against repository branch policy contract.
- Runs clean-state preflight (prune/sync/closed-branch cleanup) by default.
- Creates a new worktree in a sibling folder.
- Creates branch from `main` (or `--base` override).

### 2) Commit, push, and open a draft PR

```bash
.octon/agency/_ops/scripts/git/git-pr-open.sh \
  --title "fix(github): tighten autonomy script defaults" \
  --summary "Adds safer defaults for local autonomy helper scripts." \
  --stage-all \
  --no-issue "operator-tooling"
```

Behavior:

- Commits staged changes, or stages everything when `--stage-all` is set.
- Pushes the current branch to `origin`.
- Builds PR body from `.github/PULL_REQUEST_TEMPLATE.md`.
- Ensures issue-link policy with either `Closes #...` or `No-Issue: ...`.

### 3) Label, ready, and request auto-merge

```bash
.octon/agency/_ops/scripts/git/git-pr-ship.sh --accept-human
```

Behavior:

- Adds autonomy lane labels (`autonomy:auto-merge` by default).
- Removes `autonomy:no-automerge` when requesting autonomous lane.
- Marks draft PR as ready (unless `--no-ready`).
- Requests squash auto-merge (unless `--no-automerge`).
- Waits for PR closure (auto lane) and runs local cleanup enforcement.
- For manual lanes, starts a background cleanup watcher that runs when the PR closes.

### Thread Closeout Gate (Required)

After any thread turn with file changes, ask:

`Are you ready to closeout this branch?`

- If the answer is "yes", run closeout end-to-end using:
  1. `git-pr-open.sh`
  2. `git-pr-ship.sh`
- If the answer is "no", stop with no closeout mutations.

### 4) Enforce local cleanup state on demand

```bash
.octon/agency/_ops/scripts/git/git-pr-cleanup.sh
```

Behavior:

- Deletes local branches whose latest PR is already closed/merged.
- Deletes matching origin branches when no open PR references the branch.
- Checks out and fast-forwards `main` to `origin/main`.
- Supports `--watch-pr <number>` to wait for closure, then cleanup.

### 5) Install non-blocking local cleanup hooks

```bash
.octon/agency/_ops/scripts/git/git-autonomy-hooks-install.sh
```

Behavior:

- Installs managed `post-merge` and `post-checkout` hooks.
- Triggers `.octon/agency/_ops/scripts/git/git-pr-cleanup.sh --no-sync-main`
  in the background.
- Uses lock + throttle controls to avoid duplicate runs.
- Skips safely when the working tree is dirty.

Uninstall:

```bash
.octon/agency/_ops/scripts/git/git-autonomy-hooks-uninstall.sh
```

### 6) Sync required GitHub labels

```bash
.octon/agency/_ops/scripts/github/sync-github-labels.sh
```

Behavior:

- Creates or updates triage/policy labels idempotently.
- Keeps color/description aligned with workflow expectations.

---

## Lane Guidance

### Low-risk autonomous lane

1. Create worktree/branch with `git-wt-new.sh`.
2. Implement change.
3. Open draft PR with `git-pr-open.sh`.
4. Mark ready + request merge with `git-pr-ship.sh`.
5. Let required checks and branch rules enforce final merge safety.
6. Let cleanup enforcement return local git state to `main` + aligned origin.
7. Keep cleanup hooks installed to converge branch state after merges that
   happen outside `.octon/agency/_ops/scripts/git/git-pr-ship.sh`.

### High-impact guarded lane

When touching high-impact paths (for example `.github/` or governance paths):

1. Add `accept:human` before merge.
2. Keep PR focused and explicitly document risk/rollback.
3. Use `git-pr-ship.sh --accept-human` to preserve metadata-level check-in.
4. Cleanup watcher will run automatically once the PR is eventually closed.

---

## Safety and Exceptions

- Do not bypass required checks or branch rules via local scripts.
- Keep `main` PR-first; direct push remains break-glass only.
- Cleanup hooks are non-blocking and must not interrupt local work.
- Hooks intentionally skip execution when the working tree is dirty.
- If autonomy behavior regresses:
  1. Set `AUTONOMY_AUTO_MERGE_ENABLED=false`
  2. Keep triage/policy checks active
  3. Follow rollback guidance in
     [GitHub Autonomy Runbook](./github-autonomy-runbook.md).
