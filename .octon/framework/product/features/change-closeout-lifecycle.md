# Change Closeout Lifecycle

Change Closeout Lifecycle is Octon's route-neutral closeout feature for the
singular default work unit: one Change. It gives operators and agents a stable
navigation surface for the Change closeout state machine, the closeout skills,
receipt contracts, governed branch landing and cleanup authorization, wrapper
evidence, and repo-hygiene handoff.

This feature page is navigation-only. The source of truth remains the linked
contracts, skill definitions, validators, receipts, and repo-hygiene policy.
For architecture/governance boundary detail, see
`.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/mechanisms/change-closeout-and-repo-hygiene.md`.

## Boundary

`closeout-change` closes one Change through the route selected by the default
work unit policy. It owns material route actions for that selected Change:
staging, committing, pushing, hosted no-PR landing, PR delegation, source branch
cleanup, rollback or discard posture, validation evidence, and the singular
Change receipt.

`closeout-worktree` is the dirty-worktree wrapper. It inventories the worktree,
classifies residue, partitions coherent candidates, delegates each safely
separable candidate to singular `closeout-change`, re-inventories after each
delegation, and reports closed, retained, deferred, blocked, escalated, or
foreign candidates. It does not stage, commit, push, land, delete, reset,
restore, or clean residue directly.

`closeout-pr` is the PR-backed subflow. It is used only after the selected
Change route is `branch-pr` or when work starts from an existing PR context.

Repo hygiene owns post-closeout non-material residue management. A completed
`cleaned` Change outcome proves the selected Change's route cleanup and required
main alignment. It does not prove the whole repository has no retained evidence,
generated output, control state, ignored local files, or cleanup-safe run
residue unless repo hygiene has separately classified and disposed or retained
that residue.

## Core Guarantees

- The default work unit remains singular `Change`.
- A plain closeout request defaults `target_lifecycle_outcome` to `cleaned`.
- Actual lifecycle outcome is evidence-based and may truthfully downgrade to
  `landed`, `published-branch`, `branch-local-complete`, `preserved`,
  `deferred`, `blocked`, `escalated`, or `denied`.
- `published-branch` and `branch-local-complete` are continued handoff outcomes,
  not completed closeout.
- Branch-based `landed` or `cleaned` claims require source integration into
  `origin/main`, post-landing fetch, local `main` sync, landed-ref containment
  in local `main` and `origin/main`, and final alignment evidence.
- Hosted no-PR landing requires governed `branch-landing-authorization-v1`
  evidence.
- Source branch cleanup requires governed `branch-cleanup-authorization-v1`
  evidence.
- Proposal lifecycle handoff receipts, phase context, and lifecycle events are
  advisory context only; they cannot select a Change route, satisfy Change
  receipt or evidence gates, authorize hosted landing or branch cleanup, or
  report the final lifecycle outcome.
- Generated outputs, raw inputs, host projections, control artifacts, chat
  state, tool availability, provider metadata, and ignored local files are not
  closeout authority.
- Detection never authorizes deletion.

## Operator Entry Points

- `/closeout-change`
- `/closeout-worktree`
- `/closeout-pr`
- `closeout-change`
- `closeout-worktree`
- `closeout-pr`

Use `closeout-change` when the scope is already one coherent Change. Use
`closeout-worktree` when the worktree may contain multiple candidates or
retained residue. Use `closeout-pr` only for a selected `branch-pr` route or an
existing PR context.

## Repo-Hygiene Handoff

After a truthful `cleaned` Change closeout, remaining residue must be treated as
repo hygiene unless it is inside the selected Change boundary. Repo hygiene may
classify local run/control/evidence residue, generated scratch output, durable
evidence, active control state, manual-review artifacts, and ignored local
files. Cleanup-safe local residue may be removed only through governed
repo-hygiene policy and helper evidence. Generated run-health projections remain
generator-owned and must be pruned through the run-health generator's retained
`pruned_paths` evidence rather than through Change closeout.

## Validation

Focused validation lives in the default work unit validator, Change closeout
state machine validator, lifecycle alignment validator, closeout-worktree wrapper
validator, hosted no-PR landing tests, wrapper orchestration tests, repo-hygiene
validators, generated non-authority validator, run-health read-model validator,
and product feature catalog validator.
