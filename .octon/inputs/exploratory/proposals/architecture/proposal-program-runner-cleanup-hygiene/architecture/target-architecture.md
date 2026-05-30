# Target Architecture

## Desired State

Keep implementation hygiene, publication hygiene, archive hygiene, cleanup
predicates, residue fingerprints, and blocked hygiene receipts inside existing
repo-hygiene and lifecycle-residue ownership.

## Route Ownership Constraints

- Do not delete foreign, ambiguous, manual-review, or user-authored residue automatically.
- Do not let cleanup routes be status-triggered rather than event/blocker-triggered and phase-scoped.
- Do not block child implementation on no-op or blocked-retained cleanup receipts where `implementation_blocking: false`.

Shared constraints for this packet:

- The runner remains an orchestrator and does not duplicate route-owned behavior.
- Existing proposal lifecycle routes, workflow routes, skill bundles, validators,
  repo-hygiene tooling, publication scripts, registry scripts, promotion
  workflows, archive workflows, run lifecycle control, evidence-disclosure-tier
  contracts, and authority/admission contracts retain their ownership.
- Parent program evidence may summarize child outcomes but never satisfies child
  receipts or child authority.

## Evidence Plan

- Lifecycle residue cleanup receipts with implementation/publication/archive hygiene verdicts.
- Dry-run classifier summaries and residue fingerprints.
- Blocked hygiene receipts for foreign or manual-review residue.

## Rollback Posture

Rollback posture: `git-revert`. Later implementation must include a
revert or regeneration plan for every edited authored source and every generated
artifact refreshed by canonical scripts.
