# Source of Truth Map

## Proposal Authority

Within this packet, `proposal.yml` is the proposal identity and lifecycle record.

`policy-proposal.yml` is the subtype manifest for policy-proposal validation.

`policy/decision.md` is the proposed product decision.

`policy/routing-model.md` is the proposed route-selection model for automation.

`implementation/implementation-map.md` is the proposed execution-grade alignment inventory.

`policy/policy-delta.md` is the proposed promotion map.

`policy/enforcement-plan.md` is the proposed validation and adoption plan.

## Durable Authority After Promotion

The intended canonical policy authority is `.octon/framework/product/contracts/default-work-unit.md` with a machine-readable companion at `.octon/framework/product/contracts/default-work-unit.yml`.

The intended canonical durable-history contract is `.octon/framework/product/contracts/change-receipt-v1.schema.json`.

The intended canonical internal execution-bundle contract is the promoted Change Package schema family. Legacy Work Package schema names should not remain active after promotion.

Architecture and constitutional registries should make that policy discoverable but should not restate it.

Git worktree, closeout, skills, and GitHub adapter surfaces should reference the canonical policy and keep implementation details local to their domains. The route-neutral skill entry point should be `closeout-change`; PR-specific closeout remains an implementation subflow.

Repo-local `.github/**` workflows are implementation projections. They are required alignment work, but they are not promotion targets in this octon-internal packet because active proposal manifests may not mix `.octon/**` and non-`.octon/**` targets.

## Non-Authority

This proposal packet is not runtime authority.

`resources/source-context.md` records lineage and synthesis context only.

`support/creation-prompt.md` records creation input only.

`support/implementation-grade-completeness-review.md` records proposal lifecycle
readiness evidence only.

`support/executable-implementation-prompt.md` records generated implementation guidance only.

Generated registries and reports remain derived outputs and must not become the canonical source of this policy.
