# Change Closeout State Machine

This is a temporary, implementation-scoped architecture proposal for
`change-closeout-state-machine`. It is a build or decision aid. It is not a
canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: define a first-class state machine for Octon Change closeout

## Why Proposal Packet

This work requires governed proposal lifecycle handling because it changes
cross-surface lifecycle semantics, route evidence, authority boundaries, receipt
schema expectations, workflow and skill behavior, validator coverage, and
generated/effective publication boundaries. A normal direct Change would leave
too much policy and contract design implicit.

## Promotion Targets

- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/default-work-unit.md`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/implementation-plan.md`
6. `architecture/acceptance-criteria.md`
7. `validation-plan.md`
8. `support/implementation-grade-completeness-review.md`
9. `support/revisions/change-closeout-state-machine-pre-review-gap-closure-2026-05-20.md`
10. `support/proposal-review.md`
11. `navigation/artifact-catalog.md`
12. `/.octon/generated/proposals/registry.yml`

## Exit Path

Promote only after review acceptance, implementation authorization, durable
contract and validator edits, receipt-schema evidence, implementation
conformance review, post-implementation drift/churn review, and closeout
evidence exist outside proposal-local inputs. Otherwise revise, reject,
supersede, or archive this packet.

## Registry

Proposal operations regenerate `/.octon/generated/proposals/registry.yml` from
proposal manifests when this proposal is created, promoted, archived, rejected,
or materially reclassified. The registry is a committed discovery projection
only; it does not outrank `proposal.yml` or the subtype manifest.
