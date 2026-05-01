---
title: Safety Reference
description: Safety policies and constraints for the closeout-pr skill.
---

# Safety Reference

## Git Safety

- Never force-push
- Never amend during ordinary remediation
- Never rebase during ordinary remediation
- Never merge `main` into the branch as a remediation shortcut

## PR Safety

- Reuse the same branch and same PR for the life of the task
- Keep the PR in draft until the ready gate is satisfied
- Do not treat helper output as proof of readiness or mergeability

## Review Safety

- Unresolved conversations block merge
- The author must not resolve reviewer-owned threads programmatically unless
  the documented solo-maintainer exception applies: repository owner or
  maintainer actor, fix committed and pushed, evidence reply posted, required
  checks green, and resolution recorded as conversation cleanup rather than
  approval
- The author path is `fix + commit + push + reply`

## Blocker Handling

- If GitHub transport or policy blocks progress, report the exact blocker
- Do not claim success until merged
