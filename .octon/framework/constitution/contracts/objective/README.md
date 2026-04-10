# Constitutional Objective Contracts

`/.octon/framework/constitution/contracts/objective/**` defines the
constitutional objective model for governed execution.

## Status

The objective family is fully active.

- workspace-charter pair remains:
  `/.octon/instance/charter/workspace.md` and
  `/.octon/instance/charter/workspace.yml`
- live workspace machine validation uses:
  `/.octon/framework/constitution/contracts/objective/workspace-charter-v1.schema.json`
- historical compatibility shims remain retained only as archived,
  non-authoritative provenance at:
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
- `mission_mode` must be machine-distinguishable.
- Legal states are:
  - `requires_mission: true` with `mission_id` bound and
    `mission_mode: mission-bound`
  - `requires_mission: false` with `mission_mode: run-only`
- `requires_mission: true` with `mission_id: null` is illegal.
- `mission_mode: none` is retired from the live state model.

## Canonical Files

- `family.yml`
- `workspace-charter-pair.yml`
- `workspace-charter-v1.schema.json`
- `run-contract-v3.schema.json`
- `stage-attempt-v2.schema.json`

## Canonical Roots

- workspace-charter pair: `/.octon/instance/charter/{workspace.md,workspace.yml}`
- mission charter pair: `/.octon/instance/orchestration/missions/<mission-id>/**`
- run contracts: `/.octon/state/control/execution/runs/<run-id>/run-contract.yml`
- stage attempts: `/.octon/state/control/execution/runs/<run-id>/stage-attempts/**`

## Compatibility/Historical Surfaces

- `run-contract-v1.schema.json`
- `stage-attempt-v1.schema.json`
- `/.octon/instance/bootstrap/OBJECTIVE.md`
- `/.octon/instance/cognition/context/shared/intent.contract.yml`

## Non-Authority Note

Compatibility-era objective files remain lineage or compatibility-only
surfaces. They must not be cited as current authority for workspace, mission,
run, or stage bindings.

## Validator Obligations

- `validate-single-canonical-run-contract-family.sh`
- `validate-stage-attempt-family.sh`
- `validate-contract-family-version-coherence.sh`
