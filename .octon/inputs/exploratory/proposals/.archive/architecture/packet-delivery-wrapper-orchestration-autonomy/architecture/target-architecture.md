# Target Architecture

`/proposal-packet-delivery outcome=cleaned route=branch-no-pr` should operate
as the outer route-owned wrapper for accepted proposal packets.

## Desired Wrapper Behavior

- Validate the delivery profile before any delivery claim.
- Require `route=branch-no-pr` for cleaned no-PR delivery and forbid PR
  fallback.
- Recognize pre-archive and already-archived packet states explicitly.
- Route implementation, conformance, drift/churn, promotion, packet closeout,
  terminal closeout, archive handoff, Change closeout, final sync, branch
  cleanup, terminal proof, and hygiene through their owning lifecycles.
- Emit an aggregate delivery receipt that summarizes target-owned receipts
  without replacing them.
- Report `blocked` with the next owning lifecycle when a gate lacks required
  evidence.

## Durable Authorities

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`
  owns workflow stages and outputs.
- `.octon/framework/capabilities/runtime/commands/proposal-packet-delivery.md`
  owns the command contract.
- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-delivery/SKILL.md`
  owns the skill contract.
- `.octon/framework/product/contracts/proposal-packet-delivery-profile-v1.schema.json`
  owns the profile contract.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh`
  owns workflow validation.

## Dependency Boundary

The wrapper depends on the first child for truthful blocked receipt semantics.
Implementation must perform a dependency preflight and must not compensate by
loosening wrapper checks or editing historical receipts.
