# Rollback Posture

## Targets

- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Rollback Strategy

- Revert code/spec/policy/schema changes made for this child.
- Invalidate generated/read-model artifacts produced by the reverted surfaces.
- Preserve retained evidence and receipts as historical proof.
- Regenerate proposal registry or generated projections only through canonical producers if required.
- Do not delete raw evidence as rollback.

## Failure Handling

Fail closed or block closeout when rollback evidence is missing, compact artifact still points to reverted source, generated/read-model freshness cannot be proven, context-pack hash cannot be reconstructed, or child-owned receipts are incomplete.

## Support Proof

Rollback must retain enough evidence to prove what was changed, why it was reverted, and whether downstream generated/read-model surfaces were invalidated or refreshed.
