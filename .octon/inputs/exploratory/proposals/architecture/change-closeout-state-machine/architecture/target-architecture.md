# Target Architecture

Proposal: `change-closeout-state-machine`

## Canonical Model

The durable model is named **Change Closeout State Machine**. It is a
route-neutral closeout contract for Octon's default work unit, the Change.

The state machine owns:

- route, target lifecycle outcome, and actual lifecycle outcome separation;
- inventory and residue classification for staged, unstaged, untracked, ignored,
  branch, generated, evidence, host-projection, release, and input-surface
  residue;
- safe cleanup evidence gates;
- route-specific validation and hosted landing gates;
- PR-backed delegation boundaries;
- branch cleanup and local worktree cleanup gates;
- Change receipt completeness;
- rollback or discard posture;
- final `local main == origin/main == landed_ref` verification when that claim is
  made.

The state machine does not own:

- feature implementation before closeout;
- extension activation;
- generated/effective publication unless a selected Change intentionally includes
  it;
- host projection regeneration unless intentionally scoped;
- PR creation unless the selected route is `branch-pr`;
- destructive cleanup of ambiguous or user-owned work;
- treating `.octon/inputs/**`, proposal-local files, generated outputs, host
  state, GitHub state, chat, model memory, or tool availability as authority.

## Route Relationship

The existing route set remains intact:

- `direct-main`: clean current `main`, low-risk Change, local validation,
  commit, receipt, rollback handle, origin push, fetch/sync, and final main
  alignment.
- `branch-no-pr`: branch-isolated Change without PR-backed review. It may end as
  preserved, branch-local-complete, published-branch, landed, cleaned, blocked,
  escalated, or denied.
- `branch-pr`: PR-backed Change closeout delegated to the PR-backed subflow
  after route selection.
- `stage-only-escalate`: preservation or blocker outcome when authority,
  ownership, validation, rollback, route, or cleanup evidence is missing.

Hosted no-PR landing remains a `branch-no-pr` lifecycle path, not a separate
top-level route. PR-backed closeout remains a subflow, not the default Change
closeout model.

## Stateful Phases

| Phase | Mode | Re-entry and backward transitions | Exit evidence | Stop or escalation conditions |
| --- | --- | --- | --- | --- |
| Read-in and constraints | Single-pass unless scope changes | Return only when new user instructions change route, authority, or forbidden actions. | Ingress, default work-unit policy, git autonomy, receipt, validation, and provider constraints recorded. | Required governing source missing, route conflict, or forbidden action required. |
| Inventory | Loop | Repeat after cleanup, validation repair, fetch/sync, landing, branch deletion, or unexpected dirty state. | Current branch, HEAD, main, origin/main, staged, unstaged, untracked, ignored, branch, remote, and worktree state captured. | Repository state cannot be inspected safely. |
| Residue classification | Loop | Return when new residue appears, a group splits, ownership is unclear, or validation reveals contamination. | Every dirty, untracked, ignored, generated, evidence, host-projection, release, input-surface, and branch item has exactly one disposition. | Ambiguous or user-owned work would need deletion, restoration, or overwrite. |
| Route and target lifecycle resolution | Loop | Repeat when requested route, target outcome, authority, provider rule, or operator intent is ambiguous. | Exactly one route and target outcome recorded, or an honest blocked/escalated outcome recorded. | PR-required predicate conflicts with fixed `branch-no-pr`, or no authority exists to choose route/outcome. |
| Safe cleanup | Loop | Return to inventory and classification after each removal because cleanup can reveal new residue. | Only evidence-backed residue removed; retained or ambiguous items documented. | Removal lacks containment, patch equivalence, tracked replacement, explicit ignored/local-residue status, or validator proof. |
| Change-set preparation | Loop | Return when branch base is stale, staged scope is contaminated, or change-set grouping changes. | Branch or direct-main state contains only the coherent accepted change set. | Coherent scope cannot be isolated without overwriting user-owned work. |
| Validation | Loop | Repair and rerun only for failures inside the accepted change set; otherwise return to classification or escalate. | `git diff --check` and minimum credible validators pass, with command evidence retained. | Required publishers, projection generators, migrations, alignment profiles, or activation changes are outside scope. |
| Hosted no-PR checks and landing | Loop for `branch-no-pr` hosted landing | Poll while checks are pending; return to inventory if `origin/main` moves; revalidate after rebase/recreate. | Pushed source branch, exact source-SHA required checks, provider no-PR permission, fast-forward/update proof, `origin/main == landed_ref`, rollback handle, and final local sync. | Provider requires PR, exact-SHA checks fail out of scope, or fast-forward/update cannot be proven. |
| PR-backed subflow | Loop inside `branch-pr` only | Delegate to PR-backed monitor/remediate loop after route selection. | PR state, checks, review disposition, merge or blocker evidence. | PR mutation would occur without `branch-pr` route. |
| Branch cleanup | Loop | Repeat until containment, no-open-PR status, rollback posture, and local/remote cleanup are proven. | Branch contained in `origin/main`, no open PR, rollback/discard handle retained, local and remote cleanup status recorded. | Containment, no-open-PR status, or rollback posture cannot be proven. |
| Receipt and evidence | Loop | Repeat when receipt overclaims lifecycle state, misses required evidence, or validator fails. | Receipt records route, target outcome, actual outcome, state-machine evidence, validation, integration, cleanup, publication, rollback, and blockers. | Receipt cannot truthfully support requested outcome. |
| Final verification | Loop | Return to inventory when dirty state, remote drift, branch ambiguity, or final equality mismatch appears. | Worktree clean or retained residue documented; local `HEAD`, `main`, and `origin/main` equality proven when claimed. | Final sync cannot be proven or would require unsafe mutation. |
| Final report | Single-pass | Only after all terminal evidence gates pass or an honest blocker is recorded. | Actual lifecycle outcome, landed refs, validation, receipt, cleanup, retained residue, blockers, rollback handle, and final sync stated. | None; report the blocker instead of looping. |

## Evidence Gates

The promoted model must require evidence before claiming:

- `landed`: landed ref, route-compatible integration method, validation evidence,
  rollback handle, hosted or origin evidence, and final main alignment.
- `cleaned`: landed or explicitly non-landing outcome plus branch cleanup and
  worktree cleanup completed or explicitly deferred with evidence.
- `blocked`: preserved state plus exact missing condition.
- `preserved`: recoverable patch, checkpoint, branch, or durable state plus
  rollback or discard plan.
- `escalated`: preserved state plus the specific human, policy, provider, or
  ownership decision required.

Destructive cleanup requires direct evidence such as containment in
`origin/main`, patch equivalence, tracked replacement, explicit ignored/local
residue status, or validator proof. Detection alone is not deletion authority.

## Terminology

- Keep `Closeout Change` as the singular route-neutral executor.
- Reserve `Closeout Worktree` for the optional dirty-worktree wrapper that
  decomposes residue into singular Change closeouts.
- Do not use `Closeout Changes` as a canonical model or default work unit.
- Keep the command id `closeout-pr`, but use the human-facing name
  `Closeout PR-Backed Change`.
- Do not introduce a peer `Publish Changes` workflow. Publication remains a
  route/status operation or generated/effective publication mechanism.
