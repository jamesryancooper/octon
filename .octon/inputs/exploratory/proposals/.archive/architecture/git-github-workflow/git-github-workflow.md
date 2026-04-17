I treated the current `main` branch as the target state and used your seed files as entry points into the live repo’s ingress, contracts, scripts, workflows, template, and review skill surfaces.

## 1. Executive Judgment

Octon’s actual Git/GitHub workflow is not generic GitHub Flow. It is **PR-first on `main`, worktree-first for implementation, and autonomy-first for merge orchestration**. The repo-local helper lane assumes you create a **feature branch + linked worktree** from `main`, do the implementation there, open a **draft PR early**, let triage/policy/quality/AI gates run, and only then move the PR into the appropriate merge lane. `main` itself is guarded as PR-first, and the local `git-pr-open.sh` explicitly refuses to open a PR from `main`. ([GitHub][1])

Inside Codex App, the right operating model is: **keep the main worktree clean and use branch worktrees as the normal unit of isolated task execution**. In practice, one task/PR should normally equal one branch worktree. The main worktree is the control anchor for syncing `main`, spawning new worktrees, comparing against trunk, and converging back to clean state after merge. The branch worktree is where implementation, PR iteration, and review-comment remediation should normally happen. ([GitHub][2])

The current closeout model is too weak. Today the manifest holds a single scalar prompt, and ingress/playbook surfaces repeat the rule to ask it after any file-changing turn: `Are you ready to closeout this branch?` That is current, but it is not good enough for Octon’s actual worktree-aware, PR-state-aware workflow. The correct closeout model is a **context-aware gate** that behaves differently on the primary `main` worktree, a branch worktree with no PR, a branch worktree with an existing draft PR, and a manual-lane PR. ([GitHub][3])

The most important tension is your “resolve any open conversations” step. Octon’s control plane requires resolved review threads before merge, but Octon’s PR policy and remediation skill also say the author/agent should **address comments with new commits and replies, and should not resolve reviewer-owned conversations programmatically**. So the correct operational rule is: **clear all author-side review action items, but do not forcibly resolve reviewer-owned threads; let the reviewer or an authorized maintainer confirm and resolve them**. If GitHub still shows required unresolved review threads after the author has fixed and replied, the PR is correctly in an “await reviewer confirmation” state, not a “force it green” state. ([GitHub][4])

My bottom-line recommendation is: keep Octon’s existing control plane, but **tighten the closeout gate, clarify review-thread semantics, and make the assistant smarter than the current `git-pr-ship.sh` default behavior**. The repo should evolve the ingress prompt contract, update the playbook/docs/template to match reviewer-owned resolution semantics, and either harden `git-pr-ship.sh` or document clearly that it is a **ship-intent helper**, not a proof that a PR is actually merge-ready. ([GitHub][5])

## 2. Repository-Grounded Source-of-Truth Map

### Canonical constitutional / ingress authority

The highest repo-local authority for this question starts with the Octon charter and ingress surfaces. `CHARTER.md` says the charter is the supreme repo-local constitutional regime for `/.octon/**`, and subordinate prompts/workflows may project it but may not redefine it. The ingress manifest is the machine-readable source of truth for mandatory reads, parity targets, and the branch closeout prompt, and ingress `AGENTS.md` explicitly says to treat the manifest that way. Octon’s normative precedence also says labels/comments/checks never become authority when canonical control artifacts disagree, and epistemic precedence says current repo/worktree state outranks stale summaries and chat. ([GitHub][6])

### Machine-readable merge-critical contracts

For Git/PR semantics, the key machine contracts are `commit-pr-standards.json`, `github-control-plane-contract.json`, and the AI-gate policy surfaces. They define the conventional commit/PR-title format, allowed branch types, default branch naming format, squash as the canonical merge strategy, the required `main` checks, review-thread resolution, auto-merge allowance, branch deletion on merge, and the workflow permission to approve PR reviews. ([GitHub][7])

### Executable local operator surfaces

The authoritative local operator behavior lives in the git helper scripts. `git-wt-new.sh` creates a worktree/branch under repo naming standards and runs a cleanup preflight first. `git-pr-open.sh` refuses `main`, uses the PR template, commits staged changes, pushes the branch, and opens a draft PR by default. `git-pr-ship.sh` defaults to “mark ready + request auto-merge,” and `git-pr-cleanup.sh` handles post-closure local/remote branch cleanup plus `main` convergence. Hook installation adds managed `post-checkout` / `post-merge` cleanup behavior. ([GitHub][2])

### Executable GitHub control-plane enforcement

The live GitHub workflow layer materially governing PR lifecycle is `.github/workflows/`. The relevant enforcement surfaces are `main-pr-first-guard.yml`, `commit-and-branch-standards.yml`, `pr-quality.yml`, `pr-autonomy-policy.yml`, `ai-review-gate.yml`, `pr-triage.yml`, `pr-auto-merge.yml`, and `pr-clean-state-enforcer.yml`. `codex-pr-review.yml` exists, but it is advisory rather than required merge authority. ([GitHub][1])

### Canonical policy / practice docs

The main human-readable policy layer is still important, but it is subordinate to the constitutional + machine + executable layers above. The key docs here are `pull-request-standards.md`, `commits.md`, `git-autonomy-playbook.md`, `git-github-autonomy-workflow-v1.md`, and `github-autonomy-runbook.md`. Those documents largely align with the scripts, but not perfectly. ([GitHub][8])

### Supporting / advisory surfaces

The PR template, Codex review workflow, `daily-flow.md`, and `SHIPPING.md` are supporting surfaces. They matter, but they are not merge authority. The template affects PR body enforcement because `pr-quality.yml` validates against it; Codex review is advisory; `daily-flow.md` is operator-rhythm guidance; and `SHIPPING.md` is about **post-merge promotion to production**, not branch closeout. ([GitHub][9])

### Thin ingress adapters, not independent authority

The root `AGENTS.md`, `.octon/AGENTS.md`, and `CLAUDE.md` are parity adapters pointing back to the canonical ingress surface. They are not separate policy sources. ([GitHub][3])

### Current conflicting / underspecified surfaces

The main conflicting or underspecified surfaces are: the static branch-closeout prompt in manifest/ingress/playbook/workflow-v1; the PR template checklist item `All review conversations resolved`; and the tension between PR-standards force-push cleanup advice and the remediation skill’s “new commits, no force-push/amend without approval” boundary. These are current surfaces, but they are not fully coherent as a single operational model. ([GitHub][3])

### One honest uncertainty

I did **not** directly read the live repository ruleset/settings through GitHub’s settings API during this audit, so I am treating the repo-published control-plane contract, runbook, and enforcement workflows as the best current authority. Octon’s own precedence files say that if the actual live ruleset/control truth diverges, the live control truth would outrank stale prose. ([GitHub][4])

## 3. Current-State Workflow Audit

### What actually happens locally

When you start new work through Octon’s local git helper lane, the expected entry point is `git-wt-new.sh`. It runs a cleanup preflight first, validates the branch against the standards contract, and then creates a sibling worktree/branch from `main` or another specified base. That makes linked worktrees a first-class operational primitive, not an afterthought. ([GitHub][2])

PR opening is branch-only. `git-pr-open.sh` refuses to run from `main`, commits staged changes or all changes with `--stage-all`, pushes the current branch, builds the PR body from `.github/PULL_REQUEST_TEMPLATE.md`, and opens a draft PR unless `--ready` is explicitly passed. In other words, the local helper already encodes “branch first, template-backed PR, draft by default.” ([GitHub][10])

Local “shipping” is implemented by `git-pr-ship.sh`, but its default behavior is **submit ready/automerge intent**, not independently prove readiness. Its default behavior is: mark draft PR ready, request squash auto-merge, then wait for closure and run cleanup, or fall back to a background watcher. For manual lane it can skip auto-merge but still launches cleanup watching. ([GitHub][5])

Local cleanup is post-closure. `git-pr-cleanup.sh` fetches/prunes origin, refuses to clean up an open PR head, deletes local and remote branches when safe, checks out the PR base or `main` if it is about to delete the current branch, fast-forwards `main` to `origin/main`, and prunes again. Hook installation adds managed `post-checkout` and `post-merge` automation to run cleanup opportunistically when the worktree is clean. ([GitHub][11])

### What actually happens in GitHub

On the GitHub side, `main` is explicitly PR-first. The `main-pr-first-guard.yml` workflow blocks direct pushes to `main` unless a break-glass footer is present, and it adds extra governance requirements for charter-related break-glass edits. ([GitHub][1])

PR lifecycle enforcement is split across several workflows. Branch naming is hard-failed by `Validate branch naming`, while commit-message lint is advisory. PR template/body structure is enforced by `PR Quality Standards`, which reads the canonical template from the PR’s base SHA and checks for required sections and checklist items. `Validate autonomy policy` evaluates PR autonomy policy from canonical sources, and `AI Review Gate / decision` is the provider-agnostic AI gate check. Codex review exists, but it is explicitly advisory and not a required merge check. ([GitHub][12])

PR triage classifies risk and lane. It keeps manual-lane exclusions for `exp/*`, high-impact governance/control-plane changes, and major/unknown Dependabot updates, and it marks other non-draft PRs as remaining eligible for the canonical auto-merge path. The autonomy runbook says the authoritative merge decision comes from canonical approval artifacts and required checks, not labels. ([GitHub][13])

Autonomous merge is implemented in two cooperating layers. The local script can request GitHub native auto-merge. The repository’s `pr-auto-merge.yml` workflow then revalidates eligibility; if native auto-merge is already enabled it exits, otherwise it polls GitHub’s merge endpoint directly because fine-grained PATs cannot reliably inspect check-runs. In both cases it treats rulesets/branch protections as the source of truth for required checks and mergeability. ([GitHub][5])

### What the merge gates are

The published control-plane contract says the `main` ruleset requires these checks: `AI Review Gate / decision`, `enforce-ci-efficiency-policy`, `PR Quality Standards`, `Validate branch naming`, and `Validate autonomy policy`. It also requires review-thread resolution, allows auto-merge, allows squash merge, disallows merge commits and rebase merges, and deletes branches on merge. The workflow permission to approve pull-request reviews is also expected to be enabled. ([GitHub][4])

The AI gate itself has a strict/shadow distinction. The workflow docs describe strict mode as `AI_GATE_ENFORCE=true` and shadow mode as non-blocking telemetry, while Codex review remains advisory and non-blocking. ([GitHub][14])

### What the cleanup / convergence behavior is

Beyond the local cleanup script, GitHub also runs a clean-state enforcer. It labels overdue PRs needing attention, opens or updates an autonomy-health issue, reminds operators to resolve manual-lane/blocking conditions and to use `git-pr-ship.sh` / `git-pr-cleanup.sh`, and tracks deleted closed head refs. That means cleanup/convergence is not just local; there is also a remote hygiene loop. ([GitHub][15])

### What the current closeout question behavior is

The current ingress behavior is unambiguous: the manifest contains `branch_closeout_prompt: Are you ready to closeout this branch?`, and ingress `AGENTS.md` says that after any turn that changes files, the assistant should ask exactly that. The same static gate is mirrored in the git autonomy playbook and the Git/GitHub workflow doc. ([GitHub][3])

### One terminology collision worth calling out

Octon currently overloads the word **ship**. `git-pr-ship.sh` is a PR-readiness / merge-path helper, but `SHIPPING.md` uses “ship” to mean **after the PR is merged, promote trunk preview to production behind flags**. That is not fatal, but it is a real source of operator confusion and matters when designing a closeout prompt. ([GitHub][5])

## 4. Conflict and Gap Analysis

### 4.1 Your desired finish sequence vs Octon’s actual PR flow

Your desired sequence overlaps with Octon on the big structure—stage, commit, PR, checks, review feedback, merge—but it does **not** match Octon literally. Octon’s PR policy says to **open early as draft**, let triage/policy/required checks run, and move to ready later; it is not “wait until you already have a check-passing PR, then open it ready.” `git-pr-open.sh` also defaults to draft. ([GitHub][8])

### 4.2 The docs and the local ship helper are not identical

The prose policy says “move to ready when policy and required checks are green.” The local `git-pr-ship.sh` helper is more eager: its default behavior is to mark ready and request auto-merge immediately, then let GitHub rulesets and mergeability decide the rest. So the script is a **submission helper**, while the prose describes a **state criterion**. That mismatch is real. ([GitHub][8])

### 4.3 “Resolve any open conversations” conflicts with Octon’s own review behavior

The repo requires review-thread resolution for merge, and the PR standards say unresolved review conversations block merge. But the same standards say “don’t resolve other people’s comments; let the commenter resolve when satisfied,” and the remediation skill is even stricter: never dismiss or resolve PR comments programmatically; use new commits and let the reviewer confirm. So “resolve any open conversations” is the wrong author-side instruction for Octon. ([GitHub][4])

### 4.4 Main worktree vs branch worktree is central, but the current closeout prompt ignores it

The executable layer makes the distinction clear: `main` is PR-first and `git-pr-open.sh` refuses to open a PR from it, while `git-wt-new.sh` exists specifically to create a feature branch worktree. But the current closeout prompt does not ask a different question on `main` than on a feature branch worktree. That is the biggest prompt-design gap in the repo today. ([GitHub][1])

### 4.5 PR standards vs remediation skill on force-push cleanup

`pull-request-standards.md` says “rebase and force-push cleanup, don’t merge main into the branch.” The remediation skill says do not force-push or amend without explicit user approval, and use new commits instead. For autonomous/assistant behavior, the remediation skill is the safer and more coherent rule—especially because `commits.md` explicitly treats branch commits as disposable working narration and trunk squash as the durable history. ([GitHub][8])

### 4.6 Labels and comments are projections, not control-plane authority

Some workflows add labels and health comments, but Octon’s precedence rules and autonomy runbook explicitly say labels/comments are not authoritative merge control when canonical artifacts disagree. That matters because any closeout logic that keys too heavily off labels would create a shadow control plane. ([GitHub][16])

### 4.7 Cleanup is strong on branches/refs, weaker on linked-worktree housekeeping

The provided cleanup helper is solid on Git refs: it deletes local/remote branches, restores/fast-forwards `main`, and prunes origin. But for a Codex-heavy linked-worktree operating model, the repo does not currently present an equally explicit, first-class **worktree-directory removal/prune** step. That is a usability gap rather than a control-plane conflict. ([GitHub][11])

### 4.8 “Ship” means two different things in Octon

Because `git-pr-ship.sh` is about PR readiness/merge while `SHIPPING.md` is about post-merge deployment promotion and flags, a user prompt like “ship this” is ambiguous unless the assistant uses context. That ambiguity should be handled in the closeout model, not ignored. ([GitHub][5])

## 5. Final Recommended Workflow

This is the single workflow I would standardize on for Octon.

### Step 1: Start from a clean primary `main` worktree

Treat the primary `main` worktree as the clean control/integration anchor. Sync it, inspect repo state, and spawn new work from it. Do not treat it as the normal implementation lane, and do not try to open PRs from it. ([GitHub][1])

### Step 2: For implementation, create a feature branch worktree

Use `git-wt-new.sh` to create a feature branch + linked worktree from `main` (or another explicit base if warranted). Let the standards contract drive branch naming, and let the cleanup preflight clear stale refs before spawning fresh work. This is the default unit of isolated work. ([GitHub][2])

### Step 3: Implement locally in the branch worktree

Do the coding, testing, and iterative refinement in that branch worktree only. Follow the commit/title grammar from `commit-pr-standards.json`, but do not over-optimize branch history: Octon’s own commit policy says branch-local commits are working narration and the durable artifact is the squash commit on `main`. ([GitHub][7])

### Step 4: Stage deliberately, then commit conventionally

When the change reaches a coherent checkpoint, stage only the intended diff and commit with the conventional `<type>(<scope>): <summary>` format. Avoid `--stage-all` unless the intent is truly “everything in this worktree belongs in this PR.” The contract requires lowercase summaries, no trailing period, and branch/PR-title alignment with the same general convention. ([GitHub][10])

### Step 5: Open the PR early as a draft

Use `git-pr-open.sh` to push the branch and open the PR as a **draft** by default. Let it generate the body from `.github/PULL_REQUEST_TEMPLATE.md`, because `pr-quality.yml` validates the PR body against the canonical template from the base SHA. Retain the template structure; do not treat Codex review reminders in that template as required merge authority. ([GitHub][10])

### Step 6: Let the GitHub control plane evaluate the PR

Once the draft PR exists, let triage, branch-name validation, PR-quality validation, autonomy policy, AI gate, and any advisory Codex review run. The required checks to watch are the ones in `github-control-plane-contract.json`, not ad hoc label states. ([GitHub][4])

### Step 7: Update the same PR from the same branch worktree

As work continues, keep pushing additional commits to the same branch and PR. Do not default to history-rewriting cleanup during agent remediation; Octon’s review skill prefers new commits, and the branch-local history is not the permanent trunk artifact anyway. ([GitHub][17])

### Step 8: Handle review comments by fix + reply, not by forcibly resolving

When reviewers comment, the assistant should fetch unresolved comments, classify them, fix what should be fixed, commit the changes, and reply explaining what changed or why not. It should **not** resolve reviewer-owned threads itself. Operationally, “review work is done” means there are no remaining author-side action items, even if GitHub still shows reviewer-owned unresolved threads awaiting confirmation. ([GitHub][18])

### Step 9: Move from draft to ready only at a real completion point

The right readiness criterion is: the requested implementation is credibly complete for this branch, the required checks are green enough for the relevant lane, the PR body meets template standards, and all author-side review actions are done. This matches Octon’s prose workflow better than simply firing `git-pr-ship.sh` as soon as files changed. ([GitHub][8])

### Step 10: Use the correct merge lane

If the PR is in the autonomous lane, mark it ready and request the canonical squash-merge path; GitHub rulesets and required checks remain the final merge authority. If the PR is in the manual lane—`exp/*`, high-impact governance/control-plane changes, major/unknown Dependabot updates—mark it ready for human review and keep auto-merge off. `git-pr-ship.sh --no-automerge` is the correct local helper for that manual lane. ([GitHub][13])

### Step 11: After merge/close, converge local state back to clean `main`

After PR closure, run or allow `git-pr-cleanup.sh` / its watcher to delete no-longer-needed branch refs, return to `main`, and fast-forward to `origin/main`. For Codex-heavy worktree usage, add one more explicit housekeeping step: remove/prune the linked worktree directory once it is no longer needed. The current helper already handles the ref convergence; the directory cleanup should become documented operator behavior or an extended helper capability. ([GitHub][5])

## 6. Codex App Worktree Operating Model

### Main worktree role

Use the primary `main` worktree for: syncing `main`, inspecting repo-wide control surfaces, creating new worktrees, comparing branch state against trunk, and converging back to a clean steady state after merge. Avoid routine implementation there. The repo’s own scripts and guards already push you this way: `main` is PR-first, and `git-pr-open.sh` rejects it as a PR source branch. ([GitHub][1])

### Branch worktree role

Use branch worktrees as the default execution cell for feature work, bugfixes, refactors, and review remediation. Octon’s local operator design already supports this: `git-wt-new.sh` exists specifically to create branch worktrees from `main`, and the playbook describes “create a branch + worktree” as the normal start of the lane. ([GitHub][2])

### Concurrency model

In Codex App, the cleanest model is **one worktree per active task/PR**. If you have three active efforts, you should normally have three branch worktrees, not one branch with stacked unrelated work. This prevents branch contamination, makes review remediation trivial, and matches Octon’s willingness to treat branch-local commits as disposable narration until the squash merge lands on `main`. ([GitHub][17])

### Contamination avoidance

Do not reuse a worktree for unrelated tasks. Do not carry task edits on the primary `main` worktree. Do not branch-hop within the same linked worktree for unrelated PRs. Keep each Codex conversation anchored to one worktree path and one PR objective. That is the natural extension of Octon’s existing worktree and squash-based design. ([GitHub][2])

### Review remediation model

When a PR gets comments, go back to **the same branch worktree**, make the fixes there, add new commits, push to the same PR, and reply to the review threads. Do not create a second branch just to answer review comments unless the review has materially changed scope and you are intentionally abandoning the first PR. ([GitHub][18])

### Behavioral guidance for common requests

When you say **“finish up”** or **“close out”** from a branch worktree with no PR, the assistant should interpret that as “prepare this worktree for a draft PR.” When you say it from a branch worktree with an existing draft PR, the assistant should interpret it as “evaluate whether this PR should stay draft, be updated, or be promoted to ready.” When you say it from `main`, the assistant should interpret it as “branch/worktree-hop first; do not PR from `main`.” That behavior is consistent with the current scripts even though the current prompt text is not. ([GitHub][10])

## 7. End-of-Work / “Ship This” Closeout Sequence

This is the exact closeout sequence I would use in Octon.

### A. If the current context is the main worktree

If the current worktree is the primary `main` worktree, **do not** try to open a PR from there. If there are no task changes yet, create a feature branch worktree and continue there. If there are already changes on `main`, first branch those changes off into a feature branch/worktree, then continue with the branch-worktree path. Octon’s local PR helper explicitly disallows `main` as the PR source branch. ([GitHub][10])

### B. If the current context is a branch worktree with no PR yet

If the branch worktree has reached a credible completion point, stage the intended changes, commit conventionally, push, and open a **draft** PR. Do not wait for a mythical “already green PR” before opening it; Octon expects the draft PR to exist early so the repo’s triage, policy, and quality workflows can evaluate it. ([GitHub][10])

### C. If the current context is a branch worktree with an existing draft PR

Push any remaining fixes to the same branch. Then evaluate blockers in this order: required checks, policy lane, and review action items. If required checks are red, keep fixing. If reviewer comments remain unaddressed, fix and reply. If the PR is in a manual lane, keep auto-merge off. If the PR is complete, lane-eligible, and no author-side actions remain, then mark it ready and request the correct merge lane. ([GitHub][4])

### D. If the current context is a branch worktree with an existing ready/open PR

If the PR is already ready and awaiting green checks, reviewer confirmation, or manual approval, the correct closeout action is usually **status reporting**, not another closeout prompt. If it is autonomous-lane and GitHub can merge it, let GitHub merge it. If it is manual-lane, wait for the human lane. Do not re-run closeout logic just because the branch still exists locally. ([GitHub][19])

### E. If review comments are outstanding

This is the place where your original sequence needs the most correction. The assistant should **not** “resolve any open conversations” as a generic step. It should instead: fix code, commit, push, reply to the thread, and explicitly note when the remaining blocker is reviewer confirmation. If reviewer-owned unresolved threads remain and GitHub requires review-thread resolution, merge should stay blocked until that confirmation happens. ([GitHub][4])

### F. After merge

After the PR closes/merges, run or allow the cleanup watcher to run `git-pr-cleanup.sh`, converge the local repo back to `main`, and then remove/prune the linked worktree directory once it is no longer needed. That final directory cleanup step is the one part I would strengthen for Codex-heavy worktree usage. ([GitHub][5])

### The corrected version of your original sequence

The Octon-native rewrite of your sequence is:

1. **On a branch worktree**, stage and commit the intended changes.
2. Open or update the **draft** PR.
3. Let Octon’s required checks and policy workflows run.
4. Address review comments with **fix + commit + reply**.
5. Do **not** resolve reviewer-owned threads programmatically.
6. When the work is complete, the required lane checks are green, and no author-side review actions remain, move the PR to **ready**.
7. If the PR is autonomy-eligible, request the canonical squash auto-merge path; if it is manual-lane, leave auto-merge off.
8. Let GitHub’s required checks and review-thread-resolution rules decide actual mergeability.
9. After closure, run cleanup and converge local state. ([GitHub][8])

## 8. Branch Closeout Prompt Redesign

### Judgment

A single static prompt string is **not sufficient** for what Octon now needs. The current manifest contract only exposes one scalar prompt, and ingress `AGENTS.md` currently mandates asking it after any file-changing turn. That is too weak to encode worktree context, PR existence, readiness, manual-vs-auto lane, or blocker-aware suppression. The contract itself needs a minimal evolution. ([GitHub][3])

### Minimal correct contract evolution

The least invasive fix is:

* keep `branch_closeout_prompt` as a deprecated fallback for older adapters, and
* add a new structured field such as `branch_closeout_gate` to `/.octon/instance/ingress/manifest.yml`,
* with `/.octon/instance/ingress/AGENTS.md` updated to say the structured gate is canonical when present.

A minimal shape could be:

```yaml
branch_closeout_gate:
  mode: contextual
  deprecated_fallback_prompt: "Are you ready to closeout this branch?"
  implicit_trigger:
    requires_file_changes: true
    requires_completion_point: true
  explicit_trigger:
    - finish
    - ship
    - open-pr
    - closeout
  detect:
    primary_worktree: "first entry from `git worktree list --porcelain`"
    current_worktree: "`git rev-parse --show-toplevel`"
    current_branch: "`git rev-parse --abbrev-ref HEAD`"
    pr_state: "`gh pr view` or `gh pr list --head`"
  suppress_when:
    - active_implementation_continues
    - open_pr_has_red_required_checks
    - open_pr_has_unaddressed_author_action_items
    - ready_pr_is_waiting_on_reviewer_confirmation
  contexts:
    primary_main: ...
    branch_no_pr: ...
    branch_draft_auto_ready: ...
    branch_draft_manual_ready: ...
```

### Detection logic

The correct detection logic should be:

* **Primary/main worktree** = the current path equals the first `worktree` entry from `git worktree list --porcelain`.
* **Branch worktree** = any other linked worktree path.
* **Current branch** = `git rev-parse --abbrev-ref HEAD`.
* **Existing PR state** = PR lookup for the current branch head.
* **Manual lane** = `exp/*`, high-impact governance/control-plane paths, or Dependabot major/unknown transitions.
* **Autonomous lane** = non-draft PR that is not excluded by those policy conditions, subject to canonical checks and approvals. ([GitHub][13])

### Completion heuristics

The assistant should only auto-prompt for closeout when all of the following are true:

* the last turn changed files,
* the assistant has reached a natural completion point for the current subtask,
* it is not already obvious that more implementation work is immediately needed,
* and the next best action is plausibly a PR-state transition rather than more coding.

For an existing PR, “completion point” should incorporate required-check state and author-side review action items. For `main`, it should mean “stable enough to branch/worktree-hop now,” not “safe to PR from `main`.”

### Suppression heuristics

The assistant should **not** ask a closeout question:

* after every file change,
* while a diff is obviously still mid-implementation,
* while required checks are red on an open PR,
* while there are clear unaddressed author-side review action items,
* or when a ready PR is merely waiting on reviewer confirmation / final mergeability.

For incomplete/not-ready work, the right default is **suppression**, not a weaker closeout question.

### Final prompt wording by context

Use these exact contextual prompts:

**Primary `main` worktree, credible completion point**

> This work is on the main worktree, and Octon does not open PRs from `main`. Should I branch it into a feature worktree and prepare a draft PR?

**Branch worktree, no PR yet, credible completion point**

> This branch worktree looks ready for PR closeout. Should I stage, commit, push, and open a draft PR?

**Branch worktree, existing draft PR, autonomous lane ready**

> This draft PR looks ready for Octon’s autonomous merge lane. Should I mark it ready and request squash auto-merge?

**Branch worktree, existing draft PR, manual lane ready**

> This draft PR looks ready for the manual lane. Should I mark it ready for human review and keep auto-merge off?

**Blocked / incomplete state**

* Default: **no closeout prompt**.
* If the user explicitly asked to close out: report blockers instead of asking a misleading question, e.g.

  > Not ready to close out yet: required checks are still failing.
  > Not ready to close out yet: review feedback still needs a fix/reply.
  > Not ready to close out yet: this PR is waiting on reviewer-owned thread resolution.

### What “no unresolved conversations” should mean in Octon

Operationally, in Octon this should mean:

* **no unresolved author action items remain**, and
* the assistant has replied on each addressed thread,
* but reviewer-owned threads remain for reviewer/maintainer confirmation,
* and GitHub’s actual review-thread-resolution gate remains the final merge authority.

That preserves Octon’s policy and avoids the anti-pattern of “greenwashing” the PR UI by self-resolving other people’s threads. ([GitHub][4])

## 9. Exact File Change Map

### Required changes

`/.octon/instance/ingress/manifest.yml`
Replace the scalar `branch_closeout_prompt` with a structured `branch_closeout_gate` object, keeping the scalar only as a deprecated fallback if adapter compatibility matters. This is the canonical contract surface, so the behavior belongs here first. ([GitHub][3])

`/.octon/instance/ingress/AGENTS.md`
Replace “After any turn that changes files, ask exactly...” with logic that defers to `branch_closeout_gate` and makes the structured gate canonical. This is the canonical human-readable ingress projection of the manifest. ([GitHub][20])

`/.octon/framework/agency/practices/git-autonomy-playbook.md`
Rewrite the “Thread Closeout Gate” section so it becomes completion-aware, worktree-aware, and lane-aware. Also clarify that `git-pr-ship.sh` is not the first thing to run after every file-changing turn. ([GitHub][21])

`/.octon/framework/agency/practices/git-github-autonomy-workflow-v1.md`
Update the “Conversation closeout gate” section, the main-vs-branch worktree model, and the description of the autonomous lane so the doc stops implying one fixed question and better matches the branch/manual/autonomous distinctions the repo already enforces. ([GitHub][14])

`/.octon/framework/agency/practices/pull-request-standards.md`
Clarify the operational meaning of review-thread resolution: the author must fix/reply, but should not resolve reviewer-owned threads. Also reconcile the ready-state guidance with the existence of `git-pr-ship.sh` so the policy and helper semantics are not working at cross-purposes. ([GitHub][8])

`/.github/PULL_REQUEST_TEMPLATE.md`
Replace `All review conversations resolved` with wording that does not imply author-side resolution of reviewer-owned threads. I would change it to something like:
`All review feedback addressed; reviewer-owned threads left for reviewer/maintainer confirmation.`
This is the right surface because `pr-quality.yml` reads the template from the base SHA and enforces its sections/checklist structure. ([GitHub][22])

### Strongly recommended changes

`/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md`
Keep the “do not resolve PR comments programmatically” rule, but add one clarifying note: unresolved reviewer-owned threads may still block merge, so the agent’s duty is fix + reply + re-request review, not self-resolution. That would make the skill and PR standards align more explicitly. ([GitHub][18])

`/.octon/framework/agency/_ops/scripts/git/git-pr-ship.sh`
Either add a preflight mode like `--assert-ready` / `--require-green`, or at minimum change the help text and success messaging to make clear it is a **ready/automerge request helper** that still relies on GitHub rulesets/checks for actual mergeability. Right now its defaults are easy to overread. ([GitHub][5])

### Optional but useful Codex-worktree improvement

`/.octon/framework/agency/_ops/scripts/git/git-pr-cleanup.sh` **or** a proposed new companion helper
Extend cleanup to optionally remove/prune linked worktree directories after branch cleanup, or add a documented companion helper for that purpose. Today the script clearly handles branch/ref cleanup and `main` convergence; the linked-worktree filesystem lifecycle is less explicit. ([GitHub][11])

### Probably no semantic change needed

`AGENTS.md`, `/.octon/AGENTS.md`, and `CLAUDE.md`
These look like thin parity adapters to the canonical ingress surface. I would validate parity after the ingress change, but I would not add closeout logic directly here unless those adapters stop being thin shims. ([GitHub][23])

## 10. Acceptance Criteria

You can honestly claim the workflow and closeout model are complete when all of the following are true:

1. The documented default says **implementation happens in feature branch worktrees**, not on the primary `main` worktree.
2. The primary `main` worktree is documented and treated as the clean control/integration anchor.
3. The assistant never attempts to open a PR from `main`.
4. The assistant’s default unit of work is **one task/PR per branch worktree**.
5. The closeout prompt is **not** emitted after every file-changing turn.
6. The closeout prompt is emitted only at credible completion points or explicit finish/ship/closeout requests.
7. The closeout wording changes by context: primary `main`, branch with no PR, branch with readyable draft PR, manual lane, and blocked/not-ready states.
8. Blocked/not-ready states suppress the closeout question and instead surface blockers.
9. The assistant’s review-remediation behavior is explicitly: **fix + commit + reply**, never “resolve reviewer-owned threads to make the UI green.”
10. The repo docs/template define “review conversations resolved” in a way that is consistent with reviewer-owned resolution.
11. The ready-for-review transition is documented as a **state criterion**, not just a local script button.
12. The manual lane is explicit for `exp/*`, high-impact governance/control-plane changes, and major/unknown Dependabot updates.
13. The autonomous lane is explicit as squash-only and governed by canonical required checks and review-thread-resolution rules.
14. Post-merge cleanup converges local refs and `main`, and the linked-worktree directory cleanup step is documented or automated.
15. Manifest, ingress AGENTS, playbook, workflow doc, PR standards, PR template, and helper-script semantics no longer contradict one another. ([GitHub][4])

The shortest true summary is: **Octon wants clean `main`, work done in feature worktrees, draft PRs opened early, GitHub as the final merge gate, reviewer-owned thread resolution preserved, and a closeout gate that asks the right question only when the branch is actually at a real completion point.**

[1]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/main-pr-first-guard.yml "https://github.com/jamesryancooper/octon/blob/main/.github/workflows/main-pr-first-guard.yml"
[2]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/_ops/scripts/git/git-wt-new.sh "https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/_ops/scripts/git/git-wt-new.sh"
[3]: https://github.com/jamesryancooper/octon/blob/main/.octon/instance/ingress/manifest.yml "https://github.com/jamesryancooper/octon/blob/main/.octon/instance/ingress/manifest.yml"
[4]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/practices/standards/github-control-plane-contract.json "https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/practices/standards/github-control-plane-contract.json"
[5]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/_ops/scripts/git/git-pr-ship.sh "https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/_ops/scripts/git/git-pr-ship.sh"
[6]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/constitution/CHARTER.md "https://github.com/jamesryancooper/octon/blob/main/.octon/framework/constitution/CHARTER.md"
[7]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/practices/standards/commit-pr-standards.json "https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/practices/standards/commit-pr-standards.json"
[8]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/practices/pull-request-standards.md "octon/.octon/framework/agency/practices/pull-request-standards.md at main · jamesryancooper/octon · GitHub"
[9]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-quality.yml "https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-quality.yml"
[10]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/_ops/scripts/git/git-pr-open.sh "https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/_ops/scripts/git/git-pr-open.sh"
[11]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/_ops/scripts/git/git-pr-cleanup.sh "https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/_ops/scripts/git/git-pr-cleanup.sh"
[12]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/commit-and-branch-standards.yml "https://github.com/jamesryancooper/octon/blob/main/.github/workflows/commit-and-branch-standards.yml"
[13]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-triage.yml "https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-triage.yml"
[14]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/practices/git-github-autonomy-workflow-v1.md "https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/practices/git-github-autonomy-workflow-v1.md"
[15]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-clean-state-enforcer.yml "https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-clean-state-enforcer.yml"
[16]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/constitution/precedence/normative.yml "https://github.com/jamesryancooper/octon/blob/main/.octon/framework/constitution/precedence/normative.yml"
[17]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/practices/commits.md "octon/.octon/framework/agency/practices/commits.md at main · jamesryancooper/octon · GitHub"
[18]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md "octon/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md at main · jamesryancooper/octon · GitHub"
[19]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-auto-merge.yml "https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-auto-merge.yml"
[20]: https://github.com/jamesryancooper/octon/blob/main/.octon/instance/ingress/AGENTS.md "https://github.com/jamesryancooper/octon/blob/main/.octon/instance/ingress/AGENTS.md"
[21]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/practices/git-autonomy-playbook.md "octon/.octon/framework/agency/practices/git-autonomy-playbook.md at main · jamesryancooper/octon · GitHub"
[22]: https://github.com/jamesryancooper/octon/blob/main/.github/PULL_REQUEST_TEMPLATE.md "octon/.github/PULL_REQUEST_TEMPLATE.md at main · jamesryancooper/octon · GitHub"
[23]: https://github.com/jamesryancooper/octon/blob/main/AGENTS.md "octon/AGENTS.md at main · jamesryancooper/octon · GitHub"
