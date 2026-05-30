# Target Architecture

## Desired State

Route generated effective lifecycle projection, capability routing, host
projection, and proposal registry refreshes through canonical publication
scripts while keeping generated state non-authoritative.

## Route Ownership Constraints

- Do not hand-edit `.octon/generated/effective/**`.
- Do not make generated registries or projections satisfy route receipts or archive authorization.
- Do not hard-code publication-state validators into generic runner logic outside declared ownership.

Shared constraints for this packet:

- The runner remains an orchestrator and does not duplicate route-owned behavior.
- Existing proposal lifecycle routes, workflow routes, skill bundles, validators,
  repo-hygiene tooling, publication scripts, registry scripts, promotion
  workflows, archive workflows, run lifecycle control, evidence-disclosure-tier
  contracts, and authority/admission contracts retain their ownership.
- Parent program evidence may summarize child outcomes but never satisfies child
  receipts or child authority.

## Evidence Plan

- Publication receipts under retained validation evidence roots.
- Proposal registry generation output and drift checks.
- Source digest links from generated projections to authored inputs.

## Rollback Posture

Rollback posture: `regenerate-or-revert`. Later implementation must include a
revert or regeneration plan for every edited authored source and every generated
artifact refreshed by canonical scripts.
