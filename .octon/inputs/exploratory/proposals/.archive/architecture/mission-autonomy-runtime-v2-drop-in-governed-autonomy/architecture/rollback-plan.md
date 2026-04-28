# Rollback Plan

## Objective

Return Octon to v1 state where Engagement / Project Profile / Work Package compiler prepares first governed run-contract candidates, while Mission Autonomy Runtime v2 continuation is disabled.

## Steps

1. Set mission continuation policy to disabled/fail-closed.
2. Disable `octon continue` and `octon mission continue`.
3. Ensure `octon run start --contract` still functions.
4. Mark active v2 Autonomy Windows paused or revoked.
5. Preserve any run-level evidence and journals untouched.
6. Preserve v2 mission evidence as historical evidence if v2 ran.
7. Rebuild generated projections to remove active v2 status.
8. Run v1 validation suite.
9. Record rollback decision/evidence.

## Non-rollback invariants

- Do not delete retained run evidence.
- Do not rewrite run journals.
- Do not promote generated v2 summaries to authority.
- Do not leave a mission lease active while Mission Runner is disabled.
- Do not widen support targets to preserve a failed v2 cutover.
