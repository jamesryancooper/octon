# Target Architecture

## Executive decision

Adopt a **worktree-native, draft-first, GitHub-gated** Git workflow for
Octon, with the model defined in a way that is portable across any Git
implementation and operator environment that supports linked worktrees.

The durable target state is:

1. the primary `main` worktree or clone is the clean integration anchor
2. implementation happens in feature branch worktrees
3. draft PRs open early and are promoted to ready only at a real completion
   point
4. GitHub rulesets, required checks, and review-thread resolution remain the
   final merge gate
5. closeout prompting becomes contextual instead of a single fixed question

## What this packet explicitly avoids

- Codex-only operating assumptions
- opening PRs from `main`
- a closeout question after every file-changing turn
- author-side resolution of reviewer-owned review threads
- making local helper scripts the only valid workflow definition
- creating a new control plane from labels, comments, or generated summaries

## Architectural decision set

### 1. Worktree-capable operator model

Octon should define the workflow in terms of standard Git concepts, not one
host app:

- **primary `main` worktree or clone**
  - clean integration anchor
  - sync `main`
  - inspect repo-wide control surfaces
  - create new branch worktrees
  - converge back to clean state after merge
- **branch worktree**
  - one task or PR per worktree
  - coding, testing, review remediation, and PR iteration happen here
- **shared invariants**
  - no PRs from `main`
  - no unrelated work stacked in one worktree
  - no branch-hopping within a worktree for unrelated tasks

Local scripts such as `git-wt-new.sh` remain recommended projections, but the
durable workflow is defined so an operator could follow it with plain Git
commands if needed.

### 2. Contextual branch closeout gate

The current scalar ingress prompt is replaced with a structured contextual gate
owned by `/.octon/instance/ingress/manifest.yml`.

A minimal target shape is:

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
    - closeout
  detect:
    primary_worktree: "git worktree list --porcelain"
    current_worktree: "git rev-parse --show-toplevel"
    current_branch: "git rev-parse --abbrev-ref HEAD"
    pr_state: "gh pr view or gh pr list --head"
  suppress_when:
    - active_implementation_continues
    - open_pr_has_red_required_checks
    - open_pr_has_unaddressed_author_action_items
    - ready_pr_is_waiting_on_reviewer_confirmation
```

The important architectural point is not the exact field spelling. It is that
closeout becomes **context-sensitive, suppressible, and completion-aware**.

### 3. Review remediation and merge-lane normalization

The durable workflow semantics become:

- open draft PRs early
- keep work on the same branch and same PR
- handle review with `fix + commit + reply`
- do not resolve reviewer-owned threads programmatically
- treat ready-for-review as a **state criterion**
- use an explicit merge lane:
  - **autonomous lane**
    - eligible draft PR becomes ready
    - request canonical squash auto-merge
    - GitHub remains final gate
  - **manual lane**
    - `exp/*`
    - high-impact governance or control-plane changes
    - major or unknown Dependabot transitions
    - mark ready for human review with auto-merge off

### 4. Helper-script projection model

`git-pr-ship.sh` should be treated as a helper that **requests** ready or
merge-lane transitions. It is not itself the definition of readiness.

The durable model should make these distinctions explicit:

- docs define when a PR is actually ready
- helper scripts accelerate the transition
- GitHub rulesets and required checks decide mergeability

The cleanup model should also become explicit about the linked-worktree
filesystem lifecycle:

- current helper already cleans refs and converges `main`
- target state also documents or automates worktree-directory pruning after
  closure

### 5. Companion repo-local alignment

Because this packet is `octon-internal`, repo-local companions are not
promotion targets. They are still required for a truthful implementation.

The key companion alignment surface is:

- `.github/PULL_REQUEST_TEMPLATE.md`
  - change reviewer-resolution wording from a self-resolution implication to
    "feedback addressed; reviewer-owned threads left for reviewer or maintainer
    confirmation"

## Contextual prompt set to standardize

The target user-facing closeout prompts are:

- **Primary `main` worktree**
  - "This work is on the main worktree, and Octon does not open PRs from `main`. Should I branch it into a feature worktree and prepare a draft PR?"
- **Branch worktree, no PR yet**
  - "This branch worktree looks ready for PR closeout. Should I stage, commit, push, and open a draft PR?"
- **Branch worktree, existing draft PR, autonomous lane**
  - "This draft PR looks ready for Octon's autonomous merge lane. Should I mark it ready and request squash auto-merge?"
- **Branch worktree, existing draft PR, manual lane**
  - "This draft PR looks ready for the manual lane. Should I mark it ready for human review and keep auto-merge off?"
- **Blocked state**
  - no closeout prompt; report blockers instead

## End-state behavior model

Once implemented, the durable workflow should read as:

1. start from a clean primary `main` worktree or clone
2. create a feature branch worktree
3. implement there
4. open a draft PR early
5. let GitHub evaluate it
6. fix review feedback with new commits and replies
7. move to ready only when the work is complete and the lane is appropriate
8. merge through the correct GitHub lane
9. clean refs, converge `main`, and prune the linked worktree
