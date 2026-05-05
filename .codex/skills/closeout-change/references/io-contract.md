---
title: Closeout Change I/O Contract
---

# I/O Contract

Inputs:

- Optional `change_id`
- Optional `route`
- Optional `target_lifecycle_outcome`
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

When target lifecycle outcome is `landed` or `cleaned` but actual outcome is
lower, receipt outputs must also record landing evaluation evidence and
`not_landed_reason`. When target lifecycle outcome is `cleaned` but cleanup or
local-main sync is not proven, receipt outputs must record
`not_cleaned_reason`.
