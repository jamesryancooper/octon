# Target Architecture

## Desired State

Route all parent, child, extension, and workflow dispatch through the shared
lifecycle executor adapter with retained delegation proof, route-declared
gates, invocation authority checks, and human exception handling.

## Route Ownership Constraints

- Do not bypass the shared executor adapter.
- Do not move workflow-owned promotion, archive, closeout, cleanup, publication, registry, or validator ownership into the runner.
- Do not treat invocation authority alone as sufficient proof for durable mutation.

Shared constraints for this packet:

- The runner remains an orchestrator and does not duplicate route-owned behavior.
- Existing proposal lifecycle routes, workflow routes, skill bundles, validators,
  repo-hygiene tooling, publication scripts, registry scripts, promotion
  workflows, archive workflows, run lifecycle control, evidence-disclosure-tier
  contracts, and authority/admission contracts retain their ownership.
- Parent program evidence may summarize child outcomes but never satisfies child
  receipts or child authority.

## Evidence Plan

- Delegation proof receipts under retained run evidence.
- Adapter preflight and dispatch receipts.
- Negative-control test evidence for missing proof and unsupported authority.

## Rollback Posture

Rollback posture: `git-revert`. Later implementation must include a
revert or regeneration plan for every edited authored source and every generated
artifact refreshed by canonical scripts.
