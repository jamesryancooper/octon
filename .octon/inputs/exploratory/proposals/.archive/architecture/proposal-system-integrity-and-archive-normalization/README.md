# Proposal System Integrity and Archive Normalization

This is a temporary, implementation-scoped architecture proposal for `proposal-system-integrity-and-archive-normalization`. It preserves Octon's current proposal model and tightens the parts that are under-specified or operationally weak. It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose
- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Tighten Octon's proposal system without redesigning it: align subtype contracts, make the proposal registry a fail-closed projection, normalize archive integrity, add explicit validate/promote/archive workflows, and shift low-value artifact inventory to generated projection while preserving proposals as temporary non-canonical change packets.

## Promotion Targets
- `.octon/README.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `.octon/framework/cognition/_meta/architecture/generated/proposals/`
- `.octon/framework/scaffolding/governance/patterns/`
- `.octon/framework/scaffolding/runtime/templates/`
- `.octon/framework/assurance/runtime/`
- `.octon/framework/orchestration/runtime/workflows/`

## Reading Order
1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/proposal-system-critique.md`
4. `resources/contract-alignment-matrix.md`
5. `resources/registry-drift-report.md`
6. `resources/archive-normalization-inventory.md`
7. `navigation/source-of-truth-map.md`
8. `architecture/target-architecture.md`
9. `architecture/acceptance-criteria.md`
10. `architecture/implementation-plan.md`
11. `navigation/artifact-catalog.md`

## What This Proposal Preserves
- proposals remain temporary and non-canonical
- the current four proposal kinds remain: `design`, `migration`, `policy`, `architecture`
- the current lifecycle statuses remain: `draft`, `in-review`, `accepted`, `implemented`, `rejected`, `archived`
- `proposal.yml` and the subtype manifest remain the proposal-local authority pair
- `/.octon/generated/proposals/registry.yml` remains a committed discovery projection, not a second source of truth

## Exit Path
Promote one coherent proposal-system contract into durable architecture, standards, templates, validators, and workflows; deterministically rebuild the proposal registry from manifests; repair or exclude broken archive entries from the main projection; then archive this proposal once proposal-system operation no longer depends on proposal-local guidance.

## Notes
- `resources/proposal-system-critique.md` is the baseline current-state critique for this package; the matrix and inventory resources distill its findings into promotable contract and cleanup work.
- This pack keeps `navigation/artifact-catalog.md` because the current v1 standard requires it.
- The promoted design turns that artifact into generated inventory and moves semantic boundary work into `navigation/source-of-truth-map.md`.

## Registry
Add or update the matching entry in `/.octon/generated/proposals/registry.yml` when this proposal is created, archived, rejected, or materially reclassified. Until registry generation is promoted, the registry remains a committed discovery projection that must stay subordinate to `proposal.yml` and `architecture-proposal.yml`.
