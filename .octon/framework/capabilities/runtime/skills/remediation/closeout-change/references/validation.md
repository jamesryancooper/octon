---
title: Closeout Change Validation
---

# Validation

Successful closeout proves one route and one lifecycle outcome:

- `direct-main`: commit on current clean `main`, local validation evidence,
  Change receipt, landed ref, cleanup status, and rollback handle exist without
  PR metadata.
- `branch-no-pr`: branch or worktree state, no-PR rationale, lifecycle outcome,
  validation or blocker, durable history, integration/publication/cleanup
  status, receipt, and rollback or discard plan exist. Hosted `landed` requires
  provider ruleset evidence showing route-neutral fast-forward updates are
  allowed, a pushed source branch, exact source SHA required checks, freshness
  against `origin/main`, a fast-forward-only hosted update, landed ref, rollback
  handle, and post-push proof that `origin/main` equals `landed_ref`.
- `branch-pr`: Change identity, PR metadata, hosted checks when required,
  review evidence, lifecycle outcome, receipt, and rollback handle exist.
  Full closeout requires merge evidence or a precise external blocker.
- `stage-only-escalate`: preserved state and blockers are recorded without
  claiming completion.
