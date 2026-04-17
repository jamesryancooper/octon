# Octon Git + GitHub Worktree-Native Workflow Normalization

## Purpose

This packet converts the exploratory workflow audit in
`git-github-workflow.md` into a manifest-governed architecture proposal for
implementing a cleaner Octon Git + GitHub operating model.

The target state is:

1. PR-first on `main`
2. worktree-native for implementation
3. GitHub as the final merge gate
4. portable across any Git implementation and operator environment that
   supports linked worktrees

This packet intentionally treats Octon's local helper scripts as
**convenience projections** of the workflow, not as the only supported way to
execute it.

## Executive triage

The workflow audit is directionally correct, but it currently mixes three
different layers:

- durable Octon ingress and practice rules
- helper-script behavior
- one environment-specific interpretation of worktree usage

The packet therefore standardizes on four durable decisions:

1. keep the primary `main` worktree or clone clean and use it as the
   integration anchor
2. treat one branch worktree per task or PR as the default execution model in
   any worktree-capable environment
3. replace the static branch-closeout prompt with a contextual closeout gate
4. normalize review handling to `fix + commit + reply`, without author-side
   resolution of reviewer-owned threads

## Important scope boundary

This proposal is intentionally `promotion_scope: octon-internal`, so its
manifest promotion targets stay inside `/.octon/**` to remain
standard-conformant.

That means repo-local alignment surfaces such as
`.github/PULL_REQUEST_TEMPLATE.md` are treated here as **companion alignment
surfaces**, not manifest promotion targets. They still need to be updated in
the implementation branch if this packet is accepted.

## Current repo posture assumed by this packet

- GitHub remains the authoritative host control plane for PR state,
  required-check enforcement, and review-thread resolution.
- Standard Git worktree semantics remain available through `git worktree`
  or an equivalent implementation-compatible interface.
- Labels, comments, and generated summaries remain projections, not merge
  authority.
- `git-pr-open.sh` and `git-wt-new.sh` already encode the right default shape:
  branch worktrees and draft-first PR creation.
- `git-pr-ship.sh` remains a helper for ready or merge-intent transitions, not
  an independent proof that a PR is ready to merge.

## Historical lineage considered

- Active exploratory memo:
  `git-github-workflow.md`
- Archived historical implementation package:
  `/.octon/inputs/exploratory/proposals/.archive/design/git-github-workflow/`

The archived design package is useful lineage, but this packet supersedes it
for the current architecture-level question because the repo now has live
worktree helpers, PR autonomy docs, and a clearer control-plane contract.

## Recommended reading order

1. `navigation/source-of-truth-map.md`
2. `resources/source-artifact.md`
3. `architecture/current-state-gap-map.md`
4. `architecture/target-architecture.md`
5. `architecture/file-change-map.md`
6. `architecture/implementation-plan.md`
7. `architecture/migration-cutover-plan.md`
8. `architecture/validation-plan.md`
9. `architecture/acceptance-criteria.md`
10. `resources/assumptions-and-blockers.md`
11. `resources/risk-register.md`
12. `resources/decision-record-plan.md`

## Non-authority notice

This packet lives under `inputs/exploratory/proposals/**` and is not canonical
runtime, policy, or workflow authority. Promotion must land in durable targets
outside the proposal tree.
