# Workstream Execution Checklist

Use this checklist at the start and end of every workstream or major sub-cutover.

## Before implementation
- [ ] Restate the finding IDs this change is supposed to close.
- [ ] Identify the exact supported live envelope affected.
- [ ] Identify all repo paths touched.
- [ ] Identify which contracts/artifacts must be emitted or updated.
- [ ] Define the red/green evidence that will prove completion.
- [ ] Define any deletion/retirement candidates created by the change.

## During implementation
- [ ] Keep the new truth path visible in code and artifacts.
- [ ] Do not silently keep the old path as the real runtime while only renaming things.
- [ ] Emit receipts/evidence while implementing, not after the fact.
- [ ] Record any exception or temporary bridge in the retirement registry.

## Before calling the workstream green
- [ ] At least one ordinary supported consequential run used the new path.
- [ ] The associated disclosure artifacts reflect the new path.
- [ ] Validators/workflows that should block now actually block.
- [ ] Every legacy surface touched has been removed or explicitly retained with owner + trigger.
- [ ] Traceability matrix updated.
