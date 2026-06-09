# Rollback Posture

proposal_id: delegated-governance-shared-contract-model
recorded_at: 2026-06-09T18:03:14Z

## Rollback Scope

Rollback is file-level revert of:

- `.octon/framework/constitution/contracts/authority/delegated-governance-contract-v1.schema.json`
- `.octon/framework/engine/runtime/spec/delegated-governance-contract-v1.md`
- delegated-governance references added to
  `.octon/framework/constitution/contracts/authority/family.yml`
- delegated-governance references added to
  `.octon/framework/constitution/contracts/runtime/family.yml`
- delegated-governance notes added to
  `.octon/framework/constitution/contracts/authority/README.md`
- delegated-governance notes added to
  `.octon/framework/constitution/contracts/runtime/README.md`
- delegated-governance notes added to
  `.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- proposal-local support receipts for this route
- retained evidence under this timestamped validation root

## Dangling Reference Check

No runtime implementation consumes the new contract by direct path as part of
this route. Removing the schema and the family/spec references restores the
previous durable surface without generated-output or state/control repair.

## Constraints

Do not remove predecessor inventory evidence as part of this rollback; it
belongs to a separate child route.
