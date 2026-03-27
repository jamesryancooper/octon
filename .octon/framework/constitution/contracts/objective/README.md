# Constitutional Objective Contracts

`/.octon/framework/constitution/contracts/objective/**` defines the
constitutional objective model for governed execution.

## Wave 1 Status

Wave 1 promotes the existing workspace objective pair into the constitutional
kernel and introduces the run-contract control family without breaking the
current mission-backed operating model.

- workspace-charter pair remains:
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

## Transitional Rules

- Mission remains the continuity container during Wave 1.
- Run contracts become the defined atomic execution unit during Wave 1.
- Mission-only execution assumptions are legal only as explicit transitional
  compatibility and must carry retirement metadata.
- Wave 3 removes mission-only execution assumptions once run-root lifecycle
  state becomes the primary execution-time source of truth.

## Canonical Files

- `family.yml`
- `workspace-charter-pair.yml`
- `run-contract-v1.schema.json`
- `stage-attempt-v1.schema.json`
