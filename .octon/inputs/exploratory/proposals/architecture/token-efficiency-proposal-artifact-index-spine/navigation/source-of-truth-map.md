# Source Of Truth Map

## Proposal-local lifecycle sources

1. `proposal.yml`
2. `architecture-proposal.yml`

## Durable authority targets

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`
- `.octon/generated/proposals/`

## Derived / non-authoritative artifacts

- `proposal-artifact-index.yml`
- `proposal-program-spine.yml`
- `child-handoff-capsule.yml`

These artifacts are compact evidence, generated/read-model projections, or templates. They do not replace durable authorities or raw evidence.

## Parent Program

Parent proposal: `token-efficient-proposal-program-controller`

The parent may coordinate and summarize. It cannot satisfy this child's receipts.

## Boundary Rules

- This child cannot use parent summaries as child-owned evidence.
- Raw proposal inputs are non-authoritative.
- Generated/read-model outputs are advisory only.
- Material execution requires engine-owned authorization.
