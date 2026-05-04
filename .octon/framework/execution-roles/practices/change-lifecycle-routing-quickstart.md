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
   `stage-only-escalate`.
3. Select lifecycle outcome separately from the selected route.
4. Validate route-specific evidence at the selected validation floor.
5. Record or update a Change receipt shaped by
   `.octon/framework/product/contracts/change-receipt-v1.schema.json`.
6. Perform only the mutation authorized by the selected route.
7. Verify every landing, publication, cleanup, and rollback claim.
8. Report closeout status or the exact blocker, evidence gathered, attempted
   remediation, and smallest human decision needed.

## Route Matrix

| route | select when | allowed outcomes | required evidence | forbidden claims | handoff or escalation point |
|---|---|---|---|---|---|
| `direct-main` | Low-risk solo Change on clean, current `main`; local validation and rollback are straightforward; no branch, PR, collaboration, protection, or operator predicate requires another route. | `landed`, `cleaned` | Change receipt, landed commit on `main`, local validation evidence, rollback handle, target branch ref, landed ref, cleanup status. | PR metadata as required evidence; completion from an unstaged patch; protected-main bypass; missing validation or rollback. | Escalate to `stage-only-escalate` when risk, ownership, validation, rollback, or authority is ambiguous; reroute only by explicit authority. |
| `branch-no-pr` | The Change needs branch or worktree isolation, pause/resume, multiple commits, handoff, backup, or hosted no-PR landing, and no PR-required predicate applies. | `preserved`, `branch-local-complete`, `published-branch`, `landed`, `cleaned`, `blocked`, `escalated`, `denied` | Branch/worktree identity, no-PR rationale, local validation or recorded blocker, durable commit/patch/checkpoint, lifecycle outcome, rollback or discard plan. Hosted `landed` additionally requires route-neutral provider ruleset evidence, pushed source branch, exact source SHA check refs, fast-forward integration, target post-ref equals landed ref, proof `origin/main` equals landed ref, rollback handle, and cleanup disposition. | PR URL, PR number, or PR metadata; pushed-only branch claiming `landed`; branch-local commit claiming `landed`; hosted landing while provider ruleset requires PR. | If provider rules require PR for `main`, hosted no-PR landing is blocked. Report the blocker or explicitly reroute to `branch-pr`; do not silently convert routes. |
| `branch-pr` | The Change needs hosted review, external signoff, unresolved review discussion, PR-required provider rules, release automation, collaboration, protected/high-impact governance handling, existing PR context, or explicit operator request. | `preserved`, `published`, `ready`, `landed`, `cleaned`, `blocked`, `escalated`, `denied` | Branch identity, PR URL/number, Change receipt or PR closeout evidence, PR body evidence, hosted checks when required, review or waiver evidence, rollback handle. `ready` requires open draft PR in the autonomous `branch-pr` lane, green required checks, `AI Review Gate / decision` when required, PR quality, branch naming, clean-state, autonomy checks, no unresolved author-action threads, no blocking labels, no requested changes, no merge conflicts, no stale head state, and high-impact self-review when applicable. | Draft/open/ready PR reported as landed or full closeout; bypassing GitHub protections; treating labels, comments, helper output, or PR metadata alone as authority. | Escalate only for concrete blockers: human-only approval, unsafe failing checks, product/security/legal/architecture judgment, unsafe rollback, unprovable mergeability, or ambiguous authority. High-impact alone is not a manual-lane blocker. |
| `stage-only-escalate` | Required decision, validation, rollback, authorization, review, ownership, support posture, or route authority is missing or ambiguous. | `preserved`, `blocked`, `escalated`, `denied` | Preserved patch/checkpoint/branch state, blocker reason, missing item, next route condition, rollback or discard plan. | `landed`, `complete`, `publication_ready`, or cleanup completion without evidence. | Resume only after the missing evidence or authority is supplied and route selection is re-run. |

## Ruleset State

| concern | current live state | repo-local target | operator rule |
|---|---|---|---|
| `main` protection posture | PR-required protected `main`; hosted `branch-no-pr` landing remains blocked. | Route-neutral protected `main`. Universal PR-required merging removed, while required status checks, linear history, non-fast-forward protection, and deletion protection remain. | Do not claim live route-neutral migration from repo-local projection alone. |
| Universal route-neutral checks | Current live required checks are recorded in `current_live_main` and may remain PR-oriented until migration. | `route_neutral_closeout_validation`, `branch_naming_validation`, `route_aware_autonomy_validation`, `exact_source_sha_validation`. | These checks must be runnable against the exact source SHA intended for hosted no-PR landing. |
| PR-only checks | Required in the current PR-backed live lane when configured by live rulesets. | Remain scoped to `branch-pr`: `AI Review Gate / decision`, `PR Quality Standards`, PR auto-merge, clean-state, PR template quality, and PR review projections. | Do not add PR-only checks as universal `main` requirements for `direct-main` or hosted `branch-no-pr`. |
| Live migration evidence | Not proven by repo-local docs, workflow files, fixtures, or validators. | Proven only after accepted live ruleset migration and strict live validation. | Update `current_live_main` only after `.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh --expect target-route-neutral --strict-live` passes and durable evidence is retained. |

## Receipt Examples

Example receipts live in
`.octon/framework/product/contracts/examples/change-receipts/`.

- `valid-branch-pr-ready.json`: valid `branch-pr` ready state. It is not
  landed and uses `closeout_outcome: continued`.
- `valid-hosted-branch-no-pr-landed.json`: valid hosted no-PR landing evidence.
- `invalid-pushed-only-branch-claimed-landed.json`: invalid overclaim; a pushed
  branch alone is not hosted landing.
- `invalid-draft-pr-claimed-full-closeout.json`: invalid overclaim; draft/open
  or ready PR state is not full closeout.

Validate examples with:

```bash
.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/valid-branch-pr-ready.json
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
