---
title: Closeout Change I/O Contract
---

# I/O Contract

Inputs:

- Optional `change_id`
- Optional `route`
- Optional `target_lifecycle_outcome`; omitted means `cleaned` for generic
  closeout requests
- Optional `lifecycle_outcome`
- Optional `include_paths`
- Optional `exclude_paths`
- Optional `receipt_ref`
- Optional `lifecycle_interaction_request_ref`; advisory context only

When `include_paths` and `exclude_paths` come from `closeout-worktree`, they
are candidate boundaries, not optional hints. `closeout-change` must stage and
commit only the included boundary paths, preserve excluded paths, and create or
select a task branch for branch-isolated candidates when the selected route
requires branch identity and none exists.

When boundaries come from a `lifecycle-interaction-request-v1`, the request is
handoff context only. `closeout-change` must still inventory, validate route
eligibility, prove landing or cleanup authorization when applicable, and emit
its own Change receipt before any lifecycle outcome is claimed.

Outputs:

- Change closeout report under
  `/.octon/state/evidence/validation/analysis/{{date}}-change-closeout-{{run_id}}.md`
- Skill execution log under
  `/.octon/state/evidence/runs/skills/closeout-change/{{run_id}}.md`
- Change receipt conforming to
  `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- Optional `lifecycle-interaction-return-v1` evidence that cites the
  target-owned Change receipt or blocker evidence without transferring cleanup,
  Git, hosted-provider, promotion, archive, rollback, or scope authority

Receipt outputs must record selected route, target lifecycle outcome, actual
lifecycle outcome, integration status, publication status, cleanup status,
durable history, rollback handle, cleanup evidence when cleanup is claimed, and
structured stop reasons when a target of `landed` or `cleaned` downgrades.

When the input omits `target_lifecycle_outcome` and the operator asked to close
out the Change, the receipt must record `target_lifecycle_outcome: cleaned`.
Explicit `published-branch`, `branch-local-complete`, `landed`, `preserved`,
or `blocked` requests remain narrower lifecycle targets. Explicit
`stage-only-escalate` requests are route requests and must be paired with a
route-compatible target such as `preserved`, `blocked`, or `escalated`.

For branch-based completed closeout, receipt outputs must also record
`source_branch_integration` and `main_alignment` evidence proving the source
branch changes are integrated into `origin/main`, local `main` was synchronized
to the fetched `origin/main`, and both local `main` and `origin/main` contain
the recorded `landed_ref`.

For hosted `branch-no-pr` landing, receipt outputs must include
`landing_authorization_ref` pointing to a retained
`branch-landing-authorization-v1` receipt. The authorization receipt must
validate before `origin/main` mutation and match the source branch, source ref,
target branch, target pre-ref, provider no-PR proof, exact-SHA check evidence
or explicit empty-check policy, and rollback/discard posture.

For branch cleanup that deletes or prunes local or remote source branch refs,
receipt outputs must include `cleanup_authorization_ref` pointing to a retained
`branch-cleanup-authorization-v1` receipt. The authorization receipt must
validate before cleanup mutation and match the source branch, landed ref,
local `main`, `origin/main`, no-open-PR proof, rollback/discard posture, and
cleanup policy proof.

Repo-hygiene cleanup is outside the Change receipt unless it is cited as a
separate delegated hygiene route. Eligible local Octon run/artifact residue
uses `repo-hygiene-cleanup`; generated run-health projections use the
run-health generator; stale detached Git worktrees require explicit Git
worktree cleanup proof.

When target lifecycle outcome is `landed` or `cleaned` but actual outcome is
lower, receipt outputs must also record landing evaluation evidence and
`not_landed_reason` plus `landing_stop_reason`. When target lifecycle outcome
is `cleaned` but cleanup or local-main sync is not proven, receipt outputs must
record `not_cleaned_reason` plus `cleanup_stop_reason`; the actual outcome must
be downgraded instead of claiming `cleaned`.
