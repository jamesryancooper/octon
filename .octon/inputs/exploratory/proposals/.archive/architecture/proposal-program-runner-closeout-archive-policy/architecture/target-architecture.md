# Target Architecture

## Desired State

Enforce active program closeout policy, child terminal outcome requirements,
child archive workflow delegation when required, blocked closeout/archive
receipts, and workflow-owned parent archival.

## Route Ownership Constraints

- Do not hard-code child archival as a universal prerequisite across all policies.
- Do not loosen the current authored closeout policy.
- Do not let closeout-program or closeout-packet own Git cleanup, repo-hygiene deletion, branch cleanup, hosted landing, archive mutation, or generated-state mutation outside their declared route boundary.

Shared constraints for this packet:

- The runner remains an orchestrator and does not duplicate route-owned behavior.
- Existing proposal lifecycle routes, workflow routes, skill bundles, validators,
  repo-hygiene tooling, publication scripts, registry scripts, promotion
  workflows, archive workflows, run lifecycle control, evidence-disclosure-tier
  contracts, and authority/admission contracts retain their ownership.
- Parent program evidence may summarize child outcomes but never satisfies child
  receipts or child authority.

## Evidence Plan

- Child closeout and archive authorization receipts remain child-owned.
- Parent closeout receipts summarize child outcomes without satisfying child receipts.
- Blocked closeout/archive receipts with route guidance and hygiene evidence.

## Rollback Posture

Rollback posture: `git-revert`. Later implementation must include a
revert or regeneration plan for every edited authored source and every generated
artifact refreshed by canonical scripts.
