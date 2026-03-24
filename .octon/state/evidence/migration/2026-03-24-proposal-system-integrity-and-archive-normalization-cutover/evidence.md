# Proposal System Integrity And Archive Normalization Cutover Evidence (2026-03-24)

## Scope

Single-promotion atomic migration implementing
`proposal-system-integrity-and-archive-normalization`:

- align proposal standards, templates, schemas, and validators
- rebuild the proposal registry deterministically from manifests
- add explicit validate/promote/archive proposal lifecycle operations
- normalize broken archived proposal packets so fail-closed projection passes
- archive the implemented proposal package and refresh proposal discovery

## Cutover Assertions

- `proposal.yml` and the subtype manifest are now the only lifecycle
  authorities for manifest-governed proposals.
- `generate-proposal-registry.sh` is the only canonical path that writes
  `generated/proposals/registry.yml`.
- Create, promote, and archive proposal operations regenerate the committed
  registry instead of editing it directly.
- Proposal navigation inventory is generated from the on-disk package shape,
  while source-of-truth maps remain manual proposal-local precedence guides.
- The live architecture archive no longer contains the previously broken
  lifecycle/status/artifact-catalog cases that blocked fail-closed projection.

## Receipts And Evidence

- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
- ADR:
  `/.octon/instance/cognition/decisions/065-proposal-system-integrity-and-archive-normalization-atomic-cutover.md`
- Migration plan:
  `/.octon/instance/cognition/context/shared/migrations/2026-03-24-proposal-system-integrity-and-archive-normalization-cutover/plan.md`
- Archived proposal package:
  `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-system-integrity-and-archive-normalization/`
