---
title: Change Lifecycle Routing Quickstart
description: Operator quickstart for selecting Change routes, recording lifecycle outcomes, and collecting closeout evidence.
status: active
---

# Change Lifecycle Routing Quickstart

Use this as the first maintainer-facing entry point when closing, publishing,
or landing Octon work. The authoritative policy remains
`.octon/framework/product/contracts/default-work-unit.yml`; this document is
the operator path through that policy.

## Mental Model

- Change = durable unit of intent, scope, validation, review, rollback, and
  closeout.
- Route = how the Change proceeds: `direct-main`, `branch-no-pr`, `branch-pr`,
  or `stage-only-escalate`.
- Lifecycle outcome = how far the Change actually got: preserved, branch-local,
  published, ready, landed, cleaned, blocked, escalated, or denied.
- PR = optional publication and review output only after `branch-pr` is
  selected.
- Change receipt = durable evidence record. It may be projected into a PR, but
  the PR is not the authority source.

Route selection and lifecycle outcome are separate decisions. A route never
proves landing, publication, cleanup, or completion by itself.

## Executable Path

1. Resolve Change identity, intent, scope, touched paths, and existing branch or
   PR context.
2. Select exactly one route from `direct-main`, `branch-no-pr`, `branch-pr`, or
   `stage-only-escalate`, using the fastest safe solo route rule below.
3. Select lifecycle outcome separately from the selected route.
4. Validate route-specific evidence at the selected validation floor.
5. Record or update a Change receipt shaped by
   `.octon/framework/product/contracts/change-receipt-v1.schema.json`.
6. Perform only the mutation authorized by the selected route.
7. Verify every landing, publication, cleanup, and rollback claim.
8. Report closeout status or the exact blocker, evidence gathered, attempted
   remediation, and smallest human decision needed.

## Fastest Safe Solo Route

For solo Changes, choose the fastest route that still satisfies evidence,
validation, rollback, cleanup, and protected-main controls.

1. Check hard blockers and PR-required predicates first: hosted review,
   external signoff, unresolved PR review context, PR-required provider rules,
   release automation, collaboration, or explicit operator PR request.
2. If no hard PR or branch predicate applies, select `direct-main` when `main`
   is clean and current, the Change is low-risk and locally understandable,
   local validation is sufficient, rollback is straightforward from the
   resulting commit, and a Change receipt can be recorded.
3. Select `branch-no-pr` when the solo Change needs branch/worktree isolation,
   pause/resume safety, multiple commits, backup, or handoff, but no PR
   predicate applies.
4. Select `branch-pr` only when a PR predicate applies or the operator
   explicitly chooses PR-backed review/publication.
5. Select `stage-only-escalate` only when evidence, authority, rollback,
   validation, or route choice is genuinely blocked or ambiguous.

Provider route-neutral capability is a hosted `branch-no-pr` landing
precondition. It is not a reason to skip an otherwise eligible `direct-main`
route.

## Route Matrix

| route | select when | allowed outcomes | required evidence | forbidden claims | handoff or escalation point |
|---|---|---|---|---|---|
| `direct-main` | Low-risk solo Change on clean, current `main`; local validation and rollback are straightforward; no branch, PR, collaboration, protection, or operator predicate requires another route. | `landed`, `cleaned` | Change receipt, landed commit on `main`, local validation evidence, rollback handle, target branch ref, landed ref, cleanup status. | PR metadata as required evidence; completion from an unstaged patch; protected-main bypass; missing validation or rollback. | Escalate to `stage-only-escalate` when risk, ownership, validation, rollback, or authority is ambiguous; reroute only by explicit authority. |
| `branch-no-pr` | The Change needs branch or worktree isolation, pause/resume, multiple commits, handoff, backup, or hosted no-PR landing, and no PR-required predicate applies. | `preserved`, `branch-local-complete`, `published-branch`, `landed`, `cleaned`, `blocked`, `escalated`, `denied` | Branch/worktree identity, no-PR rationale, local validation or recorded blocker, durable commit/patch/checkpoint, lifecycle outcome, rollback or discard plan. Hosted `landed` additionally requires route-neutral provider ruleset evidence, pushed source branch, exact source SHA check refs, fast-forward integration, target post-ref equals landed ref, proof `origin/main` equals landed ref, rollback handle, and cleanup disposition. | PR URL, PR number, or PR metadata; pushed-only branch claiming `landed`; branch-local commit claiming `landed`; hosted landing while provider ruleset requires PR. | If provider rules require PR for `main`, hosted no-PR landing is blocked. Report the blocker or explicitly reroute to `branch-pr`; do not silently convert routes. |
| `branch-pr` | The Change needs hosted review, external signoff, unresolved review discussion, PR-required provider rules, release automation, collaboration, protected or high-impact work whose governing evidence requires hosted review or remote validation, existing PR context, or explicit operator request. | `preserved`, `published`, `ready`, `landed`, `cleaned`, `blocked`, `escalated`, `denied` | Branch identity, PR URL/number, Change receipt or PR closeout evidence, PR body evidence, hosted checks when required, review or waiver evidence, rollback handle. `ready` requires open draft PR in the autonomous `branch-pr` lane, green required checks, `AI Review Gate / decision` when required, PR quality, branch naming, clean-state, autonomy checks, no unresolved author-action threads, no blocking labels, no requested changes, no merge conflicts, no stale head state, and high-impact self-review when applicable. | Draft/open/ready PR reported as landed or full closeout; bypassing GitHub protections; treating labels, comments, helper output, or PR metadata alone as authority. | Escalate only for concrete blockers: human-only approval, unsafe failing checks, product/security/legal/architecture judgment, unsafe rollback, unprovable mergeability, or ambiguous authority. High-impact alone is not a manual-lane blocker. |
| `stage-only-escalate` | Required decision, validation, rollback, authorization, review, ownership, support posture, or route authority is missing or ambiguous. | `preserved`, `blocked`, `escalated`, `denied` | Preserved patch/checkpoint/branch state, blocker reason, missing item, next route condition, rollback or discard plan. | `landed`, `complete`, `publication_ready`, or cleanup completion without evidence. | Resume only after the missing evidence or authority is supplied and route selection is re-run. |

## Ruleset State

| concern | current live state | repo-local target | operator rule |
|---|---|---|---|
| `main` protection posture | Route-neutral protected `main`; universal PR-required merging has been removed while required status checks, linear history, non-fast-forward protection, and deletion protection remain. | Same as current live state. | Do not claim live route-neutral migration from repo-local projection alone. Require accepted migration evidence and strict-live validation. |
| Universal route-neutral checks | `route_neutral_closeout_validation`, `branch_naming_validation`, `route_aware_autonomy_validation`, `exact_source_sha_validation`. | Same route-neutral check set. | These checks must be runnable against the exact source SHA intended for hosted no-PR landing. |
| PR-only checks | Remain scoped to `branch-pr`: `AI Review Gate / decision`, `PR Quality Standards`, PR auto-merge, clean-state, PR template quality, and PR review projections. | Same PR-specific scope. | Do not add PR-only checks as universal `main` requirements for `direct-main` or hosted `branch-no-pr`. |
| Live migration evidence | Proven by accepted live ruleset migration, durable provider export, and `.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh --expect target-route-neutral --strict-live`. | `current_live_main` must stay aligned with strict-live provider evidence. | Update `current_live_main` only after strict-live target validation passes and durable evidence is retained. |

For hosted `branch-no-pr` pushes, `Main Change Route Guard` classifies the
main update from provider-hosted evidence at the landed SHA: a pushed non-main
source branch, route-neutral live rules, exact-SHA check refs, fast-forward
ancestry from the previous `main`, rollback ref, and cleanup-pending source
branch disposition. Durable closeout evidence still has to be retained after
landing.

## Receipt Examples

Example receipts live in
`.octon/framework/product/contracts/examples/change-receipts/`.

- `valid-direct-main-landed.json`: valid low-risk solo `direct-main` landing.
- `valid-branch-pr-ready.json`: valid `branch-pr` ready state. It is not
  landed and uses `closeout_outcome: continued`.
- `valid-branch-no-pr-branch-local-complete.json`: valid branch-local
  completion without hosted landing or PR metadata.
- `valid-hosted-branch-no-pr-landed.json`: valid hosted no-PR landing evidence.
- `invalid-pushed-only-branch-claimed-landed.json`: invalid overclaim; a pushed
  branch alone is not hosted landing.
- `invalid-draft-pr-claimed-full-closeout.json`: invalid overclaim; draft/open
  or ready PR state is not full closeout.

Validate examples with:

```bash
.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/valid-direct-main-landed.json
.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/valid-branch-pr-ready.json
.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/valid-branch-no-pr-branch-local-complete.json
.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh --receipt .octon/framework/product/contracts/examples/change-receipts/valid-hosted-branch-no-pr-landed.json --skip-live-remote
```

The invalid examples are expected to fail the same validators.

## Closeout Checks

Before reporting completion:

- Verify the selected route is explicit.
- Verify lifecycle outcome is route-compatible.
- Verify validation evidence matches the selected floor.
- Verify rollback handle exists and is usable.
- Verify cleanup status is `completed`, `deferred`, `pending`, or
  `not_applicable` with route-appropriate evidence.
- Verify no branch-local commit, pushed-only branch, draft PR, or ready PR is
  being described as landed.
- Verify current live GitHub rulesets allow the intended hosted mutation.
