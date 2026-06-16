---
title: Change-First Default Work Unit
description: Canonical product contract for Octon's default work unit and Git/GitHub route selection.
status: active
---

# Change-First Default Work Unit

## Contract

Octon's default work unit is a Change.

A Change is the durable unit of intent, execution, evidence, validation,
review, rollback, and closeout. The compiled internal runtime bundle for a
Change is a Change Package. A Run Contract remains the authority for a material
run; neither a Change nor a Change Package authorizes material execution by
itself.

Pull Requests are optional publication and review outputs. They are selected
when a Change needs hosted review, external signoff, unresolved review
discussion, PR-required provider rules, preview publication, release automation,
protected or high-impact work whose governing evidence requires hosted review or
remote validation, or when the operator explicitly requests a PR. Branch
isolation, high-impact scope, protected-surface scope, provider caution, blocked
direct-main landing, or blocked hosted no-PR landing is not enough by itself to
select a PR.

Branches are isolation mechanisms. They are selected when a Change needs
isolation from `main`, pause/resume safety, multiple commits, handoff,
elevated-risk validation, protected-surface review, or when repository policy
requires branch-based handling.

When the operator asks for closeout without naming a narrower target outcome or
route request, the default target lifecycle outcome is `cleaned`. Actual
lifecycle outcome remains evidence-based: if `cleaned` cannot be proven, the
receipt must downgrade truthfully to the highest supported route-compatible
outcome and record the exact blocker, missing proof, structured stop reason, or
next-route condition. `direct-main`
and `branch-no-pr` closeout include an origin push by default. For
`direct-main`, push `main` and verify `origin/main` contains the recorded landed
ref, then fetch and sync local `main` to `origin/main` before declaring closeout
complete. For `branch-no-pr`, attempt the full hosted no-PR landing and cleanup
path needed for `cleaned` unless the operator explicitly requested
`published-branch`, `branch-local-complete`, `landed`, `preserved`, or
`blocked`, or explicitly selected the `stage-only-escalate` route, or unless a
concrete blocker prevents the proof. After any `branch-no-pr` or `branch-pr`
work lands in `origin/main`, closeout also includes safe branch cleanup,
followed by a fetch, local `main` sync, and proof that local `main`,
`origin/main`, and the recorded landed ref are aligned. Skipping the push or
cleanup is allowed only for an explicit local-only operator instruction or a
concrete blocker, and the receipt must downgrade the actual outcome instead of
claiming `cleaned`.

For solo work, select the fastest safe route. Consider `direct-main` first
when the Change is low-risk, the operator is on clean current `main`, local
validation is sufficient, rollback is straightforward from the resulting
commit, durable history and Change receipt evidence can be recorded, and no
policy, repository protection, documented review/signoff need, branch-isolation need, or
operator instruction requires a branch or PR.

If `direct-main` is not eligible and the Change needs branch isolation, select
`branch-no-pr` unless a concrete PR predicate is independently proven and
recorded with `branch_pr_predicate_evidence`.

Provider route-neutral capability is not itself a reason to choose
`branch-no-pr`. It is a hosted landing precondition after `branch-no-pr` is
selected for branch isolation and hosted no-PR landing is intended.
Before the hosted `origin/main` mutation, Closeout Change must also emit or
reference a governed `branch-landing-authorization-v1` receipt that binds the
selected `branch-no-pr` route, landing target, pushed source ref, current
`origin/main` pre-ref, provider no-PR proof, exact-SHA check evidence or
explicit empty-check policy plus retained rationale, and rollback/discard handle. The mutating hosted
landing helper must validate that receipt and fail closed if it is missing,
malformed, stale, denied, or mismatched. This authorization is Octon evidence;
it does not bypass platform, sandbox, or host safety controls.

Change Package is the active internal execution-bundle name for pre-1.0 and
later target-state surfaces. No active compatibility alias, shim, parallel
schema, or duplicate compiler path is part of the target state.

## Routes

Maintainer quickstart:
`.octon/framework/execution-roles/practices/change-lifecycle-routing-quickstart.md`
provides the operator route matrix, live-vs-target ruleset table, and receipt
examples that make this contract executable for day-to-day closeout. This file
and `.octon/framework/product/contracts/default-work-unit.yml` remain the
authoritative policy.

Route selection starts from Change identity and chooses the execution or review
channel the Change needs. Target lifecycle outcome records what the operator or
agent is trying to achieve; when the operator only asks to "close out" the
Change or worktree, the default target is `cleaned`. Lifecycle outcome is
recorded separately and answers how far through closeout the Change actually
progressed.

The Change Closeout State Machine at
`.octon/framework/product/contracts/change-closeout-state-machine.yml` binds the
phase loop, residue classification, cleanup safety, stateful receipt evidence,
rollback posture, and final verification required to prove those lifecycle
claims. It operationalizes this policy; it does not replace route selection or
create a competing closeout authority.
Hosted/shared closeout claims, and claims intended to leave the local machine,
also require digest-backed repo-publishable receipt references rather than raw
local evidence or local-only paths.

Final post-mutation terminal proof snapshots may be retained locally under
`.octon/state/evidence/local/terminal-closeout/<change-id>/` when writing them
under `.octon/state/evidence/runs/**` would create recursive closeout residue.
That terminal local evidence sink is ignored by git and is local/operator
evidence only. It is never landing authorization, cleanup authorization,
hosted check evidence, packet evidence, archive evidence, generated publication
freshness evidence, mutation authority, policy authority, or hosted/shared
closeout proof. A Change receipt may cite a sink proof only with
`terminal_current_state_proof_ref` plus a matching
`terminal_current_state_proof_digest`, and live refs must still prove local
`HEAD`, local `main`, `origin/main`, and `landed_ref` alignment.

`Closeout Worktree` is the optional wrapper for dirty worktrees. It decomposes
multiple local residue groups into singular `Closeout Change` executions. It
does not replace the default work unit, mint a `Closeout Changes` model, or
authorize direct staging, commits, pushes, PRs, landing, deletion, reset,
restore, or overwrite.

Routine closeout autonomy is allowed inside those boundaries. A generic
closeout request already means `target_lifecycle_outcome: cleaned`; the agent
does not need to ask whether routine branch landing, cleanup, final sync, or
receipt generation should continue when the selected route, validation,
rollback, and authorization evidence all satisfy policy. A dirty worktree with
unambiguous path groups, branch identities or branch-creation need, receipt
references, validation floors, and rollback posture should be partitioned into
candidate Changes and routed one at a time through `closeout-change` without
requiring the operator to name each partition. The wrapper records boundaries
and delegates; the singular `closeout-change` run owns branch creation,
staging, commit, push, hosted no-PR landing, branch cleanup authorization,
branch cleanup, final `main` sync, and the Change receipt.

Ask the operator only for real ambiguity or unsafe action: overlapping
candidate boundaries, unclear ownership, user-owned paths, protected branches,
unmerged or open-PR branches, missing authority, unresolved validation,
missing rollback posture, policy conflicts, provider PR requirements, host or
sandbox approval denial, or cleanup outside an authorized route.

Residual cleanup is routed by authority path. Branch refs require governed
branch cleanup authorization. Eligible untracked local Octon run/artifact
residue under the helper's scope routes through `repo-hygiene-cleanup` and
`cleanup-local-run-artifacts.sh`; the worktree wrapper may classify and cite
that route but must not delete those paths itself. Generated run-health
projections route through `generate-run-health-read-model.sh --all-runs` and
its pruning evidence, not generic deletion. Stale detached Git worktrees may be
removed only through Git worktree cleanup policy with explicit proof that the
worktree is detached, clean, unreferenced by active branch or PR state, and not
the current worktree. Tracked files, proposal inputs, durable evidence, active
control state, generated authority, ignored or user-owned paths, and ambiguous
residue are retained or blocked with precise evidence unless a singular
authorized route owns the cleanup.
Repo-hygiene cleanup claims that are shared outside the local machine must cite
a `publishable-evidence-receipt-v1` summary receipt; the raw cleanup evidence
remains retained or local-only according to the evidence disclosure tier
contract.
Recursive final terminal proof files are not generic repo-hygiene cleanup
candidates. They should be written through
`write-terminal-closeout-local-evidence.sh` into the ignored terminal local
sink, where `closeout-worktree` treats them as `local_private_retained` only
after exact path, digest, schema, non-authority, and live-ref checks pass.

When the operator asks for `branch-no-pr` closeout and does not name a target
outcome, resolve the target to `cleaned` and attempt the full route lifecycle
needed to prove it. If the operator explicitly requests `published-branch`,
`branch-local-complete`, `landed`, `preserved`, or `blocked`, honor that
narrower target. If the operator explicitly requests the `stage-only-escalate`
route, select that route only when its route preconditions apply and pair it
with a route-compatible target such as `preserved`, `blocked`, or `escalated`.
If the target is `landed` or `cleaned` but the actual result is only
`published-branch`, the receipt must record landing evaluation evidence,
`closeout_outcome: continued`, a precise `not_landed_reason`, and structured
`landing_stop_reason`. If the target is `cleaned` but cleanup cannot be
completed, or if proof is missing for full closeout, the receipt must also
record `not_cleaned_reason` and structured `cleanup_stop_reason`.

- `direct-main`: low-risk solo Change, locally validated, landed directly on
  current clean `main`, pushed to `origin`, with a Change receipt and rollback
  handle. If the push is blocked or the operator explicitly requests local-only
  handling, report closeout as incomplete or local-only; do not present it as
  full closeout.
- `branch-no-pr`: isolated Change that needs a branch or worktree but does not
  need PR-backed review or publication. This route can preserve state, complete
  locally on the branch, push the branch for backup or handoff, fast-forward
  land on hosted `main` without a PR when provider rules allow route-neutral
  updates, and clean up only when the receipt records evidence for that
  lifecycle outcome.
- `branch-pr`: PR-backed Change selected for hosted review, external signoff,
  unresolved review discussion, PR-required provider rules, preview publication,
  release automation, protected or high-impact work whose governing evidence
  requires hosted review or remote validation, existing PR context, or explicit
  operator request. Each selection must record `branch_pr_predicate` and
  `branch_pr_predicate_evidence`.
- `stage-only-escalate`: blocked Change that preserves state and records the
  missing decision, validation, rollback, authorization, review, or ownership
  condition.

When route inputs conflict, the safer or more constrained route wins. Ambiguous
risk, ownership, validation, rollback, freshness, or authority routes fail
closed to `stage-only-escalate` unless a higher authority denies the action.

## Lifecycle Outcomes

Routes do not by themselves prove landing, publication, or cleanup. Every Change
receipt must separately record lifecycle outcome and status fields.

Branch-no-PR outcomes:

- `preserved`: patch, checkpoint, or branch state is recoverable; it is not
  committed, landed, or published unless additional evidence says so.
- `branch-local-complete`: intended scope is committed on the branch; it is not
  landed on `main`.
- `published-branch`: the branch is pushed for backup or handoff; no PR exists.
  This is a continued handoff outcome, not completed closeout. It can satisfy a
  handoff-only target, but it cannot satisfy a target outcome of `landed` or
  `cleaned` without a recorded blocker.
- `landed`: the branch Change is fast-forward integrated into hosted `main`
  without a PR, with provider ruleset evidence, exact source SHA validation,
  source branch push evidence, a governed landing authorization receipt,
  rollback handle, and post-push proof that `origin/main` equals the recorded
  landed ref. Full closeout after landing requires cleanup completion or an
  explicit deferred-cleanup blocker plus local `main` synchronized to
  `origin/main`; cleanup that deletes or prunes branch refs requires a
  governed branch cleanup authorization receipt.
- `cleaned`: local branch, remote branch when present, and worktree cleanup are
  complete with governed cleanup authorization when branch refs are mutated.
  Deferred cleanup downgrades the actual outcome to `landed`, `deferred`, or
  `blocked` with blocker evidence; it is not a truthful `cleaned` outcome.
- `deferred`: the target remains reachable, but the current run stops before the
  target outcome because a specific proof, authority, hosted check, sync, or
  cleanup condition is pending.

PR-backed outcomes:

- `preserved`: branch state is recoverable but no usable PR exists yet.
- `published`: the branch is pushed and a PR exists.
- `ready`: required hosted checks and review gates are satisfied or blocked by
  a precise external condition. Autonomous draft completion may mark an open
  draft PR ready only when it is in the autonomous `branch-pr` lane, all
  required checks are green, `AI Review Gate / decision` is green when
  required, PR quality, branch naming, clean-state, and autonomy checks are
  green, no unresolved author-action review threads, blocking labels,
  requested changes, merge conflicts, or stale head state remain, and required
  Change receipt or PR closeout evidence is present. High-impact PRs also
  require explicit self-review of diff, policy impact, evidence, and rollback
  path, but high-impact classification alone is not a manual-lane outcome.
- `landed`: the PR is merged into `main` and `origin/main` is fetched and
  verified to contain the merged result. Full closeout after landing requires
  cleanup completion or an explicit deferred-cleanup blocker plus local `main`
  synchronized to `origin/main`; cleanup that deletes or prunes branch refs
  requires a governed branch cleanup authorization receipt.
- `cleaned`: local branch, remote branch, and worktree cleanup are complete,
  and source branch ref mutation requires governed cleanup authorization.
  Deferred cleanup downgrades the actual outcome to `landed`, `deferred`, or
  `blocked` with blocker evidence.
- `deferred`: the target remains reachable, but the current run stops before the
  target outcome because a specific proof, authority, hosted check, sync, or
  cleanup condition is pending.

A checkpoint, patch, or branch-local commit must never be reported as landed.
A draft or open PR must never be reported as full closeout. Landing requires a
target branch reference, landed ref, integration method, validation evidence,
rollback handle, and cleanup disposition.

For no-PR closeout, local landing alone is not enough when the operator asks to
close out the Change. `direct-main` closeout must push to `origin/main` and
verify the hosted branch contains the landed ref, then fetch and sync local
`main` to `origin/main`. `branch-no-pr` closeout must push the source branch to
origin or complete hosted no-PR landing; otherwise it is a local checkpoint or
blocker, not full closeout.

## Post-Landing Cleanup And Sync

When `branch-no-pr` or `branch-pr` work has landed in `origin/main`, branch
cleanup is part of Change closeout. After the source branch, PR branch, or
merge ref is verified as contained in `origin/main`:

1. Verify `origin/main` contains the landed commit or merge ref.
2. Verify required post-landing checks and closeout evidence are complete.
3. Emit or reference a `branch-cleanup-authorization-v1` receipt before any
   local or remote source branch deletion or pruning.
4. Delete only obsolete local and remote source branches that are safe to
   delete.
5. Do not delete protected branches, active work branches, unmerged branches,
   open-PR branches, or branches whose evidence and rollback posture are not
   retained.
6. If cleanup cannot be completed safely, record the precise blocker,
   `cleanup_stop_reason`, and downgraded actual lifecycle outcome in the Change
   receipt.
7. After cleanup is complete, fetch from origin and sync local `main` to
   `origin/main`.
8. Verify local `main`, `origin/main`, and the recorded landed ref are aligned
   before declaring closeout complete.

For `direct-main`, there is no source-branch cleanup requirement, but closeout
still performs the post-push fetch and verifies local `main`, `origin/main`,
and the recorded landed ref are aligned after post-push checks complete.

## Durable History

Every completed Change requires durable history:

- Change identity and selected route.
- Target lifecycle outcome and final lifecycle outcome.
- Intent and scope.
- Touched paths or diff reference.
- Validation evidence at the selected floor.
- Review evidence or explicit waiver when required.
- Durable history reference: commit, patch, checkpoint, branch, or PR.
- Lifecycle outcome, integration status, publication status, and cleanup status.
- Stateful closeout evidence for completed or cleaned claims.
- Rollback handle.
- Closeout outcome and remaining blockers.

When a receipt targets `landed` or `cleaned` but records a lower actual
outcome, durable history must include landing evaluation evidence plus
`not_landed_reason` and `landing_stop_reason` as appropriate. When the target
is `cleaned` but actual cleanup is not completed, the receipt must include
`not_cleaned_reason` and `cleanup_stop_reason`. A receipt that only records a
pushed source branch is a handoff receipt and must not be reported as completed
closeout.

PR-backed Changes may project this information into PR bodies and checks, but
the PR is not the authority source. No-PR Changes must retain equivalent local
validation, review or waiver, receipt, and rollback evidence.

## Gate Semantics

Validation and review gates attach to the Change.

GitHub checks, review threads, PR templates, and auto-merge workflows are valid
gate projections for PR-backed Changes. Route-neutral required checks may also
gate hosted no-PR landing, but the check evidence must attach to the exact
source SHA that is fast-forward pushed to `main`.

For `direct-main`, hosted protected-main checks do not convert the Change into
`branch-pr`. The route still starts from clean current `main`, local validation,
Change receipt evidence, and a rollback handle. If the receipt claims
`hosted-main-updated` or hosted protected-main checks were required for the
direct update, route-neutral check evidence must attach to the exact
`landed_ref`; PR metadata and PR-only checks are not required.

Local validation output, local review evidence, AI review evidence, explicit
waiver, and rollback evidence are valid gate projections for no-PR Changes when
the governing validation floor allows local proof. A no-PR branch checkpoint,
branch-local commit, or pushed-only branch is not hosted landing evidence.

If a provider ruleset currently requires a pull request for `main`, hosted
`branch-no-pr` landing is unavailable and the route must fail closed with a
blocker unless the operator explicitly selects a PR-backed route. Do not
silently convert `branch-no-pr` to `branch-pr`.

Route transition is a separate authority-backed event. If the selected route
changes after initial route selection, the Change receipt must record
`initial_route`, `route_transition_reason`, `route_transition_authority`,
`route_transition_authority_ref`, and `route_transition_evidence_refs`.
`route_transition_authority` must be `explicit-operator-reroute` or
`policy-reroute-after-new-evidence`; `none` is valid only when
`initial_route` equals `selected_route`.

A blocked direct-main push or blocked hosted `branch-no-pr` landing is not
itself a `branch-pr` predicate. A PR-backed closeout must either select
`branch-pr` up front from a recorded `branch_pr_predicate`, or record an
authority-backed transition to `branch-pr` plus the resulting
`branch_pr_predicate`. In both cases, the receipt must include
`branch_pr_predicate_evidence` proving the independent PR requirement and
explaining why `branch-no-pr` was not policy-valid.

Branch-PR predicate evidence requirements:

| `branch_pr_predicate` | additional required evidence |
| --- | --- |
| `explicit-operator-pr-request` | `operator_request_ref` |
| `existing-pr-context` | `existing_pr_or_review_ref` |
| `release-automation` | release or automation requirement in `requirement_ref` |
| `preview-publication-required` | preview-publication requirement in `requirement_ref` |
| `hosted-review-required` | hosted-review requirement in `requirement_ref` |
| `external-signoff-required` | external-signoff requirement in `requirement_ref` |
| `protected-or-high-impact-remote-review-required` | `scope_classification_ref` plus `governing_review_requirement_ref`; high-impact or protected scope alone is insufficient |
| `provider-ruleset-requires-pr-for-requested-pr-backed-landing` | `provider_ruleset_ref` proving PR-backed landing is required |

Hosted `branch-no-pr` landing must fail closed unless a current governed
landing authorization receipt validates immediately before mutation. The
authorization must name the same source branch, source ref, target branch,
target pre-ref, provider/ruleset evidence, and rollback posture used by the
landing helper. If the execution environment still requires a late external
approval after the authorization validates, record that runtime approval
boundary as an execution-environment blocker and do not overclaim landing.

Branch cleanup must fail closed unless a current governed
`branch-cleanup-authorization-v1` receipt validates before deleting or pruning
local or remote source branch refs. The authorization must prove source branch
changes are integrated into `origin/main`, local `main` is synchronized to
`origin/main`, the landed ref is contained in both refs, the source branch is
not protected, no open PR exists, rollback/discard posture is retained, cleanup
policy allows the mutation, and platform, sandbox, provider, and host controls
are not bypassed.

The target GitHub ruleset is route-neutral protected `main`: required status
checks, linear history, non-fast-forward protection, and deletion protection
remain universal, while universal PR-required merging is removed. Universal
checks must be runnable against the exact source SHA used for hosted no-PR
landing. PR-specific checks such as PR template quality and AI review gate
decisions remain behind `branch-pr` and must not be required for no-PR hosted
landing.

The route-neutral hosted check set is `route_neutral_closeout_validation`,
`branch_naming_validation`, `route_aware_autonomy_validation`, and
`exact_source_sha_validation`.

## Boundary Rules

- Do not treat a PR, branch, GitHub workflow, or Change Package as the product
  default work unit.
- Do not bypass required validation, evidence, review, approval, or rollback
  obligations by selecting a no-PR route.
- Do not claim a stage-only Change as landed or complete.
- Do not claim `published-branch`, `branch-local-complete`, `published`, or
  `ready` as completed closeout.
- Do not downgrade a target outcome of `landed` or `cleaned` without recording
  landing evaluation evidence and a precise blocker.
- Do not claim `branch-no-pr` as hosted landed unless `origin/main` equals the
  recorded landed ref after the fast-forward push.
- Do not mutate hosted `origin/main` for `branch-no-pr` landing without a valid
  governed landing authorization receipt matching the current source and target
  refs.
- Do not delete or prune local or remote source branch refs without a valid
  governed cleanup authorization receipt matching the current source branch,
  landed ref, local `main`, `origin/main`, no-open-PR proof, and rollback
  posture.
- Do not claim full `branch-no-pr` or `branch-pr` closeout after landing while
  branch cleanup is still pending; cleanup must be completed or explicitly
  deferred with blocker evidence.
- Do not claim full branch-based closeout without receipt evidence that the
  source branch changes are integrated into `origin/main`, origin was fetched
  after landing, local `main` was synchronized to `origin/main`, and the
  recorded landed ref is contained in both local `main` and `origin/main`.
- Do not delete protected branches, active work branches, unmerged branches,
  open-PR branches, or branches whose evidence and rollback posture are not
  retained.
- Do not declare closeout complete until local `main`, `origin/main`, and the
  recorded landed ref are aligned after the final fetch/sync step.
- Do not open a PR unless `branch-pr` is selected.
- Do not select or transition to `branch-pr` without recording the
  `branch_pr_predicate` and `branch_pr_predicate_evidence`.
- Do not treat blocked direct-main pushes, GH013, required checks, or blocked
  hosted no-PR landing as implicit authority to open a PR.
- Do not change routes after initial selection without structured route
  transition authority in the Change receipt.
- Do not choose `branch-no-pr` solely because the provider can support
  route-neutral hosted landing; direct-main remains the faster safe route for
  eligible low-risk solo Changes.
- Do not use proposal-local files as runtime or policy dependencies.
- Keep GitHub and host adapters projection-only. They may mirror status, but
  they do not mint authority.
