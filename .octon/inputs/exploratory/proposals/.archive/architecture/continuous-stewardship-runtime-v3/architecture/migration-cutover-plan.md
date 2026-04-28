# Migration / Cutover Plan

## Cutover Posture

This proposal adds a new v3 stewardship layer. It should be introduced as an
opt-in surface and must not change normal run or mission behavior until a
Stewardship Program is explicitly opened.

## Stages

1. Promote framework contracts and practice guidance.
2. Add instance stewardship scaffold without activating any program.
3. Add state/control, state/evidence, and state/continuity roots.
4. Add runtime/CLI commands in observe-only mode.
5. Enable scheduled-review and human-objective triggers only.
6. Enable admission decisions and Idle Decisions.
7. Enable handoff to v2 Mission Runner for admitted mission candidates.
8. Enable renewal decisions at epoch close.
9. Add generated read models.
10. Run validation and closeout.

## No-Migration Rule for Existing Missions

Existing missions remain valid. They are not automatically moved under
stewardship. A Stewardship Program may link to missions only through explicit
control/evidence records.

## Campaign Cutover

No campaign promotion occurs as part of v3 unless campaign promotion criteria are
separately met and evidenced. This proposal may add hooks for campaign candidate
admission but must preserve campaign deferment by default.
