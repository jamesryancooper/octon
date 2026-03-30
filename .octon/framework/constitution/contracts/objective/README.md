# Constitutional Objective Contracts

`/.octon/framework/constitution/contracts/objective/**` defines the
constitutional objective model for governed execution.

## Status

The objective family is fully active.

- workspace-charter pair remains:
  `/.octon/instance/charter/workspace.md` and
  `/.octon/instance/charter/workspace.yml`
- compatibility shims remain at:
  `/.octon/instance/bootstrap/OBJECTIVE.md` and
  `/.octon/instance/cognition/context/shared/intent.contract.yml`
- mission charter pair remains under:
  `/.octon/instance/orchestration/missions/<mission-id>/{mission.md,mission.yml}`
- per-run objective binding now lands under:
  `/.octon/state/control/execution/runs/<run-id>/run-contract.yml`
- stage attempts now belong under:
  `/.octon/state/control/execution/runs/<run-id>/stage-attempts/**`

## Objective Stack

1. Workspace-charter pair
   - repo-wide narrative and machine objective authority
2. Mission charter pair
   - continuity, ownership, overlap policy, and long-horizon autonomy
3. Run contract
   - atomic execution-time objective binding for one consequential run
4. Stage-attempt contract
   - retry, staged execution, and resumption records under the bound run root

## Final Rules

- Mission remains the continuity container for recurring, overlapping, and
  long-horizon autonomy.
- Run contracts are the atomic execution unit for consequential work.
- Stage attempts, checkpoints, rollback posture, replay pointers, and retained
  evidence stay subordinate to the bound run root.

## Canonical Files

- `family.yml`
- `workspace-charter-pair.yml`
- `run-contract-v1.schema.json`
- `stage-attempt-v1.schema.json`
