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

When target lifecycle outcome is `landed` or `cleaned` but actual outcome is
lower, receipt outputs must also record landing evaluation evidence and
`not_landed_reason`. When target lifecycle outcome is `cleaned` but cleanup or
local-main sync is not proven, receipt outputs must record
`not_cleaned_reason`.
