---
title: Closeout Change Dependencies
---

# Dependencies

- `git` for local status, diff, branch, commit, and rollback handle discovery.
- Branch-only git helpers for branch-local commit, push, landing, and cleanup
  when `branch-no-pr` selects those lifecycle outcomes.
- `gh` only when the selected route is `branch-pr` or the task starts from an
  existing PR.
- Canonical policy:
  `.octon/framework/product/contracts/default-work-unit.yml`.
- Receipt schema:
  `.octon/framework/product/contracts/change-receipt-v1.schema.json`.
