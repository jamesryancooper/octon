# Mission: <mission-id>

## Goal

Define the bounded outcome for this mission.

## Mission Class

- describe the mission class and why its default control posture is correct

## Owner

- identify the accountable `owner_ref` and any additional asset owners

## Scope

- list the repo areas this mission may change
- list the allowed action classes
- list any explicit exclusions

## Risk And Safing

- state the risk ceiling
- state the safe subset the mission may contract down to
- state what must never proceed on silence

## Schedule Intent

- describe whether this mission is one-shot, continuous, or interruptible on a
  schedule
- describe expected preview and digest posture
- note that control truth, route generation, and mission-view creation happen
  through the seed-before-active path rather than inside this authority scaffold

## Objective Binding

- mission is the continuity container, not the atomic execution unit
- consequential work should bind a run contract under
  `/.octon/state/control/execution/runs/<run-id>/run-contract.yml`
- stage attempts belong under
  `/.octon/state/control/execution/runs/<run-id>/stage-attempts/`
- any mission-only execution assumption is transitional and must retain its
  retirement gate

## Notes

Add optional mission-local guidance here.
