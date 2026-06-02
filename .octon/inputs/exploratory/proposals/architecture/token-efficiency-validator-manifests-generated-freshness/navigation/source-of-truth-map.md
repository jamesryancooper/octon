# Source Of Truth Map

## Proposal-local lifecycle sources

1. `proposal.yml`
2. `architecture-proposal.yml`

## Durable authority targets

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/engine/runtime/spec/operator-read-models-v1.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

## Derived / non-authoritative artifacts

- `validator-result-manifest.yml`
- `publication-freshness-manifest.yml`
- `run-health-compact-manifest.yml`

These artifacts are compact evidence, generated/read-model projections, or templates. They do not replace durable authorities or raw evidence.

## Parent Program

Parent proposal: `token-efficient-proposal-program-controller`

The parent may coordinate and summarize. It cannot satisfy this child's receipts.

## Boundary Rules

- This child cannot use parent summaries as child-owned evidence.
- Raw proposal inputs are non-authoritative.
- Generated/read-model outputs are advisory only.
- Material execution requires engine-owned authorization.
