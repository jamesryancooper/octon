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

Outputs:

- Change closeout report under
  `/.octon/state/evidence/validation/analysis/{{date}}-change-closeout-{{run_id}}.md`
- Skill execution log under
  `/.octon/state/evidence/runs/skills/closeout-change/{{run_id}}.md`
- Change receipt conforming to
  `.octon/framework/product/contracts/change-receipt-v1.schema.json`

Receipt outputs must record selected route, target lifecycle outcome, actual
lifecycle outcome, integration status, publication status, cleanup status,
durable history, rollback handle, and cleanup evidence or deferred-cleanup
evidence when cleanup is claimed.

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

When target lifecycle outcome is `landed` or `cleaned` but actual outcome is
lower, receipt outputs must also record landing evaluation evidence and
`not_landed_reason`. When target lifecycle outcome is `cleaned` but cleanup or
local-main sync is not proven, receipt outputs must record
`not_cleaned_reason`.
