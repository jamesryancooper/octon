# Retained Run Evidence Index v1

Retained run evidence indexes are compact retained evidence records for
terminal lifecycle runs. They make terminal evidence, substitute workflow
evidence, rollback evidence, closeout evidence, cleanup evidence, and source
digests discoverable before audits, retries, and postmortems.

The canonical schema is
`/.octon/framework/constitution/contracts/assurance/retained-run-evidence-index-v1.schema.json`.

## Boundary

The index is a discovery and replay aid only. It does not replace source
evidence, authorize execution, satisfy lifecycle transition authority, satisfy
child receipts, grant proposal input authority, or grant generated output
authority.

The evidence-store boundary from `evidence-store-v1.md` remains intact:

- control refs establish live lifecycle state, authority route, journal head,
  rollback posture, and runtime state;
- retained evidence refs establish replay inputs, immutable snapshots,
  disclosure inputs, validation evidence, and closeout completeness; and
- generated/operator refs may summarize evidence but never satisfy control or
  evidence requirements by themselves.

When direct control refs are unavailable, an index may include substitute
retained workflow evidence refs. Those substitute refs only help reconstruct a
terminal lifecycle record. They do not become control truth and must not satisfy
child receipts or lifecycle transition authority.

## Required Shape

Each retained-run evidence index records:

- subject run id, lifecycle kind, and terminal status;
- whether direct control refs are present;
- direct control refs when available;
- substitute retained workflow refs when direct control refs are absent;
- terminal child, parent, validation, rollback, closeout, and cleanup evidence
  refs when applicable;
- digest bindings for every local indexed ref; and
- an explicit authority boundary that keeps generated and proposal-local refs
  non-authoritative.

Every local ref must carry a `sha256:` digest. Missing refs, mismatched digests,
unresolved substitutes, missing required terminal validation evidence, missing
required rollback evidence, or authority-boundary conflicts fail closed.

## Validation

Use
`/.octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh`
with `--index <path>` and optional `--root <repo-root>`.

The validator checks schema posture, terminal evidence completeness, direct or
substitute evidence availability, local ref digests, and non-authority
boundaries. Passing validation proves that the index is internally consistent;
it does not prove lifecycle completion and does not promote or close a run.
