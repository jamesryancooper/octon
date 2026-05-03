---
title: Validation Reference
description: Acceptance criteria and verification for the closeout-pr skill.
---

# Validation Reference

## Acceptance Criteria

- [ ] Intended task-scoped files are reviewed and committed
- [ ] The branch is pushed
- [ ] One draft PR exists for the branch, or the existing PR was reused
- [ ] The PR body satisfies required template sections and checklist items
- [ ] Required checks are green
- [ ] `AI Review Gate / decision` is green when required
- [ ] PR quality, branch naming, clean-state, and autonomy checks are green
- [ ] No unresolved review conversations remain
- [ ] No blocking labels, requested changes, merge conflicts, or stale head
      state remain
- [ ] Change receipt or PR closeout evidence is present
- [ ] The PR is moved out of draft only after the ready gate is satisfied
- [ ] Draft/open PR state is recorded as `published`, not full closeout
- [ ] Ready but unmerged PR state is recorded as `ready`, not landed
- [ ] The PR is merged through the currently valid protected-main route, or a
      precise external blocker is reported
- [ ] Cleanup is recorded as completed or deferred with evidence

## Verification Checklist

1. Report exists under `.octon/state/evidence/validation/analysis/`
2. Execution log exists under `/.octon/state/evidence/runs/skills/closeout-pr/`
3. The loop outcome is one of:
   - published
   - ready
   - landed
   - cleaned
   - blocked with explicit reason
4. No force-push, amend, or rebase occurred during remediation
