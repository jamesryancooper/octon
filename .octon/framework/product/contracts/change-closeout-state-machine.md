---
title: Change Closeout State Machine
description: Durable state-machine contract for route-neutral Octon Change closeout.
status: active
---

# Change Closeout State Machine

The Change Closeout State Machine is the route-neutral closeout contract for
Octon's default work unit, the Change. It operationalizes the existing
`direct-main`, `branch-no-pr`, `branch-pr`, and `stage-only-escalate` routes in
`.octon/framework/product/contracts/default-work-unit.yml`; it does not replace
that policy and does not add a competing route authority.

## Authority Boundary

The state machine owns closeout phases, loop semantics, evidence gates,
cleanup safety, receipt evidence, rollback posture, and final sync checks. The
default work-unit policy still owns route selection. PR-backed mechanics remain
delegated only after selected route `branch-pr`. Hosted no-PR landing remains a
`branch-no-pr` lifecycle path, not a top-level route.

When an operator asks to close out a Change or worktree without explicitly
naming a narrower target or route request, the state machine resolves
`target_lifecycle_outcome` to `cleaned`. Actual `lifecycle_outcome` stays
evidence-based; if `cleaned` cannot be proven, the receipt must downgrade to the
highest supported route-compatible outcome and record the exact missing proof,
structured stop reason, blocker, or next-route condition.

The model forbids `branch-land-no-pr` as a top-level route, `Closeout Changes`
as a default work unit, and a peer `Publish Changes` workflow. Publication is a
route/status operation or generated/effective publication mechanism, not a
second closeout workflow.

`Closeout Worktree` is the optional dirty-worktree wrapper. It may inventory
and partition multiple local candidate Changes, but each coherent unit must be
closed by singular `Closeout Change` execution with its own route, target
outcome, actual outcome, evidence, and receipt or blocker. The wrapper is not a
replacement default work unit and does not authorize direct staging, commits,
pushes, PRs, landing, deletion, reset, restore, or overwrite.

## Phase Loop

| Phase | Mode | Exit Evidence | Stop Or Escalation |
| --- | --- | --- | --- |
| Read-in and constraints | Single pass | Ingress, default work-unit policy, git autonomy, receipt, validation, and provider constraints recorded. | Required governing source missing, route conflict, or forbidden action required. |
| Inventory | Loop | Current branch, HEAD, main, origin/main, staged, unstaged, untracked, ignored, branch, remote, and worktree state captured. | Repository state cannot be inspected safely. |
| Residue classification | Loop | Every dirty, untracked, ignored, generated, evidence, host-projection, release, input-surface, and branch item has exactly one disposition. | Ambiguous or user-owned work would need deletion, restoration, reset, or overwrite. |
| Route and target lifecycle resolution | Loop | Exactly one route and target outcome recorded, with unspecified closeout requests defaulted to `cleaned`, or an honest blocked/escalated outcome recorded. | PR-required predicate conflicts with fixed `branch-no-pr`, or no authority exists to choose route/outcome. |
| Safe cleanup | Loop | Only evidence-backed residue removed; retained or ambiguous items documented. | Removal lacks containment, patch equivalence, tracked replacement, explicit ignored/local-residue status, or validator proof. |
| Change-set preparation | Loop | Branch or direct-main state contains only the coherent accepted change set. | Coherent scope cannot be isolated without overwriting user-owned work. |
| Validation | Loop | `git diff --check` and the selected validators pass, or blocker evidence is recorded. | Required publishers, projection generators, migrations, alignment profiles, or activation changes are outside scope. |
| Hosted no-PR checks and landing | Loop for `branch-no-pr` | Pushed source branch, exact source-SHA checks, provider permission, governed landing authorization receipt, fast-forward/update proof, `origin/main == landed_ref`, rollback handle, and final local sync. | Provider requires PR, governed landing authorization is missing, malformed, stale, denied, or mismatched, runtime platform approval still blocks mutation, exact-SHA checks fail out of scope, or fast-forward/update cannot be proven. |
| PR-backed subflow | Loop for `branch-pr` | PR state, checks, review disposition, merge or blocker evidence. | PR mutation would occur without `branch-pr` route. |
| Branch cleanup | Loop for branch routes | Branch contained in `origin/main`, no open PR, rollback/discard handle retained, governed cleanup authorization when refs are mutated, and local/remote cleanup status recorded. | Containment, no-open-PR status, rollback posture, or cleanup authorization cannot be proven. |
| Receipt and evidence | Loop | Receipt records route, target outcome, actual outcome, state-machine evidence, validation, integration, cleanup, publication, rollback, and blockers. | Receipt cannot truthfully support requested outcome. |
| Final verification | Loop | Worktree clean or retained residue documented; local `HEAD`, `main`, and `origin/main` equality proven when claimed. | Final sync cannot be proven or would require unsafe mutation. |
| Final report | Single pass | Actual lifecycle outcome, landed refs, validation, receipt, cleanup, retained residue, blockers, rollback handle, and final sync stated. | Report the blocker instead of looping. |

## Evidence Gates

`landed` requires a landed ref, route-compatible integration method,
validation evidence, rollback handle, hosted or origin evidence, governed
landing authorization evidence for hosted `branch-no-pr` landing, final main
alignment, and `stateful_closeout` receipt evidence.

`cleaned` requires landed evidence or an explicitly non-landing outcome, branch
cleanup and worktree cleanup completed when claiming cleaned, governed cleanup
authorization when branch refs are mutated, cleanup safety evidence, final main
alignment when landed, and `stateful_closeout` receipt evidence. Deferred
cleanup is valid blocker evidence for a lower actual outcome such as `landed`,
`deferred`, or `blocked`; it is not a truthful `cleaned` outcome.

`deferred` requires preserved state plus the exact pending proof, authority,
hosted check, sync, cleanup, or next-route condition. `blocked` requires
preserved state plus the exact missing condition. `preserved` requires a
recoverable patch, checkpoint, branch, or durable state plus rollback or discard
plan. `escalated` requires preserved state plus the specific human, policy,
provider, or ownership decision required.

## Cleanup Safety

Destructive cleanup is allowed only when backed by direct evidence:

- origin/main containment;
- patch equivalence;
- tracked replacement;
- explicit ignored or local-residue status;
- validator proof.

Detection alone is not deletion authority. Cleanup must fail closed for
ambiguous ownership, user-owned work, protected branches, active work branches,
unmerged branches, open-PR branches, and refs without retained rollback
posture.

## Receipt Evidence

Completed or cleaned closeout claims must include a `stateful_closeout` object
in the Change receipt. The object records the state-machine version, initial
inventory, residue classification, phase exits, cleanup decisions, cleanup
safety class, hosted landing references when applicable, branch cleanup
references when applicable, final verification, and escalation references when
applicable.

Branch-based completed closeout additionally requires retained receipt evidence
that the source branch changes are integrated into `origin/main`, origin was
fetched after landing, local `main` was synchronized to `origin/main`, and the
recorded landed ref is contained in both local `main` and `origin/main`.
Hosted `branch-no-pr` landing additionally requires a retained
`branch-landing-authorization-v1` receipt that validates before the hosted
mutation and matches the source ref and target pre-ref used by the landing
helper.
Branch cleanup that deletes or prunes source branch refs additionally requires
a retained `branch-cleanup-authorization-v1` receipt that validates before the
cleanup mutation and matches the source branch, landed ref, local `main`,
`origin/main`, no-open-PR proof, and rollback/discard posture used by the
cleanup helper.

Receipts must reject `published-branch`, `published`, or `ready` as completed
closeout. They must also reject force-push, ambiguous deletion, reset,
restoration, overwrite, and branch cleanup without containment, no-open-PR
status, rollback/discard posture, governed cleanup authorization, and
local/remote cleanup status.

Downgraded receipts must distinguish the stop class from the prose reason. A
target of `landed` or `cleaned` that stops before landing records
`landing_stop_reason` alongside `not_landed_reason`; a target of `cleaned` that
lands but does not clean records `cleanup_stop_reason` alongside
`not_cleaned_reason`. If Octon governance authorization is present but the
runtime, sandbox, provider, or host refuses the mutation, the receipt cites the
authorization receipt and records `runtime_approval_denied` instead of
collapsing the case into a generic blocker.

## Non-Authority Boundaries

`.octon/inputs/**`, proposal-local files, raw inputs, generated outputs, host
state, GitHub state, chat, model memory, and tool availability are not
runtime, policy, control, retained-evidence, publication, or closeout
authority. They may inform an implementation only when durable contracts and
retained evidence outside `inputs/**` support the claim.
