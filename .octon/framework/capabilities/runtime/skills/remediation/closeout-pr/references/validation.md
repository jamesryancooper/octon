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
- [ ] No unresolved review conversations remain
- [ ] The PR is moved out of draft only after the ready gate is satisfied
- [ ] The PR is merged, or a precise external blocker is reported

## Verification Checklist

1. Report exists under `.octon/state/evidence/validation/analysis/`
2. Execution log exists under `/.octon/state/evidence/runs/skills/closeout-pr/`
3. The loop outcome is one of:
   - merged
   - blocked with explicit reason
4. No force-push, amend, or rebase occurred during remediation
