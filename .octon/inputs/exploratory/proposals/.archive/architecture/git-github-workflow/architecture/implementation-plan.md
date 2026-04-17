# Implementation Plan

## Profile Selection Receipt

- Semantic version source: `version.txt`
- Current version: `0.6.30`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Hard-gate facts:
  - no new top-level root is introduced
  - no support-target widening is required
  - no dual workflow regime is required for steady state
  - repo-local companion alignment can land in the same implementation branch
- Tie-break status: none
- `transitional_exception_note`: `n/a`

## Posture

This packet is **proposal-first and additive**. The repo already contains the
correct worktree and PR primitives, so the target motion is to align the
contract surfaces around them rather than replace the workflow with a new one.

## Phase 0 — Packet acceptance and scope lock

1. Accept this packet as the current architecture aid for workflow
   normalization.
2. Freeze the durable concepts:
   - worktree-native execution
   - contextual closeout gate
   - reviewer-owned thread resolution
   - helper-script projection model
3. Confirm that the implementation branch will also carry companion alignment
   for `.github/PULL_REQUEST_TEMPLATE.md`.

**Exit criterion:** packet scope is accepted and no one expects repo-local
workflow authority to move into the proposal tree.

## Phase 1 — Ingress contract normalization

1. Replace `branch_closeout_prompt` with a structured
   `branch_closeout_gate`, keeping the scalar only as a deprecated fallback if
   adapter compatibility requires it.
2. Update ingress `AGENTS.md` so the contextual gate is the canonical human
   projection of the manifest.
3. Define suppression and context-selection rules in durable prose.

**Incomplete if omitted:** the workflow would still rely on a fixed prompt that
cannot reason about branch, PR, or blocker state.

## Phase 2 — Practice and overview alignment

1. Rewrite `git-autonomy-playbook.md` so it speaks in terms of any
   worktree-capable Git environment, not one host app.
2. Update `git-github-autonomy-workflow-v1.md` so the durable story matches:
   - draft-first PRs
   - ready as a state criterion
   - manual versus autonomous lanes
   - contextual closeout prompts
3. Preserve the durable distinction between helper scripts and workflow
   authority.

**Incomplete if omitted:** script behavior and workflow docs would continue to
drift.

## Phase 3 — Review remediation normalization

1. Update `pull-request-standards.md` to define "review work complete" as
   "no unresolved author action items remain".
2. Update the remediation skill so it explicitly says:
   - fix
   - commit
   - push
   - reply
   - re-request review if needed
   - do not resolve reviewer-owned threads programmatically
3. Update the PR template wording in the implementation branch so checklist and
   prose no longer imply author-side resolution of reviewer-owned threads.

**Incomplete if omitted:** merge-blocking thread-resolution policy would remain
ambiguous.

## Phase 4 — Helper-script semantics and housekeeping

1. Clarify `git-pr-ship.sh` help text and success messaging so it reads as a
   ready or merge-intent helper.
2. Add either:
   - documented worktree-pruning behavior to `git-pr-cleanup.sh`, or
   - a companion helper and documented operator step for pruning worktree
     directories after closure.
3. Keep `git-pr-open.sh` and `git-wt-new.sh` behavior unchanged unless testing
   reveals a necessary follow-on.

**Incomplete if omitted:** the durable docs would say one thing while the local
helpers still imply another.

## Phase 5 — Validation and cutover

1. Validate proposal structure and regenerate the proposal registry.
2. Run targeted repo checks after implementation:
   - ingress parity
   - stale-string sweeps for the fixed closeout prompt
   - stale-string sweeps for reviewer-resolution wording
3. Exercise the scenario matrix from `validation-plan.md`.
4. Close only when acceptance criteria and companion alignment surfaces are
   satisfied in the same implementation branch.

## Preferred Change Path

One coordinated implementation branch that updates ingress, workflow docs,
review semantics, helper scripts, and the companion PR template together.

## Minimal fallback path

Only if the coordinated branch becomes too risky:

1. land ingress contract and practice-doc alignment first
2. land helper-script clarification second
3. land repo-local PR-template wording in a linked follow-up

This fallback is not preferred because the problem is primarily one of drift
between surfaces, and split delivery prolongs that drift.
