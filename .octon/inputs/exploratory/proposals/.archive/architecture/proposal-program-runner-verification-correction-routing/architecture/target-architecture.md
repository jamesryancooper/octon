# Target Architecture

## Desired State

Route final verification and targeted correction through existing contract-
declared verification/correction routes, validators, and prompt bundles
without bespoke runner semantics.

## Route Ownership Constraints

- Do not schedule standalone packet verification, correction, or closeout prompt bundles unless the authored packet lifecycle contract declares them as routes and generated projections are refreshed.
- Do not create bespoke verification semantics inside the runner.
- Do not synthesize unbound correction work without retained finding ids.

Shared constraints for this packet:

- The runner remains an orchestrator and does not duplicate route-owned behavior.
- Existing proposal lifecycle routes, workflow routes, skill bundles, validators,
  repo-hygiene tooling, publication scripts, registry scripts, promotion
  workflows, archive workflows, run lifecycle control, evidence-disclosure-tier
  contracts, and authority/admission contracts retain their ownership.
- Parent program evidence may summarize child outcomes but never satisfies child
  receipts or child authority.

## Evidence Plan

- Verification finding receipts with finding ids.
- Correction prompt receipts bound to specific findings.
- Post-correction validator rerun evidence for affected validators and aggregate parent validators.

## Rollback Posture

Rollback posture: `git-revert`. Later implementation must include a
revert or regeneration plan for every edited authored source and every generated
artifact refreshed by canonical scripts.
