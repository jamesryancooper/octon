# Closeout Change Run Log

Run: `main-closeout-ci-repair-cleaned-20260521T200156Z`

Selected route: `branch-no-pr`
Target lifecycle outcome: `cleaned`
Actual lifecycle outcome: `cleaned`

## Summary

The direct push of `e5c0608d2e408b9146dac22c79bab43a6a6ada72` to
`origin/main` was rejected by repository branch rules, so the repair was
published as `chore/main-closeout-ci-repair` and routed through governed
branch-no-PR closeout.

The source branch passed the required exact-SHA hosted checks, received
governed hosted landing authorization, and was fast-forwarded into
`origin/main`. Local `main` was synchronized to `origin/main`, the landed ref
was proven contained in both refs, cleanup authorization was emitted, and the
local and remote repair branch refs were deleted through
`git-branch-cleanup.sh`.

## Evidence

- Landing authorization:
  `.octon/state/evidence/runs/skills/closeout-change/main-closeout-ci-repair-cleaned-20260521T200156Z/branch-landing-authorization.json`
- Cleanup authorization:
  `.octon/state/evidence/runs/skills/closeout-change/main-closeout-ci-repair-cleaned-20260521T200156Z/branch-cleanup-authorization.json`
- Final receipt:
  `.octon/state/evidence/runs/skills/closeout-change/main-closeout-ci-repair-cleaned-20260521T200156Z/change-receipt.json`

## Final Verification

- `origin/main`: `e5c0608d2e408b9146dac22c79bab43a6a6ada72`
- local `main`: `e5c0608d2e408b9146dac22c79bab43a6a6ada72`
- `HEAD`: `e5c0608d2e408b9146dac22c79bab43a6a6ada72`
- local source branch: absent
- remote source branch: absent
- tracked worktree: clean
- retained residue: untracked state/control/evidence residue, stale local-only
  generated run-health copies, and ignored local residue remain outside
  material branch closeout authority.
