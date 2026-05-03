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
- Autonomous ready and merge are allowed only for open draft PRs in the
  autonomous `branch-pr` lane after required checks, AI gate when required, PR
  quality, branch naming, clean-state, autonomy policy, review-thread,
  requested-change, conflict, stale-head, Change receipt, and live-ruleset
  criteria are satisfied
- High-impact PRs require elevated caution, explicit self-review, stronger
  evidence discipline, and post-merge verification, but high-impact
  classification alone must not force manual handling
- Do not treat helper output as proof of readiness or mergeability
- Do not report draft/open PR state as full closeout
- Do not report ready PR state as landed
- Do not bypass protected-main controls when requesting or performing the
  merge
- Escalate only for concrete unresolved blockers and report the exact blocker,
  evidence gathered, attempted remediation, and smallest human decision needed

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
- Do not claim cleanup without local branch, remote branch, and worktree cleanup
  evidence or a deferred-cleanup record
