# Assumptions and Blockers

## Assumptions

- `version.txt` remains `0.6.30`, so `release_state=pre-1.0`.
- `change_profile=atomic` remains correct because the packet does not require a
  dual workflow regime or a multi-step migration window.
- GitHub remains the intended forge and final merge-control plane.
- Standard Git worktree semantics remain available.
- Octon's local helper scripts remain optional convenience layers rather than
  the only valid execution path.

## Current blockers

### 1. Manifest scope versus repo-local companion surfaces

Active proposals may not mix `/.octon/**` and non-`.octon/**` promotion
targets, so `.github/PULL_REQUEST_TEMPLATE.md` cannot appear in this manifest.

Impact:

- not a blocker to packet authoring
- implementation must still align the PR template in the same branch or in a
  linked repo-local proposal

### 2. Worktree-directory cleanup design choice

The packet calls for explicit worktree-directory cleanup after PR closure, but
the exact delivery vehicle remains open:

- extend `git-pr-cleanup.sh`, or
- add a companion helper and document it

Impact:

- not a blocker to packet acceptance
- must be resolved before implementation closeout

## Non-blockers

- The existing required GitHub checks already support the target model.
- `git-pr-open.sh` and `git-wt-new.sh` already express the right default
  branch-worktree behavior.
