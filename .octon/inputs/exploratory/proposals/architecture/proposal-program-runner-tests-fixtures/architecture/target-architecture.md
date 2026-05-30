# Target Architecture

## Desired State

Add comprehensive tests, fixtures, negative controls, and validation receipts
for every acceptance criterion and edge case in the lifecycle improvement
source text.

## Route Ownership Constraints

- Do not substitute implementation description for behavior tests.
- Do not claim coverage from generated snapshots without canonical source references.
- Do not close the program while required validator, review gate, child-readiness, or source-coverage checks fail.

Shared constraints for this packet:

- The runner remains an orchestrator and does not duplicate route-owned behavior.
- Existing proposal lifecycle routes, workflow routes, skill bundles, validators,
  repo-hygiene tooling, publication scripts, registry scripts, promotion
  workflows, archive workflows, run lifecycle control, evidence-disclosure-tier
  contracts, and authority/admission contracts retain their ownership.
- Parent program evidence may summarize child outcomes but never satisfies child
  receipts or child authority.

## Evidence Plan

- Test run receipts with command, result, and coverage class.
- Fixture matrix mapping acceptance criteria and edge cases to positive and negative tests.
- Final source-coverage check proving no material requirement remains unmapped.

## Rollback Posture

Rollback posture: `git-revert`. Later implementation must include a
revert or regeneration plan for every edited authored source and every generated
artifact refreshed by canonical scripts.
