# Implementation Plan

## Workstream 1: Receipt Schema

- Review the current `proposal-packet-delivery-receipt-v1` outcome conditions.
- Add or refine conditional requirements for `actual_outcome: blocked` so
  explicit blockers are accepted without requiring success-only proof fields.
- Preserve strict requirements for `cleaned`, including target-owned receipts,
  final sync, terminal current-state proof, and worktree hygiene.

## Workstream 2: Receipt Validator

- Update `validate-proposal-packet-delivery-receipt.sh` so blocked receipts
  validate only when blocker evidence is present and outcome-compatible.
- Keep non-blocked outcomes incompatible with open blockers.
- Keep cleaned receipts incompatible with dirty worktree, missing terminal
  proof, missing final sync, missing target-owned receipts, or generated
  authority overclaims.

## Workstream 3: Validation Evidence

- Extend or reuse proposal-packet delivery validator fixtures to cover valid
  blocked receipts.
- Add negative controls for missing blockers, forged pass states, open blockers
  on non-blocked outcomes, and cleaned overclaims.
- Run proposal packet validators before implementation and receipt validators
  after durable changes.

## Rollback

Revert schema and validator changes together if blocked receipt validation
becomes permissive or cleaned requirements weaken. Historical delivery evidence
remains lineage only and must not be edited to simulate success.
