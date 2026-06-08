# Target Architecture

## Desired State

Audit the existing proposal-program runner, lifecycle contracts, generated
projections, route prompts, validators, executor adapter, run-control
machinery, and tests before any implementation work is attempted.

## Route Ownership Constraints

- Do not implement runner changes inside this audit packet.
- Do not treat generated projections, proposal packets, or chat history as authority.
- Do not rewrite behavior already owned by lifecycle routes, validators, workflows, publication scripts, registry scripts, or run lifecycle machinery.

Shared constraints for this packet:

- The runner remains an orchestrator and does not duplicate route-owned behavior.
- Existing proposal lifecycle routes, workflow routes, skill bundles, validators,
  repo-hygiene tooling, publication scripts, registry scripts, promotion
  workflows, archive workflows, run lifecycle control, evidence-disclosure-tier
  contracts, and authority/admission contracts retain their ownership.
- Parent program evidence may summarize child outcomes but never satisfies child
  receipts or child authority.

## Evidence Plan

- Audit receipt under child support or retained run evidence when implemented.
- Gap classification table with source requirement ids and owner surfaces.
- Test-selection rationale for preserved existing behavior.

## Rollback Posture

Rollback posture: `manual`. Later implementation must include a
revert or regeneration plan for every edited authored source and every generated
artifact refreshed by canonical scripts.
