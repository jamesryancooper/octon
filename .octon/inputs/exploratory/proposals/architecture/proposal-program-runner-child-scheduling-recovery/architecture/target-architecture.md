# Target Architecture

## Desired State

Implement dependency-aware child batch scheduling, concurrency bounds, blocker
classification, recovery budgets, independent child continuation, and
maintenance-route starvation prevention.

## Route Ownership Constraints

- Do not invent recovery behavior outside the contract-declared recovery policy.
- Do not continue dependent children past unresolved predecessor blockers.
- Do not treat no-op cleanup receipts with `implementation_blocking: false` as child implementation blockers.

Shared constraints for this packet:

- The runner remains an orchestrator and does not duplicate route-owned behavior.
- Existing proposal lifecycle routes, workflow routes, skill bundles, validators,
  repo-hygiene tooling, publication scripts, registry scripts, promotion
  workflows, archive workflows, run lifecycle control, evidence-disclosure-tier
  contracts, and authority/admission contracts retain their ownership.
- Parent program evidence may summarize child outcomes but never satisfies child
  receipts or child authority.

## Evidence Plan

- Scheduler decisions and recovery attempt receipts.
- Blocker classification receipts with dependent handling.
- Concurrency and retry-budget test output.

## Rollback Posture

Rollback posture: `git-revert`. Later implementation must include a
revert or regeneration plan for every edited authored source and every generated
artifact refreshed by canonical scripts.
