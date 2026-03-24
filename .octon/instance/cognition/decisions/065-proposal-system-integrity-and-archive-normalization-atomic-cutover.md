# ADR 065: Proposal System Integrity And Archive Normalization Atomic Cutover

- Date: 2026-03-24
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-system-integrity-and-archive-normalization/`
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-24-proposal-system-integrity-and-archive-normalization-cutover/plan.md`
  - `/.octon/state/evidence/migration/2026-03-24-proposal-system-integrity-and-archive-normalization-cutover/`
  - `/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`

## Context

Octon's proposal model was architecturally sound but operationally uneven.
Templates, validators, and live manifests had already converged on one
practical subtype contract, but the JSON schemas still lagged. The committed
proposal registry was meant to be projection-only, but direct mutation logic
still existed in the runner and the archive corpus still contained a few
status, lineage, and inventory gaps that prevented true fail-closed
projection.

## Decision

Promote the proposal-system integrity update as one pre-1.0 atomic cutover.

Rules:

1. `proposal.yml` and the subtype manifest are the only lifecycle authorities
   for manifest-governed proposals.
2. `generate-proposal-registry.sh` is the only canonical writer for
   `generated/proposals/registry.yml`.
3. Proposal create, promote, and archive operations regenerate proposal
   discovery instead of editing the registry directly.
4. `navigation/source-of-truth-map.md` remains the manual proposal-local
   precedence and boundary artifact; `navigation/artifact-catalog.md` becomes
   generated inventory.
5. Archived proposal packets in the main projection must be standard-conformant
   and validator-clean.
6. The implementing proposal package is archived in the same change set as the
   durable promotion surfaces.

## Consequences

### Benefits

- Proposal discovery is now deterministic and reviewable instead of partially
  manual.
- Proposal lifecycle operations are explicit, evidence-backed, and validator
  clean.
- The live archive corpus is coherent enough to support fail-closed registry
  projection.

### Costs

- Proposal validation and workflow coverage gained new scripts, tests, and
  runner logic.
- Archive repair required touching a few already-implemented historical
  packets.

### Follow-on Work

1. Extend proposal-operation command wrappers only if the repo later wants a
   distinct command surface beyond workflow discovery.
2. Tighten archived design-package normalization further only if future audits
   find additional non-conformant packets outside the bounded set repaired in
   this cutover.
