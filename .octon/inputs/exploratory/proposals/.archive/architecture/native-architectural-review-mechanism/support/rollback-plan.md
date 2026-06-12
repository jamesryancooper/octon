# Rollback Plan

Rollback is child-owned.

## Parent Rollback

Before implementation starts, reject or supersede this parent packet and remove
the unaccepted child packets if the program shape is wrong.

## Child Rollback

After implementation starts, each child must rollback only its own promotion
targets and retain evidence showing:

- implementation targets touched;
- validator outputs before and after rollback;
- conformance and drift/churn impact;
- generated projection refresh status;
- any deferred cleanup or compatibility retirement.

## Prohibited Rollback Shortcuts

- Do not use parent summaries to revert child changes.
- Do not remove generated projections without rerunning publication scripts.
- Do not leave permanent differently named aliases for
  `architecture-readiness-audit`.
- Do not treat extension prompt reversion as native lifecycle gate rollback.
