# Objective Binding Cutover Evidence (2026-03-26)

## Scope

Wave 1 promotes the constitutional objective family, ratifies the existing
workspace objective pair, aligns mission guidance to the continuity-container
role, and adds canonical run-control roots under
`/.octon/state/control/execution/runs/`.

## Cutover Assertions

- The constitutional kernel now contains an active transitional objective
  family under `framework/constitution/contracts/objective/**`.
- `OBJECTIVE.md` and `intent.contract.yml` are explicitly marked as the
  workspace-charter pair.
- Mission guidance now states that mission remains the continuity container
  while run contracts are the atomic execution unit.
- Run-control roots and stage-attempt placement are defined without breaking
  current mission-backed flows.
- Extension and capability publication state were republished so the effective
  locks agree with the updated root manifest after the new runtime-input paths
  landed.
- Live orchestration run creation now materializes the canonical Wave 1
  `run-contract.yml` root and initial stage-attempt artifact rather than
  relying on the orchestration projection alone.
- Final comprehensive validation across the objective-binding validator,
  orchestration runtime suite, mission-autonomy profile, and harness profile
  passed after aligning the authoritative-doc trigger registry for the new
  Wave 1 authority docs.

## Receipts And Evidence

- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
- ADR:
  `/.octon/instance/cognition/decisions/069-objective-binding-cutover.md`
- Migration plan:
  `/.octon/instance/cognition/context/shared/migrations/2026-03-26-objective-binding-cutover/plan.md`
