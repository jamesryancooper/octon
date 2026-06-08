# Target Architecture

## Desired State

Close gaps in handoff-first planning, live-state route selection, parent route
versus child batch selection, receipt rereads, and replan behavior while
preserving handoff-only default semantics.

## Route Ownership Constraints

- Do not infer scheduler routes from skill or prompt bundles.
- Do not introduce proposal statuses for runtime states.
- Do not let parent evidence satisfy child receipts or child authority.

Shared constraints for this packet:

- The runner remains an orchestrator and does not duplicate route-owned behavior.
- Existing proposal lifecycle routes, workflow routes, skill bundles, validators,
  repo-hygiene tooling, publication scripts, registry scripts, promotion
  workflows, archive workflows, run lifecycle control, evidence-disclosure-tier
  contracts, and authority/admission contracts retain their ownership.
- Parent program evidence may summarize child outcomes but never satisfies child
  receipts or child authority.

## Evidence Plan

- Controller handoff evidence and checkpoint receipts.
- Test output proving handoff-only default and execute-routes step semantics.
- Source traceability rows for planning and replan requirements.

## Rollback Posture

Rollback posture: `git-revert`. Later implementation must include a
revert or regeneration plan for every edited authored source and every generated
artifact refreshed by canonical scripts.
