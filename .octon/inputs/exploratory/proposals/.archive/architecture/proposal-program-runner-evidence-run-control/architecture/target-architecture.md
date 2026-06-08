# Target Architecture

## Desired State

Preserve disclosure-tier separation, checkpoint/event convergence,
cancellation, resume, replay verification, and lock release semantics across
all program-controller exits.

## Route Ownership Constraints

- Do not raw-copy local evidence into publishable retained evidence.
- Do not let generated read models satisfy route receipts, closeout evidence, or archive authorization.
- Do not proceed on unsafe resume, checkpoint/event divergence, stale lock ambiguity, or invalid evidence-tier publication.

Shared constraints for this packet:

- The runner remains an orchestrator and does not duplicate route-owned behavior.
- Existing proposal lifecycle routes, workflow routes, skill bundles, validators,
  repo-hygiene tooling, publication scripts, registry scripts, promotion
  workflows, archive workflows, run lifecycle control, evidence-disclosure-tier
  contracts, and authority/admission contracts retain their ownership.
- Parent program evidence may summarize child outcomes but never satisfies child
  receipts or child authority.

## Evidence Plan

- Checkpoint and event receipts under run evidence.
- Evidence classification receipts for local, publishable, disclosure, and generated tiers.
- Lock cleanup receipts or stale-lock blocker receipts.

## Rollback Posture

Rollback posture: `git-revert`. Later implementation must include a
revert or regeneration plan for every edited authored source and every generated
artifact refreshed by canonical scripts.
